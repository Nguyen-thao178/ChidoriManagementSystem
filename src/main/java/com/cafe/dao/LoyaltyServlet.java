package com.cafe.dao;

import com.cafe.dao.LoyaltyDAO;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/loyalty")
public class LoyaltyServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        LoyaltyDAO dao = new LoyaltyDAO();
        var points = dao.getByUserId(user.getId());
        req.setAttribute("points", points);
        req.getRequestDispatcher("/WEB-INF/views/loyalty.jsp").forward(req, resp);
    }
}