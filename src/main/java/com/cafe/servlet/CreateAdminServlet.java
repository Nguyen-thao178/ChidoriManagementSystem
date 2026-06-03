package com.cafe.servlet;

import com.cafe.dao.UserDAO;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/create-admin")
public class CreateAdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        UserDAO dao = new UserDAO();
        if (dao.findByUsername("admin") == null) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setFullname("Administrator");
            admin.setEmail("admin@chidori.com");
            admin.setRole("admin");
            boolean created = dao.createUser(admin, "admin123");
            if (created) {
                resp.getWriter().write("Tạo tài khoản admin thành công! Mật khẩu: admin123");
            } else {
                resp.getWriter().write("Tạo thất bại. Kiểm tra database hoặc log.");
            }
        } else {
            resp.getWriter().write("Tài khoản admin đã tồn tại.");
        }
    }
}