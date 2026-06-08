package fr.epita.quiz.services;

import fr.epita.quiz.datamodel.Student;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class EmbeddedStudentDAO {

    private final DataSource ds;

    public EmbeddedStudentDAO(DataSource datasource) {
        this.ds = datasource;
        try (Connection cnx = datasource.getConnection();
             Statement stmt = cnx.createStatement()) {
            stmt.execute(
                    "CREATE TABLE IF NOT EXISTS STUDENT (" +
                            "ID VARCHAR(50) PRIMARY KEY, " +
                            "NAME VARCHAR(255), " +
                            "ADDRESS VARCHAR(255))");
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize STUDENT table", e);
        }
    }

    public void create(Student student) {
        String sql = "INSERT INTO STUDENT (ID, NAME, ADDRESS) VALUES (?, ?, ?)";
        try (Connection cnx = ds.getConnection();
             PreparedStatement ps = cnx.prepareStatement(sql)) {
            ps.setString(1, student.getId());
            ps.setString(2, student.getName());
            ps.setString(3, student.getAddress());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create student", e);
        }
    }

    public void update(Student student) {
        String sql = "UPDATE STUDENT SET NAME = ?, ADDRESS = ? WHERE ID = ?";
        try (Connection cnx = ds.getConnection();
             PreparedStatement ps = cnx.prepareStatement(sql)) {
            ps.setString(1, student.getName());
            ps.setString(2, student.getAddress());
            ps.setString(3, student.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("Failed to update student", e);
        }
    }

    public void delete(Student student) {
        String sql = "DELETE FROM STUDENT WHERE ID = ?";
        try (Connection cnx = ds.getConnection();
             PreparedStatement ps = cnx.prepareStatement(sql)) {
            ps.setString(1, student.getId());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete student", e);
        }
    }

    public List<Student> search(String id) {
        String sql = "SELECT ID, NAME, ADDRESS FROM STUDENT WHERE ID LIKE ?";
        List<Student> results = new ArrayList<>();
        try (Connection cnx = ds.getConnection();
             PreparedStatement ps = cnx.prepareStatement(sql)) {
            ps.setString(1, "%" + id + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(new Student(
                            rs.getString("ID"),
                            rs.getString("NAME"),
                            rs.getString("ADDRESS")));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to search students", e);
        }
        return results;
    }

    public Student getById(String id) {
        String sql = "SELECT ID, NAME, ADDRESS FROM STUDENT WHERE ID = ?";
        try (Connection cnx = ds.getConnection();
             PreparedStatement ps = cnx.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Student(
                            rs.getString("ID"),
                            rs.getString("NAME"),
                            rs.getString("ADDRESS"));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to get student by id", e);
        }
        return null;
    }
}