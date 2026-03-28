package com.sql_natural_laguage_0.SNAPSHOT.services; 

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sql_natural_laguage_0.SNAPSHOT.entities.User;
import com.sql_natural_laguage_0.SNAPSHOT.repositories.UserRepository;

@Service
public class UserService {

	@Autowired
	private UserRepository repository;
	
	public List<User> findAll() {
		return repository.findAll();
	}
	
	public User findById(Long id) {
		Optional<User> obj = repository.findById(id);
		return obj.get();
	}
	
	public void delete(Long id) {
		repository.deleteById(id);
	}
	
	public User insert(User obj) {
		return repository.save(obj);
	}
	
	public User update(Long id, User obj) {
		User entity = findById(id);
		insertUpdatedValues(entity, obj);
		return entity;
	}

	private void insertUpdatedValues(User entity, User obj) {
		entity.setName(obj.getName());
		entity.setEmail(obj.getEmail());
		entity.setPassword(obj.getPassword());
	}
	
}
