package fr.epita.calculator.services.test;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TestConfig {

    @Bean(name="current-version")
    public String version1(){
        return "1.0.3";
    }
    @Bean
    public String version2(){
        return "1.0.1";
    }



}
