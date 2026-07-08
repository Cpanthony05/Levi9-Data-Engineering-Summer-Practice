SELECT * FROM rooms WHERE status = 'vacant';

SELECT * FROM rooms WHERE price_per_night BETWEEN 80 AND 150;

SELECT * FROM rooms WHERE (type = 'double' OR type = 'suite') AND status = 'vacant';

SELECT * FROM rooms WHERE floor >= 3 AND price_per_night > 100;

SELECT * FROM rooms ORDER BY floor ASC, price_per_night DESC;
