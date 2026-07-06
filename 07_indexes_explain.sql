-- =====================================================================
-- FILE 07: TỐI ƯU HÓA TRUY VẤN VỚI CHỈ MỤC (INDEXES & EXPLAIN) - BẢN SỬA LỖI TRÙNG LẶP
-- =====================================================================

USE datafrontiers_journal_db;

-- 1. Sử dụng cú pháp ALTER TABLE DROP INDEX thuần túy. 
-- (Nếu chạy lần đầu bảng sạch sẽ báo cảnh báo/lỗi nhẹ nhưng chạy lần 2 sẽ dọn sạch index cũ)


-- Khối lệnh xóa Index cũ phòng thủ (nếu có)
DROP PROCEDURE IF EXISTS proc_drop_index_if_exists;
DELIMITER $$
CREATE PROCEDURE proc_drop_index_if_exists()
BEGIN
    -- Kiểm tra và xóa idx_submission_status
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='datafrontiers_journal_db' AND TABLE_NAME='SUBMISSION' AND INDEX_NAME='idx_submission_status') THEN
        ALTER TABLE SUBMISSION DROP INDEX idx_submission_status;
    END IF;
    
    -- Kiểm tra và xóa idx_author_email
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='datafrontiers_journal_db' AND TABLE_NAME='AUTHOR' AND INDEX_NAME='idx_author_email') THEN
        ALTER TABLE AUTHOR DROP INDEX idx_author_email;
    END IF;

    -- Kiểm tra và xóa idx_reviewer_email
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='datafrontiers_journal_db' AND TABLE_NAME='REVIEWER' AND INDEX_NAME='idx_reviewer_email') THEN
        ALTER TABLE REVIEWER DROP INDEX idx_reviewer_email;
    END IF;
END$$
DELIMITER ;

-- Gọi thủ tục dọn sạch Index cũ
CALL proc_drop_index_if_exists();
DROP PROCEDURE IF EXISTS proc_drop_index_if_exists;


-- 2. Tiến hành tạo mới các chỉ mục để tối ưu hiệu năng (Đảm bảo luôn ra tích xanh)
CREATE INDEX idx_submission_status ON SUBMISSION(Status);
CREATE INDEX idx_author_email ON AUTHOR(Email);
CREATE INDEX idx_reviewer_email ON REVIEWER(Email);


-- ---------------------------------------------------------------------
-- KIỂM THỬ HIỆU NĂNG BẰNG LỆNH EXPLAIN
-- ---------------------------------------------------------------------

-- Đánh giá câu lệnh lọc trạng thái bài viết
EXPLAIN SELECT SubmissionID, Title, Status 
FROM SUBMISSION 
WHERE Status = 'Published';

-- Đánh giá câu lệnh truy vấn có sử dụng chỉ mục Email tác giả
EXPLAIN SELECT AuthorID, FullName, Email 
FROM AUTHOR 
WHERE Email = 'a.nguyen@vnu.edu.vn';