
-- 12.1
-- Student - role
/*
| Table       | SELECT            | INSERT | UPDATE | DELETE |
|------------|-------------------|--------|--------|--------|
| Students   | Own rows only     | No     | No     | No     |
| Enrollments| Own rows only (only their own enrollments) | No | No | No |
| Lessons    | Own rows only (only lessons linked to their enrollments) | No | No | No |
| Payments   | No (cannot see any payment amounts) | No | No | No |
*/

-- 12.2 - Instructor Role
/*
| Table       | SELECT                               | INSERT | UPDATE                         | DELETE |
|------------|---------------------------------------|--------|-------------------------------|--------|
| Students   | No                                    | No     | No                            | No     |
| Enrollments| No (instructors see only through lessons) | No | No | No |
| Lessons    | Own rows only (only lessons they teach) | No (lessons are created by scheduling system) | Own rows only (can update Score, Status) | No |
| Payments   | No (cannot view any payment data)    | No     | No                            | No     |
*/

-- 12.3 - Manager Role
/*
| Table       | SELECT                                   | INSERT | UPDATE                         | DELETE |
|------------|-------------------------------------------|--------|-------------------------------|--------|
| Students   | Own rows only (students belonging to manager’s branch) | No | Own rows only (e.g., update contact info) | No |
| Enrollments| Own rows only (branch‑specific enrollments) | Yes (can create enrollments) | Own rows only (change status) | No |
| Lessons    | Own rows only (lessons held at manager’s branch) | Yes (schedule lessons) | Own rows only (change status/score) | No |
| Payments   | Own rows only (payments for enrollments in branch) | Yes (record payments) | Own rows only (adjust amount/status) | No (cannot delete payment records) |
*/

-- 12.4 - Data Analyst Role
/*
| Table       | SELECT                                   | INSERT | UPDATE | DELETE |
|------------|-------------------------------------------|--------|--------|--------|
| Students   | Yes (but column CNP must be hidden – can be achieved via a view that omits CNP) | No | No | No |
| Enrollments| Yes (full read‑only)                     | No | No | No |
| Lessons    | Yes (full read‑only)                     | No | No | No |
| Payments   | Yes (full read‑only)                     | No | No | No |
*/

-- 12.5 - Short Answer
/*
Because allowing students to delete rows would let them remove or
tamper with core business data (their own enrollment records,
lesson results, or even other students’ data if constraints are
bypassed). Deleting records can corrupt the audit trail, break
referential integrity, and violate data‑retention policies. Therefore,
the Student role must be limited to read‑only (or at most update
their own contact information) and never granted DELETE rights.
*/