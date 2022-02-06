 	

-- SESJA A 590
-- 3.
UPDATE pracownicy SET placa_pod=placa_pod+100 WHERE nazwisko='HAPKE';
select * from table(sbd.blokady);

-- 5.
select * from table(sbd.blokady);
select * from table(sbd.blokady(631));

--6.
ROLLBACK;

-- WSPOLBIEZNOSC, POZIOMY IZOLACJI
-- 1.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT placa_pod FROM pracownicy WHERE nazwisko='KONOPKA'; -1000
UPDATE pracownicy
ET placa_pod=800 WHERE nazwisko='KONOPKA';
COMMIT;
-- 4.
-- Operacje symulowaly anomalie utraconej modyfikacji.KONOPKA ma place_pod rowna 800.
-- W przypadku sekwencyjnego wykonania transakcji KONOPKA mialby place podstawowa o wartosci 1100.

-- 5.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT placa_pod FROM pracownicy WHERE nazwisko='KONOPKA'; -800
UPDATE pracownicy
SET placa_pod= 600 WHERE nazwisko='KONOPKA';
-- Nie jest mozliwe wykonanie sekwencyjne tej transakcji

-- ANOMALIA SKROSNEGO ZAPISU

-- 1.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- 3.
UPDATE pracownicy SET placa_pod=(SELECT placa_pod FROM pracownicy WHERE nazwisko='BRZEZINSKI') WHERE nazwisko='MORZY';
-- 5.
COMMIT;
-- W przypadku wykonania sekwencyjnego taki stan nie jest osiagalny. Doszlo do skosnego zapisu.

-- ZAKLESZCZENIE

-- 1.
UPDATE pracownicy
SET placa_pod=placa_pod+10 WHERE id_prac=210;
-- 3.
UPDATE pracownicy
SET placa_pod=placa_pod+10 WHERE id_prac=220;
-- 5.
COMMIT;

-- SESJA B 631

-- 4. SELECT * FROM pracownicy WHERE nazwisko='HAPKE';
--    UPDATE pracownicy
--    SET placa_pod=placa_pod+50 WHERE nazwisko='HAPKE';
-- 6. select * from table(sbd.blokady);
-- 7. ROLLBACK;

--WSPOLBIEZNOSC, POZIOMY IZOLACJI

-- 2.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT placa_pod FROM pracownicy WHERE nazwisko='KONOPKA'; -- 1000
UPDATE pracownicy
SET placa_pod= 1300 WHERE nazwisko='KONOPKA';
COMMIT;

-- 5.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT placa_pod FROM pracownicy WHERE nazwisko='KONOPKA'; -- 800
UPDATE pracownicy
SET placa_pod= 1100 WHERE nazwisko='KONOPKA';

-- ANOMALIA SKROSNEGO ZAPISU
-- 2.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- 4.
UPDATE pracownicy
SET placa_pod=(SELECT placa_pod FROM pracownicy WHERE nazwisko='MORZY') WHERE nazwisko='BRZEZINSKI';
-- 5.
COMMIT

-- ZAKLESZCZENIE
-- 2.
UPDATE pracownicy
SET placa_pod=placa_pod+10 WHERE id_prac=220;

-- 4.
UPDATE pracownicy
SET placa_pod=placa_pod+10 WHERE id_prac=210; -- zakleszczenie

-- 5.
ROLLBACK;