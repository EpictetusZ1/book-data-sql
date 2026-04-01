CREATE MATERIALIZED VIEW mv_tag_title_words AS
WITH stopwords AS (
  SELECT unnest(ARRAY[
    'the','a','an','and','or','or','of','in','on','at','to','for','with',
    'by','from','as','is','it','its','be','was','are','were','been','has',
    'have','had','do','does','did','but','not','this','that','these','those',
    'what','which','who','when','where','how','all','one','two','three',
    'my','your','his','her','our','their','his','no','so','if','can',
    'will','would','could','should','may','might','than','then','into',
    'over','after','before','about','up','out','some','any','more','other',
    'also','just','like','very','even','new','old','only','first','last',
    'own','same','such','through','between','against','through','during',
    's','t','re','ve','ll','d','m'
  ]) AS word
),
tag_books AS (
  SELECT
    COALESCE(c.canonical_tag, bs.canonical_tag) AS tag,
    bs.book_id
  FROM book_shelves bs
  LEFT JOIN shelf_tag_curation c
    ON bs.shelf_name = c.shelf_name AND c.include = true
  WHERE COALESCE(c.canonical_tag, bs.canonical_tag) IS NOT NULL
),
words AS (
  SELECT
    tb.tag,
    lower(regexp_replace(w.word, '[^a-zA-Z]', '', 'g')) AS word
  FROM tag_books tb
  JOIN books b ON tb.book_id = b.id
  CROSS JOIN LATERAL regexp_split_to_table(
    COALESCE(b.title_without_series, b.title), '\s+'
  ) AS w(word)
  WHERE length(regexp_replace(w.word, '[^a-zA-Z]', '', 'g')) > 2
)
SELECT
  tag,
  word,
  COUNT(*)::int AS frequency
FROM words
WHERE word NOT IN (SELECT word FROM stopwords)
  AND word <> ''
GROUP BY tag, word
ORDER BY tag, frequency DESC;

CREATE INDEX ON mv_tag_title_words (tag);