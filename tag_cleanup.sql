BEGIN;

-- ============================================================
-- ADD canonical_tag column
-- ============================================================
ALTER TABLE book_shelves ADD COLUMN IF NOT EXISTS canonical_tag TEXT;

-- ============================================================
-- SIMPLE MERGES (true duplicates, no granularity lost)
-- Pattern for each:
--   1. add counts into canonical where both exist
--   2. delete rows conflicting with existing canonical
--   3. delete rows conflicting with each other (no canonical exists yet)
--   4. rename remaining rows
-- ============================================================

-- classics -> classic
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'classic' AND b2.shelf_name IN ('classics', 'clàssics', 'classic-literature') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('classics', 'clàssics', 'classic-literature') AND b.shelf_name = 'classic' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('classics', 'clàssics', 'classic-literature') AND b.shelf_name IN ('classics', 'clàssics', 'classic-literature') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'classic' WHERE shelf_name IN ('classics', 'clàssics', 'classic-literature');

-- sci-fi true duplicates only (not subgenres)
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'science-fiction' AND b2.shelf_name IN ('sci-fi', 'scifi', 'sf') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('sci-fi', 'scifi', 'sf') AND b.shelf_name = 'science-fiction' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('sci-fi', 'scifi', 'sf') AND b.shelf_name IN ('sci-fi', 'scifi', 'sf') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'science-fiction' WHERE shelf_name IN ('sci-fi', 'scifi', 'sf');

-- non-fiction
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'non-fiction' AND b2.shelf_name = 'nonfiction' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'nonfiction' AND b.shelf_name = 'non-fiction' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'non-fiction' WHERE shelf_name = 'nonfiction';

-- ya -> young-adult (ya and teen are true duplicates, new-adult and ya-fantasy are subgenres)
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'young-adult' AND b2.shelf_name IN ('ya', 'teen') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('ya', 'teen') AND b.shelf_name = 'young-adult' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('ya', 'teen') AND b.shelf_name IN ('ya', 'teen') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'young-adult' WHERE shelf_name IN ('ya', 'teen');

-- childrens
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'childrens' AND b2.shelf_name IN ('children', 'children-s', 'childrens-books', 'children-s-books', 'kids', 'kids-books') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('children', 'children-s', 'childrens-books', 'children-s-books', 'kids', 'kids-books') AND b.shelf_name = 'childrens' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('children', 'children-s', 'childrens-books', 'children-s-books', 'kids', 'kids-books') AND b.shelf_name IN ('children', 'children-s', 'childrens-books', 'children-s-books', 'kids', 'kids-books') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'childrens' WHERE shelf_name IN ('children', 'children-s', 'childrens-books', 'children-s-books', 'kids', 'kids-books');

-- graphic novels
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'graphic-novels' AND b2.shelf_name = 'graphic-novel' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'graphic-novel' AND b.shelf_name = 'graphic-novels' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'graphic-novels' WHERE shelf_name = 'graphic-novel';

-- vampire
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'vampires' AND b2.shelf_name = 'vampire' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'vampire' AND b.shelf_name = 'vampires' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'vampires' WHERE shelf_name = 'vampire';

-- memoir
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'memoir' AND b2.shelf_name IN ('memoirs', 'autobiography', 'biography-memoir') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('memoirs', 'autobiography', 'biography-memoir') AND b.shelf_name = 'memoir' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('memoirs', 'autobiography', 'biography-memoir') AND b.shelf_name IN ('memoirs', 'autobiography', 'biography-memoir') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'memoir' WHERE shelf_name IN ('memoirs', 'autobiography', 'biography-memoir');

-- thriller
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'thriller' AND b2.shelf_name = 'thrillers' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'thrillers' AND b.shelf_name = 'thriller' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'thriller' WHERE shelf_name = 'thrillers';

-- mystery
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'mystery' AND b2.shelf_name = 'mysteries' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'mysteries' AND b.shelf_name = 'mystery' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'mystery' WHERE shelf_name = 'mysteries';

-- humor
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'humor' AND b2.shelf_name IN ('humour', 'comedy', 'funny') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('humour', 'comedy', 'funny') AND b.shelf_name = 'humor' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('humour', 'comedy', 'funny') AND b.shelf_name IN ('humour', 'comedy', 'funny') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'humor' WHERE shelf_name IN ('humour', 'comedy', 'funny');

-- biography
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'biography' AND b2.shelf_name = 'biographies' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'biographies' AND b.shelf_name = 'biography' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'biography' WHERE shelf_name = 'biographies';

-- plays
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'plays' AND b2.shelf_name IN ('play', 'theatre') AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('play', 'theatre') AND b.shelf_name = 'plays' AND a.book_id = b.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name IN ('play', 'theatre') AND b.shelf_name IN ('play', 'theatre') AND a.book_id = b.book_id AND a.id > b.id;
UPDATE book_shelves SET shelf_name = 'plays' WHERE shelf_name IN ('play', 'theatre');

-- novels
UPDATE book_shelves b1 SET count = b1.count + b2.count
FROM book_shelves b2 WHERE b1.shelf_name = 'novels' AND b2.shelf_name = 'novel' AND b1.book_id = b2.book_id;
DELETE FROM book_shelves a USING book_shelves b
WHERE a.shelf_name = 'novel' AND b.shelf_name = 'novels' AND a.book_id = b.book_id;
UPDATE book_shelves SET shelf_name = 'novels' WHERE shelf_name = 'novel';

-- ============================================================
-- SUBGENRES: keep shelf_name, set canonical_tag
-- ============================================================

-- fantasy subgenres
UPDATE book_shelves SET canonical_tag = 'fantasy'
WHERE shelf_name IN ('high-fantasy', 'epic-fantasy', 'urban-fantasy', 'magic', 'dragons', 'werewolves', 'paranormal', 'magical-realism');

-- romance subgenres
UPDATE book_shelves SET canonical_tag = 'romance'
WHERE shelf_name IN ('paranormal-romance', 'historical-romance', 'contemporary-romance', 'chick-lit');

-- science-fiction subgenres
UPDATE book_shelves SET canonical_tag = 'science-fiction'
WHERE shelf_name IN ('sci-fi-fantasy', 'fantasy-sci-fi', 'steampunk', 'dystopian', 'dystopia', 'post-apocalyptic', 'time-travel');

-- mystery subgenres
UPDATE book_shelves SET canonical_tag = 'mystery'
WHERE shelf_name IN ('mystery-thriller', 'detective', 'crime', 'suspense');

-- thriller subgenres
UPDATE book_shelves SET canonical_tag = 'thriller'
WHERE shelf_name IN ('romantic-suspense');

-- horror subgenres
UPDATE book_shelves SET canonical_tag = 'horror'
WHERE shelf_name IN ('supernatural', 'gothic', 'zombies', 'vampires');

-- young-adult subgenres
UPDATE book_shelves SET canonical_tag = 'young-adult'
WHERE shelf_name IN ('new-adult', 'ya-fantasy', 'high-school', 'coming-of-age', 'middle-grade');

-- childrens subgenres
UPDATE book_shelves SET canonical_tag = 'childrens'
WHERE shelf_name IN ('picture-books', 'picture-book', 'fairy-tales');

-- non-fiction subgenres
UPDATE book_shelves SET canonical_tag = 'non-fiction'
WHERE shelf_name IN ('biography', 'memoir', 'history', 'science', 'philosophy', 'psychology',
                     'politics', 'economics', 'business', 'self-help', 'religion', 'spirituality',
                     'travel', 'essays', 'feminism');

-- ============================================================
-- SET canonical_tag on the canonical tags themselves for easy filtering
-- ============================================================
UPDATE book_shelves SET canonical_tag = shelf_name
WHERE shelf_name IN (
    'fantasy', 'romance', 'science-fiction', 'mystery', 'thriller', 'horror',
    'young-adult', 'childrens', 'non-fiction', 'classic', 'historical-fiction',
    'biography', 'memoir', 'humor', 'graphic-novels'
) AND canonical_tag IS NULL;

COMMIT;




BEGIN;

DELETE FROM book_shelves WHERE shelf_name IN (
    -- should have been caught before but weren't
    'to-read',
    'currently-reading',
    'books-i-own',
    'owned',
    'favorites',
    -- new removals
    'fiction'  -- too broad to be useful
);

COMMIT;
