-- 8.1
-- Yes, create index on EnrollmentID column.
-- It has high cardinality(the id is specific to an enrollment)
-- The DB will quickly find the matching rows
-- without scanning the entire table

-- 8.2 
-- Yes, create index on InstructorID column.
-- It has high cardinality(each instructor has his own id).

-- 8.3
-- No, the unique constraint already creates a B-tree index on that column.
-- So the query will use that, no need for a second one

-- 8.4
-- No – PaymentStatus has low cardinality (few distinct values such as
-- 'Completed', 'Pending', 'Refunded').  Indexing a low‑cardinality column
-- is rarely beneficial because the index would return a large fraction of the table