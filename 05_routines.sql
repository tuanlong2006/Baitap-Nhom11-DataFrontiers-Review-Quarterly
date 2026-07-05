-- =====================================================================
-- ĐỒ ÁN GIỮA KỲ CƠ SỞ DỮ LIỆU - NHÓM 11
-- FILE: 05_routines.sql (Định nghĩa Stored Procedures & Stored Functions)
-- Đáp ứng barem: Ít nhất 2 Procedures + 1 Function hoạt động ổn định
-- =====================================================================

-- ---------------------------------------------------------------------
-- PHẦN I: ĐỊNH NGHĨA CÁC STORED FUNCTIONS (HÀM LƯU TRỮ)
-- ---------------------------------------------------------------------

-- =====================================================================
-- FUNCTION SỐ 1: fn_count_total_reviews
-- Mục đích: Trả về tổng số bài báo mà một chuyên gia đã phản biện hoàn thành.
-- =====================================================================
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

-- =====================================================================
-- PROCEDURE SỐ 1: proc_get_reviewer_performance
-- Mục đích: Kết xuất báo cáo hiệu suất phản biện của các chuyên gia.
-- =====================================================================
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
-- PROCEDURE SỐ 2: proc_submit_article_safe
-- Mục đích: Thực hiện nghiệp vụ nộp bài bọc TRANSACTION an toàn.
--           Tự động gán tác giả chính vào bảng trung gian submission_author.
--           Ném lỗi nghiệp vụ (1644) trực quan cho các kịch bản kiểm thử lỗi.
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
    
    -- Bộ bọc lỗi hệ thống khách quan (sập kết nối, lỗi phần cứng, tràn dữ liệu)
    -- Sẽ tự động ROLLBACK để bảo vệ dữ liệu không bị mồ côi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @p_sqlstate = RETURNED_SQLSTATE;
        -- Nếu không phải mã lỗi nghiệp vụ chủ động (45000) thì mới báo lỗi hệ thống chung
        IF @p_sqlstate <> '45000' THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Xảy ra lỗi hệ thống nghiêm trọng! Tiến trình giao dịch bị hủy bỏ.';
        END IF;
    END;

    -- [BƯỚC KIỂM TRA CHẶN NGHIỆP VỤ - CHẠY TRƯỚC TRANSACTION]
    -- Kiểm tra nếu tác giả không tồn tại thì lập tức chặn lại và ném thông báo rõ ràng
    IF NOT EXISTS (SELECT 1 FROM AUTHOR WHERE AuthorID = p_author_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Mã tác giả (AuthorID) không tồn tại!';
    END IF;

    -- Nếu tác giả hợp lệ, bắt đầu chuỗi hành vi ghi dữ liệu đồng bộ
    START TRANSACTION;
        
        -- 1. Thêm mới bài viết vào bảng SUBMISSION
        INSERT INTO SUBMISSION (Title, Abstract, Keywords, SubmitDate, Status)
        VALUES (p_title, p_abstract, p_keywords, CURDATE(), 'Submitted');
        
        -- Lấy ra ID tự tăng vừa sinh ra của bài viết
        SET v_submission_id = LAST_INSERT_ID();
        
        -- 2. Thêm vào bảng liên kết SUBMISSION_AUTHOR (Tác giả chính có thứ tự số 1)
        INSERT INTO SUBMISSION_AUTHOR (SubmissionID, AuthorID, AuthorOrder)
        VALUES (v_submission_id, p_author_id, 1);
        
    COMMIT;
END$$

DELIMITER ;