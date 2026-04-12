package com.sql_engine.v_1_0.services.exceptions.ai;

public class DatabaseSecurityException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	public DatabaseSecurityException(String msg) {
		super(msg);
	}

}
