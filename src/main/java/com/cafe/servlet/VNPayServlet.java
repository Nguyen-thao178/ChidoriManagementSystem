package com.cafe.servlet;

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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/vnpay-pay")
public class VNPayServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (user == null || cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        Object payable = session.getAttribute("checkoutPayableAmount");
        String orderType = (String) session.getAttribute("checkoutOrderType");
        if (payable == null || orderType == null) {
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }
        double payableAmount = ((Number) payable).doubleValue();
        long amount = (long) (payableAmount * 100);
        String vnp_TxnRef = VNPayConfig.TMN_CODE + System.currentTimeMillis();
        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", VNPayConfig.VERSION);
        vnp_Params.put("vnp_Command", VNPayConfig.COMMAND);
        vnp_Params.put("vnp_TmnCode", VNPayConfig.TMN_CODE);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", VNPayConfig.CURRENCY);
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", "deposit".equals(orderType)
                ? "Dat coc don hang Chidori"
                : "Thanh toan truc tiep don hang Chidori");
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", VNPayConfig.LOCALE);
        vnp_Params.put("vnp_ReturnUrl", VNPayConfig.RETURN_URL);
        vnp_Params.put("vnp_IpAddr", req.getRemoteAddr());
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        for (String fieldName : fieldNames) {
            String value = vnp_Params.get(fieldName);
            if (value != null && value.length() > 0) {
                hashData.append(fieldName).append('=').append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII)).append('=').append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                if (fieldNames.indexOf(fieldName) < fieldNames.size() - 1) {
                    hashData.append('&');
                    query.append('&');
                }
            }
        }
        String secureHash = "";
        try {
            secureHash = VNPayConfig.hmacSHA512(VNPayConfig.SECRET_KEY, hashData.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
        query.append("&vnp_SecureHash=").append(secureHash);
        String paymentUrl = VNPayConfig.PAY_URL + "?" + query.toString();
        resp.sendRedirect(paymentUrl);
    }
}
