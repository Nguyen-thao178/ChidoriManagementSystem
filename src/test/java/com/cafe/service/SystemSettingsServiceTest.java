package com.cafe.service;

import org.junit.jupiter.api.Test;

import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SystemSettingsServiceTest {
    @Test
    void validSettingsAreNormalized() {
        Map<String, String> values = validValues();
        values.put("currency", "vnd");

        SystemSettingsService.ValidationResult result =
                SystemSettingsService.validate(values);

        assertTrue(result.valid());
        assertEquals("VND", result.values().get("currency"));
        assertEquals("true", result.values().get("barcode_scanner_enabled"));
    }

    @Test
    void invalidDepositPercentIsRejected() {
        Map<String, String> values = validValues();
        values.put("deposit_percent", "100");

        SystemSettingsService.ValidationResult result =
                SystemSettingsService.validate(values);

        assertFalse(result.valid());
        assertTrue(result.message().contains("tiền cọc"));
    }

    @Test
    void missingSettingIsRejected() {
        Map<String, String> values = validValues();
        values.remove("hotline");

        SystemSettingsService.ValidationResult result =
                SystemSettingsService.validate(values);

        assertFalse(result.valid());
        assertTrue(result.message().contains("hotline"));
    }

    private Map<String, String> validValues() {
        Map<String, String> values = new LinkedHashMap<>();
        values.put("store_name", "Chidori Coffee");
        values.put("store_tagline", "Cà phê rang xay nguyên chất");
        values.put("hotline", "1900 1234");
        values.put("address", "123 Đường Cà Phê, TP.HCM");
        values.put("weekday_hours", "T2 - T6: 07:00 - 21:00");
        values.put("weekend_hours", "T7 - CN: 08:00 - 22:00");
        values.put("social_links", "Facebook | Instagram");
        values.put("currency", "VND");
        values.put("deposit_percent", "30");
        values.put("loyalty_vnd_per_point", "1000");
        values.put("barcode_scanner_enabled", "true");
        return values;
    }
}
