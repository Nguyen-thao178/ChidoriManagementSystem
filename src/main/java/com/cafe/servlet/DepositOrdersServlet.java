package com.cafe.servlet;

import com.cafe.dao.OrderDAO;
import com.cafe.model.Order;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/deposit-orders")
public class DepositOrdersServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            orderDAO.expireOverdueDeposits();
        } catch (Exception e) {
            getServletContext().log("Không thể cập nhật đơn cọc quá hạn", e);
        }

        List<Order> orders = orderDAO.getDepositOrdersByUserId(user.getId());
        req.setAttribute("depositOrders", orders);
        req.getRequestDispatcher("/WEB-INF/views/deposit_orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            boolean updated = orderDAO.markDepositPickedUp(orderId, user.getId());
            resp.sendRedirect(req.getContextPath() + "/deposit-orders?"
                    + (updated ? "received=1" : "error=invalid"));
        } catch (Exception e) {
            getServletContext().log("Không thể xác nhận nhận hàng", e);
            resp.sendRedirect(req.getContextPath() + "/deposit-orders?error=update");
        }
    }
}
