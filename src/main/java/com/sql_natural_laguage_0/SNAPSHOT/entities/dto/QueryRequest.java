package com.sql_natural_laguage_0.SNAPSHOT.entities.dto;

public record QueryRequest(

	String userQuery,
	DatabaseCredentials credentials
		
) {}
