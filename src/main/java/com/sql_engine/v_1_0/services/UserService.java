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
		return obj.orElseThrow( () -> new ResourceNotFoundException(id) ); 
	}
	
	public void delete(Long id) {
		try {
			
			if (repository.existsById(id)) {
				repository.deleteById(id);
			} else {
				throw new ResourceNotFoundException(id);
			}
			
		} catch (EmptyResultDataAccessException e) {
			throw new ResourceNotFoundException(id);
		} catch (DataIntegrityViolationException e) {
			throw new DatabaseException(e.getMessage());
		}
	}
	
	public User insert(User obj) {
		if (repository.findByEmail(obj.getEmail()).isPresent()) {
			throw new DatabaseException("Email already registered: " + obj.getEmail());
		}
		
		String encodedPassword = encoder.encode(obj.getPassword());
		obj.setPassword(encodedPassword);
		
		if (obj.getDbCredentials() == null) {
			obj.setDbCredentials(new DbCredentials("root", "", "jdbc:mysql://localhost:3306/rede_lojas_roupas"));
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
			throw new ResourceNotFoundException(id);
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
			throw new ResourceNotFoundException(id);
		}
	}

	public User updatePassword(Long id, UserPasswordUpdate passwordRequest) {
		if (passwordRequest.password() == null || passwordRequest.password().isBlank()) {
			throw new InvalidCredentialsException("Password cannot be null or empty.");
		}
		try {
			User entity = repository.getReferenceById(id);
			entity.setPassword(encoder.encode(passwordRequest.password()));
			return repository.save(entity);
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException(id);
		}
	}

	public User updateDbCredentials(Long id, DatabaseCredentials credentialsRequest) {
		try {
			User entity = repository.getReferenceById(id);
			DbCredentials credentials = entity.getDbCredentials();
			if (credentials == null) {
				credentials = new DbCredentials();
			}
			if (credentialsRequest.username() != null) {
				credentials.setUsername(credentialsRequest.username());
			}
			if (credentialsRequest.url() != null) {
				credentials.setUrl(credentialsRequest.url());
			}
			if (credentialsRequest.password() != null) {
				credentials.setPassword(cryptoUtils.encrypt(credentialsRequest.password()));
			}
			entity.setDbCredentials(credentials);
			return repository.save(entity);
		} catch (EntityNotFoundException e) {
			throw new ResourceNotFoundException(id);
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
			throw new ResourceNotFoundException(id);
		}
	}

	public User login(String email, String password) {
		return repository.findByEmail(email)
				.filter(user -> encoder.matches(password, user.getPassword()))
				.orElseThrow( () -> new InvalidCredentialsException(null) );
	}
	
}
