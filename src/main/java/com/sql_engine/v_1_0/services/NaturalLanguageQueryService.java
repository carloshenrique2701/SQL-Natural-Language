package com.sql_engine.v_1_0.services;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;

@Service
public class NaturalLanguageQueryService {
	
	@Autowired
	private SchemaExtractorService extractor;
	
	@Autowired
	private AiSqlGeneratorService generator;
	
	@Autowired
	private QueryExecutorService executor;

	@Autowired
	private DatabaseDialectService dialectService;
	
	public List<Map<String, Object>> processQuery(String userReq, DatabaseCredentials creds, String model) {
		
		String schema = extractor.extractSchema(creds);
		
		String dialect = dialectService.getDialect(creds);
		
		String generatedSql = generator.generateSql(userReq, schema, dialect, model);
		
		return executor.executeSelect(generatedSql, creds);
	}
	
	public String htmlDataApresentation(String userReq, DatabaseCredentials creds, String model) {
		
		List<Map<String, Object>> data = processQuery(userReq, creds, model);
		System.out.println("\n\n\nData retornada do banco: " + data);
		if (data.isEmpty()) {
			return "<p>No results found.</p>";
		}
		
		return generator.generateHtml(data, userReq, model);
		
	}
	
}
