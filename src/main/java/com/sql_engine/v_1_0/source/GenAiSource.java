package com.sql_engine.v_1_0.source;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sql_engine.v_1_0.entities.dto.QueryRequest;
import com.sql_engine.v_1_0.services.NaturalLanguageQueryService;

@RestController
@RequestMapping(value="api/genAi")
@CrossOrigin(origins = "http://127.0.0.1:5500")
public class GenAiSource {

	@Autowired
	private NaturalLanguageQueryService service;
	
	@PostMapping
	public ResponseEntity<String> apiReq(@RequestBody QueryRequest request) {

		String res = service.htmlDataApresentation(
				request.userQuery(), 
				request.credentials(),
				request.model());
				
		return ResponseEntity.ok().body(res);
	}
	
}
