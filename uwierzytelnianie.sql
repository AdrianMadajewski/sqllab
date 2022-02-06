-- 145192 Uzytkownik A
-- 145406 Uzytkownik B

-- 1.
-- A
SELECT * FROM INF145406.pracownicy;
-- B
SELECT * FROM INF145192.pracownicy;

-- 2.
-- B
GRANT SELECT ON pracownicy TO INF145192;

-- 3.
-- A
SELECT * FROM INF145406.pracownicy;

-- 4. A
GRANT UPDATE(placa_pod, placa_dod) ON pracownicy TO INF145406;

-- 5. B
UPDATE INF145192.pracownicy
SET placa_pod = placa_pod * 2;
-- Niepowodzenie bo nie mam grantu na select
UPDATE INF145192.pracownicy
SET placa_pod = 2000
WHERE nazwisko LIKE 'MORZY';
-- Niepowodzenie bo nie mam grantu na select
UPDATE INF145192.pracownicy
SET placa_pod = 700;
commit;
rollback;
-- Udalo sie

-- 6. B
CREATE SYNONYM prac_michal FOR INF145192.pracownicy;

UPDATE prac_michal
SET plac_dod = 800;
commit;

-- 7.
SELECT * FROM prac_michal;

-- 8
select owner, table_name, grantee, grantor, privilege
from   user_tab_privs;
 
select table_name, grantee, grantor, privilege
from   user_tab_privs_made;
 
 
select owner, table_name, grantor, privilege
from   user_tab_privs_recd;
 
select owner, table_name, column_name, grantee, grantor, privilege
from   user_col_privs;
 
select table_name, column_name, grantee, grantor, privilege
from   user_col_privs_made;
 
select owner, table_name, column_name, grantor, privilege
from   user_col_privs_recd;

-- 9.
-- A
REVOKE UPDATE ON pracownicy FROM INF145406;
-- B
SELECT * FROM INF145192.pracownicy;
SELECT * FROM prac_michal;

-- 10.
-- A
CREATE ROLE ROLA_145192 IDENTIFIED BY 'papiez';
GRANT SELECT, UPDATE ON pracownicy TO ROLA_145192;
-- B
CREATE ROLE ROLA_145406;
-- GRANT SELECT, UPDATE ON pracownicy TO ROLA_145406;

-- 11 A.
GRANT ROLA_145192 TO INF145406;
-- B
SELECT * FROM prac_michal; -- Nie moge bo musze ustawic SET ROLE

-- 12
SET ROLE ROLA_145192 IDENTIFIED BY 'papiez';
SELECT * FROM prac_michal; -- Teraz dziala

select granted_role, admin_option from user_role_privs
where  username = 'INF145406';
 
select role, owner, table_name, column_name, privilege
from   role_tab_privs

-- 13
-- A
REVOKE ROLE ROLA_145192 FROM INF145406;

-- B
SELECT * FROM prac_michal; -- Nadal dziala dopiero po reconnecie mam odebrane prawa

-- 14
SELECT * FROM prac_michal;

-- 15. A
UPDATE INF145406.pracownicy
SET placa_dod = 2137
WHERE nazwisko LIKE 'MORZY'; -- jak wczesniej byl grant od B to zadziala, ale jak nie bylo to nie

-- 16.
-- B.
GRANT ROLA_145406 TO INF145192;
-- A.
UPDATE INF145406.pracownicy
SET placa_dod = 2137
WHERE nazwisko LIKE 'MORZY'; -- nie dziala, trzeba sie przelogowac

-- 17
-- A.
UPDATE INF145406.pracownicy
SET placa_dod = 2137
WHERE nazwisko LIKE 'MORZY'; -- Teraz dziala ;)

-- 18.
-- B
REVOKE UPDATE ON pracownicy FROM ROLA_145406;

-- A
UPDATE INF145406.pracownicy
SET placa_dod = 2137
WHERE nazwisko LIKE 'MORZY'; -- Zabral uprawnienia - niefajny gostek

-- 19.
DROP ROLE ROLA_145406;
DROP ROLE ROLA_145192;

-- 20.
-- A.
GRANT SELECT ON pracownicy TO INF145406 WITH GRANT OPTION;
-- B.
GRANT SELECT ON INF145192.pracownicy TO INF145404;
-- C.
SELECT * FROM INF145192.pracownicy; -- DZIALA

-- 21.
-- to samo co w zad. 8

-- 22.
REVOKE SELECT ON pracownicy FROM INF145404; -- Nie dziala - tylko osoba ktora nadala uprawnienia moze je zabrac
REVOKE SELECT ON pracownicy FROM INF145406; -- Na B zadziala - pociagnie to dalej ze C tez nie bedzie mialo dostepu (kaskadowo)

-- 23.
-- A.
CREATE OR REPLACE VIEW prac20 AS
SELECT nazwisko, placa_pod, placa_dod
FROM pracownicy
WHERE id_zesp = 20;

-- B.
SELECT * FROM INF145192.prac20;

UPDATE INF145192.prac20
SET placa_dod = 2137
WHERE nazwisko LIKE 'MORZY';
commit;

-- 24. -- A
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION funLiczEtaty
    RETURN INTEGER IS
    vIle INTEGER;
BEGIN
    SELECT COUNT(*) INTO vIle from etaty;
    RETURN vIle;
END funLiczEtaty;

GRANT EXECUTE ON funLiczEtaty TO INF145406;

-- 25.
BEGIN
    dbms_output.put_line(INF145192.funLiczEtaty);
END;

-- 26. -- A
CREATE OR REPLACE FUNCTION funLiczEtaty
    RETURN INTEGER AUTHID CURRENT_USER IS
    vIle INTEGER;
BEGIN
    SELECT COUNT(*) INTO vIle from etaty;
    RETURN vIle;
END funLiczEtaty;

GRANT EXECUTE ON funLiczEtaty TO INF145406;

-- 27. -- B
BEGIN
    dbms_output.put_line(INF145192.funLiczEtaty);
END; -- Wynik nie rozni sie

-- 28.
-- A
INSERT INTO etaty VALUES('WYKLADOWCA', 1000, 2000);
commit;

-- B.
BEGIN
    dbms_output.put_line(INF145192.funLiczEtaty);
END; -- Wynik rozni sie bo w mojej relacji jest mniej rekordow niz u kolegi ;)

-- 29.
BEGIN
    dbms_output.put_line(INF145192.funLiczEtaty);
END; -- Bo zmienila sie tabela etaty uzytkownika A a ja nie mam do niej dostepu

-- 30. -- B
CREATE TABLE test
(
    id NUMBER(2),
    tekst VARCHAR2(20)
);

INSERT INTO test VALUES(1, 'pierwszy');
INSERT INTO test VALUES(2, 'drugi');
-- commit;

SELECT * FROM test;

CREATE OR REPLACE PROCEDURE procPokazTest AUTHID CURRENT_USER IS
    BEGIN
        DECLARE
            CURSOR cur IS
                SELECT tekst
                FROM test
                ORDER BY id ASC;
    BEGIN
        FOR vTekst IN cur LOOP
            DBMS_OUTPUT.PUT_LINE(vTekst.tekst);
        END LOOP;
    END;
END procPokazTest;

EXEC procPokazTest;

GRANT EXECUTE ON procPokazTest TO INF145192;
GRANT SELECT ON test TO INF145192;

-- 31. NIE WIEM

-- 32.
CREATE TABLE info_dla_znajomych
(
    nazwa VARCHAR2(20) NOT NULL,
    info VARCHAR2(200) NOT NULL
);

INSERT INTO info_dla_znajomych VALUES ('INF145406', 'info1');
INSERT INTO info_dla_znajomych VALUES ('INF145404', 'info2');
INSERT INTO info_dla_znajomych VALUES ('INF145192', 'info3');
INSERT INTO info_dla_znajomych VALUES ('INF145316', 'info3');

CREATE OR REPLACE VIEW info4u AS
    SELECT * FROM info_dla_znajomych WHERE nazwa LIKE USER;
    
GRANT SELECT ON info4u TO INF145192;
SELECT * FROM info_dla_znajomych;

SELECT * FROM INF145192.info4u;