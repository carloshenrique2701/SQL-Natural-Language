package com.sql_engine.v_1_0.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.services.UserService;

@Configuration
@Profile("test")
public class TestConfig implements CommandLineRunner {
	
	@Autowired
	private UserService userService;
	
	@Override
	public void run(String... args) throws Exception {

		User u1 = new User(null, "Maria Brown", "maria@gmail.com", "12345678", null);
		User u2 = new User(null, "Alex Green", "alex@gmail.com", "76574456", null);
		
		userService.insert(u1);
		userService.insert(u2);
		
	}

	
	
}
