package com.cafe.service;

import com.cafe.dao.ProductDAO;
import com.cafe.dao.PromotionDAO;
import com.cafe.dao.PromotionItemDAO;
import com.cafe.model.CartItem;
import com.cafe.model.Product;
import com.cafe.model.Promotion;
import com.cafe.model.PromotionItem;
import com.cafe.service.CartService.AddResult;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CartServiceTest {
    private static final String BARCODE = "8938501434012";

    private Product product;
    private FakeProductDAO productDAO;
    private FakePromotionDAO promotionDAO;
    private FakePromotionItemDAO promotionItemDAO;
    private CartService cartService;
    private HttpSession session;

    @BeforeEach
    void setUp() {
        product = new Product(
                1,
                "Cà phê sữa",
                35_000,
                "Cà phê rang xay với sữa đặc",
                2,
                0,
                null,
                "Coffee",
                BARCODE
        );
        productDAO = new FakeProductDAO(product);
        promotionDAO = new FakePromotionDAO();
        promotionItemDAO = new FakePromotionItemDAO();
        cartService = new CartService(productDAO, promotionDAO, promotionItemDAO);
        session = createSession();
    }

    @Test
    void scanKnownBarcodeAddsProductToCart() {
        AddResult result = cartService.addByBarcode(session, BARCODE);

        assertTrue(result.isSuccess());
        assertEquals("ADDED", result.getCode());
        assertEquals(1, result.getProductQuantity());
        assertEquals(1, result.getCartQuantity());

        List<CartItem> cart = getCart();
        assertEquals(1, cart.size());
        assertEquals(product.getId(), cart.get(0).getProduct().getId());
        assertEquals(1, cart.get(0).getQuantity());
        assertEquals(35_000, cart.get(0).getDiscountedPrice());
    }

    @Test
    void ean13AimPrefixIsRemovedBeforeLookup() {
        AddResult result = cartService.addByBarcode(session, "]E0" + BARCODE + "\r\n");

        assertTrue(result.isSuccess());
        assertEquals(BARCODE, result.getProduct().getBarcode());
        assertEquals(product.getId(), getCart().get(0).getProduct().getId());
    }

    @Test
    void eachBarcodeAddsOnlyItsMatchingProduct() {
        Product tea = new Product(
                2,
                "Trà đào",
                45_000,
                "Trà đào thanh mát",
                5,
                0,
                null,
                "Tea",
                "8938501434036"
        );
        productDAO = new FakeProductDAO(product, tea);
        cartService = new CartService(productDAO, promotionDAO, promotionItemDAO);

        AddResult result = cartService.addByBarcode(session, tea.getBarcode());

        assertTrue(result.isSuccess());
        assertEquals(tea.getId(), result.getProduct().getId());
        assertEquals(tea.getBarcode(), result.getProduct().getBarcode());
        assertEquals(1, getCart().size());
        assertEquals("Trà đào", getCart().get(0).getProduct().getName());
        assertEquals(45_000, getCart().get(0).getDiscountedPrice());
    }

    @Test
    void repeatedScanIncreasesQuantity() {
        cartService.addByBarcode(session, BARCODE);
        AddResult result = cartService.addByBarcode(session, BARCODE);

        assertTrue(result.isSuccess());
        assertEquals(2, result.getProductQuantity());
        assertEquals(2, result.getCartQuantity());
        assertEquals(2, getCart().get(0).getQuantity());
    }

    @Test
    void scanCannotExceedAvailableStock() {
        cartService.addByBarcode(session, BARCODE);
        cartService.addByBarcode(session, BARCODE);
        AddResult result = cartService.addByBarcode(session, BARCODE);

        assertFalse(result.isSuccess());
        assertEquals("STOCK_LIMIT", result.getCode());
        assertEquals(2, getCart().get(0).getQuantity());
    }

    @Test
    void unknownBarcodeDoesNotCreateCart() {
        AddResult result = cartService.addByBarcode(session, "4006381333931");

        assertFalse(result.isSuccess());
        assertEquals("NOT_FOUND", result.getCode());
        assertTrue(getCart().isEmpty());
    }

    @Test
    void invalidEan13CheckDigitIsRejected() {
        AddResult result = cartService.addByBarcode(session, "8938501434013");

        assertFalse(result.isSuccess());
        assertEquals("INVALID_BARCODE", result.getCode());
        assertTrue(getCart().isEmpty());
    }

    @Test
    void emptyBarcodeIsRejected() {
        AddResult result = cartService.addByBarcode(session, "   ");

        assertFalse(result.isSuccess());
        assertEquals("EMPTY_BARCODE", result.getCode());
        assertTrue(getCart().isEmpty());
    }

    @Test
    void productPromotionIsAppliedWhenScanned() {
        PromotionItem promotion = new PromotionItem();
        promotion.setProductId(product.getId());
        promotion.setDiscountPercent(20);
        promotionItemDAO.promotionItem = promotion;

        AddResult result = cartService.addByBarcode(session, BARCODE);

        assertTrue(result.isSuccess());
        assertEquals(28_000, getCart().get(0).getDiscountedPrice());
    }

    @SuppressWarnings("unchecked")
    private List<CartItem> getCart() {
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        return cart == null ? new ArrayList<>() : cart;
    }

    private HttpSession createSession() {
        Map<String, Object> attributes = new HashMap<>();
        return (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(),
                new Class<?>[]{HttpSession.class},
                (proxy, method, args) -> {
                    switch (method.getName()) {
                        case "getAttribute":
                            return attributes.get((String) args[0]);
                        case "setAttribute":
                            attributes.put((String) args[0], args[1]);
                            return null;
                        case "removeAttribute":
                            attributes.remove((String) args[0]);
                            return null;
                        case "getId":
                            return "test-session";
                        case "isNew":
                            return false;
                        case "getCreationTime":
                        case "getLastAccessedTime":
                            return 0L;
                        case "getMaxInactiveInterval":
                            return 0;
                        default:
                            return null;
                    }
                }
        );
    }

    private static class FakeProductDAO extends ProductDAO {
        private final List<Product> products;

        FakeProductDAO(Product... products) {
            this.products = List.of(products);
        }

        @Override
        public Product getById(int id) {
            return products.stream()
                    .filter(product -> product.getId() == id)
                    .findFirst()
                    .orElse(null);
        }

        @Override
        public Product getByBarcode(String barcode) {
            if (barcode == null) {
                return null;
            }
            return products.stream()
                    .filter(product -> product.getBarcode().equals(barcode.trim()))
                    .findFirst()
                    .orElse(null);
        }
    }

    private static class FakePromotionDAO extends PromotionDAO {
        @Override
        public List<Promotion> getActivePromotions() {
            return List.of();
        }
    }

    private static class FakePromotionItemDAO extends PromotionItemDAO {
        private PromotionItem promotionItem;

        @Override
        public PromotionItem getByProductId(int productId) {
            return promotionItem != null && promotionItem.getProductId() == productId
                    ? promotionItem
                    : null;
        }
    }
}
