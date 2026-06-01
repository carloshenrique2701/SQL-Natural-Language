package com.sql_engine.v_1_0.services;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.entities.dto.DatabaseCredentials;
import com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException;

@Service
public class DbConnectionValidator {

	public String testConnection(DatabaseCredentials credentials) throws DatabaseSecurityException {
		try {
			if (credentials.driver() != null && !credentials.driver().isBlank()) {
				Class.forName(credentials.driver());
			}

			NormalizedConnectionInfo normalized = normalizeJdbcConnectionInfo(credentials);

			try (Connection conn = DriverManager.getConnection(normalized.url(), normalized.username(),
					normalized.password())) {

				if (!conn.isValid(5)) {
					throw new DatabaseSecurityException("Conexão inválida: timeout ao validar a conexão com o banco.");
				}

				String databaseName = extractDatabaseName(conn, normalized.url());
				return databaseName;
			}
		} catch (ClassNotFoundException e) {
			throw new DatabaseSecurityException("Driver JDBC não encontrado ou url inválida: " + e.getMessage());
		} catch (java.sql.SQLException e) {
			throw new DatabaseSecurityException("Falha ao conectar com o banco de dados: " + e.getMessage());
		} catch (DatabaseSecurityException e) {
			throw e;
		} catch (Exception e) {
			throw new DatabaseSecurityException("Erro ao validar conexão: " + e.getMessage());
		}
	}

	private String extractDatabaseName(Connection conn, String url) {
		try {
			String databaseName = conn.getCatalog();
			if (databaseName == null || databaseName.isBlank()) {
				databaseName = conn.getSchema();
			}
			if (databaseName != null && !databaseName.isBlank()) {
				return databaseName;
			}
		} catch (SQLException e) {
			// Ignora, tentaremos extrair da URL como fallback. o objetivo é não deixar a falha de extração do nome do banco quebrar a validação inteira.
		}

		return extractDatabaseNameFromUrl(url);
	}

	private String extractDatabaseNameFromUrl(String url) {
		try {
			String lowerUrl = url.toLowerCase();

			if (lowerUrl.contains("databasename=")) {
				String[] parts = url.split("databasename=");
				String dbPart = parts[1];
				int separator = dbPart.indexOf(';');
				if (separator > -1) {
					dbPart = dbPart.substring(0, separator);
				}
				return dbPart;
			}

			if (lowerUrl.contains("/")) {
				int lastSlash = url.lastIndexOf('/');
				if (lastSlash != -1 && lastSlash + 1 < url.length()) {
					String dbPart = url.substring(lastSlash + 1);
					int queryIndex = dbPart.indexOf('?');
					if (queryIndex > -1) {
						dbPart = dbPart.substring(0, queryIndex);
					}
					if (!dbPart.isBlank()) {
						return dbPart;
					}
				}
			}

			return "unknown";
		} catch (Exception e) {
			return "unknown";
		}
	}

	public static record NormalizedConnectionInfo(String url, String username, String password) {
	}

	public NormalizedConnectionInfo normalizeJdbcConnectionInfo(DatabaseCredentials credentials) {
		String url = credentials.url();
		String username = credentials.username();
		String password = credentials.password();

		if (url == null) {
			return new NormalizedConnectionInfo(null, username, password);
		}

		String normalized = url.trim();
		if (normalized.isBlank()) {
			return new NormalizedConnectionInfo(normalized, username, password);
		}

		if (!normalized.regionMatches(true, 0, "jdbc:", 0, 5)) {
			if (normalized.regionMatches(true, 0, "postgresql://", 0, 13)
					|| normalized.regionMatches(true, 0, "mysql://", 0, 8)
					|| normalized.regionMatches(true, 0, "mariadb://", 0, 10)
					|| normalized.regionMatches(true, 0, "sqlserver://", 0, 12)
					|| normalized.regionMatches(true, 0, "oracle://", 0, 9)) {
				normalized = "jdbc:" + normalized;
			}
		}

		String cleanUrl = normalized;
		int schemeSep = cleanUrl.indexOf("://");
		if (schemeSep > 0) {
			int authorityStart = schemeSep + 3;
			int atSign = cleanUrl.indexOf('@', authorityStart);
			int pathStart = cleanUrl.indexOf('/', authorityStart);
			if (atSign > authorityStart && (pathStart == -1 || atSign < pathStart)) {
				String userInfo = cleanUrl.substring(authorityStart, atSign);
				cleanUrl = cleanUrl.substring(0, authorityStart) + cleanUrl.substring(atSign + 1);

				if (username == null || username.isBlank()) {
					int colon = userInfo.indexOf(':');
					if (colon > -1) {
						username = userInfo.substring(0, colon);
						if (password == null || password.isBlank()) {
							password = userInfo.substring(colon + 1);
						}
					} else {
						username = userInfo;
					}
				}
			}
		}

		return new NormalizedConnectionInfo(cleanUrl, username, password);
	}
}
