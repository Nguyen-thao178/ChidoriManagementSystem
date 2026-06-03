document.addEventListener('DOMContentLoaded', () => {
    // Lấy context path từ thẻ meta hoặc biến toàn cục
    const contextPath = window.contextPath || '';

    // ==================== SLIDER ====================
    let slideIndex = 0;
    const slides = document.querySelectorAll('.slide');
    if (slides.length) {
        slides[0].classList.add('active');
        setInterval(() => {
            slides.forEach(s => s.classList.remove('active'));
            slideIndex = (slideIndex + 1) % slides.length;
            slides[slideIndex].classList.add('active');
        }, 4000);
    }

    const prevBtn = document.querySelector('.prev');
    const nextBtn = document.querySelector('.next');
    if (prevBtn) {
        prevBtn.addEventListener('click', () => {
            slides.forEach(s => s.classList.remove('active'));
            slideIndex = (slideIndex - 1 + slides.length) % slides.length;
            slides[slideIndex].classList.add('active');
        });
    }
    if (nextBtn) {
        nextBtn.addEventListener('click', () => {
            slides.forEach(s => s.classList.remove('active'));
            slideIndex = (slideIndex + 1) % slides.length;
            slides[slideIndex].classList.add('active');
        });
    }

    // ==================== CHATBOT ====================
    const chatIcon = document.getElementById('chatIcon');
    const chatWindow = document.getElementById('chatWindow');
    if (chatIcon) {
        chatIcon.addEventListener('click', () => {
            const isVisible = chatWindow.style.display === 'flex';
            chatWindow.style.display = isVisible ? 'none' : 'flex';
        });
    }

    const sendBtn = document.getElementById('sendChat');
    const chatInput = document.getElementById('chatInput');
    const chatBody = document.getElementById('chatBody');

    function addBotMessage(text) {
        const msgDiv = document.createElement('div');
        msgDiv.innerHTML = `<strong>🤖 Bot:</strong> ${text}`;
        msgDiv.style.marginBottom = '10px';
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function addUserMessage(text) {
        const msgDiv = document.createElement('div');
        msgDiv.innerHTML = `<strong>👤 Bạn:</strong> ${text}`;
        msgDiv.style.marginBottom = '10px';
        chatBody.appendChild(msgDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    if (sendBtn) {
        sendBtn.addEventListener('click', () => {
            const msg = chatInput.value.trim();
            if (msg === '') return;
            addUserMessage(msg);
            chatInput.value = '';
            setTimeout(() => {
                const lower = msg.toLowerCase();
                if (lower.includes('menu') || lower.includes('món')) {
                    addBotMessage(`Mời bạn xem menu: <a href="${contextPath}/menu" style="color:#ff5722;">Tại đây</a>`);
                } else if (lower.includes('giá')) {
                    addBotMessage('Giá từ 25.000đ - 55.000đ. Bạn muốn gọi món gì?');
                } else if (lower.includes('cảm ơn')) {
                    addBotMessage('Rất hân hạnh! ☕');
                } else {
                    addBotMessage('Cảm ơn bạn! Chúng tôi sẽ hỗ trợ bạn sớm nhất.');
                }
            }, 500);
        });
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendBtn.click();
        });
    }

    // ==================== ANIMATION KHI THÊM GIỎ ====================
    const addBtns = document.querySelectorAll('.btn-add-cart');
    addBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const ripple = document.createElement('div');
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
            setTimeout(() => {
                ripple.style.transform = 'translate(30px, -80px)';
                ripple.style.opacity = '0';
            }, 10);
            setTimeout(() => ripple.remove(), 700);
        });
    });

    // ==================== SCROLL REVEAL ====================
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.product-card, .widget, .cart-container, .product-detail').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(el);
    });
});