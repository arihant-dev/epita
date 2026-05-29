package fr.epita.calculator.services.test;

import fr.epita.calculator.services.Calculator;

public class TestCalculator {

    public static void main(String[] args) {
        // given a = 10, b = 2 then when doing a/b should be = 5

        double a = 10;
        double b = 2;
        int expected = 5;

        Calculator calculator = new Calculator();
        Double result = calculator.div(a, b);

        if (result == expected) {
            System.out.println("Test passed");
        }
    }
}
