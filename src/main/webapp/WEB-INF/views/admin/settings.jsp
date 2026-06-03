<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài đặt hệ thống - Chidori Coffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .settings-container {
            max-width: 700px;
            margin: 2rem auto;
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 2rem;
            border: 1px solid var(--border);
        }
        .settings-container h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            border-left: none;
        }
        .settings-form {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        .setting-item {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .setting-item label {
            font-weight: 600;
            color: var(--orange);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .setting-item .key-name {
            text-transform: uppercase;
            font-size: 0.85rem;
            background: #2a2a2a;
            padding: 0.2rem 0.6rem;
            border-radius: 20px;
        }
        .setting-item input {
            padding: 0.8rem;
            background: #2a2a2a;
            border: 1px solid var(--border);
            border-radius: 12px;
            color: white;
            font-size: 1rem;
            transition: 0.2s;
        }
        .setting-item input:focus {
            outline: none;
            border-color: var(--orange);
            box-shadow: 0 0 5px rgba(255,87,34,0.5);
        }
        .setting-item .description {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }
        .save-btn {
            background: var(--orange);
            color: white;
            border: none;
            padding: 0.8rem;
            border-radius: 40px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: var(--transition);
            margin-top: 1rem;
        }
        .save-btn:hover {
            background: var(--red);
            transform: translateY(-2px);
        }
        .message {
            margin-top: 1rem;
            padding: 0.8rem;
            border-radius: 8px;
            text-align: center;
            display: none;
        }
        .message.success {
            background: #4caf5020;
            border-left: 4px solid #4caf50;
            color: #8bc34a;
        }
        .message.error {
            background: #d32f2f20;
            border-left: 4px solid var(--red);
            color: #ff8a8a;
        }
        @media (max-width: 768px) {
            .settings-container {
                margin: 1rem;
                padding: 1.5rem;
            }
        }
    </style>
    <script>
        function showMessage(msg, isSuccess) {
            const msgDiv = document.getElementById('formMessage');
            msgDiv.textContent = msg;
            msgDiv.className = 'message ' + (isSuccess ? 'success' : 'error');
            msgDiv.style.display = 'block';
            setTimeout(() => {
                msgDiv.style.display = 'none';
            }, 3000);
        }
    </script>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="settings-container">
    <h2>⚙️ Cài đặt hệ thống</h2>

    <c:if test="${not empty param.success}">
        <div class="message success" style="display: block;">Cập nhật thành công!</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="message error" style="display: block;">Cập nhật thất bại, vui lòng thử lại.</div>
    </c:if>

    <form id="settingsForm" class="settings-form" action="${pageContext.request.contextPath}/admin/settings" method="post">
        <c:forEach var="s" items="${settings}">
            <div class="setting-item">
                <label>
                    <span>${s.key}</span>
                    <span class="key-name">${s.key}</span>
                </label>
                <input type="hidden" name="key" value="${s.key}">
                <input type="text" name="value" value="${s.value}" required>
                <div class="description">${s.description}</div>
            </div>
        </c:forEach>
        <button type="submit" class="save-btn">💾 Lưu cài đặt</button>
    </form>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>