package com.cafe.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import com.cafe.model.User;

@WebFilter("/*")
public class AuthFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        // Cho phép login, assets, register-member (không cần đăng nhập)
        if (uri.startsWith(contextPath + "/login") || uri.startsWith(contextPath + "/assets") || uri.startsWith(contextPath + "/register-member")) {
            chain.doFilter(req, res);
            return;
        }
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }
        // Kiểm tra role cho admin/*
        if (uri.startsWith(contextPath + "/admin")) {
            if (!"admin".equals(user.getRole())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập");
                return;
            }
        }
        chain.doFilter(req, res);
    }
}