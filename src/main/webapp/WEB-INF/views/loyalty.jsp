<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Điểm tích lũy - Chidori Coffee</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="header.jsp" %>
<div class="main-content" style="padding: 2rem;">
    <h2>🏆 Điểm thưởng thành viên</h2>
    <c:choose>
        <c:when test="${empty points}">
            <p>Bạn chưa có điểm tích lũy. Hãy mua sắm để nhận ưu đãi!</p>
        </c:when>
        <c:otherwise>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Điểm hiện tại</h3>
                    <div class="number">${points.points}</div>
                </div>
                <div class="stat-card">
                    <h3>Tổng chi tiêu</h3>
                    <div class="number"><fmt:formatNumber value="${points.totalSpent}" type="number"/>₫</div>
                </div>
                <div class="stat-card">
                    <h3>Cập nhật lần cuối</h3>
                    <div class="number">${points.updatedAt}</div>
                </div>
            </div>
            <p style="margin-top: 1rem;">💡 Mỗi 1.000đ chi tiêu bạn nhận được 1 điểm. Điểm có thể đổi voucher hoặc quà tặng.</p>
        </c:otherwise>
    </c:choose>
</div>
<%@ include file="footer.jsp" %>
</body>
</html>