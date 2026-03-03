SELECT pg_size_pretty(pg_total_relation_size('books'));

SELECT n_live_tup, n_dead_tup, last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'books';