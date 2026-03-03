-- ============================================================
-- Merge _staging_ol_editions into books table (bulletproof)
--
-- Core fix: builds a 1:1 mapping table guaranteeing:
--   - each ol_key maps to at most ONE book
--   - each book maps to at most ONE ol_key
-- No more unique constraint violations.
-- ============================================================

-- Reset any leftovers from previous attempts
UPDATE books SET openlibrary_key = NULL, openlibrary_work_key = NULL
WHERE source = 'goodreads' AND openlibrary_key IS NOT NULL;

UPDATE _staging_ol_editions SET matched = FALSE WHERE matched = TRUE;

-- ============================================================
-- Step 1: Build clean 1:1 mapping via ISBN13
-- ============================================================
DROP TABLE IF EXISTS _match_13;

CREATE TEMP TABLE _match_13 AS
WITH by_ol AS (
    -- each ol_key gets at most one book
    SELECT DISTINCT ON (s.ol_key)
        s.ol_key, s.ol_work_key, s.description, s.num_pages,
        s.format, s.publisher, s.publication_year, s.image_url,
        s.language, b.id AS book_id
    FROM _staging_ol_editions s
    JOIN books b ON b.isbn13 = s.isbn13
    WHERE s.isbn13 IS NOT NULL
      AND s.matched = FALSE
      AND b.openlibrary_key IS NULL
    ORDER BY s.ol_key, b.id
)
-- each book gets at most one ol_key
SELECT DISTINCT ON (book_id) * FROM by_ol ORDER BY book_id, ol_key;

CREATE INDEX ON _match_13(ol_key);
CREATE INDEX ON _match_13(book_id);

-- Apply ISBN13 matches
UPDATE books b SET
    openlibrary_key      = m.ol_key,
    openlibrary_work_key = COALESCE(b.openlibrary_work_key, m.ol_work_key),
    description          = COALESCE(b.description, m.description),
    num_pages            = COALESCE(b.num_pages, m.num_pages),
    format               = COALESCE(b.format, m.format),
    publisher            = COALESCE(b.publisher, m.publisher),
    publication_year     = COALESCE(b.publication_year, m.publication_year),
    image_url            = COALESCE(b.image_url, m.image_url),
    language             = COALESCE(b.language, m.language)
FROM _match_13 m
WHERE b.id = m.book_id;

-- Flag matched staging rows
UPDATE _staging_ol_editions st SET matched = TRUE
FROM _match_13 m WHERE st.ol_key = m.ol_key;

SELECT COUNT(*) FROM books WHERE openlibrary_key IS NOT NULL AND source = 'goodreads';
DROP TABLE IF EXISTS _match_13;

SELECT COUNT(*) AS isbn13_matched FROM _match_13;

DROP TABLE _match_13;

-- ============================================================
-- Step 2: Build clean 1:1 mapping via ISBN10 (remaining only)
-- ============================================================
DROP TABLE IF EXISTS _match_10;
CREATE TEMP TABLE _match_10 AS
WITH by_ol AS (
    SELECT DISTINCT ON (s.ol_key)
        s.ol_key, s.ol_work_key, s.description, s.num_pages,
        s.format, s.publisher, s.publication_year, s.image_url,
        s.language, b.id AS book_id
    FROM _staging_ol_editions s
    JOIN books b ON b.isbn10 = s.isbn10
    WHERE s.isbn10 IS NOT NULL
      AND s.matched = FALSE
      AND b.openlibrary_key IS NULL
    ORDER BY s.ol_key, b.id
)
SELECT DISTINCT ON (book_id) * FROM by_ol ORDER BY book_id, ol_key;

CREATE INDEX ON _match_10(ol_key);
CREATE INDEX ON _match_10(book_id);

-- Apply ISBN10 matches
UPDATE books b SET
    openlibrary_key      = m.ol_key,
    openlibrary_work_key = COALESCE(b.openlibrary_work_key, m.ol_work_key),
    description          = COALESCE(b.description, m.description),
    num_pages            = COALESCE(b.num_pages, m.num_pages),
    format               = COALESCE(b.format, m.format),
    publisher            = COALESCE(b.publisher, m.publisher),
    publication_year     = COALESCE(b.publication_year, m.publication_year),
    image_url            = COALESCE(b.image_url, m.image_url),
    language             = COALESCE(b.language, m.language)
FROM _match_10 m
WHERE b.id = m.book_id;

-- Flag matched staging rows
UPDATE _staging_ol_editions st SET matched = TRUE
FROM _match_10 m WHERE st.ol_key = m.ol_key;

SELECT COUNT(*) AS isbn10_matched FROM _match_10;

DROP TABLE _match_10;

-- ============================================================
-- Step 3: INSERT unmatched as new OL-only books
-- Deduplicate by ol_key to avoid hitting goodreads_book_id unique
-- ============================================================
DROP TABLE IF EXISTS _to_insert;
CREATE TEMP TABLE _to_insert AS
SELECT DISTINCT ON (ol_key) *
FROM _staging_ol_editions
WHERE matched = FALSE
ORDER BY ol_key;

INSERT INTO books (
    goodreads_book_id, goodreads_work_id, title, title_without_series,
    isbn10, isbn13, language, description, format, num_pages,
    publisher, publication_year, image_url, goodreads_url,
    openlibrary_key, openlibrary_work_key, source
)
SELECT
    ol_key, ol_work_key, title, title,
    isbn10, isbn13, language, description, format, num_pages,
    publisher, publication_year, image_url, ol_url,
    ol_key, ol_work_key, 'openlibrary'
FROM _to_insert
ON CONFLICT (goodreads_book_id) DO NOTHING;

SELECT COUNT(*) AS new_books_inserted FROM _to_insert;

DROP TABLE _to_insert;

-- ============================================================
-- Step 4: Cleanup
-- ============================================================
DROP TABLE IF EXISTS _staging_ol_editions;

