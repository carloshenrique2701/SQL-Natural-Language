package com.sql_engine.v_1_0.source;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.entities.dto.QueryRequest;
import com.sql_engine.v_1_0.services.NaturalLanguageQueryService;
import com.sql_engine.v_1_0.services.UserService;

@RestController
@RequestMapping(value="api/genai")
@CrossOrigin(origins = "http://127.0.0.1:5500")
public class GenAiSource {

	@Autowired
	private NaturalLanguageQueryService service;

	@Autowired
	private UserService userService;
	
	@PostMapping
	public ResponseEntity<Map<String, String>> apiReq(@RequestBody QueryRequest request) {
		User authenticatedUser = userService.getAuthenticatedUser();

		String res = service.htmlDataApresentation(
				request.userQuery(),
				request.model(),
				authenticatedUser);
				
		return ResponseEntity.ok().body(Map.of("res", res));
	}
	
}
