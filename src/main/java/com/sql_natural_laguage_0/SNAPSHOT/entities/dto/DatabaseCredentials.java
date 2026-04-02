package com.sql_natural_laguage_0.SNAPSHOT.entities.dto;

public record DatabaseCredentials (
	String url,
	String username,
	String password,
	String driver
) {}
