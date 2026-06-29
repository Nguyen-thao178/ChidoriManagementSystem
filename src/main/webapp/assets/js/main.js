document.addEventListener('DOMContentLoaded', function() {
    var contextPath = window.contextPath || '';

    // ==================== SLIDER ====================
    var slideIndex = 0;
    var slides = document.querySelectorAll('.slide');
    if (slides.length) {
        slides[0].classList.add('active');
        setInterval(function() {
            slides.forEach(function(s) { s.classList.remove('active'); });
            slideIndex = (slideIndex + 1) % slides.length;
            slides[slideIndex].classList.add('active');
        }, 4000);
    }

    var prevBtn = document.querySelector('.prev');
    var nextBtn = document.querySelector('.next');
    if (prevBtn) {
        prevBtn.addEventListener('click', function() {
            slides.forEach(function(s) { s.classList.remove('active'); });
            slideIndex = (slideIndex - 1 + slides.length) % slides.length;
            slides[slideIndex].classList.add('active');
        });
    }
    if (nextBtn) {
        nextBtn.addEventListener('click', function() {
            slides.forEach(function(s) { s.classList.remove('active'); });
            slideIndex = (slideIndex + 1) % slides.length;
            slides[slideIndex].classList.add('active');
        });
    }

    // ==================== CHATBOT (AI) ====================
    var chatIcon = document.getElementById('chatIcon');
    var chatWindow = document.getElementById('chatWindow');
    if (chatIcon) {
        chatIcon.addEventListener('click', function() {
            var isVisible = chatWindow.style.display === 'flex';
            chatWindow.style.display = isVisible ? 'none' : 'flex';
        });
    }

    var sendBtn = document.getElementById('sendChat');
    var chatInput = document.getElementById('chatInput');
    var chatBody = document.getElementById('chatBody');

    function addBotMessage(text) {
        var msgDiv = document.createElement('div');
        msgDiv.innerHTML = '<strong>🤖 Bot:</strong> ' + text;
        msgDiv.style.marginBottom = '10px';
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function addUserMessage(text) {
        var msgDiv = document.createElement('div');
        msgDiv.innerHTML = '<strong>👤 Bạn:</strong> ' + text;
        msgDiv.style.marginBottom = '10px';
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function sendToAI(message) {
        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'message=' + encodeURIComponent(message)
        })
        .then(function(response) { return response.json(); })
        .then(function(data) {
            if (data.success) addBotMessage(data.message);
            else addBotMessage('Xin lỗi, tôi chưa hiểu. Vui lòng thử lại.');
        })
        .catch(function(error) {
            addBotMessage('Lỗi kết nối đến máy chủ.');
        });
    }

    if (sendBtn) {
        sendBtn.addEventListener('click', function() {
            var msg = chatInput.value.trim();
            if (msg === '') return;
            addUserMessage(msg);
            chatInput.value = '';
            sendToAI(msg);
        });
        if (chatInput) {
            chatInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') sendBtn.click();
            });
        }
    }

    // ==================== ANIMATION THÊM GIỎ ====================
    var addBtns = document.querySelectorAll('.btn-add-cart');
    addBtns.forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            var ripple = document.createElement('div');
            ripple.textContent = '➕';
            ripple.style.position = 'fixed';
            ripple.style.left = e.clientX + 'px';
            ripple.style.top = e.clientY + 'px';
            ripple.style.fontSize = '24px';
            ripple.style.pointerEvents = 'none';
            ripple.style.zIndex = '9999';
            ripple.style.transition = 'all 0.6s ease';
            ripple.style.opacity = '1';
            document.body.appendChild(ripple);
            setTimeout(function() {
                ripple.style.transform = 'translate(30px, -80px)';
                ripple.style.opacity = '0';
            }, 10);
            setTimeout(function() { ripple.remove(); }, 700);
        });
    });

    // ==================== SCROLL REVEAL ====================
    var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.product-card, .widget, .cart-container, .product-detail').forEach(function(el) {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(el);
    });

    // ==================== THEME TOGGLE (Light/Dark) ====================
    var themeToggle = document.getElementById('themeToggle');
    if (themeToggle) {
        var currentTheme = localStorage.getItem('theme') || 'dark';
        if (currentTheme === 'light') document.documentElement.classList.add('light');
        themeToggle.textContent = currentTheme === 'light' ? '🌙' : '☀️';
        themeToggle.addEventListener('click', function() {
            var isLight = document.documentElement.classList.toggle('light');
            localStorage.setItem('theme', isLight ? 'light' : 'dark');
            themeToggle.textContent = isLight ? '🌙' : '☀️';
        });
    }
});