-- 9.1
WITH completed_lessons AS (SELECT LessonType FROM Lessons WHERE Status = 'Completed')
SELECT LessonType, COUNT(*) AS completed_count
FROM completed_lessons GROUP BY LessonType ORDER BY LessonType;
-- 9.2
WITH completed_payments AS (SELECT EnrollmentID, SUM(Amount) AS total_paid FROM Payments
    WHERE PaymentStatus = 'Completed' GROUP BY EnrollmentID),
enrollment_student AS (SELECT e.EnrollmentID, s.StudentID, s.FirstName, s.LastName,cp.total_paid
    FROM Enrollments e JOIN Students s ON e.StudentID = s.StudentID
    JOIN completed_payments cp ON e.EnrollmentID = cp.EnrollmentID)
SELECT FirstName, LastName, total_paid  FROM enrollment_student ORDER BY total_paid DESC LIMIT 3;
-- 9.3
WITH completed_2024 AS (
    SELECT DATE_TRUNC('month', PaymentDate) AS month_start, Amount FROM Payments
    WHERE PaymentStatus = 'Completed' AND EXTRACT(YEAR FROM PaymentDate) = 2024
)
SELECT EXTRACT(YEAR FROM month_start)  AS year, EXTRACT(MONTH FROM month_start) AS month,
       SUM(Amount) AS total_amount FROM completed_2024 GROUP BY year, month ORDER BY year, month;
-- 9.4
WITH completed_lessons AS (
    SELECT InstructorID, COUNT(*) AS lesson_cnt FROM Lessons WHERE Status = 'Completed'
    GROUP BY InstructorID
)
SELECT i.FirstName || ' ' || i.LastName AS instructor_name, cl.lesson_cnt
FROM completed_lessons cl JOIN Instructors i ON i.InstructorID = cl.InstructorID
ORDER BY cl.lesson_cnt DESC;

-- 9. 5
WITH enrollment_counts AS (
    SELECT StudentID, COUNT(*) AS enrollment_cnt FROM Enrollments
    GROUP BY StudentID HAVING COUNT(*) > 1
)
SELECT s.FirstName,
       s.LastName,
       ec.enrollment_cnt
FROM enrollment_counts ec JOIN Students s ON s.StudentID = ec.StudentID
ORDER BY ec.enrollment_cnt DESC, s.LastName, s.FirstName;
