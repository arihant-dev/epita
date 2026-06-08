package fr.epita.calculator.services.test;

import fr.epita.calculator.services.Calculator;
import org.apache.logging.log4j.LogManager;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.util.logging.Logger;

public class TestCalculatorWithJunit {

    private static final org.apache.logging.log4j.Logger LOGGER = LogManager.getLogger(TestCalculatorWithJunit.class);

    static Integer countOfCalculatorUseDuringTest = 0;

    @BeforeAll
    public static void globalInit(){
        System.out.println("only once");
    }

    @BeforeEach
    public void beforeEachTest(){
        System.out.println("before each");
    }


    @ParameterizedTest
    @CsvSource("""
        5,5,1
        10, 2, 5"""
    )
    public void testDivision(double a, double b, int expected){
        //given a=5, b= 5 when doing a/b the result should be equal to 1
        Calculator calculator = new Calculator();

        Double result = calculator.divide(a, b);

        Assertions.assertEquals(expected, result, 0.01);
    }

    @Test
    public void testAddition(){
        //given a=5, b= 5 when doing a/b the result should be equal to 1
        double a = 5;
        double b = 5;
        int expected_result = 10;

        Calculator calculator = new Calculator();

        Double result = calculator.add(a, b);

        Assertions.assertEquals(expected_result, result, 0.01);
    }

    @AfterEach
    public void afterEach(){
        System.out.println("after each" + this);
    }

    @AfterAll
    public static void afterAllTest(){
        //System.out.println("printed once: after all");
        //Logger testLogger = Logger.getLogger("test");
        //testLogger.info("this is an info message");

        LOGGER.info("test");


        LOGGER.error("test");
        LOGGER.warn("");
        LOGGER.info(()-> "test" );
        LOGGER.debug("d");
        LOGGER.trace("t");
    }

}
