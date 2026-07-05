-- =====================================================================
-- FILE 04: KHỞI TẠO KHUNG NHÌN (VIEWS)
-- =====================================================================

USE datafrontiers_journal_db;

DROP VIEW IF EXISTS view_published_articles;

-- Khung nhìn chi tiết các bài báo đã xuất bản cùng tác giả chính và số phát hành
CREATE VIEW view_published_articles AS
SELECT 
    s.SubmissionID,
    s.Title AS 'Article_Title',
    a.FullName AS 'Primary_Author',
    i.Title AS 'Journal_Issue',
    i.PublishDate
FROM SUBMISSION s
JOIN SUBMISSION_AUTHOR sa ON s.SubmissionID = sa.SubmissionID AND sa.AuthorOrder = 1
JOIN AUTHOR a ON sa.AuthorID = a.AuthorID
JOIN ISSUE i ON s.IssueID = i.IssueID
WHERE s.Status = 'Published';

-- Chạy thử View kiểm tra dữ liệu
SELECT * FROM view_published_articles;


-- =====================================================================
-- VIEW SỐ 2: vw_reviewer_pending_assignments
-- Mục đích: Giúp Ban biên tập theo dõi các chuyên gia đang có bài chờ phản biện
--           và số ngày họ còn lại trước khi trễ hạn.
-- =====================================================================
CREATE OR REPLACE VIEW vw_reviewer_pending_assignments AS
SELECT 
    r.ReviewerID,
    r.FullName AS ReviewerName,
    r.Institution,
    COUNT(ra.AssignmentID) AS TotalPendingReviews,
    MIN(ra.DueDate) AS NextDeadline,
    DATEDIFF(MIN(ra.DueDate), CURDATE()) AS DaysLeft
FROM REVIEWER r
JOIN REVIEW_ASSIGNMENT ra ON r.ReviewerID = ra.ReviewerID
WHERE ra.CompletedDate IS NULL
GROUP BY r.ReviewerID, r.FullName, r.Institution;

-- Kịch bản kiểm thử nhanh View số 2 (Theo yêu cầu barem trang 6 )
SELECT * FROM vw_reviewer_pending_assignments WHERE DaysLeft >= 0;