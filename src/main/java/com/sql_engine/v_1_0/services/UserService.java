package com.sql_engine.v_1_0.services; 

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.config.security.SecurityDataBaseConfig;
import com.sql_engine.v_1_0.entities.User;
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
		
		String criptedUserPassword = encoder.encode(obj.getPassword());
		obj.setPassword(criptedUserPassword);	
		
		String criptedDbPassword = cryptoUtils.encrypt(obj.getDbCredentials().getPassword());
		obj.getDbCredentials().setPassword(criptedDbPassword);
		
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
		entity.setName(obj.getName());
		entity.setEmail(obj.getEmail());
		String criptedPassword = encoder.encode(obj.getPassword());
		entity.setPassword(criptedPassword);	
	}
	
	public User login(String email, String password) {
		return repository.findByEmail(email)
				.filter(user -> encoder.matches(password, user.getPassword()))
				.orElseThrow( () -> new InvalidCredentialsException() );
	}
	
}
