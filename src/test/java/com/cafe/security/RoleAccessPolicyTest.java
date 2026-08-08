package com.cafe.security;

import com.cafe.model.User;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RoleAccessPolicyTest {

    @Test
    void staffCanSellAndViewOwnHistoryButCannotManage() {
        User staff = user("staff");
        assertTrue(RoleAccessPolicy.canAccess(staff, "/menu"));
        assertTrue(RoleAccessPolicy.canAccess(staff, "/cart/scan"));
        assertTrue(RoleAccessPolicy.canAccess(staff, "/checkout"));
        assertTrue(RoleAccessPolicy.canAccess(staff, "/history"));
        assertFalse(RoleAccessPolicy.canAccess(staff, "/admin/users"));
        assertFalse(RoleAccessPolicy.canAccess(staff, "/admin/report"));
        assertEquals("/home", RoleAccessPolicy.landingPath(staff));
    }

    @Test
    void managerCanManageStaffMenuAndReportsButCannotSellOrConfigure() {
        User manager = user("manager");
        assertTrue(RoleAccessPolicy.canAccess(manager, "/history"));
        assertTrue(RoleAccessPolicy.canAccess(manager, "/admin/users"));
        assertTrue(RoleAccessPolicy.canAccess(manager, "/admin/products"));
        assertTrue(RoleAccessPolicy.canAccess(manager, "/admin/report"));
        assertTrue(RoleAccessPolicy.canAccess(manager, "/admin/report/chat-history/print"));
        assertFalse(RoleAccessPolicy.canAccess(manager, "/checkout"));
        assertFalse(RoleAccessPolicy.canAccess(manager, "/admin/settings"));
        assertFalse(RoleAccessPolicy.canAccess(manager, "/admin/contacts"));
        assertEquals("/history", RoleAccessPolicy.landingPath(manager));
    }

    @Test
    void adminCanReportManageContactsAndSettingsOnly() {
        User admin = user("admin");
        assertTrue(RoleAccessPolicy.canAccess(admin, "/admin/report"));
        assertTrue(RoleAccessPolicy.canAccess(admin, "/admin/contacts"));
        assertTrue(RoleAccessPolicy.canAccess(admin, "/admin/settings"));
        assertFalse(RoleAccessPolicy.canAccess(admin, "/admin/users"));
        assertFalse(RoleAccessPolicy.canAccess(admin, "/admin/products"));
        assertFalse(RoleAccessPolicy.canAccess(admin, "/checkout"));
        assertFalse(RoleAccessPolicy.canAccess(admin, "/history"));
        assertEquals("/admin/report", RoleAccessPolicy.landingPath(admin));
    }

    @Test
    void commonAccountActionsRemainAvailableToAuthenticatedRoles() {
        for (String role : new String[]{"staff", "manager", "admin", "customer"}) {
            assertTrue(RoleAccessPolicy.canAccess(user(role), "/logout"));
            assertTrue(RoleAccessPolicy.canAccess(user(role), "/change-password"));
            assertTrue(RoleAccessPolicy.canAccess(user(role), "/chat"));
        }
    }

    @Test
    void customerCanOnlyCreateDepositsAndCannotProcessBalance() {
        User customer = user("customer");
        assertTrue(RoleAccessPolicy.canAccess(customer, "/promotion"));
        assertTrue(RoleAccessPolicy.canAccess(customer, "/deposit-orders"));
        assertTrue(RoleAccessPolicy.canAccess(customer, "/history"));
        assertTrue(RoleAccessPolicy.canAccess(customer, "/add-to-cart"));
        assertFalse(RoleAccessPolicy.canAccess(customer, "/cart/scan"));
        assertTrue(RoleAccessPolicy.canCreateOrderType(customer, "deposit"));
        assertFalse(RoleAccessPolicy.canCreateOrderType(customer, "direct"));
        assertTrue(RoleAccessPolicy.canUsePaymentMethod(customer, "vnpay"));
        assertFalse(RoleAccessPolicy.canUsePaymentMethod(customer, "cash"));
        assertFalse(RoleAccessPolicy.canProcessCustomerDeposit(customer));
    }

    @Test
    void staffCanSellAndProcessCustomerDeposits() {
        User staff = user("staff");
        assertTrue(RoleAccessPolicy.canCreateOrderType(staff, "direct"));
        assertTrue(RoleAccessPolicy.canCreateOrderType(staff, "deposit"));
        assertTrue(RoleAccessPolicy.canUsePaymentMethod(staff, "cash"));
        assertTrue(RoleAccessPolicy.canUsePaymentMethod(staff, "vnpay"));
        assertTrue(RoleAccessPolicy.canProcessCustomerDeposit(staff));
    }

    @Test
    void unknownRoleAndUnknownRouteAreDeniedByDefault() {
        assertFalse(RoleAccessPolicy.canAccess(user("unknown"), "/home"));
        assertFalse(RoleAccessPolicy.canAccess(user("admin"), "/create-admin"));
        assertFalse(RoleAccessPolicy.canAccess(null, "/home"));
    }

    private User user(String role) {
        User user = new User();
        user.setRole(role);
        return user;
    }
}
