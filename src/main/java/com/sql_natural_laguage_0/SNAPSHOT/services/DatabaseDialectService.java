package com.sql_natural_laguage_0.SNAPSHOT.services;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.springframework.stereotype.Service;

import com.sql_natural_laguage_0.SNAPSHOT.entities.dto.DatabaseCredentials;

@Service
public class DatabaseDialectService {

	public String getDialect(DatabaseCredentials creds) {

		try (Connection conn = DriverManager.getConnection(creds.url(), creds.username(), creds.password())) {

			DatabaseMetaData meta = conn.getMetaData();
			String dialect = meta.getDatabaseProductName();

			return dialect;

		} catch (SQLException e) {
			throw new RuntimeException("Erro ao conectar ou consultar o banco de dados: ");
		}

	}

}
