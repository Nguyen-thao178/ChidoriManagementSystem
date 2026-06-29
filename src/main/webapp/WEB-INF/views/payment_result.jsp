<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kết quả thanh toán - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="form-container">
    <c:choose>
        <c:when test="${paymentStatus == 'success'}">
            <h2>✅ Thanh toán thành công!</h2>
            <p>Cảm ơn bạn đã mua hàng. Đơn hàng đã được ghi nhận.</p>
            <a href="${pageContext.request.contextPath}/history" class="btn-primary">Xem lịch sử</a>
        </c:when>
        <c:when test="${paymentStatus == 'failed'}">
            <h2>❌ Thanh toán thất bại</h2>
            <p>${message}</p>
            <a href="${pageContext.request.contextPath}/cart" class="btn">Quay lại giỏ hàng</a>
        </c:when>
        <c:otherwise>
            <h2>⚠️ Lỗi xử lý</h2>
            <p>${message}</p>
            <a href="${pageContext.request.contextPath}/cart" class="btn">Thử lại</a>
        </c:otherwise>
    </c:choose>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>