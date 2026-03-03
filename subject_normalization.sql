--  estimated coverage with overlap -- subjects
SELECT COUNT(DISTINCT book_id) FROM book_subjects
UNION ALL
SELECT COUNT(DISTINCT book_id) FROM book_shelves;


-- total coverage of subjects no overlap
SELECT COUNT(DISTINCT book_id) FROM (
    SELECT book_id FROM book_subjects
    UNION
    SELECT book_id FROM book_shelves
) combined;


SELECT subject, COUNT(*) as frequency
FROM book_subjects
WHERE subject_type = 'subjects'
GROUP BY subject
ORDER BY frequency DESC
LIMIT 100;