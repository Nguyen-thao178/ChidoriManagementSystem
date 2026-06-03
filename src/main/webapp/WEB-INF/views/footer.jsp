<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer>
    <div class="footer-content">
        <div class="footer-section">
            <h4>Chidori Coffee</h4>
            <p>Thương hiệu cà phê rang xay nguyên chất</p>
            <p>📞 Hotline: 1900 1234</p>
            <p>📍 123 Đường Cà Phê, Quận 1, TP.HCM</p>
        </div>
        <div class="footer-section">
            <h4>Giờ mở cửa</h4>
            <p>Thứ 2 - Thứ 6: 7:00 - 21:00</p>
            <p>Thứ 7 - CN: 8:00 - 22:00</p>
        </div>
        <div class="footer-section">
            <h4>Theo dõi</h4>
            <p>Facebook | Instagram | Tiktok</p>
        </div>
    </div>
    <div class="copyright">
        &copy; 2025 Chidori Coffee System. All rights reserved.
    </div>
</footer>
<!-- Chatbot -->
<div class="chatbot-icon" id="chatIcon">💬</div>
<div class="chat-window" id="chatWindow">
    <div class="chat-header">🤖 Trợ lý Chidori</div>
    <div class="chat-body" id="chatBody">🤖 Bot: Chào bạn! Cần tư vấn món gì ạ?</div>
    <div class="chat-footer">
        <input type="text" id="chatInput" placeholder="Nhập tin nhắn...">
        <button id="sendChat">Gửi</button>
    </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>