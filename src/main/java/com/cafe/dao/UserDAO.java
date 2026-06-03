package com.cafe.dao;

import com.cafe.model.User;
import com.cafe.utils.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Tìm user theo username
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Tìm user theo id
    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy tất cả users
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tạo user mới (có hash mật khẩu)
    public boolean createUser(User user, String plainPassword) {
        String sql = "INSERT INTO users (username, password_hash, fullname, email, role) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, PasswordUtil.hashSHA256(plainPassword));
            ps.setString(3, user.getFullname());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getRole() != null ? user.getRole() : "staff");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật thông tin user (không đổi mật khẩu)
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET fullname = ?, email = ?, role = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullname());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getRole());
            ps.setInt(4, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đổi mật khẩu (đã hash)
    public boolean changePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa user (cascade xóa orders, loyalty_points trước)
    public boolean deleteUser(int id) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            // Xóa các bảng liên quan
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE user_id = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM loyalty_points WHERE user_id = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return false;
    }

    // Validate đăng nhập
    public User validateLogin(String username, String password) {
        User user = findByUsername(username);
        if (user != null && user.getPasswordHash().equals(PasswordUtil.hashSHA256(password))) {
            return user;
        }
        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullname(rs.getString("fullname"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role"));
        return user;
    }
}