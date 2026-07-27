# Cấu hình Gemini cho Chidori Assistant

Ứng dụng đọc khóa Gemini từ biến môi trường, không lưu khóa trong source code.

## Cấu hình trên Windows

1. Tạo API key trong Google AI Studio.
2. Tạo biến môi trường người dùng:

   ```powershell
   [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_API_KEY", "User")
   ```

3. Có thể chọn model khác (không bắt buộc):

   ```powershell
   [Environment]::SetEnvironmentVariable("GEMINI_MODEL", "gemini-3.6-flash", "User")
   ```

4. Khởi động lại Eclipse/NetBeans và Tomcat để tiến trình Java nhận biến mới.

Khi chưa có key, key sai hoặc Gemini tạm lỗi, chatbox tự chuyển sang bộ trả lời nội bộ
dựa trên menu và khuyến mãi trong database. Không đặt API key vào JSP, JavaScript,
Git hoặc file cấu hình được commit.
