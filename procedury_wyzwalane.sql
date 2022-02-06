 	

SET SERVEROUTPUT ON;

-- 1.
CREATE TABLE DziennikOperacji(
    data_realizacji DATE,
    typ VARCHAR(50),
    tabela VARCHAR(30),
    liczbaRekordow NUMBER
);
 
 
CREATE OR REPLACE TRIGGER LogujOperacje
 AFTER INSERT OR DELETE OR UPDATE ON Zespoly
DECLARE
 op VARCHAR(50);
BEGIN
 CASE
 WHEN INSERTING THEN
 op := 'INSERT';
 WHEN DELETING THEN
 op := 'DELETE';
 WHEN UPDATING THEN
 op := 'UPDATE';
 END CASE;
 INSERT INTO DziennikOperacji VALUES(CURRENT_DATE, op, 'Zespoly', (SELECT COUNT(*) FROM zespoly));
END;
 
SELECT * FROM DziennikOperacji;
 
INSERT INTO Zespoly VALUES((SELECT MAX(id_zesp) FROM zespoly) + 10, 'zespol nowy', 'adres zespolu');
DELETE FROM Zespoly WHERE id_zesp = (SELECT MAX(id_zesp) FROM zespoly);
 
 
-- 2.
CREATE OR REPLACE TRIGGER PokazPlace
 BEFORE UPDATE OF placa_pod ON Pracownicy
 FOR EACH ROW
 WHEN (OLD.placa_pod <> NEW.placa_pod OR OLD.placa_pod IS NULL OR NEW.placa_pod IS NULL)
BEGIN
 DBMS_OUTPUT.PUT_LINE('Pracownik ' || :OLD.nazwisko);
 DBMS_OUTPUT.PUT_LINE('Płaca przed modyfikacją: ' || :OLD.placa_pod);
 DBMS_OUTPUT.PUT_LINE('Płaca po modyfikacji: ' || :NEW.placa_pod);
END;

UPDATE pracownicy
SET placa_pod = 2137
WHERE nazwisko LIKE 'BLAZEWICZ';
 
 
-- 3.
CREATE OR REPLACE TRIGGER UzupelnijPlace
    BEFORE INSERT ON pracownicy
    FOR EACH ROW
    WHEN (NEW.placa_pod IS NULL)
DECLARE
    vPlacaMin etaty.placa_min%TYPE;
BEGIN
    IF :NEW.placa_pod IS NULL AND :NEW.etat IS NOT NULL THEN
        SELECT placa_min INTO vPlacaMin FROM Etaty WHERE nazwa = :NEW.etat;

    :NEW.placa_pod := vPlacaMin;
 END IF;
    :NEW.placa_dod := NVL(:NEW.placa_dod, 0);
END;

INSERT INTO pracownicy
VALUES(PRAC_SEQ.nextval, 'MADAJEWSKI', 'STAZYSTA', 110, CURRENT_DATE, NULL, NULL, NULL);

SELECT * FROM pracownicy WHERE nazwisko LIKE 'MADAJEWSKI';

-- 4.
SELECT MAX(id_zesp) FROM zespoly;

CREATE SEQUENCE SEQ_Zespoly
    START WITH 51
    INCREMENT BY 1

CREATE OR REPLACE TRIGGER UzupelnijID
    BEFORE INSERT ON zespoly
    FOR EACH ROW
    WHEN (NEW.id_zesp IS NULL)
BEGIN
    :NEW.id_zesp := SEQ_Zespoly.nextval;
END;

INSERT INTO zespoly(nazwa, adres) VALUES('NOWY ZESPOL', 'ADRES');
SELECT * FROM zespoly;

-- 5.
CREATE OR REPLACE VIEW Szefowie AS
SELECT s.nazwisko as NAZWISKO, COUNT(p.nazwisko) AS PRACOWNICY FROM pracownicy s INNER JOIN pracownicy p ON p.id_szefa = s.id_prac
GROUP BY s.nazwisko;

SELECT * FROM Szefowie;

CREATE OR REPLACE TRIGGER UsunKaskadowo
    INSTEAD OF DELETE ON Szefowie
DECLARE
    CURSOR podwladni IS
        SELECT * FROM pracownicy WHERE id_szefa = (select id_prac FROM pracownicy WHERE nazwisko = :old.nazwisko);
    vPodpod INT := 0;
BEGIN
    for pod in podwladni loop
        SELECT COUNT(*) INTO vPodpod FROM pracownicy WHERE id_szefa IN (SELECT id_prac FROM pracownicy WHERE NAZWISKO = pod.nazwisko);
        DBMS_OUTPUT.PUT_LINE(vPodpod);
       
        if vPodpod > 0 then
            raise_application_error(-20001, 'Jeden z podwladnych usuwanego pracownika jest szefem innych pracownikow. Usuwanie anulowane!');
        else
            DELETE FROM pracownicy WHERE nazwisko = pod.nazwisko;
        end if;
    end loop;

    DELETE FROM pracownicy WHERE nazwisko = :old.nazwisko;
END;

DELETE FROM szefowie
WHERE nazwisko LIKE 'MORZY';

SELECT * FROM Szefowie;

rollback;

-- 6.
ALTER TABLE zespoly
    ADD liczba_pracownikow INTEGER;
   
UPDATE zespoly
    SET liczba_pracownikow = (SELECT COUNT(id_prac) FROM pracownicy WHERE id_zesp = zespoly.id_zesp);

CREATE OR REPLACE TRIGGER IluPracownikow
    AFTER INSERT OR UPDATE OR DELETE ON pracownicy
    FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN
            UPDATE zespoly
                SET liczba_pracownikow = liczba_pracownikow + 1 WHERE id_zesp = :NEW.id_zesp;
        WHEN DELETING THEN
             UPDATE zespoly
                SET liczba_pracownikow = liczba_pracownikow - 1 WHERE id_zesp = :OLD.id_zesp;
        WHEN UPDATING THEN
            UPDATE zespoly
                SET liczba_pracownikow = liczba_pracownikow - 1 WHERE id_zesp = :OLD.id_zesp;
            UPDATE zespoly
                SET liczba_pracownikow = liczba_pracownikow + 1 WHERE id_zesp = :NEW.id_zesp;
    END CASE;
END;

SELECT * FROM zespoly;

INSERT INTO pracownicy(id_prac, nazwisko, id_zesp, id_szefa)
    VALUES(300,'NOWY PRACOWNIK',40,120);

SELECT * FROM Zespoly;  

UPDATE Pracownicy SET id_zesp = 10 WHERE id_zesp = 30;

rollback;

-- 7.
ALTER TABLE pracownicy DROP CONSTRAINT fk_id_szefa;
ALTER TABLE pracownicy ADD CONSTRAINT fk_id_szefa FOREIGN KEY(id_szefa) REFERENCES pracownicy(id_prac) ON DELETE CASCADE;

CREATE OR REPLACE TRIGGER Usun_Prac
    AFTER DELETE ON pracownicy
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usunieto: ' || :OLD.nazwisko);
END;

DELETE FROM pracownicy WHERE nazwisko = 'BLAZEWICZ';

rollback;

-- Po wykonaniu DELETE wypisuja sie najpierw nazwiska, a potem pracownik BLAZEWICZ
-- Przed wykonaniem DELETE usuwa sie najpierw pracownik, a potem jego podwladni

-- 8.
ALTER TABLE pracownicy DISABLE ALL TRIGGERS;

-- 9.
SELECT * FROM user_triggers;

DROP TRIGGER LOGUJOPERACJE;
DROP TRIGGER USUNKASKADOWO;
DROP TRIGGER USUN_PRAC;
DROP TRIGGER UZUPELNIJID;