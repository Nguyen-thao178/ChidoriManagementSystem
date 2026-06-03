package com.cafe.servlet;

import com.cafe.dao.ProductDAO;
import com.cafe.dao.PromotionDAO;
import com.cafe.dao.PromotionItemDAO;
import com.cafe.model.CartItem;
import com.cafe.model.Product;
import com.cafe.model.Promotion;
import com.cafe.model.PromotionItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/add-to-cart")
public class AddToCartServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private PromotionDAO promoDAO = new PromotionDAO();
    private PromotionItemDAO promoItemDAO = new PromotionItemDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/menu");
            return;
        }
        int productId = Integer.parseInt(idStr);
        Product p = productDAO.getById(productId);
        if (p == null || p.getStock() <= 0) {
            resp.sendRedirect(req.getContextPath() + "/menu?error=outofstock");
            return;
        }

        // Kiểm tra khuyến mãi đặc biệt cho sản phẩm này trước
        PromotionItem promoItem = promoItemDAO.getByProductId(productId);
        double finalPrice = p.getPrice();
        if (promoItem != null) {
            finalPrice = p.getPrice() * (100 - promoItem.getDiscountPercent()) / 100.0;
        } else {
            // Nếu không có khuyến mãi item, lấy khuyến mãi chung
            List<Promotion> promotions = promoDAO.getActivePromotions();
            int maxDiscount = promotions.stream().mapToInt(Promotion::getDiscountPercent).max().orElse(0);
            finalPrice = p.getPrice() * (100 - maxDiscount) / 100.0;
        }

        HttpSession session = req.getSession();
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) cart = new ArrayList<>();

        boolean found = false;
        for (CartItem item : cart) {
            if (item.getProduct().getId() == productId) {
                if (item.getQuantity() + 1 <= p.getStock()) {
                    item.setQuantity(item.getQuantity() + 1);
                }
                found = true;
                break;
            }
        }
        if (!found) {
            CartItem newItem = new CartItem(p, 1);
            newItem.setDiscountedPrice(finalPrice);
            cart.add(newItem);
        }
        session.setAttribute("cart", cart);
        resp.sendRedirect(req.getContextPath() + "/menu");
    }
}