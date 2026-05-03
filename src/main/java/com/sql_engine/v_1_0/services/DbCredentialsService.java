package com.sql_engine.v_1_0.services;

import org.springframework.beans.factory.annotation.Autowired;

import com.sql_engine.v_1_0.config.security.SecurityDataBaseConfig;
import com.sql_engine.v_1_0.entities.DbCredentials;
import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.repositories.DbCredentialsRepository;
import com.sql_engine.v_1_0.repositories.UserRepository;
import com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException;
import com.sql_engine.v_1_0.services.exceptions.users.ResourceNotFoundException;

public class DbCredentialsService {

	@Autowired
	private DbCredentialsRepository repository;
	
	@Autowired
	private SecurityDataBaseConfig cryptoUtils;
	
	@Autowired
	private UserRepository userRepository;

	public void delete(Long id) {
		try {
			
			if (repository.existsById(id)) {
				repository.deleteById(id);
			} else {
				throw new ResourceNotFoundException(id);
			}
			
		} catch (ResourceNotFoundException e) {
			throw new ResourceNotFoundException(id);
		}
	}
	
	public void insert(DbCredentials obj) {
		obj.setPassword(cryptoUtils.encrypt(obj.getPassword()));
		repository.save(obj);
	}
	
	public void update(Long id, DbCredentials obj) {
		try {
			DbCredentials entity = repository.getReferenceById(id);
			insertUpdatedValues(entity, obj);
			repository.save(entity);
		} catch (ResourceNotFoundException e) {
			throw new ResourceNotFoundException(id);
		}
	}
	
	private void insertUpdatedValues(DbCredentials entity, DbCredentials obj) {
		entity.setUsername(obj.getUsername());
		entity.setPassword(cryptoUtils.encrypt(obj.getPassword()));
		entity.setUrl(obj.getUrl());
	}
	
	public DbCredentials findById(Long id) {
		return repository.findById(id).orElseThrow( () -> new ResourceNotFoundException(id) );
	}
	

	public DbCredentials findByIdAndUser(Long credentialsId, Long userId) {
		DbCredentials credentials = repository.findById(credentialsId)
			.orElseThrow(() -> new ResourceNotFoundException(credentialsId));
		
		User user = userRepository.findById(userId)
			.orElseThrow(() -> new ResourceNotFoundException(userId));
		
		if (!credentials.getId().equals(user.getDbCredentials().getId())) {
			throw new DatabaseSecurityException(
				"User " + userId + " is not authorized to access credentials " + credentialsId
			);
		}
		
		return credentials;
	}


	public DbCredentials findByAuthenticatedUser(User authenticatedUser) {
		return authenticatedUser.getDbCredentials(); 
	}

}
