package com.cafe.servlet;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    private ObjectMapper mapper = new ObjectMapper();
    private String[] greetings = {"Chào bạn! ☕", "Rất vui được giúp bạn!", "Bạn cần tư vấn gì ạ?"};
    private Random rand = new Random();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String message = req.getParameter("message");
        if (message == null || message.trim().isEmpty()) {
            writeJson(resp, false, "Vui lòng nhập tin nhắn.");
            return;
        }
        String lower = message.toLowerCase().trim();
        String reply = "";
        if (lower.contains("menu") || lower.contains("món") || lower.contains("đồ uống")) {
            reply = "📋 Menu của chúng tôi có: Cà phê đen, Bạc sỉu, Cappuccino, Matcha Latte, Bánh ngọt, Sữa chua cà phê. Xem chi tiết tại: <a href='" + req.getContextPath() + "/menu'>đây</a>.";
        } else if (lower.contains("giá") || lower.contains("bao nhiêu")) {
            reply = "💰 Giá từ 25.000đ đến 55.000đ. Bạn muốn gọi món nào?";
        } else if (lower.contains("khuyến mãi") || lower.contains("giảm giá")) {
            reply = "🎁 Hiện tại có chương trình giảm 20% cho cà phê và 15% cho trà sữa. Ghé thăm trang <a href='" + req.getContextPath() + "/promotion'>Khuyến mãi</a> nhé!";
        } else if (lower.contains("điểm") || lower.contains("tích lũy")) {
            reply = "🏆 Bạn tích lũy 1 điểm cho mỗi 1.000đ chi tiêu. Điểm có thể đổi quà hoặc voucher. Đăng nhập để xem điểm của bạn.";
        } else if (lower.contains("cảm ơn")) {
            reply = "🙏 Cảm ơn bạn! Hẹn gặp lại tại Chidori Coffee.";
        } else if (lower.contains("đặt hàng") || lower.contains("order")) {
            reply = "🛒 Bạn có thể thêm sản phẩm vào giỏ hàng và thanh toán trực tuyến. Xem giỏ hàng <a href='" + req.getContextPath() + "/cart'>tại đây</a>.";
        } else if (lower.contains("liên hệ") || lower.contains("hotline")) {
            reply = "📞 Hotline: 1900 1234 - Email: support@chidori.com. Hoặc xem danh bạ <a href='" + req.getContextPath() + "/contact'>tại đây</a>.";
        } else {
            reply = greetings[rand.nextInt(greetings.length)] + " Bạn có thể hỏi về menu, giá, khuyến mãi, điểm tích lũy hoặc liên hệ.";
        }
        writeJson(resp, true, reply);
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message) throws IOException {
        Map<String, Object> data = new HashMap<>();
        data.put("success", success);
        data.put("message", message);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        mapper.writeValue(resp.getWriter(), data);
    }
}