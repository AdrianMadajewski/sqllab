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

-- 6.
CREATE OR REPLACE PROCEDURE RaportKadrowy IS
  CURSOR cEtaty IS
  SELECT nazwa
  FROM etaty
  ORDER BY nazwa;

  CURSOR cPracownicy(
    pEtat pracownicy.etat%type
  ) IS
  SELECT nazwisko, (placa_pod + COALESCE(placa_dod, 0)) AS pensja
  FROM pracownicy
  WHERE etat = pEtat;

  vSumaPensji NUMBER := 0;
  vLicznik NUMBER := 0;
BEGIN
  FOR vEtat IN cEtaty LOOP
    vSumaPensji := 0;
    vLicznik := 0;
    DBMS_OUTPUT.PUT_LINE('Etat: ' || vEtat.nazwa);
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    FOR vPracownik IN cPracownicy(vEtat.nazwa) LOOP
      vLicznik := vLicznik + 1;
      vSumaPensji := vSumaPensji + vPracownik.pensja;
      DBMS_OUTPUT.PUT_LINE(cPracownicy%ROWCOUNT || '. ' || vPracownik.nazwisko || ', pensja: ' || vPracownik.pensja);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Liczba pracownikow: ' || vLicznik);

     IF vLicznik = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Średnia pensja: brak');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Średnia pensja: ' || (vSumaPensji / vLicznik));
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;

END;

EXEC RaportKadrowy;

-- 7.
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

        IF SQL%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE('Nie udało się dodac zespolu o nazwie: ' || pNazwa);
        END IF;
    END;

    PROCEDURE UsunZespolId(
        pIdZesp zespoly.id_zesp%type
    ) IS
    BEGIN
        DELETE FROM zespoly
        WHERE id_zesp = pIdZesp;

        IF SQL%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE('Nie udało się usunac zespolu od id: ' || pIdZesp);
        END IF;
    END;

    PROCEDURE UsunZespolNazwa(
        pNazwa zespoly.nazwa%type
    ) IS
    BEGIN
        DELETE FROM zespoly
        WHERE nazwa = pNazwa;

        IF SQL%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE('Nie udało się usunac zespolu o nazwie: ' || pNazwa);
        END IF;
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

        IF SQL%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE('Nie udało się zmodyfikowac danych zespolu o id: ' || pIdZesp);
        END IF;
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

-- 8.
CREATE OR REPLACE PACKAGE IntZespoly IS
    PROCEDURE DodajZespol(pid_zesp zespoly.id_zesp%type ,pnazwa zespoly.nazwa%type, padres zespoly.adres%type);
    PROCEDURE UsunZespolId(pid_zesp zespoly.id_zesp%type);
    PROCEDURE UsunZespolNazwa(pnazwa zespoly.nazwa%type);
    PROCEDURE Modyfikuj(pid_zesp zespoly.id_zesp%type, pnazwa zespoly.nazwa%type, padres zespoly.adres%type);
    FUNCTION PokazId(pnazwa zespoly.nazwa%type) RETURN zespoly.id_zesp%type;
    FUNCTION PokazNazwe(pid_zesp zespoly.id_zesp%type) RETURN zespoly.nazwa%type;
    FUNCTION PokazAdres(pid_zesp zespoly.id_zesp%type) RETURN zespoly.adres%type;
       
    exZleID EXCEPTION;
    exZlaNazwa EXCEPTION;

    PRAGMA EXCEPTION_INIT(exZleID, -2290);
    PRAGMA EXCEPTION_INIT(exZlaNazwa, -2291);

END IntZespoly;

CREATE OR REPLACE PACKAGE BODY IntZespoly IS

    PROCEDURE DodajZespol(pid_zesp zespoly.id_zesp%type ,pnazwa zespoly.nazwa%type, padres zespoly.adres%type) IS
    exIstniejeNazwa EXCEPTION;
    exIstniejeID EXCEPTION;
    PRAGMA EXCEPTION_INIT(exIstniejeNazwa, -2292);
    PRAGMA EXCEPTION_INIT(exIstniejeID, -2293);
        BEGIN
            DECLARE
                CURSOR cID IS
                    SELECT id_zesp
                    FROM zespoly
                    ORDER BY id_zesp ASC;
                CURSOR cNazwa is
                    SELECT nazwa
                    FROM zespoly
                    ORDER BY nazwa ASC;
        BEGIN
       
            FOR vID IN cID LOOP
                IF vID.id_zesp = pid_zesp THEN
                    RAISE exIstniejeID;
                END IF;
            END LOOP;
           
            FOR vNazwa IN cNazwa LOOP
                IF (vNazwa.nazwa = pnazwa) THEN
                    RAISE exIstniejeNazwa;
                END IF;
            END LOOP;
           
            INSERT INTO zespoly(id_zesp,  nazwa, adres)
            VALUES (pid_zesp, pnazwa, padres);
           
            EXCEPTION
                WHEN exIstniejeNazwa THEN
                    DBMS_OUTPUT.PUT_LINE('Probujesz dodac zespol o istniejacej juz nazwie ' || pnazwa);
                WHEN exIstniejeID THEN
                    DBMS_OUTPUT.PUT_LINE('Probujesz dodac zespol o istniejacym juz ID ' || pid_zesp);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd ' || SQLCODE);
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;
               
    END DodajZespol;

       

    PROCEDURE UsunZespolId(pid_zesp zespoly.id_zesp%type) IS
    vTemp NUMBER; -- BOOL
    exNiepoprawneID EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNiepoprawneID, -2294);
        BEGIN
            DECLARE
                CURSOR cID is
                    SELECT id_zesp
                    FROM zespoly;
       
        BEGIN
            vTemp := 0;
            FOR vID IN cID LOOP
                IF (vID.id_zesp = pid_zesp) THEN
                    vTemp := 1;
                END IF;
            END LOOP;
           
            IF (vTemp != 1) THEN
                RAISE exNiepoprawneID;
            END IF;
   
            DELETE FROM zespoly where id_zesp = pid_zesp;
           
            EXCEPTION
                WHEN exNiepoprawneID THEN
                    DBMS_OUTPUT.PUT_LINE('Nie istnieje zespol o podanym ID ' || pid_zesp);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd ' || SQLCODE);
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
               
        END;
    END UsunZespolId;

       

    PROCEDURE UsunZespolNazwa(pnazwa zespoly.nazwa%type) IS
    vTemp INTEGER; -- BOOL
    exNiepoprawnaNazwa EXCEPTION;
    PRAGMA EXCEPTION_INIT(exNiepoprawnaNazwa, -2295);
        BEGIN
            DECLARE
                CURSOR cNazwa is
                    SELECT nazwa
                    FROM zespoly
                    ORDER BY nazwa asc;
        BEGIN
            vTemp := 0;
           
            FOR vNazwa IN cNazwa LOOP
                IF (vNazwa.nazwa = pnazwa) THEN
                    vTemp := 1;
                END IF;
            END LOOP;
           
            IF (vTemp != 1) THEN
                RAISE exNiepoprawnaNazwa;
            END IF;
       
            DELETE FROM zespoly where nazwa = pnazwa;
           
       
            EXCEPTION
                WHEN exNiepoprawnaNazwa THEN
                    DBMS_OUTPUT.PUT_LINE('Nie istnieje zespol o podanej nazwie ' || pnazwa);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd ' || SQLCODE);
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;

    END UsunZespolNazwa;


    PROCEDURE Modyfikuj(pid_zesp zespoly.id_zesp%type, pnazwa zespoly.nazwa%type, padres zespoly.adres%type) IS
    exIstniejeNazwa EXCEPTION;
    exNiepoprawneID EXCEPTION;
    PRAGMA EXCEPTION_INIT(exIstniejeNazwa, -2296);
    PRAGMA EXCEPTION_INIT(exNiepoprawneID, -2297);
    vTemp INTEGER; -- BOOL
        BEGIN
            DECLARE
                CURSOR cID IS
                    SELECT id_zesp
                    FROM zespoly
                    ORDER BY id_zesp asc;
                CURSOR cNazwa is
                    SELECT nazwa
                    FROM zespoly
                    ORDER BY nazwa asc;

        BEGIN
            vTemp := 0;
            FOR vNazwa IN cNazwa LOOP
                IF (vNazwa.nazwa = pnazwa) THEN
                    RAISE exIstniejeNazwa;
                END IF;
            END LOOP;
           
            FOR vID IN cID LOOP
                IF (vID.id_zesp = pid_zesp) THEN
                    vTemp := 1;
                END IF;
            END LOOP;
           
            IF (vTemp != 1) THEN
                RAISE exNiepoprawneID;
            END IF;
           
            UPDATE zespoly
            SET nazwa = pnazwa, adres = padres
            WHERE id_zesp = pid_zesp;
           
            EXCEPTION
                WHEN exIstniejeNazwa THEN
                    DBMS_OUTPUT.PUT_LINE('Istnieje juz zespol o nazwie ' || pnazwa);
                WHEN exNiepoprawneID THEN
                    DBMS_OUTPUT.PUT_LINE('Nie istnieje zespol o ID ' || pid_zesp);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd ' || SQLCODE);
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 
        END;

    END Modyfikuj;

    FUNCTION PokazId(pnazwa zespoly.nazwa%type)
        RETURN zespoly.id_zesp%type IS pid_zesp zespoly.id_zesp%type;

        BEGIN
            SELECT id_zesp INTO pid_zesp FROM zespoly where nazwa = pnazwa;
            RETURN pid_zesp;
           
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE exZlaNazwa;

    END PokazId;

    FUNCTION PokazNazwe(pid_zesp zespoly.id_zesp%type)
        RETURN zespoly.nazwa%type IS pnazwa zespoly.nazwa%type;
        BEGIN
            SELECT nazwa INTO pnazwa FROM zespoly where id_zesp = pid_zesp;
            RETURN pnazwa;
           
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE exZleID;

    END PokazNazwe;

       

    FUNCTION PokazAdres(pid_zesp zespoly.id_zesp%type)
        RETURN zespoly.adres%type IS padres zespoly.adres%type;
        BEGIN
            SELECT adres INTO padres FROM zespoly where id_zesp = pid_zesp;
            RETURN padres;
           
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE exZleID;

        END PokazAdres;

END IntZespoly;


BEGIN
    IntZespoly.DodajZespol(10,'A','B');
    IntZespoly.UsunZespolId(100);
    IntZespoly.UsunZespolNazwa('A');
    IntZespoly.Modyfikuj(100,'a','b');
    IntZespoly.Modyfikuj(10,'BADANIA OPERACYJNE','b');
    DBMS_OUTPUT.PUT_LINE(IntZespoly.PokazId('a'));
   
    EXCEPTION
        WHEN IntZespoly.exZleID THEN
            DBMS_OUTPUT.PUT_LINE('Nie istnieje zespol o takim ID');
        WHEN IntZespoly.exZlaNazwa THEN
            DBMS_OUTPUT.PUT_LINE('Nie istnieje zespol o takiej nazwie');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Wystąpił błąd ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
   
END;