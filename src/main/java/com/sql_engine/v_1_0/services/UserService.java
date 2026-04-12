package com.sql_engine.v_1_0.services; 

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

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
		entity.setPassword(obj.getPassword());
	}
	
	public User login(String email, String password) {
		return repository.findByEmail(email)
				.filter(user -> user.getPassword().equals(password))
				.orElseThrow( () -> new InvalidCredentialsException() );
	}
	
}
