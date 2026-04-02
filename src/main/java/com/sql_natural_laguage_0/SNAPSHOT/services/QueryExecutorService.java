package com.sql_natural_laguage_0.SNAPSHOT.services;


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

import com.sql_natural_laguage_0.SNAPSHOT.entities.dto.DatabaseCredentials;

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
			throw new SecurityException("A query fornecida é inválida ou potencialmente perigosa.");
		} 
		
		if (!(st instanceof Select)) {
			throw new SecurityException("Não estou autorizado a realizar operações que alterem nossa base de dados.");
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
			e.printStackTrace();
			throw new RuntimeException("Erro ao executar a query.");
		}
		System.out.println("\n\n\nResultados da query:\n" + rows.toString());
		return rows;
		
	}
	
}
