<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chidori Coffee - Trang chủ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="container">
    <%@ include file="sidebar.jsp" %>
    <main class="main-content">
        <div class="slider-container">
            <div class="slide active"><img src="https://picsum.photos/id/104/1200/400" alt="Slider 1"></div>
            <div class="slide"><img src="https://picsum.photos/id/106/1200/400" alt="Slider 2"></div>
            <div class="slide"><img src="https://picsum.photos/id/107/1200/400" alt="Slider 3"></div>
            <button class="prev">&#10094;</button>
            <button class="next">&#10095;</button>
        </div>
        <h2>Sản phẩm nổi bật</h2>
        <div class="product-grid">
            <c:forEach var="p" items="${featuredProducts}">
                <div class="product-card">
                    <img src="${p.imageUrl}" alt="${p.name}">
                    <div class="product-info">
                        <h3>${p.name}</h3>
                        <p class="price">
                            <c:if test="${maxDiscount > 0}">
                                <span style="text-decoration: line-through; font-size:0.9rem; color:gray;">
                                    <fmt:formatNumber value="${p.price}" type="number"/>₫
                                </span><br/>
                            </c:if>
                            <fmt:formatNumber value="${p.price * (100 - maxDiscount) / 100}" type="number"/>₫
                        </p>
                        <p>📦 Đã bán: ${p.soldCount} | 📊 Còn: ${p.stock}</p>
                        <a href="${pageContext.request.contextPath}/add-to-cart?id=${p.id}" class="btn btn-add-cart">➕ Thêm giỏ</a>
                        <a href="${pageContext.request.contextPath}/product?id=${p.id}" class="btn-outline">🔍 Chi tiết</a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </main>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>