package com.sql_engine.v_1_0.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.sql_engine.v_1_0.entities.User;

public interface UserRepository extends JpaRepository<User, Long> {
	Optional<User> findByEmail(String email);
}
