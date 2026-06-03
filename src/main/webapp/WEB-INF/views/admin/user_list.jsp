<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quản lý nhân viên</title>
</head>
<body>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<h2>Quản lý nhân viên</h2>
<a href="${pageContext.request.contextPath}/admin/users?action=create" class="btn-primary">+ Thêm mới</a>
<table border="1" class="cart-table">
    <tr><th>ID</th><th>Username</th><th>Họ tên</th><th>Email</th><th>Role</th><th>Hành động</th></tr>
    <c:forEach var="u" items="${users}">
        <tr>
            <td>${u.id}</td><td>${u.username}</td><td>${u.fullname}</td><td>${u.email}</td><td>${u.role}</td>
            <td><a href="?action=edit&id=${u.id}">Sửa</a> | <a href="?action=delete&id=${u.id}" onclick="return confirm('Xóa?')">Xóa</a></td>
        </tr>
    </c:forEach>
</table>
</body>
</html>