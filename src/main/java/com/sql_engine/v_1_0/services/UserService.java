package com.sql_engine.v_1_0.services; 

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.config.security.SecurityDataBaseConfig;
import com.sql_engine.v_1_0.entities.DbCredentials;
import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.entities.dto.UserPasswordUpdate;
import com.sql_engine.v_1_0.entities.dto.UserProfileUpdate;
import com.sql_engine.v_1_0.repositories.UserRepository;
import com.sql_engine.v_1_0.services.exceptions.DatabaseException;
import com.sql_engine.v_1_0.services.exceptions.users.InvalidCredentialsException;
import com.sql_engine.v_1_0.services.exceptions.users.ResourceNotFoundException;

import jakarta.persistence.EntityNotFoundException;

@Service
public class UserService {

	@Autowired
	private UserRepository repository;
	
	@Autowired
	private PasswordEncoder encoder;

	@Autowired
	private SecurityDataBaseConfig cryptoUtils;
	
	@Autowired
	private DbConnectionValidator dbConnectionValidator;
	
	public List<User> findAll() {
		return repository.findAll();
	}

	public User getAuthenticatedUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (authentication == null || !authentication.isAuthenticated() || authentication instanceof AnonymousAuthenticationToken) {
			throw new InvalidCredentialsException(null);
		}
		Long userId = Long.valueOf(authentication.getName());
		return repository.findById(userId)
				.orElseThrow(() -> new InvalidCredentialsException(null));
	}
	
	public User findById(Long id) {
		Optional<User> obj = repository.findById(id);
		return obj.orElseThrow( () -> new ResourceNotFoundException() ); 
	}
	
	public void delete(Long id) {
		try {
			
			if (repository.existsById(id)) {
				repository.deleteById(id);
			} else {
				throw new ResourceNotFoundException();
			}
			
		} catch (EmptyResultDataAccessException e) {
			throw new ResourceNotFoundException();
		} catch (DataIntegrityViolationException e) {
			throw new DatabaseException(e.getMessage());
		}
	}
	
	public User insert(User obj) {
		if (repository.findByEmail(obj.getEmail()).isPresent()) {
			throw new DatabaseException("Esse email já há um usuário vindulado.");
		}
		
		String encodedPassword = encoder.encode(obj.getPassword());
		obj.setPassword(encodedPassword);
		
		if (obj.getDbCredentials() == null) {
			obj.setDbCredentials(new DbCredentials("root", "root123", "jdbc:mysql://db_analise:3306/rede_lojas_roupas", "rede_lojas_roupas"));
		}
		
		if (obj.getDbCredentials() != null && obj.getDbCredentials().getPassword() != null) {
			String encryptedDbPassword = cryptoUtils.encrypt(obj.getDbCredentials().getPassword());
			obj.getDbCredentials().setPassword(encryptedDbPassword);
		}
		
		return repository.save(obj);
	}
	
	public User update(Long id, User obj) {
		try {
			User entity = repository.getReferenceById(id);
			insertUpdatedValues(entity, obj);
			return repository.save(entity);
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException();
		}
	}
	
	private void insertUpdatedValues(User entity, User obj) {
		if (obj.getName() != null) {
			entity.setName(obj.getName());
		}
		if (obj.getEmail() != null) {
			entity.setEmail(obj.getEmail());
		}
		if (obj.getPassword() != null) {
			entity.setPassword(encoder.encode(obj.getPassword()));
		}
		if (obj.getDbCredentials() != null) {
			DbCredentials credentials = obj.getDbCredentials();
			if (credentials.getPassword() != null) {
				credentials.setPassword(cryptoUtils.encrypt(credentials.getPassword()));
			}
			entity.setDbCredentials(credentials);
		}
	}

	public User updateProfile(Long id, UserProfileUpdate updateRequest) {
		try {
			User entity = repository.getReferenceById(id);
			if (updateRequest.name() != null) {
				entity.setName(updateRequest.name());
			}
			if (updateRequest.email() != null) {
				entity.setEmail(updateRequest.email());
			}
			return repository.save(entity);
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException();
		}
	}

	public User updatePassword(Long id, UserPasswordUpdate passwordRequest) {
		if (passwordRequest.password() == null || passwordRequest.password().isBlank()) {
			throw new InvalidCredentialsException("A senha não pode estar vazia.");
		}
		try {
			User entity = repository.getReferenceById(id);
			entity.setPassword(encoder.encode(passwordRequest.password()));
			return repository.save(entity);
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException();
		}
	}

	public String updateDbCredentials(Long id, DatabaseCredentials credentialsRequest) {
		try {
			// Normaliza a URL e extrai credenciais embutidas, se houver
			DbConnectionValidator.NormalizedConnectionInfo normalized = dbConnectionValidator.normalizeJdbcConnectionInfo(credentialsRequest);

			// Monta um DatabaseCredentials temporário com os valores normalizados para testar a conexão
			DatabaseCredentials normalizedRequest = new DatabaseCredentials(
					normalized.url(),
					normalized.username(),
					normalized.password(),
					credentialsRequest.driver()
			);

			// Testa a conexão usando a URL/credenciais normalizadas
			String dbName = dbConnectionValidator.testConnection(normalizedRequest);

			User entity = repository.getReferenceById(id);
			DbCredentials credentials = entity.getDbCredentials();
			if (credentials == null) {
				credentials = new DbCredentials();
			}

			// Salva a URL normalizada (sem userinfo)
			if (normalized.url() != null && !normalized.url().isBlank()) {
				credentials.setUrl(normalized.url());
			}

			// Se o cliente não enviou username, usa o extraído da URL; caso contrário, usa o enviado
			String finalUsername = (credentialsRequest.username() == null || credentialsRequest.username().isBlank())
					? normalized.username() : credentialsRequest.username();
			if (finalUsername != null && !finalUsername.isBlank()) {
				credentials.setUsername(finalUsername);
			}

			// Semelhante para senha: prioriza a senha enviada; se não houver, usa a extraída da URL
			String rawPassword = (credentialsRequest.password() == null || credentialsRequest.password().isBlank())
					? normalized.password() : credentialsRequest.password();
			if (rawPassword != null && !rawPassword.isBlank()) {
				credentials.setPassword(cryptoUtils.encrypt(rawPassword));
			}

			credentials.setDbName(dbName);

			entity.setDbCredentials(credentials);
			repository.save(entity);
			
			return dbName;
			
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException();
		} catch (com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException e) {
			// Propaga para o handler específico manter a mensagem de validação
			throw e;
		} catch (Exception e) {
			throw new DatabaseException("Erro ao atualizar credenciais do DB.");
		}
	}

	

	public boolean verifyPassword(Long id, String password) {
		if (password == null || password.isBlank()) {
			return false;
		}
		try {
			User user = repository.getReferenceById(id);
			return encoder.matches(password, user.getPassword());
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException();
		}
	}

	public User login(String email, String password) {
		return repository.findByEmail(email)
				.filter(user -> encoder.matches(password, user.getPassword()))
				.orElseThrow( () -> new InvalidCredentialsException(null) );
	}
	
}
