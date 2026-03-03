-- Remove duplicates, keep the one with more data
DELETE FROM books a USING books b
WHERE a.openlibrary_key = b.openlibrary_key
  AND a.openlibrary_key IS NOT NULL
  AND a.id > b.id;

-- Now create it
CREATE UNIQUE INDEX idx_books_ol_key ON books(openlibrary_key) WHERE openlibrary_key IS NOT NULL;