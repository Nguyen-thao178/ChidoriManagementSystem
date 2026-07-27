package com.cafe.utils;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class BarcodeUtilTest {

    @Test
    void allConfiguredProductBarcodesAreValidEan13() {
        assertTrue(BarcodeUtil.isValidEan13("8938501434012"));
        assertTrue(BarcodeUtil.isValidEan13("8938501434029"));
        assertTrue(BarcodeUtil.isValidEan13("8938501434036"));
        assertTrue(BarcodeUtil.isValidEan13("8938501434043"));
    }

    @Test
    void scannerPrefixAndEnterSuffixAreRemoved() {
        assertEquals(
                "8938501434036",
                BarcodeUtil.normalize("]E08938501434036\r\n")
        );
    }

    @Test
    void invalidLengthOrCheckDigitIsRejected() {
        assertFalse(BarcodeUtil.isValidEan13("893850143401"));
        assertFalse(BarcodeUtil.isValidEan13("8938501434013"));
        assertFalse(BarcodeUtil.isValidEan13("ABCDEFGHIJKLM"));
    }
}
