 	

SET SERVEROUTPUT ON;

-- Transakcje DML

SELECT * FROM pracownicy;

-- 2.
UPDATE pracownicy
SET etat = 'ADIUNKT'
WHERE nazwisko LIKE 'MATYSIAK';

-- 3.
DELETE FROM pracownicy
WHERE etat = 'ASYSTENT';

-- 5. Cofnelo sie do momentu z przed ustawienia matysiaka na adiunkt
ROLLBACK;

-- Transakcje DDL

-- 1.
UPDATE pracownicy
SET placa_pod = 1.1 * placa_pod
WHERE etat = 'ADIUNKT';

SELECT * FROM pracownicy;

-- 2.
ALTER TABLE pracownicy
    MODIFY placa_pod NUMBER(7, 2);

SELECT * FROM pracownicy;

-- 3.
rollback;

SELECT * FROM pracownicy;

-- Punkty bezpieczenstwa transakcji
-- 1.
UPDATE pracownicy
SET placa_dod = placa_dod + 200
WHERE nazwisko LIKE 'MORZY';

-- 2.
SAVEPOINT S1;
SELECT * FROM pracownicy;

-- 3.
UPDATE pracownicy
SET placa_dod = 100
WHERE nazwisko LIKE 'BIALY';

-- 4.
SAVEPOINT S2;
SELECT * FROM pracownicy;

-- 5.
DELETE FROM pracownicy
WHERE nazwisko LIKE 'JEZIERSKI';

-- 6.
ROLLBACK TO S1;
SELECT * FROM pracownicy;

-- 7.
ROLLBACK TO S2;

-- 8.
ROLLBACK;

-- 9.
-- Zakonczenie sesji