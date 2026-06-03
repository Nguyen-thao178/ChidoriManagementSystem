<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đơn hàng - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="history-container">
    <h2>📜 Lịch sử đơn hàng</h2>
    <c:choose>
        <c:when test="${empty orderList}">
            <p>Bạn chưa có đơn hàng nào.</p>
        </c:when>
        <c:otherwise>
        	<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
			    <h2>📜 Lịch sử đơn hàng</h2>
			    <a href="${pageContext.request.contextPath}/export-history" class="btn-primary" style="background: #4caf50;">📄 Xuất PDF</a>
			</div>
            <table class="cart-table">
                <tr><th>Mã đơn</th><th>Ngày đặt</th><th>Tổng tiền</th><th>Trạng thái</th></tr>
                <c:forEach var="order" items="${orderList}">
                    <tr><td>#${order.id}</td>
                        <td><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                        <td><fmt:formatNumber value="${order.totalAmount}" type="number"/>₫</td>
                        <td>${order.status}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>