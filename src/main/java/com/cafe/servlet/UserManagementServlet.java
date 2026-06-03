package com.cafe.servlet;

import com.cafe.dao.UserDAO;
import com.cafe.model.User;
import com.cafe.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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
        if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            User user = userDAO.findById(id);
            req.setAttribute("user", user);
            req.getRequestDispatcher("/WEB-INF/views/admin/user_form.jsp").forward(req, resp);
        } else {
            List<User> users = userDAO.getAllUsers();
            req.setAttribute("users", users);
            req.getRequestDispatcher("/WEB-INF/views/admin/user_list.jsp").forward(req, resp);
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
        if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            userDAO.deleteUser(id);
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
            userDAO.updateUser(u);
            String newPass = req.getParameter("password");
            if (newPass != null && !newPass.trim().isEmpty()) {
                userDAO.changePassword(id, PasswordUtil.hashSHA256(newPass));
            }
        } else if ("create".equals(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String fullname = req.getParameter("fullname");
            String email = req.getParameter("email");
            String role = req.getParameter("role");
            User u = new User();
            u.setUsername(username);
            u.setFullname(fullname);
            u.setEmail(email);
            u.setRole(role);
            userDAO.createUser(u, password);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private boolean isAdmin(HttpServletRequest req) {
        User user = (User) req.getSession().getAttribute("user");
        return user != null && "admin".equals(user.getRole());
    }
}