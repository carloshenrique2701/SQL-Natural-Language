package com.sql_engine.v_1_0.entities.dto;

public record LoginResponse(
    String token,
    Long id,
    String name,
    String email,
    String dbName
) {}
