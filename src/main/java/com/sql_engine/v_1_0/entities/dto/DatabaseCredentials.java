package com.sql_engine.v_1_0.entities.dto;

public record DatabaseCredentials (
	String url,
	String username,
	String password,
	String driver
) {}
