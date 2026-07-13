-- 6.1 
-- 1. Information that is repeated - StudentName, BranchName, StudentEmail
-- 2. Email is one of the informations that is repeated. If a student updates the email,
-- all rows related to the student must be updated (since all of them contain the email).
-- 3. Students, Branches, Instructors, CourseTypes, Lessons, Enrollments

-- 6.2
-- Students(StudentID - Primary key, StudentName, StudentEmail)
-- Branches(BranchID - PK, BranchName)
-- Instructors(InstructorID - PK, InstructorName)
-- Courses(CourseID - PK, BranchID - FK to Branches, InstructorID - FK to Instructors, CourseName)
-- Enrollment(EnrollmentID - PK, CourseID - FK to Courses, StudentID - FK to Students)
-- Lessons(LessonID - PK, EnrollmentID - FK to Enrollment, LessonDate, Score)

-- 6.3
-- 1. The link between lessons and students is done through "Enrollments" table (lessons has FK to enrollments and
-- enrollments has FK to students), so including names in lessons would break normalization and make updating the name
-- of a student more complicated (it would require updating more rows).
-- 2. 
SELECT s.FirstName, s.LastName FROM Lessons l
JOIN Enrollments e ON l.EnrollmentID = e.EnrollmentID
JOIN Students s ON e.StudentID = s.StudentID WHERE LessonID = 1;

