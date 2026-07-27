package com.cafe.servlet;

import com.cafe.dao.OrderDAO;
import com.cafe.model.CartItem;
import com.cafe.model.User;
import com.cafe.payment.VNPayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet("/vnpay-return")
public class VNPayReturnServlet extends HttpServlet {
    private OrderDAO orderDAO = new OrderDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> e = req.getParameterNames(); e.hasMoreElements(); ) {
            String name = e.nextElement();
            fields.put(name, req.getParameter(name));
        }
        String vnp_SecureHash = fields.remove("vnp_SecureHash");
        StringBuilder hashData = new StringBuilder();
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        for (String fieldName : fieldNames) {
            String value = fields.get(fieldName);
            if (value != null && value.length() > 0) {
                hashData.append(fieldName).append('=').append(URLDecoder.decode(value, StandardCharsets.US_ASCII));
                if (fieldNames.indexOf(fieldName) < fieldNames.size() - 1) hashData.append('&');
            }
        }
        String calculatedHash = "";
        try {
            calculatedHash = VNPayConfig.hmacSHA512(VNPayConfig.SECRET_KEY, hashData.toString());
        } catch (Exception e) { e.printStackTrace(); }
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        String orderType = (String) session.getAttribute("checkoutOrderType");
        Date pickupDate = (Date) session.getAttribute("checkoutPickupDate");
        Object payable = session.getAttribute("checkoutPayableAmount");
        if (user != null && cart != null && !cart.isEmpty() && orderType != null && payable != null
                && calculatedHash.equalsIgnoreCase(vnp_SecureHash)) {
            String responseCode = fields.get("vnp_ResponseCode");
            if ("00".equals(responseCode)) {
                double total = cart.stream().mapToDouble(i -> i.getDiscountedPrice() * i.getQuantity()).sum();
                double expectedPayable = "deposit".equals(orderType)
                        ? Math.round(total * OrderDAO.DEFAULT_DEPOSIT_RATE)
                        : total;
                if (Math.abs(expectedPayable - ((Number) payable).doubleValue()) > 0.01) {
                    req.setAttribute("paymentStatus", "error");
                    req.setAttribute("message", "Giỏ hàng đã thay đổi trong lúc thanh toán. Không thể tạo đơn.");
                    req.getRequestDispatcher("/WEB-INF/views/payment_result.jsp").forward(req, resp);
                    return;
                }
                try {
                    orderDAO.createOrder(
                            user.getId(),
                            cart,
                            total,
                            orderType,
                            "vnpay",
                            pickupDate,
                            ((Number) payable).doubleValue()
                    );
                    session.removeAttribute("cart");
                    session.removeAttribute("checkoutOrderType");
                    session.removeAttribute("checkoutPickupDate");
                    session.removeAttribute("checkoutPayableAmount");
                    req.setAttribute("paymentStatus", "success");
                    req.setAttribute("depositOrder", "deposit".equals(orderType));
                } catch (Exception e) {
                    req.setAttribute("paymentStatus", "error");
                    req.setAttribute("message", e.getMessage());
                }
            } else {
                req.setAttribute("paymentStatus", "failed");
                req.setAttribute("message", "Mã lỗi: " + responseCode);
            }
        } else {
            req.setAttribute("paymentStatus", "error");
            req.setAttribute("message", "Chữ ký không hợp lệ");
        }
        req.getRequestDispatcher("/WEB-INF/views/payment_result.jsp").forward(req, resp);
    }
}
