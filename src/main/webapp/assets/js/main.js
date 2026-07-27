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
    var closeChat = document.getElementById('closeChat');
    var sendBtn = document.getElementById('sendChat');
    var chatInput = document.getElementById('chatInput');
    var chatBody = document.getElementById('chatBody');
    var chatTyping = document.getElementById('chatTyping');
    var sendingMessage = false;

    function setChatOpen(open) {
        if (!chatWindow || !chatIcon) return;
        chatWindow.classList.toggle('is-open', open);
        chatWindow.setAttribute('aria-hidden', String(!open));
        chatIcon.setAttribute('aria-expanded', String(open));
        chatIcon.setAttribute('aria-label', open ? 'Đóng trợ lý Chidori' : 'Mở trợ lý Chidori');
        if (open && chatInput) {
            window.setTimeout(function() { chatInput.focus(); }, 160);
        }
    }

    if (chatIcon) {
        chatIcon.addEventListener('click', function() {
            setChatOpen(!chatWindow.classList.contains('is-open'));
        });
    }
    if (closeChat) {
        closeChat.addEventListener('click', function() { setChatOpen(false); });
    }

    function addMessage(text, isUser) {
        var msgDiv = document.createElement('div');
        msgDiv.className = 'chat-message ' + (isUser ? 'user-message' : 'bot-message');

        if (!isUser) {
            var avatar = document.createElement('span');
            avatar.className = 'message-avatar';
            avatar.textContent = 'C';
            msgDiv.appendChild(avatar);
        }

        var bubble = document.createElement('div');
        bubble.className = 'message-bubble';
        bubble.textContent = text;
        msgDiv.appendChild(bubble);
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function setSending(sending) {
        sendingMessage = sending;
        if (sendBtn) sendBtn.disabled = sending;
        if (chatInput) chatInput.disabled = sending;
        if (chatTyping) chatTyping.hidden = !sending;
        if (sending && chatBody) chatBody.scrollTop = chatBody.scrollHeight;
    }

    function sendToAI(message) {
        setSending(true);
        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json'
            },
            body: new URLSearchParams({message: message})
        })
        .then(function(response) {
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.json();
        })
        .then(function(data) {
            addMessage(data.message || 'Mình chưa thể trả lời lúc này.', false);
        })
        .catch(function() {
            addMessage('Mình chưa kết nối được máy chủ. Bạn vui lòng thử lại sau nhé.', false);
        })
        .finally(function() {
            setSending(false);
            if (chatInput) chatInput.focus();
        });
    }

    function submitChat(message) {
        var msg = (message || (chatInput ? chatInput.value : '')).trim();
        if (!msg || sendingMessage) return;
        addMessage(msg, true);
        chatInput.value = '';
        document.querySelector('.chat-suggestions')?.remove();
        sendToAI(msg);
    }

    if (sendBtn && chatInput && chatBody) {
        sendBtn.addEventListener('click', function() { submitChat(); });
        chatInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                submitChat();
            }
        });
        document.querySelectorAll('[data-chat-suggestion]').forEach(function(button) {
            button.addEventListener('click', function() {
                setChatOpen(true);
                submitChat(button.dataset.chatSuggestion);
            });
        });
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
