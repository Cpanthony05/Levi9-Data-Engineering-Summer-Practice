-- 11.1
/*
Problem: the students table contains sensitive information (such as the CNP). 
once the manager has it it can get leaked and harm the students

Rule: The company must enforce a data‑handling policy that forbids
exporting personally identifiable information (PII) such as CNP to
removable media unless it is encrypted and approved by someone with a high
rank.
*/

-- 11.2
/*
Problem: Two distinct students share the same phone number, violating the
business rule that a phone number must be unique per person.

Rule: Add a UNIQUE constraint on Students.Phone (or enforce uniqueness via
application logic) so that each phone number can be stored only once.
*/

-- 11.3
/*
Problem: Student records from 2015 are still stored, but the law requires
deletion of personal data after 5 years. This means the company may get fined.

Rule: Implement a data‑retention policy that automatically purges (or
anonymises) rows older than 5 years based on RegistrationDate. This can be
a DELETE sql command like:
  DELETE FROM Students WHERE RegistrationDate < CURRENT_DATE - INTERVAL '5 years';
*/

-- 11.4
/*
Problem: An intern can view all payment amounts for every student, which
exposes financial data beyond twhat he needs to know.

Rule: Apply the principle of least privilege – grant the intern role only
SELECT on the Payments table for non‑sensitive columns (e.g., PaymentDate,
PaymentMethod, PaymentStatus) and deny access to the Amount column, or
create a view that excludes Amount and grant SELECT on that view.
*/

-- 11.5
/*
Problem: A practical lesson is marked “Completed” but has no vehicle assigned,
which is inconsistent because practical lessons require a vehicle.

Rule: Enforce data integrity with a CHECK constraint or a trigger that
prevents a lesson of type ‘Practical’ from having Status = ‘Completed’
when VehicleID IS NULL. Example trigger logic:
  IF NEW.LessonType = 'Practical' AND NEW.Status = 'Completed' AND NEW.VehicleID IS NULL
  THEN RAISE EXCEPTION 'Practical lessons must have a vehicle.';
*/