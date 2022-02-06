-- WSKAZOWKI DOTYCZACE SCIEZEK DOSTEPU DO DANYCH

-- 1.
SET AUTOTRACE ON EXPLAIN;

SELECT * FROM opt_pracownicy WHERE id_prac = 900;

-- 2.
SELECT --+ FULL(opt_pracownicy)
* FROM opt_pracownicy WHERE id_prac = 900;

-- 3.
SELECT /*+ FULL(opt_pracownicy) */ *
FROM opt_pracownicy p
WHERE id_prac = 900;

SELECT /*+ FULL(p) */ *
FROM opt_pracownicy p
WHERE id_prac = 900;

-- 4.
SELECT /*+ NO_INDEX(opt_pracownicy) */ *
FROM opt_pracownicy
WHERE id_prac = 900;

SELECT /*+ NO_INDEX(opt_pracownicy opt_prac_pk) */ *
FROM opt_pracownicy
WHERE id_prac = 900;

-- 5.
SELECT nazwisko, etat FROM opt_pracownicy;

-- Zmuszenie optymalizatora
SELECT /*+ INDEX(opt_pracownicy) */ nazwisko, etat
FROM opt_pracownicy;

-- 6. INDEX_COMBINE = INDEKS BITMAPOWY
SELECT /*+ INDEX_COMBINE(opt_pracownicy) */ nazwisko, etat
FROM opt_pracownicy;

-- 7.
SELECT placa
FROM opt_pracownicy
WHERE plec = 'K';

-- FFS - SZYBKIE PELNE PRZEGLADANIE INDEKSU
SELECT /*+ INDEX_FFS(opt_pracownicy) */ placa
FROM opt_pracownicy
WHERE plec = 'K';

-- 8.
-- INDEX_SS = PRZEGLADANIE INDEKSU Z POMINIECIEM KOLUMN
SELECT /*+ INDEX_SS(opt_pracownicy) */ placa
FROM opt_pracownicy
WHERE plec = 'K';

-- 9.
-- INDEX_JOIN = OPERACJA POLACZENIA INDEKSOW
SELECT /*+ INDEX_JOIN(opt_pracownicy
opt_prac_pk opt_prac_nazw_placa_idx) */
nazwisko
FROM opt_pracownicy
WHERE id_prac < 1000 AND placa = 1500;

-- 10. wiecej wskazowek to spacje po kazdym poleceniu

-- WSKAZOWKI W ZAPYTANAICH Z POLACZENIAMI

-- 1.
-- USE_HASH(tabela_1 tabela_2) – realizacja połączenia z użyciem algorytmu Hash Join.
-- NO_USE_HASH(tabela_1 tabela_2) – zabronienie użycia algorytmu Hash Join.
-- USE_NL(tabela_1 tabela_2) – realizacja połączenia z użyciem algorytmu Nested Loops.
-- NO_USE_NL(tabela_1 tabela_2) – zabronienie użycia algorytmu Nested Loops.
-- USE_MERGE(tabela_1 tabela_2) – realizacja połączenia z użyciem algorytmu Sort Merge.
-- NO_USE_MERGE(tabela_1 tabela_2) – zabronienie użycia algorytmu Sort Join.

SELECT /*+ USE_MERGE(e) USE_NL(z p) */ p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_zespoly z USING(id_zesp)
JOIN opt_etaty e ON p.etat = e.nazwa;

-- 2.
SELECT /*+ LEADING(p e) */
p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_zespoly z USING(id_zesp)
JOIN opt_etaty e ON p.etat = e.nazwa; -- Jako pierwsze polaczone zostaly pracownicy i etaty a zespoly zostala polaczana z wynikiem operacji tamtego polaczenia

-- 3.
SELECT /*+ LEADING(z e) */
p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_zespoly z USING(id_zesp)
JOIN opt_etaty e ON p.etat = e.nazwa;

-- PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                |      1 |        |     50 |00:00:00.01 |      16 |       |       |          |
-- |*  1 |  HASH JOIN            |                |      1 |  10000 |     50 |00:00:00.01 |      16 |  1162K|  1162K| 1387K (0)|
-- |   2 |   MERGE JOIN CARTESIAN|                |      1 |     60 |     60 |00:00:00.01 |      13 |       |       |          |
-- |   3 |    TABLE ACCESS FULL  | OPT_ZESPOLY    |      1 |      5 |      5 |00:00:00.01 |       6 |       |       |          |
-- |   4 |    BUFFER SORT        |                |      5 |     12 |     60 |00:00:00.01 |       7 | 73728 | 73728 |          |
-- |   5 |     TABLE ACCESS FULL | OPT_ETATY      |      1 |     12 |     12 |00:00:00.01 |       7 |       |       |          |
-- |   6 |   TABLE ACCESS FULL   | OPT_PRACOWNICY |      1 |  10000 |     50 |00:00:00.01 |       3 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------

-- 4.
SELECT p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_etaty e ON p.etat = e.nazwa
JOIN opt_zespoly z USING(id_zesp);

-- + ORDERED = wedlug kolejnosci laczenia z klauzuli FROM
SELECT /*+ ORDERED */
p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_etaty e ON p.etat = e.nazwa
JOIN opt_zespoly z USING(id_zesp);

-- 5. NIE WIEM ???
SELECT /*+ ORDERED */
p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_etaty e ON p.etat = e.nazwa
JOIN opt_zespoly z USING(id_zesp);

-- TRANSFORMACJE = zamiana naszego zapytania na zapytanie lepsze wzgledem optymalizatora
-- 1.
SELECT id_prac, id_zesp
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

-- 2.
SELECT nazwisko
FROM opt_pracownicy
WHERE id_zesp IN
(SELECT id_zesp FROM opt_zespoly WHERE nazwa = 'Bazy Danych');


-- HASH JOIN RIGHT SEMI, czyli realizacja tzw. półpołączenia tabel OPT_PRACOWNICY
-- i OPT_ZESPOLY. Jest to przykład transformacji, realizowanej automatycznie przez optymalizator,
-- zastępującej zapytanie z podzapytaniem zapytaniem z połączeniem

-- 3.
SELECT nazwisko, srednia
FROM opt_pracownicy JOIN
(SELECT AVG(placa) AS srednia, id_zesp FROM opt_pracownicy
GROUP BY id_zesp) z USING(id_zesp)
WHERE placa > srednia;

-- MERGE - optymzalitor nie traktuje podzapytania jak perspektuwe ale wlacza tresc tego zapytania do zapytania glownego = SCALANIE PERSPEKTYWY
SELECT /*+ MERGE(z) */ nazwisko, srednia
FROM opt_pracownicy JOIN
(SELECT AVG(placa) AS srednia, id_zesp FROM opt_pracownicy
GROUP BY id_zesp) z USING(id_zesp)
WHERE placa > srednia;

-- 4.
SELECT --+ NO_QUERY_TRANSFORMATION
id_prac, id_zesp
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

SELECT --+ NO_QUERY_TRANSFORMATION
nazwisko
FROM opt_pracownicy
WHERE id_zesp IN
(SELECT id_zesp FROM opt_zespoly WHERE nazwa = 'Bazy Danych');
