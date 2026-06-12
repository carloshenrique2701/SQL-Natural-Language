package com.sql_engine.v_1_0.services;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.services.exceptions.DatabaseException;

@Service
public class DatabaseDialectService {

	public String getDialect(DatabaseCredentials creds) {

		try (Connection conn = DriverManager.getConnection(creds.url(), creds.username(), creds.password())) {

			DatabaseMetaData meta = conn.getMetaData();
			String dialect = meta.getDatabaseProductName();

			return dialect;

		} catch (SQLException e) {
			throw new DatabaseException("Falha ao conectar o banco de dados para extrair o nome do banco de dados.");
		}

	}

}
