package com.sql_natural_laguage_0.SNAPSHOT.source;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sql_natural_laguage_0.SNAPSHOT.entities.dto.QueryRequest;
import com.sql_natural_laguage_0.SNAPSHOT.services.NaturalLanguageQueryService;

@RestController
@RequestMapping(value="api/genAi")
public class GenAiSource {

	@Autowired
	private NaturalLanguageQueryService service;
	
	@PostMapping
	public ResponseEntity<String> apiReq(@RequestBody QueryRequest request) {

		String res = service.htmlDataApresentation(
				request.userQuery(), 
				request.credentials());
				
		return ResponseEntity.ok().body(res);
	}
	
}
