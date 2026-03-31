package com.sql_natural_laguage_0.SNAPSHOT.source;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sql_natural_laguage_0.SNAPSHOT.services.GenAiService;

@RestController
@RequestMapping(value="api/genAi")
public class GenAiSource {

	@Autowired
	private GenAiService service;
	
	@GetMapping
	public ResponseEntity<String> apiReq(@RequestBody String userReq) {
		String res = service.apiReq(userReq);
		return ResponseEntity.ok().body(res);
	}
	
}
