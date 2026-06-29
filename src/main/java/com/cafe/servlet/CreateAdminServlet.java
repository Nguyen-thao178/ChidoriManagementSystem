package com.cafe.servlet;

import com.cafe.dao.UserDAO;
import com.cafe.model.User;
import com.cafe.utils.HashUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/create-admin")
public class CreateAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        UserDAO dao = new UserDAO();
        resp.setContentType("text/html; charset=UTF-8");

        try {
            // Kiểm tra admin đã tồn tại
            User existing = dao.findByUsername("admin");
            if (existing != null) {
                resp.getWriter().write("✅ Tài khoản admin đã tồn tại.");
                return;
            }

            // Tạo admin mới
            User admin = new User();
            admin.setUsername("admin");
            admin.setFullname("Administrator");
            admin.setEmail("admin@chidori.com");
            admin.setRole("admin");

            // Mã hóa mật khẩu "admin123" bằng SHA-256
            String plainPassword = "admin123";
            String hashedPassword = HashUtil.sha256(plainPassword);
            admin.setPasswordHash(hashedPassword);

            // Lưu vào database
            int userId = dao.insert(admin);
            if (userId > 0) {
                resp.getWriter().write("✅ Tạo tài khoản admin thành công!<br>");
                resp.getWriter().write("📌 Username: admin<br>");
                resp.getWriter().write("🔑 Password: admin123");
            } else {
                resp.getWriter().write("❌ Tạo thất bại (không có ID trả về).");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.getWriter().write("❌ Lỗi hệ thống: " + e.getMessage());
        }
    }
}