package com.cafe.servlet;

import com.cafe.dao.UserDAO;
import com.cafe.model.User;
import com.cafe.utils.HashUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/users")
public class UserManagementServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                User user = userDAO.findById(id);
                req.setAttribute("user", user);
                req.getRequestDispatcher("/WEB-INF/views/admin/user_form.jsp").forward(req, resp);
            } else {
                List<User> users = userDAO.findAll(); // ✅ Sửa từ getAllUsers
                req.setAttribute("users", users);
                req.getRequestDispatcher("/WEB-INF/views/admin/user_list.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                userDAO.deleteById(id); // ✅ Sửa từ deleteUser

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String fullname = req.getParameter("fullname");
                String email = req.getParameter("email");
                String role = req.getParameter("role");

                User u = new User();
                u.setId(id);
                u.setFullname(fullname);
                u.setEmail(email);
                u.setRole(role);
                // Cần lấy username hiện tại từ DB để không bị null
                User existing = userDAO.findById(id);
                if (existing != null) {
                    u.setUsername(existing.getUsername());
                }
                userDAO.update(u); // ✅ Sửa từ updateUser

                // Cập nhật mật khẩu nếu có
                String newPass = req.getParameter("password");
                if (newPass != null && !newPass.trim().isEmpty()) {
                    String hashed = HashUtil.sha256(newPass); // ✅ Sửa từ PasswordUtil.hashSHA256
                    userDAO.updatePassword(id, hashed);
                }

            } else if ("create".equals(action)) {
                String username = req.getParameter("username");
                String password = req.getParameter("password");
                String fullname = req.getParameter("fullname");
                String email = req.getParameter("email");
                String role = req.getParameter("role");

                // Kiểm tra username đã tồn tại
                if (userDAO.findByUsername(username) != null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/users?error=Username đã tồn tại!");
                    return;
                }

                User u = new User();
                u.setUsername(username);
                u.setFullname(fullname);
                u.setEmail(email);
                u.setRole(role);

                // Hash password
                String hashedPassword = HashUtil.sha256(password); // ✅ Sửa từ PasswordUtil.hashSHA256
                u.setPasswordHash(hashedPassword);

                userDAO.insert(u); // ✅ Sửa từ createUser
            }

            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + e.getMessage());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=ID không hợp lệ");
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        User user = (User) req.getSession().getAttribute("user");
        return user != null && "admin".equals(user.getRole());
    }
}