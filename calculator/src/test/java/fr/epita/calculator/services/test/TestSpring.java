package fr.epita.calculator.services.test;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = {TestConfig.class})
public class TestSpring {

    Logger LOGGER = LogManager.getLogger(TestSpring.class);

    @Autowired
    @Qualifier("current-version")
    private String version;


    @Test
    public void test(){
        LOGGER.info("version {}", version);
        BadSpringUsageExample badSpringUsageExample = new BadSpringUsageExample();
        System.out.println(badSpringUsageExample.getVersion());
    }

}
