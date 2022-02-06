 	
SET SERVEROUTPUT ON;
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- 1.
DECLARE
    vTekst VARCHAR2(255) := 'Witaj swiecie!';
    vZmienna NUMBER(7, 3) := 1000.456;
BEGIN
    dbms_output.put('Zmienna vTekst: ');
    dbms_output.put(vTekst);
    dbms_output.put_line('');
    dbms_output.put('Zmienna vZmienna: ');
    dbms_output.put(vZmienna);
    dbms_output.put_line('');
END;

-- 2.
DECLARE
    vTekst VARCHAR2(255) := 'Witaj swiecie!';
    vZmienna NUMBER(20, 3) := 1000.456;
BEGIN
    vTekst := vTekst || ' Witaj nowy dniu!';
    vZmienna := vZmienna + POWER(10, 15);

    dbms_output.put('Zmienna vTekst: ');
    dbms_output.put(vTekst);
    dbms_output.put_line('');
    dbms_output.put('Zmienna vZmienna: ');
    dbms_output.put(vZmienna);
    dbms_output.put_line('');
END;

-- 3.
DECLARE
    v1 NATURAL := 10;
    v2 NATURAL := 5;
    vResult NATURAL := 0;
BEGIN
    vResult := v1 + v2;
    DBMS_OUTPUT.PUT_LINE('Wynik dodawania: ' || v1 || ' i ' || v2 || ': ' || vResult);
END;

-- 4.
DECLARE
    vRadius FLOAT := 3;
    cPi CONSTANT FLOAT := 3.14;
    vArea FLOAT := 0;
    vCircumference FLOAT := 0;
BEGIN
    vArea := cPi * vRadius * vRadius;
    vCircumference := 2 * cPi * vRadius;

    DBMS_OUTPUT.PUT_LINE('Obwod kola o promieniu rownym: ' || vRadius || ': ' || vCircumference);
    DBMS_OUTPUT.PUT_LINE('Pole kola o promieniu rownym: ' || vRadius || ': ' || vArea);
END;

-- 5.
DECLARE
    v_nazwisko VARCHAR2(15);
    v_etat VARCHAR2(10);
BEGIN
    SELECT nazwisko, etat INTO v_nazwisko, v_etat FROM pracownicy WHERE placa_pod = (SELECT MAX(placa_pod) FROM pracownicy);

    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || v_nazwisko);
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || v_etat);
END;

-- 6.
DECLARE
    v_nazwisko PRACOWNICY.NAZWISKO%TYPE;
    v_etat PRACOWNICY.ETAT%TYPE;
BEGIN
    SELECT nazwisko, etat INTO v_nazwisko, v_etat FROM pracownicy WHERE placa_pod = (SELECT MAX(placa_pod) FROM pracownicy);

    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || v_nazwisko);
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || v_etat);
END;

-- 7.
DECLARE
    SUBTYPE tKwota IS NATURAL;
    v_zarobki tKwota;
    v_nazwisko PRACOWNICY.NAZWISKO%TYPE;
BEGIN
    SELECT nazwisko, placa_pod * 12 INTO v_nazwisko, v_zarobki FROM pracownicy WHERE UPPER(nazwisko) LIKE 'SLOWINSKI';

    DBMS_OUTPUT.PUT_LINE('Pracownik ' || v_nazwisko || ' zarabia rocznie ' || v_zarobki);
END;

-- 8.
BEGIN
   WHILE
    EXTRACT(SECOND FROM current_timestamp()) != 25 LOOP
        NULL;
   END LOOP;
 
   DBMS_OUTPUT.PUT_LINE('Nadeszla 25 sekunda');
END;

-- 9.
DECLARE
    vn NATURAL := 10;
    vSilnia NATURAL := 1;
BEGIN
    FOR vIndeks IN 1..vn LOOP
        vSilnia := vSilnia * vIndeks;
    END LOOP;
   
    DBMS_OUTPUT.PUT_LINE(vSilnia);
END;

-- 10.
DECLARE
    vDate DATE := TO_DATE('01-01-2001', 'DD-MM-YYYY');
BEGIN
    WHILE EXTRACT(YEAR FROM vDate) != 2101 LOOP
        IF TO_CHAR(vDate, 'D') = 5 AND TO_CHAR(vDate, 'DD') = 13 THEN
            DBMS_OUTPUT.PUT_LINE(TO_CHAR(vDate, 'DD-MM-YYYY'));
        END IF;
        vDate := vDate + 1;
    END LOOP;
END;