package com.sql_engine.v_1_0.services.exceptions.users;

public class InvalidCredentialsException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	public InvalidCredentialsException(String msg) {
		super(msg != null ? msg : "Invalid credentials.");
	}

}
