package fr.epita.calculator.services;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Calculator {
    private static final Logger logger = LogManager.getLogger(Calculator.class);
    
    public Double add(Double a, Double b) {
        logger.info("adding {} and {}", a, b);
        return a + b;
    }
    
    public Double sub(Double a, Double b) {
        logger.info("subtracting {} from {}", b, a);
        return a - b;
    }
    
    public Double mul(Double a, Double b) {
        logger.info("multiplying {} and {}", a, b);
        return a * b;
    }
    
    public Double div(Double a, Double b) {
        logger.info("dividing {} by {}", a, b);
        return a / b;
    }
}
