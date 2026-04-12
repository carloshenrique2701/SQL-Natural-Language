package com.sql_engine.v_1_0.entities.dto;

public record QueryRequest(

	String userQuery,
	DatabaseCredentials credentials,
	String model
		
) {}
