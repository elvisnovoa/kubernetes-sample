package com.everis.hackathon;

import lombok.extern.log4j.Log4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@Log4j
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);

//        ("hello");

    }
}
