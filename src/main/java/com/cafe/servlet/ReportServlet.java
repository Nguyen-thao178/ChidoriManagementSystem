package com.cafe.servlet;

import com.cafe.dao.ReportDAO;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;

@WebServlet("/admin/report")
public class ReportServlet extends HttpServlet {
    private ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null || (!"admin".equals(user.getRole()) && !"manager".equals(user.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String dateParam = req.getParameter("date");
        if (dateParam == null || dateParam.isEmpty()) {
            dateParam = LocalDate.now().toString();
        }
        double revenue = reportDAO.getTotalRevenueByDate(dateParam);
        Map<String, Integer> topProducts = reportDAO.getTopProducts(5);
        // Lấy doanh thu tháng hiện tại
        LocalDate now = LocalDate.now();
        double monthlyRevenue = reportDAO.getTotalRevenueByMonth(now.getYear(), now.getMonthValue());
        Map<String, Double> dailyRevenue = reportDAO.getDailyRevenue(now.getYear(), now.getMonthValue());

        req.setAttribute("revenue", revenue);
        req.setAttribute("topProducts", topProducts);
        req.setAttribute("reportDate", dateParam);
        req.setAttribute("monthlyRevenue", monthlyRevenue);
        req.setAttribute("dailyRevenue", dailyRevenue);
        req.setAttribute("currentYear", now.getYear());
        req.setAttribute("currentMonth", now.getMonthValue());

        req.getRequestDispatcher("/WEB-INF/views/admin/report.jsp").forward(req, resp);
    }
}