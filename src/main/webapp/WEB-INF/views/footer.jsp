<%@ page pageEncoding="UTF-8" %>
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
<!-- Chidori Assistant -->
<button class="chatbot-icon" id="chatIcon" type="button"
        aria-label="Mở trợ lý Chidori" aria-controls="chatWindow" aria-expanded="false">
    <span>✦</span>
    <i></i>
</button>
<aside class="chat-window" id="chatWindow" aria-label="Trợ lý Chidori" aria-hidden="true">
    <div class="chat-header">
        <div class="chat-assistant-avatar">C</div>
        <div>
            <strong>Chidori Assistant</strong>
            <small><i></i> Trợ lý thông tin của quán</small>
        </div>
        <button id="closeChat" type="button" aria-label="Đóng chat">×</button>
    </div>
    <div class="chat-body" id="chatBody" role="log" aria-live="polite">
        <div class="chat-message bot-message">
            <span class="message-avatar">C</span>
            <div class="message-bubble">Chào bạn! ☕ Mình có thể giúp tìm món, kiểm tra giá, barcode, thanh toán hoặc đơn cọc.</div>
        </div>
        <div class="chat-suggestions" aria-label="Câu hỏi gợi ý">
            <button type="button" data-chat-suggestion="Cho mình xem menu và giá món">Menu &amp; giá</button>
            <button type="button" data-chat-suggestion="Chính sách đặt cọc thế nào?">Đặt cọc</button>
            <button type="button" data-chat-suggestion="Quán mở cửa lúc mấy giờ?">Giờ mở cửa</button>
        </div>
    </div>
    <div class="chat-typing" id="chatTyping" hidden>
        <span></span><span></span><span></span>
    </div>
    <div class="chat-footer">
        <input type="text" id="chatInput" maxlength="500"
               placeholder="Hỏi Chidori Assistant..." autocomplete="off">
        <button id="sendChat" type="button" aria-label="Gửi tin nhắn">➤</button>
    </div>
    <p class="chat-disclaimer">AI chỉ trả lời thông tin liên quan đến Chidori Coffee.</p>
</aside>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
