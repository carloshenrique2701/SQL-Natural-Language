package com.sql_engine.v_1_0.source;

import java.net.URI;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.entities.dto.LoginRequest;
import com.sql_engine.v_1_0.entities.dto.LoginResponse;
import com.sql_engine.v_1_0.services.UserService;
import com.sql_engine.v_1_0.config.security.JwtUtils;

@RestController
@RequestMapping(value = "/users")
@CrossOrigin(origins = "http://127.0.0.1:5500")
public class UserSource {

	@Autowired
	private UserService service;

	@Autowired
	private JwtUtils jwtUtils;

	@PostMapping("/login")
	public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
		User obj = service.login(loginRequest.email(), loginRequest.password());
		String token = jwtUtils.generateJwtToken(obj.getEmail());
		LoginResponse response = new LoginResponse(token, obj.getId(), obj.getName(), obj.getEmail());
		return ResponseEntity.ok().body(response);
	}

	@GetMapping
	public ResponseEntity<List<User>> findAll() {
		List<User> obj = service.findAll();
		return ResponseEntity.ok().body(obj);
	}

	@GetMapping(value = "/{id}")
	public ResponseEntity<User> findById(@PathVariable Long id) {
		User obj = service.findById(id);
		return ResponseEntity.ok().body(obj);
	}

	@PostMapping
	public ResponseEntity<LoginResponse> register(@RequestBody User obj) {
		obj = service.insert(obj);
		URI uri = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}").buildAndExpand(obj.getId()).toUri();
		String token = jwtUtils.generateJwtToken(obj.getEmail());
		LoginResponse response = new LoginResponse(token, obj.getId(), obj.getName(), obj.getEmail());
		return ResponseEntity.created(uri).body(response);
	}

	@DeleteMapping(value = "/{id}")
	public ResponseEntity<Void> delete(@PathVariable Long id) {
		service.delete(id);
		return ResponseEntity.noContent().build();
	}

	@PutMapping(value = "/{id}")
	public ResponseEntity<User> update(@PathVariable Long id, @RequestBody User obj) {
		obj = service.update(id, obj);
		return ResponseEntity.ok().body(obj);
	}

}
