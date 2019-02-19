package com.everis.hackathon;

import lombok.Data;
import org.springframework.web.bind.annotation.*;

@RestController
public class LoginController {

    private final UserRepository userRepository;

    public LoginController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Data
    public static class LoginRequest {
        String username;
        String password;
    }

    @PostMapping("/login")
    public User login(@RequestBody LoginRequest request) {
       return userRepository.findByUsernameAndPassword(request.username, request.password).get(0);
    }
}
