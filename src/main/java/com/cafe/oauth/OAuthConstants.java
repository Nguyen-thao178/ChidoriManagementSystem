package com.cafe.oauth;

public class OAuthConstants {
    // Google
    public static final String GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID";
    public static final String GOOGLE_CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET";
    public static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";
    public static final String GOOGLE_REDIRECT_URI = "http://localhost:8080/ChidoriManagementSystem/oauth-callback?provider=google";

    // Facebook
    public static final String FACEBOOK_CLIENT_ID = "YOUR_FACEBOOK_CLIENT_ID";
    public static final String FACEBOOK_CLIENT_SECRET = "YOUR_FACEBOOK_CLIENT_SECRET";
    public static final String FACEBOOK_AUTH_URL = "https://www.facebook.com/v18.0/dialog/oauth";
    public static final String FACEBOOK_TOKEN_URL = "https://graph.facebook.com/v18.0/oauth/access_token";
    public static final String FACEBOOK_USERINFO_URL = "https://graph.facebook.com/v18.0/me";
    public static final String FACEBOOK_REDIRECT_URI = "http://localhost:8080/ChidoriManagementSystem/oauth-callback?provider=facebook";

    // GitHub
    public static final String GITHUB_CLIENT_ID = "YOUR_GITHUB_CLIENT_ID";
    public static final String GITHUB_CLIENT_SECRET = "YOUR_GITHUB_CLIENT_SECRET";
    public static final String GITHUB_AUTH_URL = "https://github.com/login/oauth/authorize";
    public static final String GITHUB_TOKEN_URL = "https://github.com/login/oauth/access_token";
    public static final String GITHUB_USERINFO_URL = "https://api.github.com/user";
    public static final String GITHUB_REDIRECT_URI = "http://localhost:8080/ChidoriManagementSystem/oauth-callback?provider=github";
}