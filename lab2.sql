-- 1.
-- DELETE FROM pracownicy WHERE nazwisko = 'DYNDALSKI';

CREATE OR REPLACE PROCEDURE NowyPracownik(
    pNazwisko PRACOWNICY.NAZWISKO%TYPE, 
    pNazwaZespolu ZESPOLY.NAZWA%TYPE,
    pNazwiskoSzefa PRACOWNICY.NAZWISKO%TYPE,
    pPlacaPod PRACOWNICY.PLACA_DOD%TYPE
)
AS BEGIN
    INSERT INTO pracownicy VALUES(
        prac_seq.nextval,
        pNazwisko, 
        'STAZYSTA', 
        (SELECT id_prac FROM pracownicy WHERE nazwisko LIKE pNazwiskoSzefa),
        current_date,
        pPlacaPod,
        NULL,
        (SELECT id_zesp FROM zespoly WHERE nazwa LIKE pNazwaZespolu)
    );
END NowyPracownik;
 
EXEC NowyPracownik('DYNDALSKI', 'ALGORYTMY', 'BLAZEWICZ', 250);
 
SELECT * FROM pracownicy WHERE nazwisko = 'DYNDALSKI';

-- 2.
CREATE OR REPLACE FUNCTION PlacaNetto
(
    placa IN NUMBER, 
    procent IN NUMBER
) 
RETURN NUMBER IS vplaca NUMBER;
BEGIN
    SELECT placa * (100 - procent) / 100 INTO vplaca FROM DUAL;
    return vplaca;
END PlacaNetto;

SELECT nazwisko, placa_pod AS brutto, PlacaNetto(placa_pod, 35) AS netto 
FROM pracownicy WHERE etat = 'PROFESOR' ORDER BY nazwisko;

-- 3.
CREATE OR REPLACE FUNCTION Silnia(pn in NUMBER)
RETURN NUMBER IS vsilnia NUMBER;
BEGIN
    vsilnia := 1;

    FOR i IN 1..pn LOOP
        vsilnia := vsilnia * i;
    END LOOP;

    RETURN vsilnia;
END Silnia;

SELECT Silnia(3) FROM dual;

-- 4.
CREATE OR REPLACE FUNCTION silniarek(pn IN NUMBER)
RETURN NUMBER IS vsilnia NUMBER;
BEGIN
    IF(pn = 0) THEN RETURN 1; END IF;
    RETURN pn * silniarek(pn - 1);
END silniarek;

SELECT silniarek(10) FROM dual;

-- 5.
CREATE OR REPLACE FUNCTION IleLat
(
    pdata IN DATE
)
RETURN INT AS staz INT;
BEGIN
    -- RETURN EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM pdata);
    RETURN EXTRACT(YEAR FROM (current_date - pdata) YEAR TO MONTH);
END IleLat;

SELECT nazwisko, zatrudniony, IleLat(zatrudniony) AS staz 
     FROM Pracownicy WHERE placa_pod > 1000 
     ORDER BY nazwisko;

-- 6.
CREATE OR REPLACE PACKAGE Konwersja AS

    FUNCTION cels_to_fahr
    (
        pstopnie IN NUMBER
    )
    RETURN NUMBER;

    FUNCTION fahr_to_cels
    (
        pstopnie IN NUMBER
    )
    RETURN NUMBER;

END Konwersja;
/
CREATE OR REPLACE PACKAGE BODY Konwersja AS

    FUNCTION cels_to_fahr(pstopnie IN NUMBER)
    RETURN NUMBER AS 
    BEGIN
        RETURN 9 / 5 * pstopnie + 32;
    END;

    FUNCTION fahr_to_cels(pstopnie IN NUMBER)
    RETURN NUMBER AS
    BEGIN 
        RETURN 5 / 9 * (pstopnie - 32);
    END;

END Konwersja;

SELECT Konwersja.fahr_to_cels(212) AS CELSJUSZ FROM Dual; 

SELECT Konwersja.cels_to_fahr(0) AS FAHRENHEIT FROM Dual;

-- 7.
CREATE OR REPLACE PACKAGE Zmienne AS
    PROCEDURE zwieksz_licznik;
    PROCEDURE zmniejsz_licznik;
    FUNCTION pokaz_licznik RETURN NUMBER;
END Zmienne;
/
CREATE OR REPLACE PACKAGE BODY Zmienne AS
    vLicznik NATURAL := 0;

    PROCEDURE zwieksz_licznik AS
    BEGIN
        vLicznik := vLicznik + 1;
    END;

    PROCEDURE zmniejsz_licznik AS
    BEGIN
        vLicznik := vLicznik - 1;
    END;

    FUNCTION pokaz_licznik RETURN NUMBER AS
    BEGIN
        RETURN vLicznik;
    END;
END;

set serveroutput on;
 
BEGIN 
    Zmienne.zwieksz_licznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.pokaz_licznik); 
END;