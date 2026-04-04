package com.sql_natural_laguage_0.SNAPSHOT.services;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sql_natural_laguage_0.SNAPSHOT.entities.dto.DatabaseCredentials;

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
	
	public List<Map<String, Object>> processQuery(String userReq, DatabaseCredentials creds) {
		
		String schema = extractor.extractSchema(creds);
		
		String dialect = dialectService.getDialect(creds);
		
		String generatedSql = generator.generateSql(userReq, schema, dialect);
		
		return executor.executeSelect(generatedSql, creds);
	}
	
	public String htmlDataApresentation(String userReq, DatabaseCredentials creds) {
		
		List<Map<String, Object>> data = processQuery(userReq, creds);
		System.out.println("\n\n\nData retornada do banco: " + data);
		if (data.isEmpty()) {
			return "<p>No results found.</p>";
		}
		
		return generator.generateHtml(data, userReq);
		
	}
	
}
