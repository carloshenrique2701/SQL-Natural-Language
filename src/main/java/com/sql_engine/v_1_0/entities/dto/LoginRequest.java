package com.sql_engine.v_1_0.entities.dto;

public record LoginRequest(
    String email,
    String password
) {}
