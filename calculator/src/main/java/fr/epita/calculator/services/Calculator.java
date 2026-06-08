package fr.epita.calculator.services;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Calculator {
    private static final Logger LOGGER = LogManager.getLogger(Calculator.class);

    public Double add(Double operand1, Double operand2){
        return operand1 + operand2;
    }
    public Double divide(Double numerator, Double divider){
        return numerator / divider;
    }
    public Double multiply(Double operand1, Double operand2){
       return operand2 * operand1;
    }
    public Double subtract(Double operand1, Double operand2){
        return operand1 - operand2;
    }
}
