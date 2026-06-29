package com.cafe.filter;

import com.cafe.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();

        // Các URL công khai
        boolean isPublic = uri.startsWith(contextPath + "/login")
                || uri.startsWith(contextPath + "/assets")
                || uri.startsWith(contextPath + "/register-member")
                || uri.startsWith(contextPath + "/oauth-login")
                || uri.startsWith(contextPath + "/oauth-callback")
                || uri.startsWith(contextPath + "/vnpay-pay")
                || uri.startsWith(contextPath + "/vnpay-return")
                || uri.equals(contextPath + "/")
                || uri.equals(contextPath + "/index.jsp");

        if (isPublic) {
            chain.doFilter(req, resp);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Log để debug (có thể xóa sau)
        System.out.println("[AuthFilter] URI: " + uri + ", User: " + user);

        if (user == null) {
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // Kiểm tra role Admin
        if (uri.startsWith(contextPath + "/admin")) {
            if (!"admin".equalsIgnoreCase(user.getRole())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang quản trị.");
                return;
            }
        }

        chain.doFilter(req, resp);
    }
}