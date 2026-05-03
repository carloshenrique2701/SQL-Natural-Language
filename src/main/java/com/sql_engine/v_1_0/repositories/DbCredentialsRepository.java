package com.sql_engine.v_1_0.repositories;

import java.util.Optional;

import com.sql_engine.v_1_0.entities.DbCredentials;
import com.sql_engine.v_1_0.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DbCredentialsRepository extends JpaRepository<DbCredentials, Long> {
	Optional<DbCredentials> findByUser(User user);
}
