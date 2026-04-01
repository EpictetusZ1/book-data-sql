

CREATE MATERIALIZED VIEW mv_title_words_global AS
WITH words AS (
  SELECT
    lower(regexp_replace(w.word, '[^a-zA-Z]', '', 'g')) AS word
  FROM books b
  CROSS JOIN LATERAL regexp_split_to_table(
    COALESCE(b.title_without_series, b.title), '\s+'
  ) AS w(word)
  WHERE (b.language IS NULL OR b.language ILIKE 'en%')
    AND length(regexp_replace(w.word, '[^a-zA-Z]', '', 'g')) > 2
)
SELECT
  word,
  COUNT(*)::int AS frequency
FROM words
WHERE word NOT IN (
  SELECT unnest(ARRAY[
    -- english stopwords
    'the','a','an','and','or','of','in','on','at','to','for','with',
    'by','from','as','is','it','its','be','was','are','were','been','has',
    'have','had','do','does','did','but','not','this','that','these','those',
    'what','which','who','when','where','how','all','one','two','three',
    'my','your','his','her','our','their','no','so','if','can','will',
    'would','could','should','may','might','than','then','into','over',
    'after','before','about','up','out','some','any','more','other','also',
    'just','like','very','even','new','old','only','first','last','own',
    'same','such','through','between','against','during','they','she','him',
    'her','we','you','use','get','let','see','now','here','there','come',
    'back','down','long','made','make','put','say','take','know','look',
    'why','upon','most','each','set','per','act','vol','yes','non',
    -- junk/meta
    'book','books','edition','volume','series','report','annual','reports',
    'log','planner','workbook','notebook','journal','diary','tracker',
    'calendar','guest','sketch','blank','pages','print','revised','index',
    'catalogue','directory','bibliography','proceedings','documents','manual',
    'handbook','survey','records','record','register','address','list',
    'illustrated','selected','collected','complete','general','related',
    'using','being','making','working','developing','changing','managing',
    'including','concerning','reading','writing','learning','teaching',
    'second','third','fourth','fifth','four','five','six','seven','eight',
    'nine','ten','iii','dont','etc','without','within','around','among',
    'never','ever','every','since','until','while','where','whose','whom',
    -- months
    'january','february','march','april','june','july','august',
    'september','october','november','december',
    -- german
    'der','und','des','die','von','zur','das','den','dem','als','ein',
    'aus','mit','auf','bis','bei','fur','oder','vom','nach','durch',
    'unter','einer','eine','zwischen','ueber','jahre','leben','geschichte',
    'deutschen','deutsche','deutschland','untersuchungen','ber','ein',
    -- french
    'les','sur','dans','par','pour','avec','une','aux','dun','qui',
    'vie','droit','mon','histoire','livre','coloriage','tome','entre',
    -- spanish
    'del','los','las','para','con','por','una','sobre','dos','vida',
    'derecho','historia','libro',
    -- dutch
    'van','het',
    -- italian
    'della','delle','dei','nei','nel','degli','una','alla','con','sul',
    -- latin/other
    'nihon','sefer','eine','einer',
    -- romanized chinese (from your data)
    'shi','zhi','xue','wen','zhongguo','yan','hua','jiu','xian','shu',
    'zhan','xing','sheng','xin','jing','dai','dan','lun','jian','hui',
    'gong','ren','guo','jiao','jia','ying','zhu','cheng','jin','jie',
    'ming','yuan','xiang','zheng','zhong','nian','guan','dian','zhu'
  ])
)
  AND word <> ''
  AND word ~ '^[a-z]+$'
GROUP BY word
ORDER BY frequency DESC;