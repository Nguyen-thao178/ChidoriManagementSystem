package com.cafe.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class GeminiServiceTest {
    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void systemInstructionStrictlyLimitsCafeScope() {
        String prompt = GeminiService.buildSystemInstruction("Menu: Cà phê sữa 30.000₫");

        assertTrue(prompt.contains("Chỉ trả lời về Chidori Coffee"));
        assertTrue(prompt.contains("Không tự bịa"));
        assertTrue(prompt.contains("Cà phê sữa 30.000₫"));
        assertTrue(prompt.contains("Không dùng HTML"));
    }

    @Test
    void extractsTextFromGeminiCandidates() throws Exception {
        String json = """
                {
                  "candidates": [{
                    "content": {
                      "parts": [
                        {"text": "Cà phê sữa"},
                        {"text": "30.000₫"}
                      ]
                    }
                  }]
                }
                """;

        assertEquals("Cà phê sữa\n30.000₫",
                GeminiService.extractText(mapper.readTree(json)));
    }

    @Test
    void returnsNullWhenCandidateHasNoParts() throws Exception {
        assertNull(GeminiService.extractText(mapper.readTree("{\"candidates\":[]}")));
    }
}
