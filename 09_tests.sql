-- =====================================================================
-- FILE 09: KỊCH BẢN KIỂM THỬ ĐỘC LẬP TÍNH TOÀN VẸN (TEST CASES)
-- =====================================================================

USE datafrontiers_journal_db;

-- ---------------------------------------------------------------------
-- TEST CASE 1: Kiểm tra tính hợp lệ (Positive Test - Chèn bài viết số 6)
-- ---------------------------------------------------------------------
DELETE FROM SUBMISSION WHERE SubmissionID = 6;

INSERT INTO SUBMISSION (SubmissionID, Title, SubmitDate, Status)  
VALUES (6, 'Optimizing Supply Chain with IoT', '2026-06-28', 'Submitted'); 

SELECT SubmissionID, Title, Status FROM SUBMISSION WHERE SubmissionID = 6; 


-- ---------------------------------------------------------------------
-- TEST CASE 2: Thử nghiệm vi phạm ràng buộc dữ liệu (Phòng thủ hệ thống)
-- ---------------------------------------------------------------------
-- Lệnh dưới đây cố tình trùng Email Unique -> Bỏ comment (--) để test lỗi Đỏ:
-- INSERT INTO AUTHOR (FullName, Email) VALUES ('Nguyen Van Trung', 'a.nguyen@vnu.edu.vn'); 


-- ---------------------------------------------------------------------
-- TEST CASE 3: Kiểm tra cơ chế tự động dọn rác dữ liệu ON DELETE SET NULL
-- ---------------------------------------------------------------------
UPDATE SUBMISSION SET IssueID = NULL WHERE IssueID = 999;
DELETE FROM ISSUE WHERE IssueID = 999;

-- Chèn số phát hành phụ số 999
INSERT INTO ISSUE (IssueID, Volume, Number, Quarter, PublishYear, Title) 
VALUES (999, 10, 2, 2, 2026, 'Special Issue on Emerging IoT Frameworks');

-- Gán bài 6 vào số 999
UPDATE SUBMISSION SET IssueID = 999 WHERE SubmissionID = 6;

-- Xóa số phát hành 999
DELETE FROM ISSUE WHERE IssueID = 999;

-- Kết quả kỳ vọng: Bài 6 không mất, trường IssueID tự động chuyển thành NULL
SELECT SubmissionID, Title, IssueID FROM SUBMISSION WHERE SubmissionID = 6;


-- ---------------------------------------------------------------------
-- TEST CASE 4: KIỂM THỬ TÍNH NĂNG TRIGGER TỰ TÍNH TOÁN DUE_DATE (NÂNG CAO)
-- ---------------------------------------------------------------------
DELETE FROM REVIEW_ASSIGNMENT WHERE AssignmentID = 9;

-- Mồi dữ liệu an toàn đảm bảo không dính lỗi khóa ngoại 1452
INSERT IGNORE INTO SUBMISSION (SubmissionID, Title, SubmitDate, Status)
VALUES (5, 'Advanced Blockchain Architecture for IoT', '2026-06-25', 'Under Review');

INSERT IGNORE INTO REVIEWER (ReviewerID, FullName, Email, Institution, AcademicDegree)
VALUES (4, 'Dr. John Doe', 'john.doe@academy.edu', 'Stanford University', 'Associate Professor');

-- Thực hiện chèn mới và để TRỐNG (NULL) trường DueDate
INSERT INTO REVIEW_ASSIGNMENT (AssignmentID, SubmissionID, ReviewerID, AssignedDate, DueDate) 
VALUES (9, 5, 4, '2026-07-01', NULL);

-- Kiểm tra kết quả xử lý chạy ngầm của Trigger
SELECT AssignmentID, SubmissionID, AssignedDate, DueDate 
FROM REVIEW_ASSIGNMENT 
WHERE AssignmentID = 9;
-- => ĐẦU RA KỲ VỌNG: DueDate tự nhảy thành '2026-07-31'


-- =====================================================================
-- KỊCH BẢN KIỂM THỬ CHO CÁC ĐỐI TƯỢNG MỚI BỔ SUNG (POSITIVE & NEGATIVE) [cite: 262]
-- =====================================================================

-- [TEST 1] Kiểm tra gọi hàm Function (Chuyên gia ID = 4) [cite: 239]
SELECT fn_count_total_reviews(4) AS Test_Function_Result;

-- [TEST 2 - POSITIVE] Chạy Procedure nộp bài với dữ liệu hợp lệ (Tác giả ID = 1 tồn tại) [cite: 240]
CALL proc_submit_article_safe(
    'Blockchain Security Framework for Cloud Database', 
    'Abstract text...', 
    'Blockchain, Cloud', 
    1
);
-- Xác nhận dữ liệu đã vào đủ cả 2 bảng (Dữ liệu không bị cô lập/mồ côi) [cite: 235]
SELECT * FROM SUBMISSION WHERE Title LIKE '%Blockchain Security%';

-- [TEST 3 - NEGATIVE] Chạy Procedure với mã tác giả không tồn tại (ID = 9999) -> Kỳ vọng hệ thống chặn lại [cite: 240, 246]
-- MySQL sẽ ném ra lỗi thông báo: "Lỗi nghiệp vụ: Mã tác giả (AuthorID) không tồn tại!"
CALL proc_submit_article_safe(
    'Ghost Article Test', 
    'Abstract...', 
    'Test', 
    9999
);