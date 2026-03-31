package com.sql_natural_laguage_0.SNAPSHOT.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.sql_natural_laguage_0.SNAPSHOT.entities.User;

public interface UserRepository extends JpaRepository<User, Long> {
	Optional<User> findByEmail(String email);
}
