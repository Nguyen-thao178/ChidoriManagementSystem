package com.cafe.dao;

import com.cafe.model.LoyaltyPoint;
import java.sql.*;

public class LoyaltyDAO {
    public LoyaltyPoint getByUserId(int userId) {
        String sql = "SELECT * FROM loyalty_points WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                LoyaltyPoint lp = new LoyaltyPoint();
                lp.setId(rs.getInt("id"));
                lp.setUserId(rs.getInt("user_id"));
                lp.setPoints(rs.getInt("points"));
                lp.setTotalSpent(rs.getDouble("total_spent"));
                lp.setUpdatedAt(rs.getString("updated_at"));
                return lp;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean addPoints(int userId, int points, double spent) {
        String sql = "UPDATE loyalty_points SET points = points + ?, total_spent = total_spent + ?, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, points);
            ps.setDouble(2, spent);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean createEmpty(int userId) {
        String sql = "INSERT INTO loyalty_points (user_id, points, total_spent) VALUES (?, 0, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}