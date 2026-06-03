package com.cafe.servlet;

import com.cafe.dao.ProductDAO;
import com.cafe.model.Product;
import com.cafe.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/products")
public class ProductManagementServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        String action = req.getParameter("action");
        if ("edit".equals(action) || "create".equals(action)) {
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Product p = productDAO.getById(id);
                req.setAttribute("product", p);
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/product_form.jsp").forward(req, resp);
        } else {
            List<Product> products = productDAO.getAllProducts();
            req.setAttribute("products", products);
            req.getRequestDispatcher("/WEB-INF/views/admin/product_list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            productDAO.deleteProduct(id);
        } else {
            int id = req.getParameter("id") != null && !req.getParameter("id").isEmpty() ? Integer.parseInt(req.getParameter("id")) : 0;
            String name = req.getParameter("name");
            double price = Double.parseDouble(req.getParameter("price"));
            String description = req.getParameter("description");
            int stock = Integer.parseInt(req.getParameter("stock"));
            int soldCount = Integer.parseInt(req.getParameter("soldCount"));
            String imageUrl = req.getParameter("imageUrl");
            String category = req.getParameter("category");

            Product p = new Product(id, name, price, description, stock, soldCount, imageUrl, category);
            if (id == 0) {
                productDAO.addProduct(p);
            } else {
                productDAO.updateProduct(p);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private boolean isAdmin(HttpServletRequest req) {
        User user = (User) req.getSession().getAttribute("user");
        return user != null && "admin".equals(user.getRole());
    }
}