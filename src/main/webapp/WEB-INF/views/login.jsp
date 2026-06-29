<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập nhân viên - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .oauth-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 1rem;
            flex-wrap: wrap;
        }
        .oauth-btn {
            padding: 0.5rem 1rem;
            border-radius: 40px;
            text-decoration: none;
            color: white;
            font-weight: bold;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .oauth-google { background: #db4437; }
        .oauth-facebook { background: #4267b2; }
        .oauth-github { background: #333; }
    </style>
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
    <div class="oauth-buttons">
        <a href="${pageContext.request.contextPath}/oauth-login?provider=google" class="oauth-btn oauth-google">🔑 Google</a>
        <a href="${pageContext.request.contextPath}/oauth-login?provider=facebook" class="oauth-btn oauth-facebook">📘 Facebook</a>
        <a href="${pageContext.request.contextPath}/oauth-login?provider=github" class="oauth-btn oauth-github">🐙 GitHub</a>
    </div>
    <p style="margin-top:1rem; font-size:0.9rem;">* Liên hệ quản trị để được cấp tài khoản</p>
</div>
</body>
</html>