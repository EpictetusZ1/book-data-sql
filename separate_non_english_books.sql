-- ============================================================
-- Identify & separate non-English books and textbooks
-- Run the counts first, then decide whether to proceed
-- ============================================================

-- ============================================================
-- PART A: Scope the problem — how many are we talking about?
-- ============================================================

-- 1. Non-English books (have a language tag that isn't English)
SELECT
    CASE
        WHEN language IS NULL           THEN 'unknown'
        WHEN language IN ('eng','en')   THEN 'english'
        ELSE 'non_english'
    END AS lang_group,
    COUNT(*) AS total
FROM books GROUP BY lang_group;

-- 2. Non-English breakdown by language (top 20)
SELECT language, COUNT(*) AS total
FROM books
WHERE language IS NOT NULL AND language NOT IN ('eng','en')
GROUP BY language ORDER BY total DESC LIMIT 20;

-- 3. Textbook detection — publishers commonly associated with textbooks
SELECT publisher, COUNT(*) AS total
FROM books
WHERE publisher ILIKE ANY(ARRAY[
    '%pearson%', '%mcgraw%', '%wiley%', '%cengage%', '%elsevier%',
    '%springer%', '%oxford university press%', '%cambridge university press%',
    '%academic press%', '%prentice hall%', '%addison-wesley%',
    '%thomson%', '%macmillan education%', '%routledge%', '%sage publications%',
    '%taylor & francis%', '%wolters kluwer%', '%lippincott%',
    '%mosby%', '%saunders%', '%dummies%'
])
GROUP BY publisher ORDER BY total DESC LIMIT 30;

-- 4. Count: likely textbooks by publisher
SELECT COUNT(*) AS likely_textbooks
FROM books
WHERE publisher ILIKE ANY(ARRAY[
    '%pearson%', '%mcgraw%', '%wiley%', '%cengage%', '%elsevier%',
    '%springer%', '%oxford university press%', '%cambridge university press%',
    '%academic press%', '%prentice hall%', '%addison-wesley%',
    '%thomson%', '%macmillan education%', '%routledge%', '%sage publications%',
    '%taylor & francis%', '%wolters kluwer%', '%lippincott%',
    '%mosby%', '%saunders%', '%dummies%'
]);

-- 5. Combined: total rows that would be moved
SELECT COUNT(*) AS would_be_moved
FROM books
WHERE (language NOT IN ('eng','en') AND language IS NOT NULL)
   OR publisher ILIKE ANY(ARRAY[
        '%pearson%', '%mcgraw%', '%wiley%', '%cengage%', '%elsevier%',
        '%springer%', '%oxford university press%', '%cambridge university press%',
        '%academic press%', '%prentice hall%', '%addison-wesley%',
        '%thomson%', '%macmillan education%', '%routledge%', '%sage publications%',
        '%taylor & francis%', '%wolters kluwer%', '%lippincott%',
        '%mosby%', '%saunders%', '%dummies%'
    ]);

-- ============================================================
-- PART B: Move them out (run AFTER reviewing Part A counts)
-- ============================================================

-- Create the archive table with identical structure
CREATE TABLE books_excluded (LIKE books INCLUDING ALL);

-- Add a reason column so you know why each row was moved
ALTER TABLE books_excluded ADD COLUMN exclusion_reason TEXT;

-- Move non-English books
WITH moved AS (
    DELETE FROM books
    WHERE language NOT IN ('eng','en') AND language IS NOT NULL
    RETURNING *, 'non_english' AS reason
)
INSERT INTO books_excluded
SELECT m.*, m.reason FROM moved m;

-- Move textbooks by publisher (only ones still in books)
WITH moved AS (
    DELETE FROM books
    WHERE publisher ILIKE ANY(ARRAY[
        '%pearson%', '%mcgraw%', '%wiley%', '%cengage%', '%elsevier%',
        '%springer%', '%oxford university press%', '%cambridge university press%',
        '%academic press%', '%prentice hall%', '%addison-wesley%',
        '%thomson%', '%macmillan education%', '%routledge%', '%sage publications%',
        '%taylor & francis%', '%wolters kluwer%', '%lippincript%',
        '%mosby%', '%saunders%', '%dummies%'
    ])
    RETURNING *, 'textbook_publisher' AS reason
)
INSERT INTO books_excluded
SELECT m.*, m.reason FROM moved m;

-- Verify what was moved
SELECT exclusion_reason, COUNT(*) AS total
FROM books_excluded GROUP BY exclusion_reason;

-- What's left in the main table
SELECT COUNT(*) AS remaining_books FROM books;

-- Reclaim space
VACUUM FULL books;
VACUUM ANALYZE books_excluded;