<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="cart-container">
    <h2>🛒 Giỏ hàng của bạn</h2>
    <c:choose>
        <c:when test="${empty sessionScope.cart or sessionScope.cart.size() == 0}">
            <p>Giỏ hàng trống. <a href="${pageContext.request.contextPath}/menu">Mua sắm ngay</a></p>
        </c:when>
        <c:otherwise>
            <table class="cart-table">
                <tr><th>Sản phẩm</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th><th></th></tr>
                <c:set var="total" value="0" />
                <c:forEach var="item" items="${sessionScope.cart}">
                    <tr>
                        <td>${item.product.name}</td>
                        <td><fmt:formatNumber value="${item.discountedPrice}" type="number"/>₫</td>
                        <td>
                            <form action="${pageContext.request.contextPath}/update-cart" method="post" style="display:inline;">
                                <input type="hidden" name="id" value="${item.product.id}">
                                <input type="number" name="quantity" value="${item.quantity}" min="1" max="${item.product.stock}" style="width:70px;">
                                <button type="submit" class="btn-outline" style="padding:0.2rem 0.5rem;">Cập nhật</button>
                            </form>
                         </td>
                        <td><fmt:formatNumber value="${item.discountedPrice * item.quantity}" type="number"/>₫</td>
                        <td><a href="${pageContext.request.contextPath}/remove-cart?id=${item.product.id}" class="remove-btn">❌ Xóa</a></td>
                        <c:set var="total" value="${total + item.discountedPrice * item.quantity}" />
                    </tr>
                </c:forEach>
                <tr class="total-row"><td colspan="3"><strong>Tổng cộng:</strong></td>
                <td><strong><fmt:formatNumber value="${total}" type="number"/>₫</strong></td><td></td></tr>
            </table>
            <div class="cart-actions" style="margin-top:1rem;">
                <a href="${pageContext.request.contextPath}/menu" class="btn">Tiếp tục mua</a>
                <a href="${pageContext.request.contextPath}/checkout" class="btn-primary">Thanh toán</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>