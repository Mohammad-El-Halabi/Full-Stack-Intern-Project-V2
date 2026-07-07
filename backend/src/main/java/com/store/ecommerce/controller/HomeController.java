package com.store.ecommerce.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/** A tiny landing endpoint so hitting the root URL confirms the API is up. */
@RestController
public class HomeController {

    @GetMapping("/")
    public Map<String, Object> home() {
        return Map.of(
                "application", "Full Stack Intern Project v2 - E-commerce API",
                "status", "UP",
                "docs", "See README.md and postman/ for the list of endpoints."
        );
    }
}
