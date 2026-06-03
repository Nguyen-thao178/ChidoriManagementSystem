<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<script>window.contextPath = "${pageContext.request.contextPath}";</script>
<header>
    <div class="top-bar">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/home">☕ Chidori Coffee</a>
        </div>
        <form class="search-form" action="${pageContext.request.contextPath}/search" method="get">
            <input type="text" name="keyword" placeholder="Tìm món, thức uống..." required>
            <button type="submit">🔍</button>
        </form>
        <div class="user-actions">
            <c:if test="${not empty sessionScope.user}">
                <span>🧑‍💼 ${sessionScope.user.fullname} (${sessionScope.user.role})</span>
                <a href="${pageContext.request.contextPath}/cart">🛒 Giỏ 
                    <c:if test="${not empty sessionScope.cart}">
                        (${sessionScope.cart.size()})
                    </c:if>
                </a>
                <a href="${pageContext.request.contextPath}/history">📜 Lịch sử</a>
                <a href="${pageContext.request.contextPath}/loyalty">🎖️ Điểm thưởng</a>
                <a href="${pageContext.request.contextPath}/logout">🚪 Đăng xuất</a>
            </c:if>
        </div>
    </div>
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/home">🏠 Trang chủ</a>
        <a href="${pageContext.request.contextPath}/menu">📋 Menu</a>
        <a href="${pageContext.request.contextPath}/promotion">🎁 Khuyến mãi</a>
        <a href="${pageContext.request.contextPath}/contact">📞 Liên hệ</a>
        <c:if test="${sessionScope.user.role == 'admin'}">
            <a href="${pageContext.request.contextPath}/admin/users">👥 Quản lý nhân viên</a>
            <a href="${pageContext.request.contextPath}/admin/products">📦 Quản lý menu</a>
            <a href="${pageContext.request.contextPath}/admin/report">📊 Báo cáo</a>
            <a href="${pageContext.request.contextPath}/admin/settings">⚙️ Cài đặt</a>
            <a href="${pageContext.request.contextPath}/register-member">➕ Đăng ký thành viên</a>
        </c:if>
        <c:if test="${sessionScope.user.role == 'manager'}">
            <a href="${pageContext.request.contextPath}/admin/report">📊 Báo cáo</a>
        </c:if>
    </nav>
    <div class="breadcrumb">
        <c:set var="uri" value="${pageContext.request.requestURI}"/>
        <a href="${pageContext.request.contextPath}/home">Trang chủ</a> &gt;
        <c:choose>
            <c:when test="${uri.contains('/menu')}">Menu</c:when>
            <c:when test="${uri.contains('/cart')}">Giỏ hàng</c:when>
            <c:when test="${uri.contains('/checkout')}">Thanh toán</c:when>
            <c:when test="${uri.contains('/history')}">Lịch sử đơn</c:when>
            <c:when test="${uri.contains('/promotion')}">Khuyến mãi</c:when>
            <c:when test="${uri.contains('/contact')}">Liên hệ</c:when>
            <c:when test="${uri.contains('/loyalty')}">Điểm thưởng</c:when>
            <c:when test="${uri.contains('/admin')}">Quản trị</c:when>
            <c:otherwise>Trang hiện tại</c:otherwise>
        </c:choose>
    </div>
</header>