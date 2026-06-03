package com.cafe.dao;

import com.cafe.model.SystemSetting;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemSettingsDAO {

    public List<SystemSetting> getAll() {
        List<SystemSetting> list = new ArrayList<>();
        String sql = "SELECT * FROM system_settings ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                SystemSetting s = new SystemSetting();
                s.setId(rs.getInt("id"));
                s.setKey(rs.getString("setting_key"));
                s.setValue(rs.getString("setting_value"));
                s.setDescription(rs.getString("description"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public SystemSetting getByKey(String key) {
        String sql = "SELECT * FROM system_settings WHERE setting_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                SystemSetting s = new SystemSetting();
                s.setId(rs.getInt("id"));
                s.setKey(rs.getString("setting_key"));
                s.setValue(rs.getString("setting_value"));
                s.setDescription(rs.getString("description"));
                return s;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateSetting(String key, String value) {
        String sql = "UPDATE system_settings SET setting_value = ? WHERE setting_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            ps.setString(2, key);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}