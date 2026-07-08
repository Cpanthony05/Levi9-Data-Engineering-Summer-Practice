SELECT title, author FROM books ORDER BY title ASC;

SELECT * FROM books WHERE year > 2000;

SELECT * FROM books WHERE genre = 'Science' ORDER BY year DESC;

SELECT * FROM books WHERE title LIKE '%The%';

SELECT * FROM books ORDER BY year DESC LIMIT 3;
