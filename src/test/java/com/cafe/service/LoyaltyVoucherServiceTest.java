package com.cafe.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class LoyaltyVoucherServiceTest {
    @Test
    void customerCannotRedeemPoints() {
        var quote = LoyaltyVoucherService.quote("customer", 100_000, 50, 100, 1_000);
        assertEquals(0, quote.pointsUsed());
        assertEquals(100_000, quote.netTotal());
    }

    @Test
    void memberDiscountIsCappedAtEightyPercent() {
        var quote = LoyaltyVoucherService.quote("member", 100_000, 100, 100, 1_000);
        assertEquals(80, quote.pointsUsed());
        assertEquals(80_000, quote.discountAmount());
        assertEquals(20_000, quote.netTotal());
    }

    @Test
    void memberCannotSpendMoreThanBalance() {
        var quote = LoyaltyVoucherService.quote("member", 100_000, 60, 25, 1_000);
        assertEquals(25, quote.pointsUsed());
        assertEquals(25_000, quote.discountAmount());
    }
}
