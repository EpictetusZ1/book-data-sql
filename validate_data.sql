-- ============================================================
-- Validate merged books database
-- Run each section individually in DataGrip
-- ============================================================

-- 1. Row counts by source
SELECT source, COUNT(*) AS total FROM books GROUP BY source;

-- 2. Goodreads books enriched by OL
SELECT
    COUNT(*) FILTER (WHERE openlibrary_key IS NOT NULL) AS enriched,
    COUNT(*) FILTER (WHERE openlibrary_key IS NULL)     AS gr_only,
    COUNT(*)                                             AS total
FROM books WHERE source = 'goodreads';

-- 3. Data completeness by source
SELECT
    source,
    COUNT(*)                                          AS total,
    COUNT(isbn13)                                     AS has_isbn13,
    COUNT(description)                                AS has_description,
    COUNT(num_pages)                                  AS has_pages,
    COUNT(language)                                   AS has_language,
    COUNT(image_url)                                  AS has_cover,
    ROUND(100.0 * COUNT(description) / COUNT(*), 1)  AS pct_desc,
    ROUND(100.0 * COUNT(language) / COUNT(*), 1)     AS pct_lang
FROM books GROUP BY source;

-- 4. Top 15 languages
SELECT language, COUNT(*) AS total
FROM books WHERE language IS NOT NULL
GROUP BY language ORDER BY total DESC LIMIT 15;

-- 5. Books per decade
SELECT
    (publication_year / 10) * 10 AS decade,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE source = 'goodreads')   AS from_gr,
    COUNT(*) FILTER (WHERE source = 'openlibrary') AS from_ol
FROM books
WHERE publication_year BETWEEN 1800 AND 2030
GROUP BY decade ORDER BY decade;

-- 6. Top 20 publishers
SELECT publisher, COUNT(*) AS total
FROM books WHERE publisher IS NOT NULL
GROUP BY publisher ORDER BY total DESC LIMIT 20;

-- 7. Format breakdown
SELECT format, COUNT(*) AS total
FROM books WHERE format IS NOT NULL
GROUP BY format ORDER BY total DESC LIMIT 15;

-- 8. Spot check: enriched GR books
SELECT id, title, source, openlibrary_key, isbn13,
       language, num_pages, average_rating,
       LEFT(description, 100) AS desc_preview
FROM books
WHERE source = 'goodreads' AND openlibrary_key IS NOT NULL
LIMIT 5;

-- 9. Spot check: OL-only books
SELECT id, title, openlibrary_key, isbn13, language,
       num_pages, publisher, LEFT(description, 100) AS desc_preview
FROM books WHERE source = 'openlibrary'
LIMIT 5;

-- 10. Orphan check
SELECT 'orphan_book_refs' AS check_name, COUNT(*)
FROM book_authors ba LEFT JOIN books b ON ba.book_id = b.id
WHERE b.id IS NULL
UNION ALL
SELECT 'orphan_author_refs', COUNT(*)
FROM book_authors ba LEFT JOIN authors a ON ba.author_id = a.id
WHERE a.id IS NULL;