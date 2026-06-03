package com.cafe.dao;

import com.cafe.dao.UserDAO;
import com.cafe.model.User;
import com.cafe.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register-member")
public class MemberRegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register_member.jsp").forward(req, resp);
    }
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        if (userDAO.findByUsername(username) != null) {
            req.setAttribute("error", "Tên đăng nhập đã tồn tại");
            try { req.getRequestDispatcher("/WEB-INF/views/register_member.jsp").forward(req, resp); } catch (Exception e) {}
            return;
        }
        User u = new User();
        u.setUsername(username);
        u.setFullname(fullname);
        u.setEmail(email);
        u.setRole("customer"); // role khách hàng
        userDAO.createUser(u, password);
        // Tạo điểm tích lũy
        new com.cafe.dao.LoyaltyDAO().createEmpty(u.getId());
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}