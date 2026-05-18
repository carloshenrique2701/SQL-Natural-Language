package com.sql_engine.v_1_0.services;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.config.security.SecurityDataBaseConfig;
import com.sql_engine.v_1_0.entities.DbCredentials;
import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.services.exceptions.DatabaseException;

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

	@Autowired
	private SecurityDataBaseConfig cryptoUtils;
	
	public List<Map<String, Object>> processQuery(String userReq, String model, User user) {
		DatabaseCredentials creds = buildDatabaseCredentials(user);
		
		String schema = extractor.extractSchema(creds);
		
		String dialect = dialectService.getDialect(creds);
		
		String generatedSql = generator.generateSql(userReq, schema, dialect, model);
		
		return executor.executeSelect(generatedSql, creds);
	}
	
	public String htmlDataApresentation(String userReq, String model, User user) {
		
		List<Map<String, Object>> data = processQuery(userReq, model, user);
		System.out.println("\n\n\nData retornada do banco: " + data);
		if (data.isEmpty()) {
			return "<p>No results found.</p>";
		}
		
		return generator.generateHtml(data, userReq, model);
	}
	
	private DatabaseCredentials buildDatabaseCredentials(User user) {
		if (user == null || user.getDbCredentials() == null) {
			throw new DatabaseException("Authenticated user has no database credentials.");
		}
	
		DbCredentials dbCredentials = user.getDbCredentials();
		String password = cryptoUtils.decrypt(dbCredentials.getPassword());
		return new DatabaseCredentials(dbCredentials.getUrl(), dbCredentials.getUsername(), password, "");
	}
}
