BEGIN;

-- ============================================================
-- books: add OL key, OL work key, and source columns
-- ============================================================
ALTER TABLE books
    ADD COLUMN IF NOT EXISTS openlibrary_key      TEXT,
    ADD COLUMN IF NOT EXISTS openlibrary_work_key  TEXT,
    ADD COLUMN IF NOT EXISTS source                TEXT DEFAULT 'goodreads';

CREATE UNIQUE INDEX IF NOT EXISTS idx_books_ol_key
    ON books(openlibrary_key) WHERE openlibrary_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_books_ol_work_key
    ON books(openlibrary_work_key) WHERE openlibrary_work_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_books_source
    ON books(source);

-- ============================================================
-- works: add OL work key and source
-- ============================================================
ALTER TABLE works
    ADD COLUMN IF NOT EXISTS openlibrary_work_key  TEXT,
    ADD COLUMN IF NOT EXISTS source                TEXT DEFAULT 'goodreads';

CREATE UNIQUE INDEX IF NOT EXISTS idx_works_ol_key
    ON works(openlibrary_work_key) WHERE openlibrary_work_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_works_source
    ON works(source);

-- ============================================================
-- authors: add OL author key
-- ============================================================
ALTER TABLE authors
    ADD COLUMN IF NOT EXISTS openlibrary_author_key TEXT;

CREATE INDEX IF NOT EXISTS idx_authors_ol_key
    ON authors(openlibrary_author_key) WHERE openlibrary_author_key IS NOT NULL;

COMMIT;