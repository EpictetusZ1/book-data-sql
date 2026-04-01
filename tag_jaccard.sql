CREATE MATERIALIZED VIEW mv_tag_jaccard AS
WITH tag_counts AS (
  SELECT
    COALESCE(c.canonical_tag, bs.canonical_tag) as tag,
    COUNT(DISTINCT bs.book_id)::int as book_count
  FROM book_shelves bs
  LEFT JOIN shelf_tag_curation c
    ON bs.shelf_name = c.shelf_name AND c.include = true
  WHERE COALESCE(c.canonical_tag, bs.canonical_tag) IS NOT NULL
  GROUP BY COALESCE(c.canonical_tag, bs.canonical_tag)
)
SELECT
  COALESCE(ca.canonical_tag, a.canonical_tag) as tag_a,
  COALESCE(cb.canonical_tag, b.canonical_tag) as tag_b,
  COUNT(DISTINCT a.book_id)::int as co_count,
  (ta.book_count + tb.book_count - COUNT(DISTINCT a.book_id)::int) as union_count
FROM book_shelves a
JOIN book_shelves b ON a.book_id = b.book_id
LEFT JOIN shelf_tag_curation ca ON a.shelf_name = ca.shelf_name AND ca.include = true
LEFT JOIN shelf_tag_curation cb ON b.shelf_name = cb.shelf_name AND cb.include = true
JOIN tag_counts ta ON COALESCE(ca.canonical_tag, a.canonical_tag) = ta.tag
JOIN tag_counts tb ON COALESCE(cb.canonical_tag, b.canonical_tag) = tb.tag
WHERE
  COALESCE(ca.canonical_tag, a.canonical_tag) IS NOT NULL
  AND COALESCE(cb.canonical_tag, b.canonical_tag) IS NOT NULL
  AND COALESCE(ca.canonical_tag, a.canonical_tag) < COALESCE(cb.canonical_tag, b.canonical_tag)
GROUP BY
  COALESCE(ca.canonical_tag, a.canonical_tag),
  COALESCE(cb.canonical_tag, b.canonical_tag),
  ta.book_count,
  tb.book_count
ORDER BY co_count DESC;