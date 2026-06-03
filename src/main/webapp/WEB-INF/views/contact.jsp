<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .contact-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px,1fr)); gap: 1.5rem; margin: 2rem 0; }
        .contact-card { background: var(--card-bg); border-radius: 16px; padding: 1.2rem; border: 1px solid #2a2a2a; }
        .contact-card:hover { border-color: #ff5722; }
        .badge { background: #d32f2f; display: inline-block; padding: 0.2rem 0.8rem; border-radius: 30px; font-size: 0.7rem; margin-bottom: 0.8rem; }
        .contact-card h3 { color: #ff5722; margin-bottom: 0.5rem; }
        .contact-detail p { margin: 0.5rem 0; }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>
<div class="main-content" style="padding: 2rem;">
    <h2>📞 Danh bạ liên hệ</h2>
    <c:if test="${not empty error}">
        <div class="error-msg">${error}</div>
    </c:if>
    <div class="contact-grid">
        <c:forEach var="c" items="${contacts}">
            <div class="contact-card">
                <span class="badge">
                    <c:choose>
                        <c:when test="${c.position == 'owner'}">👑 Chủ quán</c:when>
                        <c:when test="${c.position == 'manager'}">📋 Quản lý</c:when>
                        <c:when test="${c.position == 'employee'}">👨‍🍳 Nhân viên</c:when>
                        <c:when test="${c.position == 'supplier'}">🚚 Nhà cung cấp</c:when>
                        <c:otherwise>${c.position}</c:otherwise>
                    </c:choose>
                </span>
                <h3>${c.name}</h3>
                <div class="contact-detail">
                    <c:if test="${not empty c.phone}"><p>📞 ${c.phone}</p></c:if>
                    <c:if test="${not empty c.email}"><p>✉️ ${c.email}</p></c:if>
                    <c:if test="${not empty c.address}"><p>📍 ${c.address}</p></c:if>
                    <c:if test="${not empty c.notes}"><p><small>${c.notes}</small></p></c:if>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>