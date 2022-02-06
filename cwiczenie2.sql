 	
-- Polecenie EXPLAIN PLAN

-- 1.
SELECT nazwisko, nazwa
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

-- 2.
EXPLAIN PLAN FOR
SELECT nazwisko, nazwa
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

-- 3.
SELECT * FROM TABLE(dbms_xplan.display());

-- 4.
EXPLAIN PLAN  
SET STATEMENT_ID = 'zap_1_inf145406' FOR
SELECT nazwisko, nazwa
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

EXPLAIN PLAN  
SET STATEMENT_ID = 'zap_2_inf145406' FOR
SELECT etat, ROUND(AVG(placa),2)
FROM opt_pracownicy
GROUP BY etat ORDER BY etat;

SELECT *
FROM TABLE(dbms_xplan.display(statement_id => 'zap_2_inf145406'));

-- 5.
SELECT *
FROM TABLE(dbms_xplan.display(
           statement_id => 'zap_2_inf145406',
           format => 'BASIC'));  -- 'TYPICAL', 'ALL'

-- 6. Explain plan tool

-- Zadania samodzielne

-- 1.
SELECT * FROM TABLE(dbms_xplan.display(statement_id => 'zap_2_inf145406'));

-- 2.
SELECT *
FROM TABLE(dbms_xplan.display(
           statement_id => 'zap_2_inf145406',
           format => 'ALL'));  -- 'TYPICAL', 'ALL'
           
-- 3.
EXPLAIN PLAN FOR
SELECT opt_etaty.nazwa AS etat, COUNT(*) AS pracownicy
FROM opt_pracownicy JOIN opt_etaty ON opt_pracownicy.etat = opt_etaty.nazwa
GROUP BY opt_etaty.nazwa;

SELECT * FROM TABLE(dbms_xplan.display());

-- DYREKTYWA AUTOTRACE

-- 1.
SELECT etat, ROUND(AVG(placa), 2)
FROM opt_pracownicy
GROUP BY etat ORDER BY etat;

-- 2.
SET AUTOTRACE ON EXPLAIN;

-- 3.
SET AUTOTRACE ON STATISTICS;

-- 4.
SET AUTOTRACE ON; -- = SET AUTOTRACE ON STATISTICS + SET AUTOTRACE ON EXPLAIN

-- 5.
SET AUTOTRACE OFF;

-- 6.
SET AUTOTRACE TRACEONLY
 
-- Ustawia ona tryb pracy, w którym prezentowany  jest  plan  wykonania  polecenia  oraz  statystyki
-- wykonania  polecenia,  natomiast  sam  wynik  polecenia  nie  jest  prezentowany.  Jednak  bieżąca
-- wersja Oracle SQL Developer nie wspiera tego trybu pracy.

-- FUNCKJA DBMS_XPLAN.DISPLAY_CURSOR

-- 1.
SELECT nazwa, COUNT(*)
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp)
GROUP BY nazwa
ORDER BY nazwa;

-- 3.
SELECT * FROM TABLE(dbms_xplan.display_cursor());

-- 4.
SELECT sql_text, sql_id,
       to_char(last_active_time, 'yyyy.mm.dd hh24:mi:ss')
         as last_active_time,
       parsing_schema_name
FROM v$sql
WHERE sql_text LIKE  
    'SELECT nazwa%opt_pracownicy JOIN opt_zespoly%ORDER BY nazwa'
AND sql_text NOT LIKE '%v$sql%';

SELECT *  
FROM TABLE(dbms_xplan.display_cursor(sql_id => '06xnctj0zr5w1'));

-- 5.
SELECT /* TESTOWE_inf145406 */ nazwa, count(*)
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp)
GROUP BY nazwa
ORDER BY nazwa;

SELECT sql_id
FROM v$sql
WHERE sql_text LIKE '%TESTOWE_inf145406%'
AND sql_text NOT LIKE '%v$sql%';

-- 6.
SELECT *  
FROM TABLE(dbms_xplan.display_cursor(
   sql_id => '06xnctj0zr5w1', format => 'ALL'));

-- 7.

-- ZADANIA SAMODZIELNE

-- 1. 38dj6ut63njh4
SELECT /* ZAP_1_inf145406 */ *
FROM opt_pracownicy WHERE placa = (SELECT MAX(placa) FROM opt_pracownicy);

-- 0p8p83m53un1j
SELECT /* ZAP_2_inf145406 */ plec, COUNT(*) AS liczba, ROUND(AVG(placa), 2) AS srednia_placa
FROM opt_pracownicy GROUP BY plec;

-- 2.
SELECT sql_id
FROM v$sql
WHERE sql_text LIKE '%ZAP_1_inf145406%'
AND sql_text NOT LIKE '%v$sql%';

-- 3
SELECT *  
FROM TABLE(dbms_xplan.display_cursor(sql_id => '38dj6ut63njh4'));

SELECT *  
FROM TABLE(dbms_xplan.display_cursor(
   sql_id => '38dj6ut63njh4',
   format => 'BASIC +ROWS +BYTES'));
 
SELECT *  
FROM TABLE(dbms_xplan.display_cursor(
   sql_id => '38dj6ut63njh4',
   format => 'ALL -ALIAS'));
   
-- 4.
INSERT INTO /* insert_145406 */
opt_pracownicy VALUES(11111, NULL, '11111', 'M', 'N', 1337, 1337, 'ASYSTENT');

DELETE FROM /* delete_145406 */
opt_pracownicy WHERE id_prac = 11111;

-- 5.
COMMIT;

-- 6.
SELECT sql_id
FROM v$sql
WHERE sql_text LIKE '%insert_145406%'
AND sql_text NOT LIKE '%v$sql%'; -- bsfv3t2rdrp3r

SELECT sql_id
FROM v$sql
WHERE sql_text LIKE '%delete_145406%'
AND sql_text NOT LIKE '%v$sql%'; -- 2z9mh1vk5fv9v

SELECT *  
FROM TABLE(dbms_xplan.display_cursor(sql_id => 'bsfv3t2rdrp3r'));

SELECT *  
FROM TABLE(dbms_xplan.display_cursor(sql_id => '2z9mh1vk5fv9v'));