package com.sql_engine.v_1_0.services.exceptions.users;

public class DatabaseSecurityException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	public DatabaseSecurityException(String message) {
		super(message);
	}

	public DatabaseSecurityException(String message, Throwable cause) {
		super(message, cause);
	}
}
