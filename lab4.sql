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

DELETE FROM Szefowie
WHERE nazwisko LIKE 'MORZY';

SELECT * FROM Szefowie;

-- 6.