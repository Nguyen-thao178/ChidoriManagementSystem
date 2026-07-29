package com.cafe.utils;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordUtilTest {
    @Test
    void pbkdf2HashVerifiesAndUsesRandomSalt() {
        String first = PasswordUtil.hash("SecurePass123!");
        String second = PasswordUtil.hash("SecurePass123!");

        assertTrue(first.startsWith("pbkdf2$"));
        assertTrue(PasswordUtil.verify("SecurePass123!", first));
        assertFalse(PasswordUtil.verify("wrong", first));
        assertNotEquals(first, second);
    }

    @Test
    void legacySha256StillVerifiesAndRequestsUpgrade() {
        String legacy = HashUtil.sha256("admin123");

        assertTrue(PasswordUtil.verify("admin123", legacy));
        assertTrue(PasswordUtil.needsUpgrade(legacy));
    }
}
