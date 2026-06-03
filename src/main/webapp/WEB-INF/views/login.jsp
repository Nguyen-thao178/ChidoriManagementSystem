<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập nhân viên - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="form-container">
    <h2>🔐 Đăng nhập hệ thống</h2>
    <c:if test="${not empty error}">
        <div class="error-msg">${error}</div>
    </c:if>
    <form action="${pageContext.request.contextPath}/login" method="post">
        <input type="text" name="username" placeholder="Tên đăng nhập" required>
        <input type="password" name="password" placeholder="Mật khẩu" required>
        <button type="submit" class="btn-primary">Đăng nhập</button>
    </form>
    <p style="margin-top:1rem; font-size:0.9rem;">* Liên hệ quản trị để được cấp tài khoản</p>
</div>
</body>
</html>