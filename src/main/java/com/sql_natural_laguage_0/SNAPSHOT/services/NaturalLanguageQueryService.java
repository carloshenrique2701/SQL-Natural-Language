package com.sql_natural_laguage_0.SNAPSHOT.services;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;
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
		
		try (Connection conn = DriverManager.getConnection(creds.url(), creds.username(), creds.password())) {
			
			String schema = extractor.extractSchema(creds);
			
			String dialect = dialectService.getDialect(creds);
			
			String generatedSql = generator.generateSql(userReq, schema, dialect);
			
			return executor.executeSelect(generatedSql, creds);
			
		} catch (SQLException e) {
			throw new RuntimeException("Erro ao conectar ou consultar o banco de dados: ");
		} 
		
	}
	
	public String htmlDataApresentation(String userReq, DatabaseCredentials creds) {
		
		List<Map<String, Object>> data = processQuery(userReq, creds);
		
		if (data.isEmpty()) {
			return "<p>No results found.</p>";
		}
		
		return generator.generateHtml(data, userReq);
		
	}
	
}
