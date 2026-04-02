package com.sql_natural_laguage_0.SNAPSHOT.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

@Service
public class GenAiService {
	
	@Autowired
	private Client client;
	
	public String apiReq(String prompt) {
		System.out.println("\n\n\nPrompt recebido: " + prompt);
		GenerateContentResponse res = 
				client.models.generateContent(
						"gemini-3-flash-preview", 
						prompt, 
						null);
		System.out.println("\n\n\n\nResposta da API: " + res.text());
		return res.text();
	}

}