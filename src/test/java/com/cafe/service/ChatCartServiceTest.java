package com.cafe.service;

import com.cafe.dao.ProductDAO;
import com.cafe.dao.PromotionDAO;
import com.cafe.dao.PromotionItemDAO;
import com.cafe.model.Product;
import com.cafe.model.User;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ChatCartServiceTest {
    private ChatCartService service;
    private HttpSession session;

    @BeforeEach
    void setUp() {
        Product coffee = new Product(1, "Cà phê sữa", 25_000, "", 5, 0,
                "/assets/images/coffee.jpg", "Cà phê", "8938501434012");
        Product tea = new Product(2, "Trà đào", 45_000, "", 5, 0,
                "/assets/images/tea.jpg", "Trà", "8938501434036");
        FakeProductDAO productDAO = new FakeProductDAO(coffee, tea);
        CartService cartService = new CartService(productDAO,
                new EmptyPromotionDAO(), new EmptyPromotionItemDAO());
        service = new ChatCartService(productDAO, cartService);
        session = createSession();
    }

    @Test
    void customerCanAddAccentlessProductAndQuantityThroughChat() {
        ChatCartService.Result result = service.handle(
                "Thêm 2 ly ca phe sua vào giỏ", user("customer"), session);

        assertTrue(result.handled());
        assertTrue(result.success());
        assertEquals("Cà phê sữa", result.product().getName());
        assertEquals(2, result.addedQuantity());
        assertEquals(2, result.productQuantity());
        assertEquals(2, result.cartQuantity());
    }

    @Test
    void ordinaryMenuQuestionIsNotMistakenForCartCommand() {
        ChatCartService.Result result = service.handle(
                "Bên mình có cà phê gì?", user("customer"), session);

        assertFalse(result.handled());
    }

    @Test
    void explicitCommandWithUnknownProductReturnsHelpfulMessage() {
        ChatCartService.Result result = service.handle(
                "Thêm matcha vào giỏ", user("customer"), session);

        assertTrue(result.handled());
        assertFalse(result.success());
        assertTrue(result.message().contains("chưa nhận ra tên món"));
    }

    @Test
    void managerCannotCreateCartThroughChat() {
        ChatCartService.Result result = service.handle(
                "Thêm trà đào vào giỏ", user("manager"), session);

        assertTrue(result.handled());
        assertFalse(result.success());
        assertTrue(result.message().contains("không có chức năng giỏ hàng"));
    }

    @Test
    void understandsNaturalPoliteOrderPhraseFromCustomer() {
        ChatCartService.Result result = service.handle(
                "Cho tôi đặt 1 ly cà phê sữa", user("customer"), session);

        assertTrue(result.handled());
        assertTrue(result.success());
        assertEquals("Cà phê sữa", result.product().getName());
        assertEquals(1, result.addedQuantity());
    }

    @Test
    void understandsShortOrderPhraseWithQuantity() {
        ChatCartService.Result result = service.handle(
                "Đặt 2 ly trà đào", user("customer"), session);

        assertTrue(result.handled());
        assertTrue(result.success());
        assertEquals("Trà đào", result.product().getName());
        assertEquals(2, result.addedQuantity());
    }

    private User user(String role) {
        User user = new User();
        user.setRole(role);
        return user;
    }

    private HttpSession createSession() {
        Map<String, Object> attributes = new HashMap<>();
        return (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(), new Class<?>[]{HttpSession.class},
                (proxy, method, args) -> switch (method.getName()) {
                    case "getAttribute" -> attributes.get((String) args[0]);
                    case "setAttribute" -> {
                        attributes.put((String) args[0], args[1]);
                        yield null;
                    }
                    case "removeAttribute" -> {
                        attributes.remove((String) args[0]);
                        yield null;
                    }
                    case "getId" -> "chat-cart-test";
                    case "isNew" -> false;
                    case "getCreationTime", "getLastAccessedTime" -> 0L;
                    case "getMaxInactiveInterval" -> 0;
                    default -> null;
                });
    }

    private static class FakeProductDAO extends ProductDAO {
        private final List<Product> products;

        FakeProductDAO(Product... products) {
            this.products = List.of(products);
        }

        @Override
        public List<Product> getAllProducts() {
            return products;
        }

        @Override
        public Product getById(int id) {
            return products.stream().filter(product -> product.getId() == id)
                    .findFirst().orElse(null);
        }
    }

    private static class EmptyPromotionDAO extends PromotionDAO {
        @Override
        public List<com.cafe.model.Promotion> getActivePromotions() {
            return List.of();
        }
    }

    private static class EmptyPromotionItemDAO extends PromotionItemDAO {
        @Override
        public com.cafe.model.PromotionItem getByProductId(int productId) {
            return null;
        }
    }
}
