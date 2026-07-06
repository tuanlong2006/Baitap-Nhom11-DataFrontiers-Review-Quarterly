-- =====================================================================
-- ĐỒ ÁN CUỐI KỲ CƠ SỞ DỮ LIỆU - NHÓM 11
-- FILE: 05_routines.sql (Định nghĩa Stored Procedures & Stored Functions)
-- =====================================================================

USE datafrontiers_journal_db;

-- ---------------------------------------------------------------------
-- PHẦN I: ĐỊNH NGHĨA CÁC STORED FUNCTIONS (HÀM LƯU TRỮ)
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_count_total_reviews;
DELIMITER $$
CREATE FUNCTION fn_count_total_reviews(p_reviewer_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total INT DEFAULT 0;
    SELECT COUNT(*) INTO v_total
    FROM REVIEW_ASSIGNMENT
    WHERE ReviewerID = p_reviewer_id 
      AND CompletedDate IS NOT NULL;
    RETURN v_total;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- PHẦN II: ĐỊNH NGHĨA CÁC STORED PROCEDURES (THỦ TỤC LƯU TRỮ)
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_get_reviewer_performance;
DELIMITER $$
CREATE PROCEDURE proc_get_reviewer_performance()
BEGIN
    SELECT 
        r.ReviewerID,
        r.FullName AS ReviewerName,
        COUNT(ra.AssignmentID) AS TotalAssigned,
        SUM(CASE WHEN ra.CompletedDate IS NOT NULL THEN 1 ELSE 0 END) AS TotalCompleted,
        ROUND(AVG(ra.Score), 2) AS AverageScoreGiven
    FROM REVIEWER r
    LEFT JOIN REVIEW_ASSIGNMENT ra ON r.ReviewerID = ra.ReviewerID
    GROUP BY r.ReviewerID, r.FullName
    ORDER BY TotalCompleted DESC, AverageScoreGiven DESC;
END$$
DELIMITER ;

-- =====================================================================
-- PROCEDURE SỐ 2: proc_submit_article_safe (BẢN ĐÃ CHUẨN HÓA BỘ BỌC LỖI)
-- =====================================================================
DROP PROCEDURE IF EXISTS proc_submit_article_safe;

DELIMITER $$

CREATE PROCEDURE proc_submit_article_safe(
    IN p_title VARCHAR(300),
    IN p_abstract TEXT,
    IN p_keywords VARCHAR(300),
    IN p_author_id INT
)
BEGIN
    DECLARE v_submission_id INT;
    DECLARE v_author_exists INT DEFAULT 0;
    
    -- [BƯỚC 1: KIỂM TRA CHẶN NGHIỆP VỤ - ĐẶT TRƯỚC BỘ XỬ LÝ LỖI HỆ THỐNG]
    SELECT COUNT(*) INTO v_author_exists FROM AUTHOR WHERE AuthorID = p_author_id;

    -- Nếu tác giả không tồn tại, lập tức ném lỗi 1644 ra màn hình để báo cáo
    IF v_author_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Mã tác giả (AuthorID) không tồn tại!';
    END IF;

    -- [BƯỚC 2: BỘ BỌC LỖI HỆ THỐNG VẬT LÝ - CHỈ BAO PHỦ TIẾN TRÌNH TRANSACTION]
    BEGIN
        -- Khai báo bộ bọc lỗi hệ thống khách quan bên trong khối nghiệp vụ ghi dữ liệu
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Xảy ra lỗi hệ thống nghiêm trọng! Tiến trình giao dịch bị hủy bỏ.';
        END;

        -- Tiến hành chuỗi hành vi ghi dữ liệu đồng bộ an toàn
        START TRANSACTION;
            
            -- 1. Thêm mới bài viết vào bảng SUBMISSION
            INSERT INTO SUBMISSION (Title, Abstract, Keywords, SubmitDate, Status)
            VALUES (p_title, p_abstract, p_keywords, CURDATE(), 'Submitted');
            
            -- Lấy ra ID tự tăng vừa sinh ra của bài viết
            SET v_submission_id = LAST_INSERT_ID();
            
            -- 2. Thêm vào bảng liên kết SUBMISSION_AUTHOR 
            INSERT INTO SUBMISSION_AUTHOR (SubmissionID, AuthorID, AuthorOrder)
            VALUES (v_submission_id, p_author_id, 1);
            
        COMMIT;
    END;
END$$

DELIMITER ;