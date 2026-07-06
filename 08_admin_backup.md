# 🛡️ QUẢN TRỊ CƠ SỞ DỮ LIỆU, PHÂN QUYỀN VÀ SAO LƯU (ADMINISTRATION & BACKUP)
**ĐỒ ÁN CUỐI KỲ CƠ SỞ DỮ LIỆU - NHÓM 11**
*Hệ thống cơ sở dữ liệu: DataFrontiers Journal (Tạp chí Khoa học)*

---

## 1. THIẾT KẾ PHÂN QUYỀN TỐI THIỂU (LEAST PRIVILEGE DESIGN)
Theo nguyên tắc an toàn thông tin và quy chuẩn thực nghiệm môi trường Lab (Trang 10), hệ thống tuyệt đối không sử dụng tài khoản tối cao `root` cho ứng dụng khai thác hoặc lập báo cáo. Nhóm 11 thiết kế một vai trò (Role) chuyên biệt phục vụ riêng cho bộ phận Biên tập / Kết xuất báo cáo thống kê (Reporter).

### A. Kịch bản khởi tạo Role và Người dùng (User) trên MySQL
*Các lệnh DDL này được lưu trữ và triển khai đồng bộ tại tệp `06_administration.sql` hoặc chạy trực tiếp trên môi trường quản trị:*

```sql
USE datafrontiers_journal_db;

-- 1. Thu hồi và xóa các đối tượng cũ để làm sạch môi trường test
DROP USER IF EXISTS 'editor_reporter'@'localhost';
DROP ROLE IF EXISTS 'role_journal_reporter';

-- 2. Tạo vai trò (Role) chuyên trách cho nhân viên báo cáo tòa soạn
CREATE ROLE 'role_journal_reporter';

-- 3. Cấp quyền đọc dữ liệu (SELECT) trên toàn bộ bảng vật lý và khung nhìn (Views)
GRANT SELECT ON datafrontiers_journal_db.* TO 'role_journal_reporter';

-- 4. Cấp quyền thực thi (EXECUTE) để tài khoản chạy được Stored Procedures và Functions báo cáo
GRANT EXECUTE ON datafrontiers_journal_db.* TO 'role_journal_reporter';

-- 5. Tạo tài khoản người dùng local phục vụ môi trường kiểm thử
CREATE USER 'editor_reporter'@'localhost' 
IDENTIFIED BY 'ChangeThisLocalLabPassword2026!';

-- 6. Gán vai trò vào tài khoản người dùng
GRANT 'role_journal_reporter' TO 'editor_reporter'@'localhost';

-- 7. Thiết lập vai trò mặc định tự động kích hoạt ngay khi người dùng đăng nhập
SET DEFAULT ROLE 'role_journal_reporter' TO 'editor_reporter'@'localhost';

FLUSH PRIVILEGES;