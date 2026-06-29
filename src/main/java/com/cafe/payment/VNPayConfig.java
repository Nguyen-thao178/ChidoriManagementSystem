package com.cafe.payment;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class VNPayConfig {
    public static final String VERSION = "2.1.0";
    public static final String COMMAND = "pay";
    public static final String CURRENCY = "VND";
    public static final String LOCALE = "vn";
    public static final String TMN_CODE = "YOUR_TMN_CODE";
    public static final String SECRET_KEY = "YOUR_SECRET_KEY";
    public static final String RETURN_URL = "http://localhost:8080/ChidoriManagementSystem/vnpay-return";
    public static final String PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    public static String hmacSHA512(String key, String data) throws Exception {
        Mac hmac512 = Mac.getInstance("HmacSHA512");
        SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
        hmac512.init(secretKey);
        byte[] hash = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder hex = new StringBuilder();
        for (byte b : hash) hex.append(String.format("%02x", b));
        return hex.toString();
    }
}