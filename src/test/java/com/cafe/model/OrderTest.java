package com.cafe.model;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class OrderTest {

    @Test
    void directOrderUsesDirectPaymentTag() {
        Order order = new Order();
        order.setOrderType("direct");
        order.setStatus("completed");

        assertEquals("Thanh toán trực tiếp", order.getTransactionTag());
    }

    @Test
    void expiredDepositUsesNoShowTag() {
        Order order = new Order();
        order.setOrderType("deposit");
        order.setStatus("no_show");
        order.setPickupStatus("no_show");

        assertEquals("Đã cọc nhưng không nhận hàng", order.getTransactionTag());
    }

    @Test
    void collectedDepositUsesPickedUpTag() {
        Order order = new Order();
        order.setOrderType("deposit");
        order.setStatus("picked_up");
        order.setPickupStatus("picked_up");

        assertEquals("Đã cọc và đã nhận hàng", order.getTransactionTag());
    }

    @Test
    void pendingDepositUsesWaitingTag() {
        Order order = new Order();
        order.setOrderType("deposit");
        order.setStatus("deposit_pending");
        order.setPickupStatus("pending");

        assertEquals("Đã cọc - Chờ nhận hàng", order.getTransactionTag());
    }
}
