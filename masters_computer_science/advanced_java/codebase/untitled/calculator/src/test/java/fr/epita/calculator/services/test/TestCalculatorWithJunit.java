package fr.epita.calculator.services.test;
import fr.epita.calculator.services.Calculator;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class TestCalculatorWithJunit {

    @Test
    public void testDivision(){
        double a = 10;
        double b = 2;
        int expected = 5;
        Calculator calc = new Calculator();

        Double result = calc.div(a, b);

        Assertions.assertEquals(expected, result, 0.01);
    }

    @Test
    public void testMultiplication(){
        double a = 10;
        double b = 2;
        int expected = 20;
        Calculator calc = new Calculator();

        Double result = calc.mul(a, b);
        Assertions.assertEquals(expected, result, 0.01);
    }

    @Test
    public void testAddition(){
        double a = 10;
        double b = 2;
        int expected = 12;
        Calculator calc = new Calculator();

        Double result = calc.add(a, b);

        Assertions.assertEquals(expected, result, 0.01);
    }

    @Test
    public void testSubstraction(){
        double a = 10;
        double b = 2;
        int expected = 8;
        Calculator calc = new Calculator();

        Double result = calc.sub(a, b);

        Assertions.assertEquals(expected, result, 0.01);
    }
}
