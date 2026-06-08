package fr.epita.quiz.test;

import fr.epita.quiz.datamodel.Student;
import fr.epita.quiz.services.EmbeddedStudentDAO;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import javax.sql.DataSource;
import java.sql.Connection;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = TestConfig.class)
public class TestDAO {

    @Autowired
    EmbeddedStudentDAO dao;
    @Autowired
    private DataSource dataSource;


    @Test
    public void test(){
        Assertions.assertNotNull(dao);

        Student student = new Student();
        student.setId("abcd");
        student.setAddress("Paris");
        student.setName("Test");

       // Connection connection = dataSource.getConnection();



        dao.create(student);
        Student retrieved = dao.getById("abcd");
        Assertions.assertNotNull(retrieved);
        Assertions.assertEquals("Test", retrieved.getName());

        student.setName("Test2");
        dao.update(student);
        Student retrieved2 = dao.getById("abcd");
        Assertions.assertEquals("Test2", retrieved2.getName());

        dao.delete(student);
        Student retrieved3 = dao.getById("abcd");

        Assertions.assertNull(retrieved3);
       // Assertions.assertThrows(RuntimeException.class, () -> {
       // Student retrieved4 = dao.getById("abcd");
       // });







    }
}
