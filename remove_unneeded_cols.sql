SELECT pg_size_pretty(sum(pg_column_size(title_without_series)))
FROM books;
-- 2017 MB of data here

ALTER TABLE books DROP COLUMN title_without_series;