<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<form method="post">
    <input type="hidden" name="action" value="${user == null ? 'create' : 'update'}">
    <c:if test="${user != null}">
        <input type="hidden" name="id" value="${user.id}">
    </c:if>
    <label>Username:</label><input name="username" value="${user.username}" ${user != null ? 'readonly' : ''}><br>
    <label>Password:</label><input type="password" name="password" placeholder="${user != null ? 'để trống nếu không đổi' : 'bắt buộc'}"><br>
    <label>Fullname:</label><input name="fullname" value="${user.fullname}"><br>
    <label>Email:</label><input name="email" value="${user.email}"><br>
    <label>Role:</label>
    <select name="role">
        <option value="admin" ${user.role == 'admin' ? 'selected' : ''}>Admin</option>
        <option value="manager" ${user.role == 'manager' ? 'selected' : ''}>Manager</option>
        <option value="staff" ${user.role == 'staff' ? 'selected' : ''}>Staff</option>
    </select><br>
    <button type="submit">Lưu</button>
</form>
</body>
</html>