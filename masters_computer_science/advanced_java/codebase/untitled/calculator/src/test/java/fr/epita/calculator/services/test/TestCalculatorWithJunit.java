package fr.epita.calculator.services.test;
import fr.epita.calculator.services.Calculator;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

public class TestCalculatorWithJunit {

    public static final Logger logger = LogManager.getLogger(TestCalculatorWithJunit.class);

    @BeforeAll
    public static void initAll(){
        logger.info("Start of all tests");
    }

    @BeforeEach
    public void init(){
        logger.info("Start of test");
    }

    @AfterEach
    public void end(){
        logger.info("End of test");
    }

    @AfterAll
    public static void endAll(){
        logger.info("Info - End of all tests");
        logger.error("Error - End of all tests");
        logger.fatal("Fatal - End of all tests");
        logger.trace("Trace - End of all tests");
    }

    @ParameterizedTest
    @CsvSource("""
            5, 5, 1
            10, 2, 5
            """)
    public void testDivision(double a, double b, int expected){
        Calculator calc = new Calculator();

        Double result = calc.div(a, b);
        logger.info("result = {}", result);

        Assertions.assertEquals(expected, result, 0.01);
    }

    @Test
    public void shouldThrowWhenDividingByZero(){
        Calculator calc = new Calculator();
    }

    @Test
    public void testMultiplication() {
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
