-- =====================================================================
-- ĐỒ ÁN CUỐI KỲ CƠ SỞ DỮ LIỆU - NHÓM 11
-- FILE: 09_tests.sql (Kịch bản kiểm thử độc lập và bằng chứng vận hành)
-- Đáp ứng barem: Đầy đủ Positive/Negative tests, kiểm thử toàn diện 
-- từ Ràng buộc hệ thống, Nghiệp vụ Query, View, Function đến Procedure.
-- =====================================================================

USE datafrontiers_journal_db;

-- ---------------------------------------------------------------------
-- PHẦN I: KIỂM THỬ CÁC RÀNG BUỘC CƠ SỞ DỮ LIỆU (SCHEMA CONSTRAINTS TEST)
-- ---------------------------------------------------------------------

-- === CA KIỂM THỬ 1.1: Kiểm tra tính hợp lệ khi thêm mới (Positive Test) ===
-- Mục đích: Đảm bảo bảng SUBMISSION nhận dữ liệu chuẩn xác không vật cản.
DELETE FROM SUBMISSION WHERE SubmissionID = 6;

INSERT INTO SUBMISSION (SubmissionID, Title, SubmitDate, Status)   
VALUES (6, 'Optimizing Supply Chain with IoT', '2026-06-28', 'Submitted'); 

-- Đầu ra kỳ vọng: Trả về thông tin bài viết số 6 vừa chèn thành công
SELECT SubmissionID, Title, Status FROM SUBMISSION WHERE SubmissionID = 6; 


-- === CA KIỂM THỬ 1.2: Thử nghiệm vi phạm ràng buộc dữ liệu (Negative Test) === [cite: 244]
-- Mục đích: Đảm bảo ràng buộc UNIQUE của thuộc tính Email hoạt động tốt.
-- HƯỚNG DẪN: Mồi thử 1 bản ghi có email cố định trước
INSERT IGNORE INTO AUTHOR (FullName, Email) VALUES ('Nguyen Van A', 'a.nguyen@vnu.edu.vn');

-- Lệnh dưới đây cố tình trùng Email Unique đã tồn tại -> Bạn có thể bỏ comment (--) để chụp ảnh lỗi Đỏ:
-- INSERT INTO AUTHOR (FullName, Email) VALUES ('Nguyen Van Trung', 'a.nguyen@vnu.edu.vn'); 


-- === CA KIỂM THỬ 1.3: Kiểm tra cơ chế tự động dọn rác dữ liệu (ON DELETE SET NULL) ===
-- Mục đích: Đảm bảo khi số phát hành bị hủy, các bài báo liên quan không bị xóa mất (mồ côi)[cite: 237, 238].
UPDATE SUBMISSION SET IssueID = NULL WHERE IssueID = 999;
DELETE FROM ISSUE WHERE IssueID = 999;

-- Chèn thử số phát hành ảo số 999
INSERT INTO ISSUE (IssueID, Volume, Number, Quarter, PublishYear, Title) 
VALUES (999, 10, 2, 2, 2026, 'Special Issue on Emerging IoT Frameworks');

-- Gán bài viết số 6 vào số phát hành ảo 999
UPDATE SUBMISSION SET IssueID = 999 WHERE SubmissionID = 6;

-- Thực hiện lệnh xóa số phát hành 999 để kích hoạt hành vi CASCADE/SET NULL
DELETE FROM ISSUE WHERE IssueID = 999;

-- Đầu ra kỳ vọng: Bài viết số 6 giữ nguyên, nhưng trường IssueID tự động chuyển thành NULL
SELECT SubmissionID, Title, IssueID FROM SUBMISSION WHERE SubmissionID = 6;


-- ---------------------------------------------------------------------
-- PHẦN II: KIỂM THỬ BỘ KÍCH HOẠT VÀ LOGIC TỰ ĐỘNG (TRIGGER TESTS)
-- ---------------------------------------------------------------------

-- === CA KIỂM THỬ 2.1: Tự động tính hạn chót phản biện (Trigger DueDate) === [cite: 241]
-- Mục đích: Kiểm tra Trigger BEFORE INSERT tự điền DueDate = AssignedDate + 30 ngày nếu để trống.
DELETE FROM REVIEW_ASSIGNMENT WHERE AssignmentID = 9;

-- Mồi dữ liệu nền an toàn tránh lỗi ràng buộc khóa ngoại (FK Orphan Constraint) [cite: 237]
INSERT IGNORE INTO SUBMISSION (SubmissionID, Title, SubmitDate, Status)
VALUES (5, 'Advanced Blockchain Architecture for IoT', '2026-06-25', 'Under Review');

INSERT IGNORE INTO REVIEWER (ReviewerID, FullName, Email, Institution, AcademicDegree)
VALUES (4, 'Dr. John Doe', 'john.doe@academy.edu', 'Stanford University', 'Associate Professor');

-- Thực hiện chèn mới phân công và cố tình để TRỐNG (NULL) trường hạn chót DueDate
INSERT INTO REVIEW_ASSIGNMENT (AssignmentID, SubmissionID, ReviewerID, AssignedDate, DueDate) 
VALUES (9, 5, 4, '2026-07-01', NULL);

-- Đầu ra kỳ vọng: Thuộc tính DueDate tự tính toán nhảy thành ngày '2026-07-31'
SELECT AssignmentID, SubmissionID, AssignedDate, DueDate 
FROM REVIEW_ASSIGNMENT 
WHERE AssignmentID = 9;


-- ---------------------------------------------------------------------
-- PHẦN III: KIỂM THỬ CÁC TRUY VẤN VẬN HÀNH NGHIỆP VỤ (BUSINESS QUERIES PACK) [cite: 50, 238]
-- ---------------------------------------------------------------------

-- === QUERIES 3.1: Thống kê danh sách bài viết theo trạng thái hiện tại (Lập báo cáo tổng quan) ===
SELECT Status AS 'Trạng Thái Bài Nộp', COUNT(SubmissionID) AS 'Số Lượng Bài'
FROM SUBMISSION
GROUP BY Status
ORDER BY COUNT(SubmissionID) DESC;


-- === QUERIES 3.2: Tìm các bài viết chưa đủ 3 chuyên gia phản biện thẩm định (Tìm lỗ hổng tiến độ) ===
SELECT s.SubmissionID AS 'Mã Bài', s.Title AS 'Tiêu Đề Bài Viết', COUNT(ra.ReviewerID) AS 'Số Chuyên Gia Đang Gán'
FROM SUBMISSION s
LEFT JOIN REVIEW_ASSIGNMENT ra ON s.SubmissionID = ra.SubmissionID
WHERE s.Status IN ('Submitted', 'Under Review')
GROUP BY s.SubmissionID, s.Title
HAVING COUNT(ra.ReviewerID) < 3;


-- === QUERIES 3.3: Tính điểm trung bình của từng bài viết (Kết xuất dữ liệu xét duyệt xuất bản) ===
SELECT s.SubmissionID AS 'Mã Bài', s.Title AS 'Tiêu Đề Bài Viết',
       ROUND(AVG(ra.Score), 2) AS 'Điểm Phản Biện Trung Bình'
FROM SUBMISSION s
INNER JOIN REVIEW_ASSIGNMENT ra ON s.SubmissionID = ra.SubmissionID
WHERE ra.CompletedDate IS NOT NULL
GROUP BY s.SubmissionID, s.Title;


-- ---------------------------------------------------------------------
-- PHẦN IV: KIỂM THỬ ĐỐI TƯỢNG LOGIC MỞ RỘNG (ROUTINES: FUNCTIONS & PROCEDURES) [cite: 104, 259]
-- ---------------------------------------------------------------------

-- === CA KIỂM THỬ 4.1: Kiểm tra Stored Function đếm số bài phản biện hoàn thành === [cite: 239]
-- Mục đích: Đảm bảo hàm fn_count_total_reviews xử lý tính toán chính xác giá trị vô hướng (Scalar).
SELECT fn_count_total_reviews(4) AS Test_Function_Result;


-- === CA KIỂM THỬ 4.2: Thao tác nộp bài qua Procedure an toàn với dữ liệu HỢP LỆ (Positive Test) === [cite: 240]
-- Mục đích: Đảm bảo dữ liệu được ghi đồng bộ sang nhiều bảng thông qua TRANSACTION.
-- Điều kiện: Tác giả ID = 1 đã có sẵn trong bảng AUTHOR để vượt qua bộ chặn nghiệp vụ.
CALL proc_submit_article_safe(
    'Blockchain Security Framework for Cloud Database', 
    'Abstract text...', 
    'Blockchain, Cloud', 
    1
);

-- Xác nhận đầu ra: Dữ liệu đã xuất hiện đồng thời ở cả hai bảng liên quan (Không bị mồ côi) [cite: 235]
SELECT * FROM SUBMISSION WHERE Title LIKE '%Blockchain Security%';


-- === CA KIỂM THỬ 4.3: Thao tác nộp bài qua Procedure với dữ liệu SAI SÓT (Negative Test) === [cite: 240, 246]
-- Mục đích: Kiểm thử bộ phòng thủ chủ động bọc lỗi thông minh 1644 của nhóm 11.
-- Hành vi: Truyền vào mã tác giả ma (ID = 9999) hoàn toàn không tồn tại trong hệ thống.
-- Đầu ra kỳ vọng: MySQL chặn đứng hoàn toàn Transaction và ném ra thông điệp lỗi gạch chéo đỏ:
--                 "Error Code: 1644. Lỗi nghiệp vụ: Mã tác giả (AuthorID) không tồn tại!"
CALL proc_submit_article_safe(
    'Ghost Article Test', 
    'Abstract...', 
    'Test', 
    9999
);