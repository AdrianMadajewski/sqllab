-- 1.
set serveroutput on;

DECLARE 
    CURSOR cAsystent IS
        SELECT * FROM PRACOWNICY
        WHERE etat = 'ASYSTENT'
        ORDER BY nazwisko;

    vAsystent PRACOWNICY%ROWTYPE;
BEGIN
    OPEN cAsystent;
    LOOP
        FETCH cAsystent INTO vAsystent;
        EXIT WHEN cAsystent%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            vAsystent.nazwisko || ' pracuje od ' || 
            TO_CHAR(vAsystent.zatrudniony, 'DD-MM-YYYY')
        );
    END LOOP;
    CLOSE cAsystent;
END;

-- 2.
DECLARE 
    CURSOR cTopPlaca IS
        SELECT * FROM pracownicy
        ORDER BY placa_pod DESC;
    vPracownik PRACOWNICY%ROWTYPE;
BEGIN
    OPEN cTopPlaca;
    LOOP
        FETCH cTopPlaca INTO vPracownik;
        EXIT WHEN cTopPlaca%ROWCOUNT = 4;
        DBMS_OUTPUT.PUT_LINE(
           cTopPlaca%ROWCOUNT || ' : ' || vPracownik.nazwisko
        );
    END LOOP;
    CLOSE cTopPlaca;
END;

-- 3. NIEDZIELA TO PIERWSZY DZIEN TYGODNIA
SELECT * FROM PRACOWNICY ORDER BY placa_pod DESC;
SELECT * FROM pracownicy WHERE TO_CHAR(zatrudniony,'D') = 2;

DECLARE
    CURSOR cUpdatePlaca IS
        SELECT * FROM PRACOWNICY
        WHERE TO_CHAR(ZATRUDNIONY, 'D') = 2
        ORDER BY NAZWISKO
        FOR UPDATE;
BEGIN
    FOR vRow IN cUpdatePlaca LOOP
        UPDATE PRACOWNICY
        SET placa_pod = placa_pod * 1.2
        WHERE CURRENT OF cUpdatePlaca;
    END LOOP;
END;

-- 4.
DECLARE
    CURSOR cKursor is 
    select p.nazwisko,p.etat,z.nazwa,p.placa_dod from 
    PRACOWNICY p natural inner join  zespoly z for update;
    vZmienna cKursor%ROWTYPE;
BEGIN
    for vZmienna in cKursor LOOP
        if vZmienna.nazwa = 'ADMINISTRACJA' THEN
            update PRACOWNICY
            set placa_dod=NVL(placa_dod,0)+150
            where current of cKursor;
        ELSIF vZmienna.nazwa='ALGORYTMY' THEN
            update PRACOWNICY
            set placa_dod=NVL(placa_dod,0)+100
            where current of cKursor;
        ELSE
            if vZmienna.etat = 'STAZYSTA' THEN
                DELETE FROM Pracownicy
                WHERE CURRENT OF cKursor;
            end if;
        end if;
    end loop;
END;

-- 5.
CREATE OR REPLACE PROCEDURE PokazPracownikowEtatu(pNazwaEtat VARCHAR2) AS
-- DEKLARACJE
CURSOR cEtat(pEtat VARCHAR2) IS
    SELECT nazwisko
    FROM pracownicy 
    WHERE etat = pEtat;
BEGIN
    FOR vRow IN cEtat(pNazwaEtat) LOOP
         DBMS_OUTPUT.PUT_LINE(
          vRow.nazwisko
        );
    END LOOP;
END PokazPracownikowEtatu;

EXEC PokazPracownikowEtatu('PROFESOR');
