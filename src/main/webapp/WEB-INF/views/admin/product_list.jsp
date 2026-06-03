<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý sản phẩm - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
<div class="main-content" style="padding: 2rem;">
    <h2>📦 Quản lý menu sản phẩm</h2>
    <div style="margin-bottom: 1rem;">
        <a href="${pageContext.request.contextPath}/admin/products?action=create" class="btn-primary">➕ Thêm sản phẩm mới</a>
    </div>
    <table class="cart-table" style="width:100%;">
        <thead>
            <tr>
                <th>ID</th>
                <th>Hình ảnh</th>
                <th>Tên sản phẩm</th>
                <th>Danh mục</th>
                <th>Giá (VNĐ)</th>
                <th>Tồn kho</th>
                <th>Đã bán</th>
                <th>Hành động</th>
             </tr>
        </thead>
        <tbody>
            <c:forEach var="p" items="${products}">
                <tr>
                    <td>${p.id}</td>
                    <td><img src="${p.imageUrl}" style="width: 50px; height: 50px; object-fit: cover;"></td>
                    <td>${p.name}</td>
                    <td>${p.category}</td>
                    <td><fmt:formatNumber value="${p.price}" type="number"/>₫</td>
                    <td>${p.stock}</td>
                    <td>${p.soldCount}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.id}">✏️ Sửa</a> |
                        <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.id}" onclick="return confirm('Xóa sản phẩm này?')">🗑️ Xóa</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>