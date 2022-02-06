 	

-- PODSTAWY OPERACJI POLACZENIA

-- 1.
SET AUTOTRACE ON EXPLAIN;
SELECT * FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

-- 2.
SELECT * FROM opt_pracownicy RIGHT JOIN opt_zespoly USING(id_zesp);

-- 3.
ALTER TABLE opt_zespoly
    ADD CONSTRAINT opt_zesp_pk PRIMARY KEY(id_zesp);
    
ALTER TABLE opt_pracownicy ADD CONSTRAINT opt_prac_fk_oz_1
    FOREIGN KEY(id_zesp) REFERENCES opt_zespoly(id_zesp);
    
CREATE INDEX opt_prac_id_zesp_idx ON opt_pracownicy(id_zesp);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname=>'inf145406',
        tabname => 'OPT_PRACOWNICY'
    );
    
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname=>'inf145406',
        tabname => 'OPT_ZESPOLY'
    );
END;

-- 4.
SELECT * FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp)
WHERE nazwa = 'Bazy danych'; -- Warunek filtrujacy

-- 5.
ALTER session SET optimizer_index_cost_adj = 20;

-- 6.
SELECT * FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp)
WHERE nazwa = 'Bazy danych';

ALTER session SET optimizer_index_cost_adj = 100;

-- 7.
SELECT p1.nazwisko, p2.nazwisko
FROM opt_pracownicy p1 JOIN opt_pracownicy p2
ON p1.placa > p2.placa
WHERE p1.id_prac <> p2.id_prac AND p1.nazwisko LIKE 'Prac155%';

-- 8.
SELECT COUNT(*)
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp)
WHERE nazwa = 'Bazy danych';

CREATE BITMAP INDEX opt_prac_zesp_join_idx ON opt_pracownicy(nazwa)
FROM opt_pracownicy p, opt_zespoly z WHERE p.id_zesp = z.id_zesp;

-- 9.
DROP INDEX opt_prac_zesp_join_idx;

-- POLACZENIE WIELU RELACJI

-- 1.
SELECT p.nazwisko, z.nazwa, e.placa_min, e.placa_max
FROM opt_pracownicy p JOIN opt_etaty e ON p.etat = e.nazwa
JOIN opt_zespoly z USING(id_zesp);

-- 2.
SELECT p1.nazwisko, p2.nazwisko, z.nazwa
FROM opt_pracownicy p1 JOIN opt_pracownicy p2
ON p1.placa > p2.placa
JOIN opt_zespoly z ON p1.id_zesp = z.id_zesp
WHERE p1.id_prac <> p2.id_prac AND p1.nazwisko LIKE 'Prac155%'
AND nazwa = 'Bazy danych';
