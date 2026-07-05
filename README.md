# 📚 ĐỒ ÁN CUỐI KỲ: HỆ THỐNG QUẢN LÝ TÒA SOẠN TẠP CHÍ (DATAFRONTIERS REVIEW QUARTERLY)

## 👥 Thành viên nhóm 11
* **Phạm Tuấn Long** - 24070349
* **Nguyễn Đức Anh** - 24070612
* **Phạm Đức Anh** - 24070344
* **Kiều Gia Long** - 24070503

**Giảng viên hướng dẫn:** Dr. Vũ Minh Đức  
**Trường Đại học:** Trường Quốc tế - Đại học Quốc gia Hà Nội (VNU-IS)

---

## 📌 Tổng quan Đề tài 4
Hệ thống quản lý quy trình nộp bài, phân công chuyên gia phản biện, chấm điểm độc lập và lên kế hoạch xuất bản các số tạp chí khoa học theo Quý cho tòa soạn **DataFrontiers Review Quarterly**. 

Cơ sở dữ liệu được thiết kế tối ưu hóa trên nền tảng **MySQL Engine (InnoDB)**, xử lý triệt để các bài toán toàn vẹn dữ liệu động thông qua hệ thống ràng buộc khóa, quy tắc xóa dữ liệu tham chiếu ngầm (`ON DELETE SET NULL`) và cơ chế tự động hóa nâng cao.

---

## 📁 Cấu trúc thư mục nộp bài chuẩn hóa
Dự án được tổ chức khoa học, phân rã mã nguồn thành các module độc lập theo đúng cấu trúc khuyến nghị nhằm tối ưu hóa việc quản trị và chấm điểm:

```text
project-final/
├── 📄 README.md               # Tài liệu hướng dẫn hệ thống này
├── 📄 report.pdf              # Báo cáo đồ án giữa kỳ hoàn chỉnh (PDF)
├── 📄 erd.png                 # Sơ đồ quan hệ thực thể mở rộng EER Diagram
├── 📄 01_schema.sql           # Khởi tạo cấu trúc rỗng cho 8 bảng vật lý (DDL)
├── 📄 02_seed_data.sql        # Làm sạch và đổ bộ dữ liệu mẫu thử nghiệm chuẩn (DML)
├── 📄 03_queries.sql          # Các câu lệnh truy vấn, thống kê vận hành tòa soạn
├── 📄 04_views.sql            # Định nghĩa các khung nhìn ảo hỗ trợ ban biên tập
├── 📄 05_routines.sql         # Thủ tục lưu trữ (Stored Procedure) kết xuất hiệu năng
├── 📄 06_triggers_events.sql  # Lập trình Trigger ngầm tự động hóa nghiệp vụ hạn chót
├── 📄 07_indexes_explain.sql  # Tạo chỉ mục và đánh giá tối ưu truy vấn bằng EXPLAIN
├── 📄 08_admin_backup.md      # Hướng dẫn quy trình Sao lưu và Phục hồi dữ liệu
└── 📄 09_tests.sql            # Kịch bản kiểm thử độc lập tính toàn vẹn và Trigger
