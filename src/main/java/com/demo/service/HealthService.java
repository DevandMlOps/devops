package com.demo.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class HealthService {
    
    public Map<String, String> getHealth() {
        Map<String, String> health = new HashMap<>();
        health.put("status", "UP");
        health.put("version", "1.0.0");
        return health;
    }
}
