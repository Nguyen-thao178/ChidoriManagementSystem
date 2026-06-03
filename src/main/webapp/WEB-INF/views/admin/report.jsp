<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo doanh thu - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .report-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .report-header {
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid var(--border);
        }
        .report-header h2 {
            margin-top: 0;
            border-left: none;
            text-align: center;
        }
        .filter-form {
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }
        .filter-form input, .filter-form button {
            padding: 0.6rem 1rem;
            border-radius: 40px;
            border: none;
        }
        .filter-form input {
            background: #2a2a2a;
            color: white;
            border: 1px solid var(--border);
        }
        .filter-form button {
            background: var(--orange);
            color: white;
            cursor: pointer;
            transition: var(--transition);
        }
        .filter-form button:hover {
            background: var(--red);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 1.2rem;
            text-align: center;
            border: 1px solid var(--border);
            transition: var(--transition);
        }
        .stat-card:hover {
            border-color: var(--orange);
            transform: translateY(-4px);
        }
        .stat-card h3 {
            color: var(--orange);
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }
        .stat-card .number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
        }
        .section-title {
            color: var(--orange);
            margin: 1.5rem 0 1rem;
            border-left: 4px solid var(--orange);
            padding-left: 1rem;
        }
        .table-wrapper {
            overflow-x: auto;
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 0.5rem;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th, .data-table td {
            padding: 0.8rem;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }
        .data-table th {
            color: var(--orange);
            font-weight: 600;
        }
        .data-table tr:hover {
            background: #2a2a2a;
        }
        .product-list {
            list-style: none;
            padding: 0;
        }
        .product-list li {
            display: flex;
            justify-content: space-between;
            padding: 0.8rem;
            border-bottom: 1px solid var(--border);
        }
        .product-list li span:first-child {
            font-weight: 500;
        }
        .product-list li span:last-child {
            color: var(--orange);
        }
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .filter-form {
                flex-direction: column;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="report-container">
    <div class="report-header">
        <h2>📊 Báo cáo doanh thu</h2>
        <form method="get" class="filter-form">
            <input type="date" name="date" value="${reportDate}">
            <button type="submit">Xem báo cáo ngày</button>
        </form>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <h3>Doanh thu ngày ${reportDate}</h3>
            <div class="number"><fmt:formatNumber value="${revenue}" type="number"/>₫</div>
        </div>
        <div class="stat-card">
            <h3>Doanh thu tháng ${currentMonth}/${currentYear}</h3>
            <div class="number"><fmt:formatNumber value="${monthlyRevenue}" type="number"/>₫</div>
        </div>
        <div class="stat-card">
            <h3>Tổng số đơn hàng (tháng)</h3>
            <div class="number">${dailyRevenue.size()} ngày</div>
        </div>
    </div>

    <h3 class="section-title">📈 Doanh thu theo ngày trong tháng</h3>
    <div class="table-wrapper">
        <table class="data-table">
            <thead>
                <tr><th>Ngày</th><th>Doanh thu (VNĐ)</th><th>Biểu đồ</th></tr>
            </thead>
            <tbody>
                <c:forEach var="entry" items="${dailyRevenue}">
                    <c:set var="maxRevenue" value="${dailyRevenue.values().stream().max().orElse(1)}"/>
                    <c:set var="percent" value="${entry.value / maxRevenue * 100}"/>
                    <tr>
                        <td>${entry.key}</td>
                        <td><fmt:formatNumber value="${entry.value}" type="number"/>₫</td>
                        <td><div style="background: var(--orange); width: ${percent}%; max-width: 100%; height: 20px; border-radius: 10px;"></div></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <h3 class="section-title">🏆 Top 5 sản phẩm bán chạy nhất</h3>
    <div class="table-wrapper">
        <ul class="product-list">
            <c:forEach var="entry" items="${topProducts}">
                <li><span>${entry.key}</span><span>${entry.value} sản phẩm</span></li>
            </c:forEach>
        </ul>
    </div>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>