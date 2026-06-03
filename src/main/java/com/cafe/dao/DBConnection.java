package com.cafe.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=CafeDB;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";   // thay bằng user SQL Server
    private static final String PASS = "12345"; // mật khẩu của bạn

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}