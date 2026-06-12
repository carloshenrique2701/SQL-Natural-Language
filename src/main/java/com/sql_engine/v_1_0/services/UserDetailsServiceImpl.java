package com.sql_engine.v_1_0.services;

import java.util.Collection;
import java.util.Collections;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.sql_engine.v_1_0.repositories.UserRepository;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) {
        try {
        	com.sql_engine.v_1_0.entities.User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado."));

            return new User(
                    user.getEmail(),
                    user.getPassword(),
                    getAuthorities());
		} catch (UsernameNotFoundException e) {
			throw new UsernameNotFoundException("Usuário não encontrado.");
		}
    }

    public UserDetails loadUserById(Long userId) {
        try {
        	com.sql_engine.v_1_0.entities.User user = userRepository.findById(userId)
                    .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado."));

            return new User(
                    userId.toString(),
                    user.getPassword(),
                    getAuthorities());
		} catch (UsernameNotFoundException e) {
			throw new UsernameNotFoundException("Usuário não encontrado.");
		}
    }

    private Collection<? extends GrantedAuthority> getAuthorities() {
        try {
        	return Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"));
		} catch (UsernameNotFoundException e) {
			throw new UsernameNotFoundException("Usuário não encontrado.");
		}
    }
}
