CREATE TABLE shelf_tag_curation (
  shelf_name    TEXT PRIMARY KEY,
  canonical_tag TEXT,
  include       BOOLEAN DEFAULT false,
  reviewed      BOOLEAN DEFAULT false,
  reviewed_at   TIMESTAMPTZ,
  total_count   BIGINT
);



INSERT INTO shelf_tag_curation (shelf_name, total_count, reviewed)
SELECT shelf_name, SUM(count), false
FROM book_shelves
WHERE canonical_tag IS NULL
GROUP BY shelf_name
ORDER BY SUM(count) DESC
LIMIT 1000
ON CONFLICT DO NOTHING;


SELECT
  a.canonical_tag as tag_a,
  b.canonical_tag as tag_b,
  COUNT(DISTINCT a.book_id) as co_count
FROM book_shelves a
JOIN book_shelves b
  ON a.book_id = b.book_id
  AND a.canonical_tag < b.canonical_tag
WHERE a.canonical_tag IS NOT NULL
  AND b.canonical_tag IS NOT NULL
GROUP BY a.canonical_tag, b.canonical_tag
ORDER BY co_count DESC;

SELECT
  COALESCE(ca.canonical_tag, a.canonical_tag) as tag_a,
  COALESCE(cb.canonical_tag, b.canonical_tag) as tag_b,
  COUNT(DISTINCT a.book_id) as co_count
FROM book_shelves a
JOIN book_shelves b
  ON a.book_id = b.book_id
LEFT JOIN shelf_tag_curation ca
  ON a.shelf_name = ca.shelf_name AND ca.include = true
LEFT JOIN shelf_tag_curation cb
  ON b.shelf_name = cb.shelf_name AND cb.include = true
WHERE
  COALESCE(ca.canonical_tag, a.canonical_tag) IS NOT NULL
  AND COALESCE(cb.canonical_tag, b.canonical_tag) IS NOT NULL
  AND COALESCE(ca.canonical_tag, a.canonical_tag) < COALESCE(cb.canonical_tag, b.canonical_tag)
GROUP BY
  COALESCE(ca.canonical_tag, a.canonical_tag),
  COALESCE(cb.canonical_tag, b.canonical_tag)
ORDER BY co_count DESC;