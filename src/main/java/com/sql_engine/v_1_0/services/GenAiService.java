package com.sql_engine.v_1_0.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.genai.Client;
import com.google.genai.errors.ClientException;
import com.google.genai.types.GenerateContentResponse;
import com.sql_engine.v_1_0.services.exceptions.ai.AiConsultationException;

@Service
public class GenAiService {
	
	@Autowired
	private Client client;
	
	public String apiReq(String prompt, String model) {
		
		try {
			
			GenerateContentResponse res = 
					client.models.generateContent(
							model, 
							prompt, 
							null);
			return res.text();
			
		} catch (IllegalArgumentException e) {
			throw new AiConsultationException("Invalid AI credentials, please check your configuration.");
		} catch (ClientException e) {
			throw new AiConsultationException("An error occurred while consulting the AI: " + e.getMessage());
		}
		
	}

}