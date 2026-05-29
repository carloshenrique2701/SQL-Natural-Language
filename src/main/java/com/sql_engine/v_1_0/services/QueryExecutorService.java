package com.sql_engine.v_1_0.services;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.services.exceptions.DatabaseException;
import com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException;

import net.sf.jsqlparser.JSQLParserException;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.Statement;
import net.sf.jsqlparser.statement.select.Select;

@Service
public class QueryExecutorService {

	public List<Map<String, Object>> executeSelect(String sql, DatabaseCredentials creds) {
		
		Statement st = null;
		
		try {
			st = CCJSqlParserUtil.parse(sql);			
		} catch (JSQLParserException e) {
			throw new DatabaseSecurityException("Waning operation detected. It's not allowed to execute operations that can alter our database.");
		} 
		
		if (!(st instanceof Select)) {
			throw new DatabaseSecurityException("I'm sorry, but I can only execute consults that retrieve data. Operations that can alter the database are not allowed for security reasons.");
		}
		
		List<Map<String,Object>> rows = new ArrayList<>();
		
		try (Connection conn = DriverManager.getConnection(creds.url(), creds.username(), creds.password())) {
			
			PreparedStatement ps = conn.prepareStatement(sql);
			ResultSet rs = ps.executeQuery();
			
			ResultSetMetaData metaData = rs.getMetaData();
			int columnCount = metaData.getColumnCount();
			
			while(rs.next()) {
				Map<String, Object> row = new LinkedHashMap<>();
				
				for (int i = 1; i <= columnCount; i++) {
					row.put(metaData.getColumnName(i), rs.getObject(i));
				}
				
				rows.add(row);
				
			}
			
		} catch (SQLException e) {
			throw new DatabaseException("Error executing a connection to the database.");
		} catch (NoClassDefFoundError e) {
			throw new DatabaseException("We don't have the necessary driver to connect to this database. I'm sorry for the inconvenience.");
		} 
		
		return rows;
		
	}
	
}
