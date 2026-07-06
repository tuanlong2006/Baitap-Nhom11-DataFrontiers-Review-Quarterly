# 🛡️ QUẢN TRỊ CƠ SỞ DỮ LIỆU, PHÂN QUYỀN VÀ SAO LƯU (ADMINISTRATION & BACKUP)
**ĐỒ ÁN CUỐI KỲ CƠ SỞ DỮ LIỆU - NHÓM 11**
*Hệ thống quản lý Tòa soạn & Phản biện bài báo khoa học*

---

## 1. THIẾT KẾ PHÂN QUYỀN TỐI THIỂU (LEAST PRIVILEGE DESIGN)
Theo nguyên tắc an toàn thông tin và yêu cầu của lab local (Trang 10), hệ thống không sử dụng tài khoản `root` cho ứng dụng khai thác hoặc lập báo cáo. Nhóm thiết kế một vai trò chuyên biệt phục vụ cho bộ phận Biên tập / Kết xuất báo cáo (Reporter).

### A. Kịch bản khởi tạo Role và Người dùng (User)
```sql
-- 1. Tạo vai trò (Role) cho người quản lý báo cáo tòa soạn
CREATE ROLE IF NOT EXISTS 'role_journal_reporter';

-- 2. Cấp quyền đọc dữ liệu (SELECT) trên toàn bộ Schema của tòa soạn
-- Đảm bảo chỉ cấp quyền xem bảng vật lý và khung nhìn (Views), không cho phép sửa đổi dữ liệu (DML)
GRANT SELECT ON journal_db.* TO 'role_journal_reporter';

-- 3. Tạo tài khoản người dùng local phục vụ môi trường kiểm thử
CREATE USER IF NOT EXISTS 'editor_reporter'@'localhost' 
IDENTIFIED BY 'ChangeThisLocalLabPassword2026!';

-- 4. Gán vai trò vào tài khoản người dùng
GRANT 'role_journal_reporter' TO 'editor_reporter'@'localhost';

-- 5. Thiết lập vai trò mặc định khi người dùng đăng nhập vào hệ thống
SET DEFAULT ROLE 'role_journal_reporter' TO 'editor_reporter'@'localhost';