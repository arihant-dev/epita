package fr.epita.quiz.test;

import fr.epita.quiz.services.EmbeddedStudentDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

@Configuration
public class TestConfig {


    @Bean
    public DataSource dataSource(){
        return new DriverManagerDataSource("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1");
    }

    @Bean
    public EmbeddedStudentDAO getDao(@Autowired DataSource ds){
        return new EmbeddedStudentDAO(ds);
    }
}
