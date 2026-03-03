-- Overview: row counts and source breakdown
SELECT source, COUNT(*) AS books,
       COUNT(openlibrary_key) AS has_ol_key,
       COUNT(isbn13) AS has_isbn13,
       COUNT(description) AS has_description,
       COUNT(num_pages) AS has_pages
FROM books GROUP BY source;

-- Goodreads books enriched by OL
SELECT COUNT(*) AS gr_books_enriched_by_ol
FROM books WHERE source = 'goodreads' AND openlibrary_key IS NOT NULL;

-- Spot check: a book that exists in both
SELECT id, title, source, goodreads_book_id, openlibrary_key,
       isbn13, language, num_pages, publication_year,
       LEFT(description, 80) AS description_preview
FROM books
WHERE source = 'goodreads' AND openlibrary_key IS NOT NULL
LIMIT 5;

-- Works breakdown
SELECT source, COUNT(*) FROM works GROUP BY source;

VACUUM FULL books;