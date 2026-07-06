-- =====================================================================
-- FILE 02: NẠP DỮ LIỆU MẪU (SEED DATA)
-- =====================================================================

USE datafrontiers_journal_db;

-- Reset dữ liệu để đảm bảo chạy lại nhiều lần không lỗi
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE REVIEW_ASSIGNMENT;
TRUNCATE TABLE REVIEWER_FIELD;
TRUNCATE TABLE SUBMISSION_AUTHOR;
TRUNCATE TABLE SUBMISSION;
TRUNCATE TABLE REVIEWER;
TRUNCATE TABLE AUTHOR;
TRUNCATE TABLE EXPERTISE_FIELD;
TRUNCATE TABLE ISSUE;
SET FOREIGN_KEY_CHECKS = 1;

-- CHÈN LĨNH VỰC CHUYÊN MÔN
INSERT INTO EXPERTISE_FIELD (FieldID, FieldName, Description) VALUES  
(1, 'Data Science & Machine Learning', 'DS01'),
(2, 'Information Systems Management', 'IS02'),
(3, 'Business Analytics & Optimization', 'BA03'),
(4, 'Artificial Intelligence Ethics', 'AI04'),
(5, 'Big Data Architecture & Cloud', 'BD05');

-- CHÈN SỐ PHÁT HÀNH TẠP CHÍ THEO QUÝ (Đặc thù Đề tài 4)
INSERT INTO ISSUE (IssueID, Volume, Number, Quarter, PublishYear, PublishDate, Title, Status) VALUES
(1, 1, 1, 1, 2026, '2026-03-15', 'DataFrontiers Review: Vol 1 No 1 (Q1/2026)', 'Published'),
(2, 1, 2, 2, 2026, '2026-06-15', 'DataFrontiers Review: Vol 1 No 2 (Q2/2026)', 'Published'),
(3, 1, 3, 3, 2026, NULL,         'DataFrontiers Review: Vol 1 No 3 (Q3/2026)', 'Draft');

-- CHÈN TÁC GIẢ
INSERT INTO AUTHOR (AuthorID, FullName, Email, Phone, Affiliation) VALUES  
(1, 'Nguyen Van A', 'a.nguyen@vnu.edu.vn', '0912345678', 'VNU International School'),
(2, 'Tran Thi B', 'b.tran@hust.edu.vn', '0923456789', 'Hanoi University of Science and Technology'),
(3, 'Le Van C', 'c.le@hcmut.edu.vn', '0934567890', 'VNUHCM-University of Technology'),
(4, 'Pham Minh D', 'd.pham@hmu.edu.vn', '0945678901', 'Hanoi Medical University'),
(5, 'Hoang Ngo E', 'e.hoang@vnu.edu.vn', '0956789012', 'VNU University of Engineering and Technology');

-- CHÈN CHUYÊN GIA PHẢN BIỆN
INSERT INTO REVIEWER (ReviewerID, FullName, Email, Institution, AcademicDegree) VALUES  
(1, 'Prof. John Smith', 'john.smith@stanford.edu', 'Stanford University', 'Professor'),
(2, 'Dr. Alice Brown', 'alice.b@oxford.ac.uk', 'University of Oxford', 'Doctor'),
(3, 'Phd. Nguyen Duc M', 'minh.nd@vnu.edu.vn', 'VNU International School', 'Phd'),
(4, 'Assoc. Prof. Lee', 'kwang.lee@kaist.ac.kr', 'KAIST University', 'Associate Professor'),
(5, 'Dr. Elena Rostova', 'rostova.e@mit.edu', 'MIT', 'Doctor');

-- CHÈN BÀI VIẾT PHÂN QUYỀN VÀO SỐ TẠP CHÍ
INSERT INTO SUBMISSION (SubmissionID, IssueID, Title, Abstract, Keywords, SubmitDate, Status) VALUES  
(1, 1, 'Deep Learning for Credit Scoring', 'Abstract 1...', 'DL, Credit', '2026-01-10', 'Published'),
(2, 1, 'Blockchain in Healthcare Records', 'Abstract 2...', 'Blockchain', '2026-01-15', 'Published'),
(3, 2, 'Socio-Economic Impacts of AI Logistics', 'Abstract 3...', 'AI, Logistics', '2026-04-01', 'Scheduled'),
(4, 3, 'Predictive Analytics for Retail Chains', 'Abstract 4...', 'Analytics, Retail', '2026-04-12', 'Under Review'),
(5, NULL, 'An Efficient Cloud Framework for Big Data', 'Abstract 5...', 'Cloud, Big Data', '2026-05-20', 'Submitted');

-- LIÊN KẾT BÀI VIẾT - TÁC GIẢ
INSERT INTO SUBMISSION_AUTHOR (SubmissionID, AuthorID, AuthorOrder) VALUES  
(1, 1, 1), (1, 2, 2), (2, 3, 1), (3, 4, 1), (4, 5, 1), (5, 1, 1);

-- LIÊN KẾT CHUYÊN GIA - LĨNH VỰC CHUYÊN MÔN
INSERT INTO REVIEWER_FIELD (ReviewerID, FieldID) VALUES  
(1, 1), (1, 5), (2, 2), (2, 3), (3, 1), (3, 3), (4, 4), (5, 5);

-- CHÈN LỊCH SỬ PHÂN CÔNG PHẢN BIỆN (Mục số 7, 8 để NULL DueDate)
INSERT INTO REVIEW_ASSIGNMENT (AssignmentID, SubmissionID, ReviewerID, AssignedDate, DueDate, CompletedDate, Score, Recommendation, Comments) VALUES  
(1, 1, 1, '2026-01-12', '2026-02-12', '2026-02-05', 9, 'Accept', 'Excellent approach to deep learning architectures.'),
(2, 1, 3, '2026-01-12', '2026-02-12', '2026-02-06', 8, 'Accept', 'Good methodology, minor corrections required.'),
(3, 1, 2, '2026-01-14', '2026-02-14', '2026-02-10', 7, 'Accept', 'Well-written paper with comprehensive references.'),
(4, 2, 2, '2026-01-18', '2026-02-18', '2026-02-15', 9, 'Accept', 'Highly innovative application of blockchain.'),
(5, 2, 5, '2026-01-18', '2026-02-18', '2026-02-17', 8, 'Accept', 'Solid contribution to healthcare data standards.'),
(6, 3, 2, '2026-04-05', '2026-05-05', '2026-04-25', 9, 'Accept', 'A thoroughly detailed socio-economic study.'),
(7, 4, 1, '2026-04-15', NULL,         NULL,         NULL, NULL,           'Review process is currently active.'),
(8, 4, 3, '2026-04-15', NULL,         NULL,         NULL, NULL,           'Pending reviewer evaluation form.');