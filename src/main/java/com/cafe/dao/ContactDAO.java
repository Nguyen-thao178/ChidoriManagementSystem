package com.cafe.dao;

import com.cafe.model.Contact;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactDAO {
    public List<Contact> getAllContacts() {
        List<Contact> list = new ArrayList<>();
        String sql = "SELECT * FROM contacts ORDER BY " +
                     "CASE position " +
                     "WHEN 'owner' THEN 1 " +
                     "WHEN 'manager' THEN 2 " +
                     "WHEN 'employee' THEN 3 " +
                     "ELSE 4 END, name";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Contact c = new Contact();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setPosition(rs.getString("position"));
                c.setPhone(rs.getString("phone"));
                c.setEmail(rs.getString("email"));
                c.setAddress(rs.getString("address"));
                c.setNotes(rs.getString("notes"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // In lỗi ra console để debug
        }
        return list;
    }
}