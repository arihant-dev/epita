package fr.epita.calculator.services.test;

import org.junit.jupiter.api.extension.ExtendWith;

public class TestSpring {
    @ExtendWith(SpringExtension.class)
    @ContextConfiguration(classes = {TestConfiguration.class})
}
