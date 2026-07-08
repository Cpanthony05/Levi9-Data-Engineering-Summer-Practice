SELECT * FROM trains WHERE origin = 'Central';

SELECT * FROM trains WHERE departure BETWEEN '08:00' AND '12:00';

SELECT * FROM trains WHERE duration_min > 90;

SELECT * FROM trains ORDER BY departure ASC, destination ASC;

SELECT *, CASE WHEN departure < '12:00' THEN 'Morning'
               WHEN departure < '17:00' THEN 'Afternoon'
               ELSE 'Evening'
               END AS period FROM trains;
