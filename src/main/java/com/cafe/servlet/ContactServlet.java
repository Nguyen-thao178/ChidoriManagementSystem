package com.cafe.servlet;

import com.cafe.dao.ContactDAO;
import com.cafe.model.Contact;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {
    private ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Contact> contacts = contactDAO.getAllContacts();
            req.setAttribute("contacts", contacts);
            req.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Không thể tải danh sách liên hệ: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }
}