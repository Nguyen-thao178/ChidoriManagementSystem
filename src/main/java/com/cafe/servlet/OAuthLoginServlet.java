package com.cafe.servlet;

import com.cafe.oauth.OAuthConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/oauth-login")
public class OAuthLoginServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String provider = req.getParameter("provider");
        String authUrl = "";
        if ("google".equals(provider)) {
            authUrl = OAuthConstants.GOOGLE_AUTH_URL + "?client_id=" + OAuthConstants.GOOGLE_CLIENT_ID
                    + "&redirect_uri=" + URLEncoder.encode(OAuthConstants.GOOGLE_REDIRECT_URI, StandardCharsets.UTF_8)
                    + "&response_type=code&scope=email%20profile";
        } else if ("facebook".equals(provider)) {
            authUrl = OAuthConstants.FACEBOOK_AUTH_URL + "?client_id=" + OAuthConstants.FACEBOOK_CLIENT_ID
                    + "&redirect_uri=" + URLEncoder.encode(OAuthConstants.FACEBOOK_REDIRECT_URI, StandardCharsets.UTF_8)
                    + "&scope=email,public_profile";
        } else if ("github".equals(provider)) {
            authUrl = OAuthConstants.GITHUB_AUTH_URL + "?client_id=" + OAuthConstants.GITHUB_CLIENT_ID
                    + "&redirect_uri=" + URLEncoder.encode(OAuthConstants.GITHUB_REDIRECT_URI, StandardCharsets.UTF_8)
                    + "&scope=user:email";
        }
        resp.sendRedirect(authUrl);
    }
}