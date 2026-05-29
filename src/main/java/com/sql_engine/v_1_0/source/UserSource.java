package com.sql_engine.v_1_0.source;

import java.net.URI;
import java.util.List;
import java.util.Map;

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

import com.sql_engine.v_1_0.config.security.JwtUtils;
import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.entities.dto.LoginRequest;
import com.sql_engine.v_1_0.entities.dto.LoginResponse;
import com.sql_engine.v_1_0.entities.dto.UserPasswordUpdate;
import com.sql_engine.v_1_0.entities.dto.UserProfileUpdate;
import com.sql_engine.v_1_0.services.UserService;

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
		String token = jwtUtils.generateJwtToken(obj.getId());
		LoginResponse response = new LoginResponse(token, obj.getId(), obj.getName(), obj.getEmail(), obj.getDbCredentials().getDbName());
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

	@PostMapping("/sigin")
	public ResponseEntity<LoginResponse> register(@RequestBody User obj) {
		obj = service.insert(obj);
		URI uri = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}").buildAndExpand(obj.getId()).toUri();
		String token = jwtUtils.generateJwtToken(obj.getId());
		LoginResponse response = new LoginResponse(token, obj.getId(), obj.getName(), obj.getEmail(), obj.getDbCredentials().getDbName());
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

	@PutMapping(value = "/{id}/profile")
	public ResponseEntity<User> updateProfile(@PathVariable Long id, @RequestBody UserProfileUpdate request) {
		User obj = service.updateProfile(id, request);
		return ResponseEntity.ok().body(obj);
	}

	@PutMapping(value = "/{id}/password")
	public ResponseEntity<Void> updatePassword(@PathVariable Long id, @RequestBody UserPasswordUpdate request) {
		service.updatePassword(id, request);
		return ResponseEntity.ok().build();
	}

	@PutMapping(value = "/{id}/db-credentials")
	public ResponseEntity<User> updateDbCredentials(@PathVariable Long id,
			@RequestBody DatabaseCredentials request) {
		User obj = service.updateDbCredentials(id, request);
		return ResponseEntity.ok().body(obj);
	}

	@PostMapping(value = "/{id}/verify-password")
	public ResponseEntity<Map<String, Boolean>> verifyPassword(@PathVariable Long id, @RequestBody Map<String, String> request) {
		String password = request.get("password");
		boolean isValid = service.verifyPassword(id, password);
		return ResponseEntity.ok().body(Map.of("valid", isValid));
	}

}
