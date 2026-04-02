package com.sql_natural_laguage_0.SNAPSHOT.services;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.stereotype.Service;

import com.sql_natural_laguage_0.SNAPSHOT.entities.dto.DatabaseCredentials;

@Service
public class SchemaExtractorService {
	
	public String extractSchema(DatabaseCredentials creds) {
		
		StringBuilder schemaInfo = new StringBuilder();
		
		try (Connection conn = DriverManager.getConnection(creds.url(), creds.username(), creds.password())){
			
			String catalog = conn.getCatalog();
			DatabaseMetaData metaData = conn.getMetaData();
			// Obtém as tabelas do banco de dados (% é um caractere generic. ex: "busque tables com qualquer nome")
			try (ResultSet tables = metaData.getTables(catalog, null, "%", new String[] {"TABLE"})) {
				
				while(tables.next()) {
					String tableName = tables.getString("TABLE_NAME");
					schemaInfo.append("Table: ").append(tableName).append("\nColumns: ");
					
					// Obtém as colunas de cada tabela
					//null -> ignorar o esquema
					try (ResultSet columns = metaData.getColumns(catalog, null, tableName, "%")) {
						
						while(columns.next()) {
							schemaInfo.append(columns.getString("COLUMN_NAME"))
								.append(" (")
								.append(columns.getString("TYPE_NAME"))
								.append("),");
						}
					}
					
					//Quebra de linha entre as tabelas
					schemaInfo.append("\n\n");
					
				}
				
			}
			
		} catch (SQLException e) {
			throw new RuntimeException("Erro ao extrair o esquema do banco de dados.");
		}

		return schemaInfo.toString();
		
	}

}
