-- PODSTAWOWE STATYSTYKI

-- 1.
SET AUTOTRACE OFF;

BEGIN
    DBMS_STATS.DELETE_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

-- 2.
SELECT num_rows, last_analyzed, avg_row_len, blocks
FROM user_tables
WHERE table_name = 'OPT_PRACOWNICY';

SELECT column_name, num_distinct, low_value, high_value
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY';

SELECT index_name, num_rows, leaf_blocks, last_analyzed
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

-- 3.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
    ownname=>'inf145406', tabname => 'OPT_PRACOWNICY');
END;

SELECT num_rows, last_analyzed, avg_row_len, blocks
FROM user_tables
WHERE table_name = 'OPT_PRACOWNICY';

SELECT column_name, num_distinct, low_value, high_value
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY';

SELECT index_name, num_rows, leaf_blocks, last_analyzed
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

-- 4.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname=>'inf145406', tabname => 'OPT_PRACOWNICY',
        estimate_percent => 40);
END;

SELECT num_rows, last_analyzed, avg_row_len, blocks, sample_size
FROM user_tables
WHERE table_name = 'OPT_PRACOWNICY';

-- 5.
BEGIN
    DBMS_STATS.DELETE_TABLE_STATS(
    ownname=>'inf145406', tabname => 'OPT_PRACOWNICY');
END;

-- 6.
SET AUTOTRACE ON EXPLAIN;

SELECT * FROM opt_pracownicy WHERE nazwisko LIKE 'Prac155%'; -- dynamic sampling (level=2)

-- 7.
SELECT /*+ DYNAMIC_SAMPLING(0) */ *
FROM opt_pracownicy WHERE nazwisko LIKE 'Prac155%'; -- basic plan statistics not available. These are only collected when:

-- 8.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname=>'inf145406', tabname => 'OPT_PRACOWNICY',
        cascade => TRUE);
END;

SELECT num_rows, last_analyzed, avg_row_len, blocks
FROM user_tables
WHERE table_name = 'OPT_PRACOWNICY';

SELECT column_name, num_distinct, low_value, high_value
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY';

SELECT index_name, num_rows, leaf_blocks, last_analyzed
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

-- HISTOGRAMY

-- 1.
SELECT column_name, num_distinct, low_value, high_value,
num_buckets, histogram
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY'
ORDER BY column_name;

-- 2.
SELECT num_distinct, num_buckets, histogram
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY'
AND column_name = 'PLACA_DOD';

SELECT placa_dod, COUNT(*)
FROM opt_pracownicy
GROUP BY placa_dod;

-- 3. nie musialem usuwac
BEGIN
    DBMS_STATS.DELETE_COLUMN_STATS(
    ownname => 'inf145406', tabname => 'OPT_PRACOWNICY',
    colname => 'PLACA_DOD', col_stat_type => 'HISTOGRAM');
END;

SELECT num_distinct, num_buckets, histogram
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY'
AND column_name = 'PLACA_DOD';

-- 4.
DROP INDEX opt_prac_nazw_placa_idx;
DROP INDEX opt_prac_plec_placa_idx;
DROP INDEX opt_prac_fun_idx;
DROP INDEX opt_prac_etat_bmp_idx;
DROP INDEX opt_prac_plec_bmp_idx;

SELECT index_name, index_type, uniqueness
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

DROP INDEX OPT_PRAC_PLACA_DOD_IDX;

CREATE BITMAP INDEX opt_prac_placa_dod_bmp_idx
    ON opt_pracownicy(placa_dod);
    
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
    ownname=>'inf145406', tabname => 'OPT_PRACOWNICY');
END;

SELECT index_name, num_rows, leaf_blocks, last_analyzed
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

-- 5.
SET AUTOTRACE ON EXPLAIN;

SELECT * FROM opt_pracownicy WHERE placa_dod = 100;
SELECT * FROM opt_pracownicy WHERE placa_dod = 999;

-- 6.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'inf145406', tabname => 'OPT_PRACOWNICY',
    method_opt => 'FOR COLUMNS placa_dod SIZE AUTO');
END;

SELECT num_distinct, num_buckets, histogram
FROM user_tab_col_statistics
WHERE table_name = 'OPT_PRACOWNICY'
AND column_name = 'PLACA_DOD'; -- POJAWIL SIE HISTOGRAMY CZESTOTLIWOSCI

-- 7.

SELECT * FROM opt_pracownicy WHERE placa_dod = 100;
SELECT * FROM opt_pracownicy WHERE placa_dod = 999;