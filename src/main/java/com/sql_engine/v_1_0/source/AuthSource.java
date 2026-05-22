package com.sql_engine.v_1_0.source;

import com.sql_engine.v_1_0.entities.User;
import com.sql_engine.v_1_0.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthSource {

    @Autowired
    private UserService userService;

    @GetMapping("/validate")
    public ResponseEntity<?> validate() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized");
            }
            return ResponseEntity.ok().body(true);
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized");
        }
    }
    
    @GetMapping("/me")
    public ResponseEntity<User> me() {
        User authenticatedUser = userService.getAuthenticatedUser();
        return ResponseEntity.ok(authenticatedUser);
    }
}

