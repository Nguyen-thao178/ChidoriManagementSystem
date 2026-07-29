# Cấu hình Gemini cho Chidori Assistant

Ứng dụng chỉ đọc khóa Gemini ở phía Java/Tomcat. Khóa không được gửi xuống JSP hoặc
JavaScript và không được lưu vào Git.

## Google Cloud project của Chidori

- Project ID: `gen-lang-client-0750167762`
- Project number: `1014241166018`
- Model mặc định: `gemini-2.5-flash`

API key được liên kết với project ngay khi tạo trong Google AI Studio. Vì vậy
Gemini Developer API không yêu cầu truyền Project ID trong request.

## 1. Tạo API key

1. Mở Google AI Studio: <https://aistudio.google.com/app/apikey>
2. Chọn project `gen-lang-client-0750167762`.
3. Tạo hoặc sao chép API key của project.
4. Không gửi key qua chat, không dán key vào `main.js`, JSP hoặc source Java.

## 2. Cấu hình trên Windows

Mở PowerShell và chạy lệnh dưới đây, thay `DAN_API_KEY_CUA_BAN_VAO_DAY` bằng key thật:

```powershell
[Environment]::SetEnvironmentVariable(
    "GEMINI_API_KEY",
    "DAN_API_KEY_CUA_BAN_VAO_DAY",
    "User"
)
[Environment]::SetEnvironmentVariable(
    "GEMINI_MODEL",
    "gemini-2.5-flash",
    "User"
)
```

Đóng hoàn toàn Eclipse/NetBeans và Tomcat rồi mở lại. Tiến trình Java chỉ nhận biến
môi trường mới khi được khởi động lại.

Để kiểm tra key đã tồn tại mà không in key ra màn hình:

```powershell
if ([Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")) {
    "GEMINI_API_KEY đã được cấu hình"
} else {
    "Chưa có GEMINI_API_KEY"
}
```

## 3. Cấu hình tạm cho một phiên chạy

Nếu chạy Tomcat trực tiếp từ đúng cửa sổ PowerShell hiện tại:

```powershell
$env:GEMINI_API_KEY = "DAN_API_KEY_CUA_BAN_VAO_DAY"
$env:GEMINI_MODEL = "gemini-2.5-flash"
```

Biến `$env:` chỉ tồn tại trong cửa sổ PowerShell đó.

## Cách nhận biết Gemini đang hoạt động

Mở chatbox và gửi một câu hỏi về menu. Dòng trạng thái sẽ hiện
`Gemini đang hoạt động` khi API trả lời thành công. Nếu chưa có key, key sai hoặc
Gemini tạm lỗi, chatbox tự chuyển sang `Chế độ hỗ trợ nội bộ`, vẫn trả lời bằng
dữ liệu menu và khuyến mãi trong database.
