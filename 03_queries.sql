-- =====================================================================
-- FILE 03: TRUY VẤN THỐNG KÊ PHỤC VỤ VẬN HÀNH (MỤC 6.4)
-- =====================================================================

USE datafrontiers_journal_db;

-- Query 1: Thống kê mật độ bài viết theo từng trạng thái hiện tại
SELECT Status AS 'Trạng Thái Bài Nộp', COUNT(SubmissionID) AS 'Số Lượng Bài' 
FROM SUBMISSION 
GROUP BY Status 
ORDER BY COUNT(SubmissionID) DESC; 

-- Query 2: Đưa ra cảnh báo nhanh những bài viết chưa được gán đủ 3 chuyên gia phản biện
SELECT s.SubmissionID AS 'Mã Bài', s.Title AS 'Tiêu Đề Bài Viết', COUNT(ra.ReviewerID) AS 'Số Chuyên Gia Đang Gán' 
FROM SUBMISSION s 
LEFT JOIN REVIEW_ASSIGNMENT ra ON s.SubmissionID = ra.SubmissionID 
WHERE s.Status IN ('Submitted', 'Under Review') 
GROUP BY s.SubmissionID, s.Title 
HAVING COUNT(ra.ReviewerID) < 3; 

-- Query 3: Tính toán điểm số tổng kết trung bình của từng bài viết đã hoàn thành phản biện
SELECT SubmissionID AS 'Mã Bài Nộp', ROUND(AVG(Score), 2) AS 'Điểm Số Trung Bình' 
FROM REVIEW_ASSIGNMENT 
WHERE Score IS NOT NULL 
GROUP BY SubmissionID;


-- =====================================================================
-- Q01: Filter + Order trên một bảng (Danh sách bài báo đang chờ duyệt sắp xếp theo ngày nộp) [cite: 52]
-- =====================================================================
SELECT SubmissionID, Title, SubmitDate, Status 
FROM SUBMISSION 
WHERE Status = 'Submitted' 
ORDER BY SubmitDate ASC;

-- =====================================================================
-- Q02: INNER JOIN 3 bảng trở lên (Lấy danh sách Bài báo - Tác giả - Cơ quan công tác) [cite: 52]
-- =====================================================================
SELECT s.SubmissionID, s.Title, a.FullName AS AuthorName, a.Affiliation
FROM SUBMISSION s
JOIN SUBMISSION_AUTHOR sa ON s.SubmissionID = sa.SubmissionID
JOIN AUTHOR a ON sa.AuthorID = a.AuthorID
ORDER BY s.SubmissionID;

-- =====================================================================
-- Q03: LEFT JOIN / Tìm kiếm dữ liệu thiếu (Tìm chuyên gia chưa từng được phân công bài nào) [cite: 52]
-- =====================================================================
SELECT r.ReviewerID, r.FullName, r.Email
FROM REVIEWER r
LEFT JOIN REVIEW_ASSIGNMENT ra ON r.ReviewerID = ra.ReviewerID
WHERE ra.AssignmentID IS NULL;

-- =====================================================================
-- Q04: GROUP BY + HAVING (Thống kê các chuyên gia phản biện nhận từ 2 bài trở lên) [cite: 52]
-- =====================================================================
SELECT ReviewerID, COUNT(AssignmentID) AS TotalAssigned
FROM REVIEW_ASSIGNMENT
GROUP BY ReviewerID
HAVING TotalAssigned >= 2;

-- =====================================================================
-- Q05: Subquery dùng EXISTS / NOT EXISTS (Tìm bài báo chưa được gán cho bất kỳ chuyên gia nào) [cite: 52]
-- =====================================================================
SELECT s.SubmissionID, s.Title
FROM SUBMISSION s
WHERE NOT EXISTS (
    SELECT 1 FROM REVIEW_ASSIGNMENT ra 
    WHERE ra.SubmissionID = s.SubmissionID
);

-- =====================================================================
-- Q06: Sử dụng CTE hoặc Derived Table (Tính điểm trung bình phản biện và lọc bài đạt > 80 điểm) [cite: 52]
-- =====================================================================
WITH ArticleScores AS (
    SELECT SubmissionID, AVG(Score) AS AverageScore
    FROM REVIEW_ASSIGNMENT
    WHERE Score IS NOT NULL
    GROUP BY SubmissionID
)
SELECT s.SubmissionID, s.Title, round(ask.AverageScore, 2) AS FinalScore
FROM SUBMISSION s
JOIN ArticleScores ask ON s.SubmissionID = ask.SubmissionID
WHERE ask.AverageScore > 80;

-- =====================================================================
-- Q07: Thống kê báo cáo theo thời gian (Số lượng bài nộp theo từng tháng trong năm 2026) [cite: 52]
-- =====================================================================
SELECT MONTH(SubmitDate) AS SubmitMonth, COUNT(*) AS TotalSubmissions
FROM SUBMISSION
WHERE YEAR(SubmitDate) = 2026
GROUP BY MONTH(SubmitDate)
ORDER BY SubmitMonth;

-- =====================================================================
-- Q08: Sử dụng View hoặc Function đã tạo (Gọi hàm đếm tổng số bài hoàn thành của Reviewer) [cite: 52]
-- =====================================================================
SELECT ReviewerID, FullName, fn_count_total_reviews(ReviewerID) AS CompletedReviews
FROM REVIEWER;