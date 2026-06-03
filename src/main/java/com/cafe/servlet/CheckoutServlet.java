package com.cafe.servlet;

import com.cafe.dao.OrderDAO;
import com.cafe.model.CartItem;
import com.cafe.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Hiển thị trang checkout với QR
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

        if (user == null) {
            result.put("success", false);
            result.put("message", "Vui lòng đăng nhập lại.");
            writeJson(resp, result);
            return;
        }
        if (cart == null || cart.isEmpty()) {
            result.put("success", false);
            result.put("message", "Giỏ hàng trống.");
            writeJson(resp, result);
            return;
        }

        // Giả lập thanh toán: 80% thành công, 20% thất bại
        boolean paymentSuccess = new Random().nextInt(100) < 80;

        if (paymentSuccess) {
            double total = cart.stream()
                    .mapToDouble(item -> item.getDiscountedPrice() * item.getQuantity())
                    .sum();
            try {
                orderDAO.createOrder(user.getId(), cart, total);
                session.removeAttribute("cart"); // Xóa giỏ sau khi thành công
                result.put("success", true);
                result.put("message", "Thanh toán thành công! Đơn hàng đã được lưu.");
            } catch (Exception e) {
                result.put("success", false);
                result.put("message", "Lỗi lưu đơn hàng: " + e.getMessage());
            }
        } else {
            // Thanh toán thất bại, giữ nguyên giỏ hàng
            result.put("success", false);
            result.put("message", "Thanh toán thất bại. Vui lòng thử lại.");
        }
        writeJson(resp, result);
    }

    private void writeJson(HttpServletResponse resp, Map<String, Object> data) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        resp.getWriter().write(mapper.writeValueAsString(data));
    }
}