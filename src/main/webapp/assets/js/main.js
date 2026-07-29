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
    var chatProviderStatus = document.getElementById('chatProviderStatus');
    var chatCharacterCount = document.getElementById('chatCharacterCount');
    var clearChat = document.getElementById('clearChat');
    var initialChatMarkup = chatBody ? chatBody.innerHTML : '';
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
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && chatWindow && chatWindow.classList.contains('is-open')) {
            setChatOpen(false);
        }
    });

    function currentTimeLabel() {
        return new Intl.DateTimeFormat('vi-VN', {
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date());
    }

    function addMessage(text, isUser, provider) {
        var msgDiv = document.createElement('div');
        msgDiv.className = 'chat-message ' + (isUser ? 'user-message' : 'bot-message');

        if (!isUser) {
            var avatar = document.createElement('span');
            avatar.className = 'message-avatar';
            avatar.textContent = 'C';
            msgDiv.appendChild(avatar);
        }

        var messageContent = document.createElement('div');
        var bubble = document.createElement('div');
        bubble.className = 'message-bubble';
        bubble.textContent = text;
        messageContent.appendChild(bubble);

        var meta = document.createElement('span');
        meta.className = 'message-meta';
        meta.textContent = isUser
            ? 'Bạn · ' + currentTimeLabel()
            : (provider === 'gemini' ? 'Gemini · ' : 'Chidori · ') + currentTimeLabel();
        messageContent.appendChild(meta);
        msgDiv.appendChild(messageContent);
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function setSending(sending) {
        sendingMessage = sending;
        if (sendBtn) sendBtn.disabled = sending;
        if (chatInput) chatInput.disabled = sending;
        if (chatTyping) chatTyping.hidden = !sending;
        if (chatProviderStatus) {
            chatProviderStatus.innerHTML = sending
                ? '<i></i> Đang tìm câu trả lời…'
                : '<i></i> Sẵn sàng hỗ trợ';
        }
        if (sending && chatBody) chatBody.scrollTop = chatBody.scrollHeight;
    }

    function sendToAI(message) {
        setSending(true);
        fetch(contextPath + '/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json',
                'X-CSRF-Token': window.CHIDORI_CSRF || ''
            },
            body: new URLSearchParams({message: message})
        })
        .then(function(response) {
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.json();
        })
        .then(function(data) {
            addMessage(data.message || 'Mình chưa thể trả lời lúc này.', false, data.provider);
            if (chatProviderStatus) {
                chatProviderStatus.innerHTML = data.provider === 'gemini'
                    ? '<i></i> Gemini đang hoạt động'
                    : '<i></i> Chế độ hỗ trợ nội bộ';
            }
        })
        .catch(function() {
            addMessage('Mình chưa kết nối được máy chủ. Bạn vui lòng thử lại sau nhé.', false, 'local');
            if (chatProviderStatus) {
                chatProviderStatus.innerHTML = '<i class="is-error"></i> Mất kết nối';
            }
        })
        .finally(function() {
            sendingMessage = false;
            if (sendBtn) sendBtn.disabled = false;
            if (chatInput) chatInput.disabled = false;
            if (chatTyping) chatTyping.hidden = true;
            if (chatInput) chatInput.focus();
        });
    }

    function submitChat(message) {
        var msg = (message || (chatInput ? chatInput.value : '')).trim();
        if (!msg || sendingMessage) return;
        addMessage(msg, true);
        chatInput.value = '';
        chatInput.style.height = '';
        if (chatCharacterCount) chatCharacterCount.textContent = '0/500';
        document.getElementById('chatWelcome')?.remove();
        document.getElementById('chatSuggestions')?.remove();
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
        chatInput.addEventListener('input', function() {
            chatInput.style.height = 'auto';
            chatInput.style.height = Math.min(chatInput.scrollHeight, 96) + 'px';
            if (chatCharacterCount) {
                chatCharacterCount.textContent = chatInput.value.length + '/500';
            }
        });
        document.querySelectorAll('[data-chat-suggestion]').forEach(function(button) {
            button.addEventListener('click', function() {
                setChatOpen(true);
                submitChat(button.dataset.chatSuggestion);
            });
        });
    }
    if (clearChat && chatBody) {
        clearChat.addEventListener('click', function() {
            if (sendingMessage) return;
            chatBody.innerHTML = initialChatMarkup;
            chatBody.scrollTop = 0;
            chatBody.querySelectorAll('[data-chat-suggestion]').forEach(function(button) {
                button.addEventListener('click', function() {
                    submitChat(button.dataset.chatSuggestion);
                });
            });
            if (chatProviderStatus) {
                chatProviderStatus.innerHTML = '<i></i> Sẵn sàng hỗ trợ';
            }
            if (chatInput) chatInput.focus();
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
document.addEventListener('error', function (event) {
    const image = event.target;
    if (!(image instanceof HTMLImageElement) || image.dataset.fallbackApplied) return;
    if (!image.closest('.product-card, .product-detail, .cart-table')) return;
    image.dataset.fallbackApplied = 'true';
    image.src = (window.contextPath || '') + '/assets/images/caphesua.jpeg';
}, true);
