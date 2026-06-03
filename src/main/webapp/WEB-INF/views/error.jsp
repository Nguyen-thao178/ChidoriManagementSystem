<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lỗi - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="form-container">
    <h2>⚠️ Đã xảy ra lỗi</h2>
    <p>Rất tiếc, hệ thống gặp sự cố. Vui lòng quay lại sau.</p>
    <p><a href="${pageContext.request.contextPath}/home" class="btn">Về trang chủ</a></p>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>