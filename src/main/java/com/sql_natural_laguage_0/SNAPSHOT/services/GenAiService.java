package com.sql_natural_laguage_0.SNAPSHOT.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

@Service
public class GenAiService {
	
	@Autowired
	private Client client;
	
	public String apiReq(String userReq) {
		
		StringBuilder prompt = new StringBuilder();
		
		prompt.append("Torne essa pergunta em uma consulta SQL");
		
		GenerateContentResponse res = 
				client.models.generateContent(
						"gemini-3-flash-preview", 
						userReq, 
						null);
		
		return res.text();
	}

}
