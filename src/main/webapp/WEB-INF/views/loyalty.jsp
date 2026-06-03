<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<h2>Điểm tích lũy</h2>
<c:if test="${not empty points}">
<p>Điểm hiện tại: ${points.points}</p>
<p>Tổng chi tiêu: ${points.totalSpent} VNĐ</p>
<p>Cập nhật: ${points.updatedAt}</p>
</c:if>
</body>
</html>