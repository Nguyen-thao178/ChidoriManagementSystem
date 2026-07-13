[]

☕ CHIDORI COFFEE SYSTEM

Chidori Management System

Hệ thống Quản lý Bán hàng & Chăm sóc Khách hàng Quán Cà Phê

(Cafe Sales & Customer Loyalty Management System)

Đồ án tốt nghiệp — Môn PRO230 — Lớp SD2002

Giảng viên hướng dẫn: Nguyễn Thị Diệu Hiền

NHÓM 1

  Tài liệu được biên soạn dựa trên mã nguồn thực tế
  (ChidoriManagementSystem), script CSDL database1.0.sql /
  database2.0.sql, báo cáo phân tích - thiết kế (ASM1) và báo cáo kiểm
  thử - debug (Chidori_Test_Debug_Report.docx) của nhóm.

Mục lục

1. Giới thiệu dự án

Quán cà phê Chidori Coffee hiện đang vận hành thủ công: ghi order bằng
giấy, tính tiền bằng tay, quản lý kho bằng Excel — dẫn đến sai sót, chậm
trễ và khó kiểm soát doanh thu, hiệu suất nhân viên.

Dự án xây dựng Chidori Management System — hệ thống quản lý bán hàng
quán cà phê chạy trên nền Web, số hóa toàn bộ quy trình: xem menu, đặt
món, thanh toán online (VNPay), quản lý nhân viên/khách hàng, quản lý
khuyến mãi, thống kê doanh thu và tích điểm thành viên.

Hệ thống được phát triển theo mô hình 3-Tier (Client – Web Server –
Database Server), phục vụ các nhóm người dùng: Khách (Guest), Thành viên
(Customer/Member), Nhân viên (Staff) và Quản lý/Admin (Manager/Admin).

Ngoài các chức năng quản lý thông thường, hệ thống còn tích hợp:

-   Đăng nhập nhanh qua OAuth (Google/Facebook/GitHub)

-   Thanh toán trực tuyến qua VNPay (sandbox)

-   Trợ lý chat tự động (rule-based) hỗ trợ tư vấn menu, giá, khuyến
    mãi, điểm tích lũy

-   Xuất lịch sử đơn hàng ra PDF (OpenPDF)

Mục tiêu hướng đến là tạo ra một hệ thống hiện đại, dễ sử dụng, vận hành
ổn định và có khả năng mở rộng trong tương lai.

2. Mục tiêu dự án

-   Số hóa toàn bộ quy trình bán hàng tại quán cà phê (đặt món → thanh
    toán → thống kê).

-   Áp dụng kiến trúc 3-Tier rõ ràng, dễ bảo trì.

-   Quản lý tập trung: người dùng, sản phẩm/menu, đơn hàng, khuyến mãi.

-   Tích điểm thưởng và chăm sóc khách hàng thành viên.

-   Báo cáo, thống kê doanh thu trực quan theo ngày/tháng/quý/năm.

-   Phân quyền rõ ràng theo 4 vai trò: Admin, Manager, Staff, Customer.

-   Đảm bảo hiệu năng, bảo mật và khả năng phục hồi dữ liệu.

3. Chức năng hệ thống

Khách / Thành viên (Guest / Customer)

-   Xem trang chủ, xem menu đồ uống (không cần đăng nhập)

-   Tìm kiếm sản phẩm, xem chi tiết sản phẩm

-   Đăng ký tài khoản thành viên (MemberRegisterServlet)

-   Đăng nhập bằng tài khoản/mật khẩu hoặc OAuth
    (Google/Facebook/GitHub)

-   Thêm/sửa/xóa sản phẩm trong giỏ hàng (CartServlet, AddToCartServlet,
    UpdateCartServlet, RemoveCartServlet)

-   Thanh toán đơn hàng qua VNPay (CheckoutServlet, VNPayServlet,
    VNPayReturnServlet)

-   Xem lịch sử đơn hàng, xuất lịch sử ra PDF (OrderHistoryServlet,
    ExportHistoryServlet)

-   Xem & tích điểm thưởng thành viên (LoyaltyServlet)

-   Xem trang khuyến mãi (PromotionServlet)

-   Đổi mật khẩu, xem/gửi thông tin liên hệ (ChangePasswordServlet,
    ContactServlet)

-   Trò chuyện với chatbot tư vấn (menu, giá, khuyến mãi, điểm tích lũy,
    liên hệ)

Quản lý / Admin

-   Quản lý người dùng: thêm, sửa, xóa, phân quyền
    (UserManagementServlet, CreateAdminServlet)

-   Quản lý sản phẩm/menu: thêm, sửa, xóa, cập nhật tồn kho
    (ProductManagementServlet)

-   Quản lý khuyến mãi (chương trình & khuyến mãi theo từng sản phẩm)

-   Xem báo cáo doanh thu, sản phẩm bán chạy, hiệu suất nhân viên
    (ReportServlet, ReportDAO)

-   Cài đặt hệ thống: tên cửa hàng, hotline, thuế VAT, tỉ lệ quy đổi
    điểm thưởng (SettingsServlet)

-   Phân quyền truy cập tự động qua AuthFilter (chặn truy cập trái phép
    vào khu vực Admin)

  Chi tiết đặc tả từng use case (tiền điều kiện, luồng chính, luồng
  phụ/ngoại lệ) được mô tả đầy đủ trong tài liệu SRS (ASM1, mục 1.4).

4. Công nghệ sử dụng

Frontend

-   HTML5, CSS3

-   Bootstrap 5

-   JavaScript, AJAX

Backend

-   Java 17

-   Jakarta Servlet API 6.0.0, Jakarta JSP 3.1.0, JSTL 3.0.0/3.0.1

-   Mẫu thiết kế MVC: Servlet (Controller) → DAO → JSP (View),
    AuthFilter bảo vệ route

Database

-   Microsoft SQL Server (JDBC driver: mssql-jdbc 12.6.1.jre11)

-   Database: CafeDB

Tích hợp bên thứ ba

-   VNPay — cổng thanh toán trực tuyến (sandbox)

-   OAuth 2.0 — đăng nhập qua Google (google-api-client,
    google-oauth-client-jetty), hỗ trợ cấu hình sẵn cho Facebook &
    GitHub

-   Jackson Databind 2.15.2 — xử lý JSON (API chat, response AJAX)

-   OpenPDF 1.3.30 — xuất lịch sử đơn hàng ra PDF

-   Apache HttpClient 4.5.14, Nimbus OAuth2/OIDC SDK — hỗ trợ luồng
    OAuth

Build & Deploy

-   Maven (pom.xml, packaging war, finalName ChidoriManagementSystem)

-   Apache Tomcat (Jakarta EE 6.0 / Servlet 6.0)

IDE & Công cụ khác

-   IntelliJ IDEA / Eclipse

-   SQL Server Management Studio (SSMS) / Azure Data Studio

-   Git & GitHub

-   draw.io — vẽ ERD, sơ đồ kiến trúc, sơ đồ giao diện
    (ERD_LG_LVL1/2.drawio, ERD_VL_LVL1/2.drawio, TechDiagram.drawio,
    3tierfinal_PRO230.drawio, Interface.drawio)

5. Kiến trúc hệ thống

Hệ thống triển khai theo mô hình 3-Tier:

Tier 1 — Client (Trình duyệt)
HTML/CSS/JS, Bootstrap 5, AJAX
↓ HTTP Request/Response
Tier 2 — Web Server (Apache Tomcat)
Java Servlet, JSP, JSTL, JDBC
(Xử lý nghiệp vụ, bảo mật, điều hướng)
↓ JDBC Connection
Tier 3 — Database Server
Microsoft SQL Server
(Lưu trữ, truy vấn, quản lý dữ liệu)

Kiến trúc code phía Backend tổ chức theo mô hình phân lớp:

Request → AuthFilter (kiểm tra đăng nhập/phân quyền)
→ Servlet (Controller: xử lý request, gọi DAO)
→ DAO (truy vấn CSDL qua JdbcUtil/DBConnection)
→ SQL Server (CafeDB)
→ Servlet forward dữ liệu (Model) → JSP (View) render giao diện

Các module hỗ trợ tách riêng: `payment` (VNPay), `oauth` (đăng nhập
MXH), `utils` (JDBC, hash mật khẩu, validate, log).

6. Cấu trúc thư mục

Cấu trúc thực tế của project `ChidoriManagementSystem` (Maven, packaging
war):

ChidoriManagementSystem/
├── pom.xml # Maven build (Java 17, packaging war)
├── src/main/java/com/cafe/
│ ├── model/ # User, Product, Order, OrderDetail, CartItem,
│ │ # Contact, Promotion, PromotionItem, LoyaltyPoint, SystemSetting
│ ├── dao/ # DBConnection, UserDAO, ProductDAO, OrderDAO, ContactDAO,
│ │ # PromotionDAO, PromotionItemDAO, LoyaltyDAO, ReportDAO,
│ │ # SystemSettingsDAO, LoyaltyServlet
│ ├── servlet/ # HomeServlet, LoginServlet, LogoutServlet, MenuServlet,
│ │ # CartServlet/AddToCart/UpdateCart/RemoveCart,
│ │ # CheckoutServlet, VNPayServlet/VNPayReturnServlet,
│ │ # OrderHistoryServlet, ExportHistoryServlet,
│ │ # ProductManagementServlet, UserManagementServlet,
│ │ # PromotionServlet, SettingsServlet, ReportServlet,
│ │ # ContactServlet, ChatServlet, SearchServlet,
│ │ # MemberRegisterServlet, ChangePasswordServlet,
│ │ # OAuthLoginServlet, OAuthCallbackServlet, CreateAdminServlet
│ ├── filter/ # AuthFilter (bảo vệ toàn bộ route /*)
│ ├── oauth/ # OAuthConstants (Google/Facebook/GitHub)
│ ├── payment/ # VNPayConfig (HMAC-SHA512, sandbox VNPay)
│ └── utils/ # JdbcUtil, HashUtil, AuthUtil, ParamUtil, ValidationUtil,
LogUtil
│
├── src/main/webapp/
│ ├── index.jsp
│ ├── WEB-INF/web.xml
│ ├── WEB-INF/views/ # home, login, menu, product, cart, checkout,
history,
│ │ # loyalty, promotion, contact, search, changePassword,
│ │ # register_member, payment_result, header/footer/sidebar,
│ │ # error, admin/(product_list, product_form, user_list,
│ │ # user_form, report, settings)
│ └── assets/ # css/style.css, js/main.js, images/qr.png
│
├── src/test/ # Thư mục kiểm thử (java/resources)
└── target/ # Build output (Maven)
docs/ (ngoài source_code/)
├── NHOM1_PRO230_ASM1..0.docx # Báo cáo Phân tích & Thiết kế
├── NHOM1_PRO230_ASM2.0.docx # Báo cáo Hiện thực
├── Chidori_Test_Debug_Report.docx # Báo cáo kiểm thử & debug
├── ERD_LG_LVL1.drawio / LVL2 # ERD mức logic
├── ERD_VL_LVL1.drawio / LVL2 # ERD mức vật lý
├── TechDiagram.drawio # Sơ đồ công nghệ
├── 3tierfinal_PRO230.drawio # Sơ đồ kiến trúc 3-Tier
├── Interface.drawio # Sơ đồ tổ chức giao diện
├── logo.jpg # Logo Chidori Coffee
└── source_code/
├── ChidoriManagementSystem.zip # Mã nguồn (nén)
├── database1.0.sql # Script CSDL v1.0 (ASM1)
└── database2.0.sql # Script CSDL v2.0 (ASM2)

7. Yêu cầu hệ thống

Server (Web + Database)

  -----------------------------------------------------------------------
  Thành phần          Yêu cầu
  ------------------- ---------------------------------------------------
  CPU                 Intel Xeon E5 / Core i7 ≥ 4 cores

  RAM                 ≥ 16 GB (khuyến nghị 32 GB)

  Ổ cứng              ≥ 500 GB SSD (SAS/NVMe)

  Mạng                Internet ≥ 100 Mbps

  HĐH                 Windows Server 2019/2022 hoặc Linux (Ubuntu 20.04+)
  -----------------------------------------------------------------------

Client (Người dùng)

  -----------------------------------------------------------------------
  Thành phần          Yêu cầu
  ------------------- ---------------------------------------------------
  CPU                 Intel Core i3 ≥ 2 cores

  RAM                 ≥ 4 GB (khuyến nghị 8 GB)

  Trình duyệt         Chrome 120+ / Edge 120+ / Firefox 120+

  Màn hình            ≥ 15 inch, độ phân giải ≥ 1366x768
  -----------------------------------------------------------------------

Phần mềm bắt buộc

-   JDK 17

-   Apache Maven (build project → file WAR)

-   Apache Tomcat 10+ (hỗ trợ Jakarta EE / Servlet 6.0)

-   Microsoft SQL Server (Developer/Express/Standard)

-   Git + GitHub

-   IntelliJ IDEA hoặc Eclipse

8. Hướng dẫn cài đặt

Bước 1 — Clone / giải nén project

git clone <đường-dẫn-repository-của-nhóm>
# hoặc giải nén source_code/ChidoriManagementSystem.zip

Bước 2 — Import vào IDE

Mở thư mục `ChidoriManagementSystem` bằng IntelliJ IDEA hoặc Eclipse
dưới dạng Maven Project (project đã có sẵn `pom.xml`).

Bước 3 — Tạo Database & import script

Mở SSMS, chạy lần lượt:

CREATE DATABASE CafeDB;
GO

Sau đó chạy file `source_code/database2.0.sql` (bản mới nhất, có đầy đủ
bảng + trigger + dữ liệu mẫu). File `database1.0.sql` là bản đầu (ASM1),
giữ lại để tham khảo lịch sử phát triển.

Script tạo 9 bảng: `users`, `contacts`, `system_settings`, `products`,
`promotions`, `promotion_items`, `orders`, `order_items`,
`loyalty_points`, kèm theo trigger `trg_users_update` và dữ liệu mẫu
(tài khoản, sản phẩm, khuyến mãi, đơn hàng mẫu).

Bước 4 — Cấu hình kết nối JDBC

Sửa thông tin kết nối trong
`src/main/java/com/cafe/dao/DBConnection.java`:

private static final String URL =
"jdbc:sqlserver://localhost:1433;databaseName=CafeDB;encrypt=true;trustServerCertificate=true";
private static final String USER = "sa"; // đổi theo tài khoản SQL
Server của bạn
private static final String PASS = "12345"; // đổi theo mật khẩu thật

Bước 5 — Cấu hình VNPay & OAuth (tuỳ chọn)

-   src/main/java/com/cafe/payment/VNPayConfig.java: thay TMN_CODE và
    SECRET_KEY bằng thông tin merchant VNPay sandbox thật.

-   src/main/java/com/cafe/oauth/OAuthConstants.java: thay
    GOOGLE_CLIENT_ID/SECRET (và Facebook/GitHub nếu dùng) bằng thông tin
    OAuth app thật.

  ⚠️ Đây là thông tin nhạy cảm — trong bản demo/nộp bài không nên commit
  key thật lên GitHub public.

Bước 6 — Build & Deploy

mvn clean package

File `ChidoriManagementSystem.war` sẽ được tạo trong `target/`. Deploy
file này vào thư mục `webapps` của Apache Tomcat, hoặc chạy trực tiếp từ
IDE (Run on Server).

9. Hướng dẫn chạy

Chạy project trực tiếp từ IDE (Run on Server với Tomcat đã cấu hình),
hoặc build WAR rồi copy vào thư mục `webapps` của Tomcat.

Sau đó truy cập:

http://localhost:8080/ChidoriManagementSystem/

10. Tài khoản mẫu

Dữ liệu mẫu được seed sẵn trong `database2.0.sql`:

  ------------------------------------------------------------------------
  Vai trò      Username     Email                  Ghi chú
  ------------ ------------ ---------------------- -----------------------
  Admin        admin        admin@chidori.com      Mật khẩu đã băm SHA-256
                                                   sẵn trong script

  Nhân viên    staff1       staff1@chidori.com     Có 100 điểm thưởng mẫu,
  (Staff)                                          đã chi tiêu 500.000đ
  ------------------------------------------------------------------------

  🔑 Mật khẩu trong script là chuỗi đã băm SHA-256 (password_hash),
  không phải mật khẩu gốc. Trong báo cáo kiểm thử
  (Chidori_Test_Debug_Report.docx), nhóm dùng dữ liệu test mẫu admin /
  admin123 để kiểm thử đăng nhập — nếu muốn đăng nhập được, cần tự tạo
  tài khoản qua chức năng đăng ký, hoặc thay password_hash bằng giá trị
  SHA-256 của mật khẩu mong muốn.

  Khách hàng thành viên: đăng ký trực tiếp trên hệ thống qua chức năng
  "Đăng ký thành viên" (MemberRegisterServlet), hoặc đăng nhập nhanh
  bằng Google/Facebook/GitHub (OAuth).

11. Cơ sở dữ liệu

CSDL `CafeDB` (Microsoft SQL Server) gồm 9 bảng chính:

  ----------------------------------------------------------------------------
  Bảng              Mô tả                              Quan hệ chính
  ----------------- ---------------------------------- -----------------------
  users             Tài khoản người dùng               —
                    (admin/manager/staff/customer)     

  contacts          Danh bạ liên hệ (chủ quán, quản    FK → users
                    lý, nhân viên)                     

  system_settings   Cấu hình hệ thống (tên quán,       FK
                    hotline, thuế, tỉ lệ điểm thưởng)  created_by/updated_by →
                                                       users

  products          Danh sách món đồ uống (giá, tồn    —
                    kho, danh mục)                     

  promotions        Chương trình khuyến mãi            —

  promotion_items   Khuyến mãi áp dụng theo từng sản   FK → products,
                    phẩm                               promotions

  orders            Đơn hàng                           FK → users

  order_items       Chi tiết từng đơn hàng             FK → orders, products

  loyalty_points    Điểm tích lũy của khách hàng thành FK (1-1) → users
                    viên                               
  ----------------------------------------------------------------------------

Kèm theo:

-   Trigger trg_users_update tự động cập nhật updated_at khi sửa users

-   Index tối ưu truy vấn theo username, email, category, status,
    user_id...

-   Dữ liệu mẫu (seed data) đầy đủ: 2 user, 7 sản phẩm, 3 khuyến mãi, 3
    đơn hàng mẫu...

-   Sơ đồ ERD mức khái niệm/logic/vật lý — xem ERD_LG_LVL1.drawio,
    ERD_LG_LVL2.drawio, ERD_VL_LVL1.drawio, ERD_VL_LVL2.drawio, và tài
    liệu ASM1 mục 2.3.

Lịch sử phiên bản script

-   database1.0.sql — bản đầu tiên (ASM1): cấu trúc cơ bản 5 bảng
    (users, products, orders, order_items...), chưa có
    index/trigger/seed data.

-   database2.0.sql — bản cập nhật (ASM2): bổ sung đầy đủ 9 bảng (thêm
    contacts, system_settings, promotions, promotion_items,
    loyalty_points), ràng buộc UNIQUE chặt chẽ hơn, index, trigger và dữ
    liệu mẫu — dùng bản này để chạy hệ thống.

12. Hình ảnh hệ thống

-   Logo Chidori Coffee (logo.jpg)

-   Sơ đồ Use Case tổng quát

-   Sơ đồ kiến trúc 3-Tier (3tierfinal_PRO230.drawio)

-   Sơ đồ tổ chức giao diện (Interface.drawio)

-   Màn hình Đăng nhập / Đăng ký thành viên

-   Trang chủ, Menu đồ uống, Chi tiết sản phẩm

-   Giỏ hàng, Thanh toán (VNPay), Kết quả thanh toán

-   Lịch sử đơn hàng, Điểm tích lũy

-   Trang Khuyến mãi, Liên hệ

-   Trang Quản trị: Quản lý người dùng, Quản lý sản phẩm, Báo cáo, Cài
    đặt hệ thống

-   Kết quả kiểm thử (đăng nhập, đăng ký, CRUD sản phẩm, phân quyền) —
    xem Chidori_Test_Debug_Report.docx

  (Chèn ảnh chụp giao diện thực tế khi chạy hệ thống — các sơ đồ .drawio
  có thể mở bằng draw.io/diagrams.net để xuất ảnh)

12.1 Kiểm thử & Debug

Tóm tắt từ `Chidori_Test_Debug_Report.docx`:

Kết quả kiểm thử chức năng (đều Pass)

-   Đăng nhập: đúng tài khoản, sai mật khẩu, bỏ trống tài khoản

-   Đăng ký: đầy đủ thông tin, email trùng, bỏ trống dữ liệu

-   CRUD sản phẩm: thêm / sửa / xóa / tìm kiếm

-   Phân quyền: Admin truy cập trang Admin, User bị chặn, chưa đăng nhập
    bị chuyển hướng Login

Lỗi phát hiện & cách khắc phục

  -----------------------------------------------------------------------
  Lỗi                     Nguyên nhân             Cách khắc phục
  ----------------------- ----------------------- -----------------------
  Không kết nối được SQL  Sai connection string   Sửa lại URL kết nối
  Server                                          trong DBConnection

  NullPointerException    Session chưa khởi tạo   Kiểm tra null trước khi
  khi đăng nhập                                   sử dụng session

  Không hiển thị dữ liệu  Sai câu truy vấn SQL    Sửa lại câu truy vấn
  sản phẩm                                        

  User truy cập được      Thiếu kiểm tra role     Bổ sung AuthFilter kiểm
  trang Admin                                     tra role
  -----------------------------------------------------------------------

Kết luận: Sau khi kiểm thử và khắc phục các lỗi phát sinh, hệ thống hoạt
động ổn định và đáp ứng các yêu cầu chức năng của đề tài.

13. Video Demo

  (Thêm liên kết video YouTube hoặc Google Drive demo hệ thống tại đây)

14. Thành viên thực hiện

  -----------------------------------------------------------------------
  Họ và tên                       MSSV                Vai trò
  ------------------------------- ------------------- -------------------
  Đặng Huỳnh Thảo Nguyên          TS02518             Trưởng nhóm

  Huỳnh Công Danh                 TS03050             Phó nhóm

  Phạm Minh Kiệt                  TS02684             Thành viên

  Đỗ Quang Anh                    TS02902             Thành viên

  Lê Trung Bảo Long               TD01606             Thành viên
  -----------------------------------------------------------------------

Lớp: SD2002 — Mã môn: PRO230

Giảng viên hướng dẫn: Nguyễn Thị Diệu Hiền

15. Tiến độ dự án

ASM1 — Phân tích & Thiết kế

-   ✅ Khảo sát hiện trạng & thu thập yêu cầu (FR/NFR)

-   ✅ Xây dựng Use Case & đặc tả SRS

-   ✅ Thiết kế cơ sở dữ liệu (ERD mức khái niệm/logic/vật lý)

-   ✅ Thiết kế giao diện (wireframe các màn hình chính)

-   ✅ Viết script tạo CSDL v1.0 (database1.0.sql)

ASM2 — Hiện thực & Kiểm thử

-   ✅ Nâng cấp CSDL lên v2.0 (database2.0.sql): đầy đủ 9 bảng, index,
    trigger, seed data

-   ✅ Xây dựng Model, DAO cho toàn bộ các bảng

-   ✅ Xây dựng lớp tiện ích: JdbcUtil, HashUtil, AuthUtil, ParamUtil,
    ValidationUtil, LogUtil

-   ✅ Hiện thực đầy đủ Servlet/JSP cho các chức năng: bán hàng, giỏ
    hàng, thanh toán, khuyến mãi, điểm thưởng, quản trị

-   ✅ Tích hợp thanh toán VNPay (sandbox)

-   ✅ Tích hợp đăng nhập OAuth (Google, có sẵn cấu hình
    Facebook/GitHub)

-   ✅ Xây dựng chatbot tư vấn cơ bản (rule-based)

-   ✅ Xuất lịch sử đơn hàng ra PDF

-   ✅ Phân quyền qua AuthFilter

-   ✅ Kiểm thử chức năng & phân quyền, ghi nhận và khắc phục lỗi
    (Chidori_Test_Debug_Report.docx)

Còn lại

-   ⬜ Kiểm thử hiệu năng theo NFR (JMeter/Locust, mục tiêu phản hồi <
    2s với 50 concurrent users)

-   ⬜ Thay thông tin thật cho VNPay/OAuth (hiện đang dùng placeholder
    YOUR_TMN_CODE, YOUR_GOOGLE_CLIENT_ID...)

-   ⬜ Quay video demo & đóng gói bản deploy cuối cùng

16. Hướng phát triển

-   Phát triển ứng dụng di động (Mobile app) cho khách hàng đặt món.

-   Đưa VNPay từ sandbox lên tài khoản merchant thật; bổ sung thêm Momo,
    ZaloPay.

-   Nâng cấp chatbot rule-based hiện tại thành AI Chatbot thực sự (tích
    hợp LLM/NLP).

-   Hoàn thiện đăng nhập Facebook/GitHub (đã có sẵn cấu hình
    OAuthConstants, chưa điền key thật).

-   Hỗ trợ quản lý đa chi nhánh.

-   Tối ưu bảo mật: JWT thay session, rate-limit chống brute-force đăng
    nhập, chống SQL Injection nâng cao.

-   Tích hợp thông báo Email/SMS cho đơn hàng và chương trình khuyến
    mãi.

-   Triển khai lên Cloud (Azure/AWS/Render/Railway) thay vì chạy local
    Tomcat.

-   Bổ sung kiểm thử tự động (unit test/integration test) và kiểm thử
    hiệu năng (JMeter/Locust).

17. Giấy phép

Dự án được phát triển phục vụ mục đích học tập, nghiên cứu trong khuôn
khổ môn học PRO230 — Dự án tốt nghiệp.

18. Liên hệ

-   Nhóm: NHÓM 1 — Lớp SD2002

-   Môn học: PRO230 — Dự án tốt nghiệp

-   Giảng viên hướng dẫn: Nguyễn Thị Diệu Hiền

-   Trưởng nhóm: Đặng Huỳnh Thảo Nguyên (TS02518)

-   Hotline mẫu trong hệ thống: 1900 1234 (system_settings)

-   Email hỗ trợ mẫu: kietpmts02684@gmail.com

-   Email liên hệ nhóm: nguyendhtts02518@gmail.com

-   GitHub: https://github.com/Nguyen-thao178/ChidoriManagementSystem/edit/main/
