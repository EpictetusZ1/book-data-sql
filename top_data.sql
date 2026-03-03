-- ============================================================
-- TOP TAGS overall
-- ============================================================
SELECT shelf_name, SUM(count) AS total
FROM book_shelves
GROUP BY shelf_name
ORDER BY total DESC
LIMIT 20;

-- ============================================================
-- TOP GENRES (canonical tags only)
-- ============================================================
SELECT canonical_tag, SUM(count) AS total
FROM book_shelves
WHERE canonical_tag IS NOT NULL
GROUP BY canonical_tag
ORDER BY total DESC;

-- ============================================================
-- HIGHEST RATED BOOKS (min 1000 ratings to filter noise)
-- ============================================================
SELECT title, average_rating, ratings_count
FROM books
WHERE ratings_count > 1000
ORDER BY average_rating DESC
LIMIT 20;

-- ============================================================
-- MOST RATED BOOKS (popular by volume)
-- ============================================================
SELECT title, ratings_count, average_rating
FROM books
ORDER BY ratings_count DESC
LIMIT 20;

-- ============================================================
-- TOP AUTHORS by total ratings across their books
-- ============================================================
SELECT a.name, COUNT(b.id) AS book_count, SUM(b.ratings_count) AS total_ratings
FROM authors a
JOIN book_authors ba ON ba.author_id = a.id
JOIN books b ON b.id = ba.book_id
WHERE a.name IS NOT NULL
GROUP BY a.name
ORDER BY total_ratings DESC
LIMIT 20;

-- ============================================================
-- RATINGS DISTRIBUTION across all books
-- ============================================================
SELECT
    ROUND(average_rating) AS rating_bucket,
    COUNT(*) AS book_count
FROM books
WHERE average_rating IS NOT NULL
GROUP BY rating_bucket
ORDER BY rating_bucket;

-- ============================================================
-- PUBLICATION TRENDS by decade
-- ============================================================
SELECT
    (publication_year / 10) * 10 AS decade,
    COUNT(*) AS books_published,
    ROUND(AVG(average_rating)::numeric, 2) AS avg_rating
FROM books
WHERE publication_year BETWEEN 1800 AND 2024
GROUP BY decade
ORDER BY decade;

-- ============================================================
-- BOOKS PER GENRE with avg rating
-- ============================================================
SELECT
    bs.canonical_tag AS genre,
    COUNT(DISTINCT bs.book_id) AS book_count,
    ROUND(AVG(b.average_rating)::numeric, 2) AS avg_rating
FROM book_shelves bs
JOIN books b ON b.id = bs.book_id
WHERE bs.canonical_tag IS NOT NULL
GROUP BY bs.canonical_tag
ORDER BY book_count DESC;

-- ============================================================
-- FORMAT BREAKDOWN (ebook vs physical)
-- ============================================================
SELECT
    COALESCE(format, 'unknown') AS format,
    COUNT(*) AS count,
    ROUND(AVG(average_rating)::numeric, 2) AS avg_rating
FROM books
GROUP BY format
ORDER BY count DESC;

-- ============================================================
-- LONGEST BOOKS with good ratings
-- ============================================================
SELECT title, num_pages, average_rating, ratings_count
FROM books
WHERE num_pages IS NOT NULL AND ratings_count > 500
ORDER BY num_pages DESC
LIMIT 20;

-- ============================================================
-- MOST REVIEWED AUTHORS (text reviews as proxy for engagement)
-- ============================================================
SELECT a.name, SUM(b.text_reviews_count) AS total_reviews
FROM authors a
JOIN book_authors ba ON ba.author_id = a.id
JOIN books b ON b.id = ba.book_id
WHERE a.name IS NOT NULL
GROUP BY a.name
ORDER BY total_reviews DESC
LIMIT 20;