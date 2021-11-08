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

-- 8
CREATE OR REPLACE PACKAGE IntZespoly IS
    PROCEDURE DodajZespol(
        pNazwa zespoly.nazwa%type,
        pAdres zespoly.adres%type
    );
    PROCEDURE UsunZespolId(
        pIdZesp zespoly.id_zesp%type
    );
    PROCEDURE UsunZespolNazwa(
        pNazwa zespoly.nazwa%type
    );
    PROCEDURE ModyfikujZespol(
        pIdZesp zespoly.id_zesp%type,
        pNazwa zespoly.nazwa%type,
        pAdres zespoly.adres%type
    );
    FUNCTION ZnajdzIdZespolu( pNazwa zespoly.nazwa%type ) RETURN zespoly.id_zesp%type;
    FUNCTION ZnajdzNazweZespolu( pIdZesp zespoly.id_zesp%type ) RETURN zespoly.nazwa%type;
    FUNCTION ZnajdzAdresZespolu( pIdZesp zespoly.id_zesp%type ) RETURN zespoly.adres%type;
END IntZespoly;

CREATE OR REPLACE PACKAGE BODY IntZespoly IS
    PROCEDURE DodajZespol(
        pNazwa zespoly.nazwa%type,
        pAdres zespoly.adres%type
    ) IS
    BEGIN
        INSERT INTO zespoly (id_zesp, nazwa, adres)
        VALUES ((SELECT MAX(id_zesp) + 1 FROM zespoly), pNazwa, pAdres);
    END;

    PROCEDURE UsunZespolId(
        pIdZesp zespoly.id_zesp%type
    ) IS
    BEGIN
        DELETE FROM zespoly
        WHERE id_zesp = pIdZesp;
    END;

    PROCEDURE UsunZespolNazwa(
        pNazwa zespoly.nazwa%type
    ) IS
    BEGIN
        DELETE FROM zespoly
        WHERE nazwa = pNazwa;
    END;

    PROCEDURE ModyfikujZespol(
        pIdZesp zespoly.id_zesp%type,
        pNazwa zespoly.nazwa%type,
        pAdres zespoly.adres%type
    ) IS
    BEGIN
        UPDATE zespoly
        SET
            nazwa = pNazwa,
            adres = pAdres
        WHERE id_zesp = pIdZesp;
    END;

    FUNCTION ZnajdzIdZespolu(
        pNazwa zespoly.nazwa%type
    ) RETURN zespoly.id_zesp%type IS
        vIdZesp zespoly.id_zesp%type;
    BEGIN
        SELECT ID_ZESP INTO vIdZesp FROM zespoly WHERE nazwa = pNazwa;
        RETURN vIdZesp;
    END;

    FUNCTION ZnajdzNazweZespolu(
        pIdZesp zespoly.id_zesp%type
    ) RETURN zespoly.nazwa%type IS
        vNazwa zespoly.nazwa%type;
    BEGIN
        SELECT nazwa INTO vNazwa FROM zespoly WHERE id_zesp = pIdZesp;
        RETURN vNazwa; 
    END;

    FUNCTION ZnajdzAdresZespolu(
        pIdZesp zespoly.id_zesp%type
    ) RETURN zespoly.adres%type IS
        vAdres zespoly.adres%type;
    BEGIN
        SELECT adres INTO vAdres FROM zespoly WHERE id_zesp = pIdZesp;
        RETURN vAdres;
    END;
END IntZespoly;

EXEC IntZespoly.DODAJZESPOL('Zespoly NOWY', 'Adres nowy');

SELECT * FROM zespoly;

-- 9
SELECT object_name, status  
FROM user_objects 
WHERE object_type = 'PROCEDURE' OR object_type = 'FUNCTION';

SELECT text FROM user_source WHERE name = 'NOWYPRACOWNIK';

-- 10
DROP FUNCTION Silnia;
DROP FUNCTION SilniaRek;
DROP FUNCTION IleLat;

-- 10
DROP PACKAGE Konwersja;