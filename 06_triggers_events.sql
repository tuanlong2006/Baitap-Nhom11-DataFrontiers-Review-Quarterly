-- =====================================================================
-- FILE 06: LẬP TRÌNH TRIGGER VÀ SỰ KIỆN CHẠY NGẦM
-- =====================================================================

USE datafrontiers_journal_db;

DROP TRIGGER IF EXISTS tg_auto_set_due_date;

DELIMITER $$

CREATE TRIGGER tg_auto_set_due_date
BEFORE INSERT ON REVIEW_ASSIGNMENT
FOR EACH ROW
BEGIN
    -- Hệ thống kiểm tra: Nếu biên tập viên để trống hạn chót (NULL)
    IF NEW.DueDate IS NULL THEN
        -- Tự động tính toán lấy Ngày giao bài cộng thêm đúng 30 ngày để điền vào
        SET NEW.DueDate = DATE_ADD(NEW.AssignedDate, INTERVAL 30 DAY);
    END IF;
END$$

DELIMITER ;