package com.cafe.payment;

import org.junit.jupiter.api.Test;

import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class VNPayCallbackServiceTest {
    @Test
    void hashDataIsSortedAndUrlEncoded() {
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("vnp_TxnRef", "ABC 123");
        fields.put("vnp_Amount", "90000");
        fields.put("empty", "");

        assertEquals("vnp_Amount=90000&vnp_TxnRef=ABC+123",
                VNPayCallbackService.buildHashData(fields));
    }
}
