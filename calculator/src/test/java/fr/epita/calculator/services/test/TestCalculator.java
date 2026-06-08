package fr.epita.calculator.services.test;

import fr.epita.calculator.services.Calculator;

public class TestCalculator {

    public static final double TOLERANCE = 0.01;

    public static void main(String[] args) {
        //given a=5, b= 5 when doing a/b the result should be equal to 1
        double a = 5;
        double b = 5;
        int expected_result = 1;

        Calculator calculator = new Calculator();

        Double result = calculator.divide(a, b);

        if ( Math.abs(result - expected_result) > TOLERANCE){
            System.out.println("this test is failing");
        }else{
            System.out.println("success");
        }
    }
}
