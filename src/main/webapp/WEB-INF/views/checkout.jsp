<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="checkout-container">
    <h2>💳 Thanh toán</h2>
    <c:if test="${empty sessionScope.cart}">
        <p>Giỏ hàng trống. <a href="${pageContext.request.contextPath}/menu">Mua thêm</a></p>
    </c:if>
    <c:if test="${not empty sessionScope.cart}">
        <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
            <!-- Bên trái: thông tin khách hàng và chi tiết đơn hàng -->
            <div style="flex: 1;">
                <h3>Thông tin khách hàng</h3>
                <p>Họ tên: ${sessionScope.user.fullname}</p>
                <p>Email: ${sessionScope.user.email}</p>

                <h3>Chi tiết đơn hàng</h3>
                <table class="cart-table">
                    <thead>
                        <tr><th>Sản phẩm</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr>
                    </thead>
                    <tbody>
                        <c:set var="total" value="0" />
                        <c:forEach var="item" items="${sessionScope.cart}">
                            <tr>
                                <td>${item.product.name}</td>
                                <td>${item.quantity}</td>
                                <td><fmt:formatNumber value="${item.discountedPrice}" type="number"/>₫</td>
                                <td><fmt:formatNumber value="${item.discountedPrice * item.quantity}" type="number"/>₫</td>
                            </tr>
                            <c:set var="total" value="${total + item.discountedPrice * item.quantity}" />
                        </c:forEach>
                    </tbody>
                    <tfoot>
                        <tr class="total-row">
                            <td colspan="3"><strong>Tổng cộng:</strong></td>
                            <td><strong><fmt:formatNumber value="${total}" type="number"/>₫</strong></td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <!-- Bên phải: QR và nút xác nhận -->
            <div style="flex: 0 0 320px; text-align: center; background: var(--card-bg); padding: 1.5rem; border-radius: 20px;">
                <h3>📱 Quét mã QR để thanh toán</h3>
                <img src="${pageContext.request.contextPath}/assets/images/qr.png"
                     alt="QR Code"
                     style="width: 200px; margin: 1rem auto; display: block; border-radius: 12px;">
                <p><small>Chuyển khoản theo số tiền <strong><fmt:formatNumber value="${total}" type="number"/>₫</strong></small></p>
                <button id="confirmPaymentBtn" class="btn-primary" style="width: 100%; margin-top: 1rem;">✅ Xác nhận đã thanh toán</button>
                <div id="paymentMessage" style="margin-top: 1rem; font-size: 0.9rem;"></div>
            </div>
        </div>
    </c:if>
</div>

<script>
    document.getElementById('confirmPaymentBtn')?.addEventListener('click', function() {
        const btn = this;
        const msgDiv = document.getElementById('paymentMessage');
        btn.disabled = true;
        btn.textContent = 'Đang xử lý...';

        fetch('${pageContext.request.contextPath}/checkout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                msgDiv.innerHTML = '<span style="color: #4caf50;">✅ ' + data.message + '</span>';
                setTimeout(() => {
                    window.location.href = '${pageContext.request.contextPath}/history';
                }, 1500);
            } else {
                msgDiv.innerHTML = '<span style="color: #f44336;">❌ ' + data.message + '</span>';
                setTimeout(() => {
                    window.location.href = '${pageContext.request.contextPath}/menu';
                }, 1500);
            }
        })
        .catch(error => {
            msgDiv.innerHTML = '<span style="color: #f44336;">❌ Lỗi kết nối, vui lòng thử lại.</span>';
            btn.disabled = false;
            btn.textContent = '✅ Xác nhận đã thanh toán';
        });
    });
</script>
<%@ include file="footer.jsp" %>
</body>
</html>