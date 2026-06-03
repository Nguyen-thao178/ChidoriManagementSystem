package com.cafe.servlet;

import com.cafe.dao.SystemSettingsDAO;
import com.cafe.model.SystemSetting;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/settings")
public class SettingsServlet extends HttpServlet {
    private SystemSettingsDAO settingsDAO = new SystemSettingsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        List<SystemSetting> settings = settingsDAO.getAll();
        req.setAttribute("settings", settings);
        req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String key = req.getParameter("key");
        String value = req.getParameter("value");
        if (key != null && value != null && !key.trim().isEmpty()) {
            settingsDAO.updateSetting(key, value);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/settings");
    }
}