package com.cafe.dao;

import com.cafe.model.CartItem;
import com.cafe.model.Order;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int createOrder(int userId, List<CartItem> cart, double total) throws SQLException {
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetail = null;
        PreparedStatement psUpdateProduct = null;
        ResultSet generatedKeys = null;
        int orderId = -1;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Kiểm tra tồn kho
            for (CartItem item : cart) {
                if (!checkStock(conn, item.getProduct().getId(), item.getQuantity())) {
                    throw new SQLException("Sản phẩm " + item.getProduct().getName() + " không đủ hàng.");
                }
            }

            String sqlOrder = "INSERT INTO orders (user_id, total_amount, status) VALUES (?, ?, 'completed')";
            psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, userId);
            psOrder.setDouble(2, total);
            psOrder.executeUpdate();

            generatedKeys = psOrder.getGeneratedKeys();
            if (generatedKeys.next()) orderId = generatedKeys.getInt(1);
            else throw new SQLException("Không lấy được order ID.");

            String sqlDetail = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            psDetail = conn.prepareStatement(sqlDetail);
            for (CartItem item : cart) {
                psDetail.setInt(1, orderId);
                psDetail.setInt(2, item.getProduct().getId());
                psDetail.setInt(3, item.getQuantity());
                psDetail.setDouble(4, item.getDiscountedPrice()); // giá đã khuyến mãi
                psDetail.addBatch();
            }
            psDetail.executeBatch();

            String sqlUpdateProduct = "UPDATE products SET sold_count = sold_count + ?, stock = stock - ? WHERE id = ?";
            psUpdateProduct = conn.prepareStatement(sqlUpdateProduct);
            for (CartItem item : cart) {
                psUpdateProduct.setInt(1, item.getQuantity());
                psUpdateProduct.setInt(2, item.getQuantity());
                psUpdateProduct.setInt(3, item.getProduct().getId());
                psUpdateProduct.addBatch();
            }
            psUpdateProduct.executeBatch();

            conn.commit();
            return orderId;
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (psOrder != null) psOrder.close();
            if (psDetail != null) psDetail.close();
            if (psUpdateProduct != null) psUpdateProduct.close();
            if (generatedKeys != null) generatedKeys.close();
            if (conn != null) conn.close();
        }
    }

    private boolean checkStock(Connection conn, int productId, int requestedQuantity) throws SQLException {
        String sql = "SELECT stock FROM products WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("stock") >= requestedQuantity;
            return false;
        }
    }

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setOrderDate(rs.getTimestamp("order_date"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("status"));
                orders.add(o);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return orders;
    }
}