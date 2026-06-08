package fr.epita.calculator.services.test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class BadSpringUsageExample {

    @Autowired
    @Qualifier("current.version")
    String version;

    public String getVersion() {
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext();
        Object bean = applicationContext.getBean("current.version");
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }
}
