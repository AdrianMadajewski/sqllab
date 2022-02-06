 	

-- ZEBRANIE STATYSTYK DLA OPTYMALIZATORA

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
        tabname => 'OPT_PRACOWNICY');
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
        tabname => 'OPT_ZESPOLY');
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
        tabname => 'OPT_ETATY');
END;
/

-- METODY DOSTEPU DO TABELI

-- 1.
SELECT index_name, index_type
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

-- 2.
SELECT blocks
FROM user_tables
WHERE table_name = 'OPT_PRACOWNICY';

SELECT dbms_rowid.rowid_block_number(rowid) AS blok,
COUNT(*) AS liczba_rekordow
FROM opt_pracownicy
GROUP BY dbms_rowid.rowid_block_number(rowid)
ORDER BY blok;

-- 3.
SET AUTOTRACE ON;

SELECT nazwisko, placa
FROM opt_pracownicy WHERE id_prac = 10;

-- 4.
SET AUTOTRACE OFF;

SELECT nazwisko, placa, ROWID
FROM opt_pracownicy WHERE id_prac = 10; --AABJfcAAcAAAYi/AAs

-- 5.
SELECT nazwisko, placa
FROM opt_pracownicy
WHERE ROWID = 'AABJfcAAcAAAYi/AAs';

-- 6.
SET AUTOTRACE ON;

SELECT nazwisko, placa
FROM opt_pracownicy
WHERE ROWID = 'AABJfcAAcAAAYi/AAs';

-- METODY DOSTEPU DO INDEKSOW B-DRZEWO

-- 1.
SET AUTOTRACE OFF;

CREATE INDEX opt_id_prac_idx
    ON opt_pracownicy(id_prac);

SELECT index_name, index_type, uniqueness
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

SELECT column_name, column_position
FROM user_ind_columns
WHERE index_name = 'OPT_ID_PRAC_IDX'
ORDER BY column_position;

-- 2.
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

-- 3.
SET AUTOTRACE ON;

SELECT nazwisko, placa, ROWID
FROM opt_pracownicy WHERE id_prac = 10;

-- 4.
SET AUTOTRACE OFF;
DROP INDEX opt_id_prac_idx;

ALTER TABLE opt_pracownicy
ADD CONSTRAINT opt_prac_pk PRIMARY KEY(id_prac);

SELECT index_name, index_type, uniqueness
FROM user_indexes
WHERE table_name = 'OPT_PRACOWNICY';

SELECT column_name, column_position
FROM user_ind_columns
WHERE index_name = 'OPT_PRAC_PK'
ORDER BY column_position;


-- 5.
SET AUTOTRACE ON;

SELECT nazwisko, placa, ROWID
FROM opt_pracownicy WHERE id_prac = 10;

-- Zadanie samodzielne
SELECT nazwisko, placa, ROWID
FROM opt_pracownicy WHERE id_prac < 10; -- Nadal jest uzywany indeks opt_prac_pk ale system uzywa operacji INDEX RANGE SCAN

-- 6.
CREATE INDEX opt_prac_nazw_idx ON opt_pracownicy(nazwisko);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

SELECT * FROM opt_pracownicy WHERE nazwisko = 'Prac155'; -- INDEX RANGE SCAN

SELECT * FROM opt_pracownicy WHERE nazwisko LIKE 'Prac155%'; -- INDEX RANGE SCAN

SELECT * FROM opt_pracownicy WHERE nazwisko LIKE '%Prac155%'; -- TABLE ACCESS FULL

-- 7.
BEGIN
    DBMS_STATS.DELETE_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

SET AUTOTRACE ON EXPLAIN;

SELECT *
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%' OR nazwisko LIKE 'Prac255%';

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

SELECT /*+ USE_CONCAT */ *
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%' OR nazwisko LIKE 'Prac255%';

SELECT *
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%' OR nazwisko LIKE 'Prac255%';

SELECT * FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%'
UNION ALL
SELECT * FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac255%';

-- 8.
SELECT * FROM opt_pracownicy
WHERE nazwisko IN ('Prac155','Prac255');

-- 9.
SELECT nazwisko, placa, id_prac
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%' AND placa > 1000;

DROP INDEX opt_prac_nazw_idx;

CREATE INDEX opt_prac_nazw_placa_idx ON
    opt_pracownicy(nazwisko, placa);

SELECT index_name, table_name, index_type, uniqueness
FROM user_indexes
WHERE index_name = 'OPT_PRAC_NAZW_PLACA_IDX';

SELECT column_name, column_position
FROM user_ind_columns
WHERE index_name = 'OPT_PRAC_NAZW_PLACA_IDX'
ORDER BY column_position;

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

-- 10.
SELECT nazwisko, placa, id_prac
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%' AND placa > 1000;

-- 11.
SELECT nazwisko, placa, id_prac
FROM opt_pracownicy WHERE nazwisko LIKE 'Prac155%';

SELECT nazwisko, placa, id_prac
FROM opt_pracownicy WHERE placa < 200;

-- 12.
SELECT nazwisko, placa
FROM opt_pracownicy
WHERE nazwisko LIKE 'Prac155%';

-- 13.
SELECT nazwisko FROM opt_pracownicy
WHERE placa < 1000;

-- 14.
CREATE INDEX OPT_PRAC_PLACA_DOD_IDX ON opt_pracownicy(placa_dod);

SELECT placa_dod FROM opt_pracownicy WHERE placa_dod IS NULL; -- TABLE ACCESS FULL, KOSZT = 17 INDEKS TYPY B-DRZEWO niewspiera wartosci pustych w zapytaniach
SELECT placa_dod FROM opt_pracownicy WHERE placa_dod IS NOT NULL; -- INEX FAST FULL SCAN, KOSZT = 7

-- 15.
CREATE INDEX opt_prac_plec_placa_idx ON opt_pracownicy (plec, placa);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

SELECT /*+ INDEX_SS(p) */ plec, nazwisko FROM opt_pracownicy p
WHERE placa > 2500;

-- 16.
SELECT placa, etat FROM opt_pracownicy
WHERE nazwisko = 'Prac155';

SELECT placa, etat FROM opt_pracownicy
WHERE UPPER(nazwisko) = 'PRAC155';

CREATE INDEX opt_prac_fun_idx ON opt_pracownicy(UPPER(nazwisko));

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY');
END;

SELECT placa, etat FROM opt_pracownicy
WHERE UPPER(nazwisko) = 'PRAC155'; -- TABLLE ACCESS BY INDEX OPT_PRAC_FUN_IDX (RANGE SCAN) + access predicate (UPPER(NAZWISKO) = 'PRAC155');

-- 17.
SELECT nazwisko
FROM opt_pracownicy
WHERE id_prac < 500 AND nazwisko LIKE 'Prac15%'


-- METODY DOSTEPU DO INDEKSOW BITMAPOWYCH

-- 1.
SET AUTOTRACE OFF;

SELECT DISTINCT plec FROM opt_pracownicy;

SELECT DISTINCT etat FROM opt_pracownicy;

-- 2.
CREATE BITMAP INDEX opt_prac_etat_bmp_idx ON opt_pracownicy(etat);
CREATE BITMAP INDEX opt_prac_plec_bmp_idx ON opt_pracownicy(plec);

SELECT index_name, table_name, index_type, uniqueness
FROM user_indexes
WHERE index_name IN
('OPT_PRAC_ETAT_BMP_IDX', 'OPT_PRAC_PLEC_BMP_IDX');

SELECT index_name, column_name, column_position
FROM user_ind_columns
WHERE index_name IN
('OPT_PRAC_ETAT_BMP_IDX', 'OPT_PRAC_PLEC_BMP_IDX')
ORDER BY index_name, column_position;

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(ownname => 'inf145406',
    tabname => 'OPT_PRACOWNICY',
    method_opt => 'FOR COLUMNS plec SIZE auto, etat SIZE auto',
    cascade => TRUE);
END;

-- 3.
SET AUTOTRACE ON PLAN;
SELECT COUNT(*) FROM opt_pracownicy
WHERE plec = 'K' AND etat = 'DYREKTOR';

-- 4.
SELECT COUNT(*) FROM opt_pracownicy
WHERE plec = 'K' AND (etat = 'DYREKTOR' OR etat = 'PROFESOR');

-- 5.
SELECT nazwisko FROM opt_pracownicy
WHERE plec = 'K' AND etat = 'DYREKTOR'; -- TABLE ACCESS FULL

SELECT /*+ INDEX_COMBINE(opt_pracownicy) */ nazwisko FROM opt_pracownicy
WHERE plec = 'K' AND etat = 'DYREKTOR'; -- BITMAP CONVERSION TO ROWIDS

-- 6.
SELECT nazwisko FROM opt_pracownicy
WHERE plec = 'K' AND etat IS NULL; -- BITMAP INDEX SINGLE VALUE  1 - filter("PLEC"='K' 3 - access("ETAT" IS NULL)

-- SORTOWANIE

-- 1.
SET AUTOTRACE ON EXPLAIN;

SELECT id_zesp, nazwa
FROM opt_zespoly
ORDER BY id_zesp;

-- 2.   
ALTER TABLE opt_zespoly
    ADD CONSTRAINT opt_zesp_pk PRIMARY KEY(id_zesp);

-- 3.
SELECT id_zesp, nazwa
FROM opt_zespoly
ORDER BY id_zesp;

-- 4.
ALTER TABLE opt_zespoly DROP CONSTRAINT opt_zesp_pk;

-- 5.
SELECT id_zesp
FROM opt_zespoly
ORDER BY id_zesp;

-- Id  | Operation          | Name        | E-Rows |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT   |             |        |       |       |          |
--|   1 |  SORT ORDER BY     |             |      5 |  2048 |  2048 | 2048  (0)|

--PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--|   2 |   TABLE ACCESS FULL| OPT_ZESPOLY |      5 |       |       |          |

-- 6.
SELECT nazwisko, placa
FROM opt_pracownicy WHERE id_prac < 10
ORDER BY id_prac;

-- 7.
SELECT nazwisko, placa
FROM opt_pracownicy WHERE id_prac < 10
ORDER BY id_prac DESC;

-- 8.
SELECT DISTINCT placa_dod
FROM opt_pracownicy; -- HASZOWANIE = SPECYFICZNE SORTOWANIE

-- 9.
SELECT placa_dod, COUNT(*)
FROM opt_pracownicy
GROUP BY placa_dod; -- SORTOWANIE DO GRUPOWANIA REKORDOW

-- 10.
SELECT SUM(placa)
FROM opt_pracownicy;