/*
ZADANIE 1
 try (Statement stmt = conn.createStatement();
      ResultSet rs = stmt.executeQuery(
        "select count(p.nazwisko), z.nazwa from pracownicy p inner join zespoly z on z.id_zesp = p.id_zesp group by z.nazwa");) 
    {  
            int suma  = 0
            while (rs.next()) {
                suma = suma + rs.getInt(1)
            }
            System.out.println("Zatrudniono " + suma + " pracowników, w tym:");
            rs = stmt.executeQuery(
            "select count(p.nazwisko), z.nazwa from pracownicy p inner join zespoly z on z.id_zesp = p.id_zesp group by z.nazwa"); 
            while (rs.next()) {
                System.out.println(rs.getInt(1) + " w zespole " + rs.getString(2));
            }
*/
/*
ZADANIE 2
try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
      ResultSet rs = stmt.executeQuery(
        "select RPAD(nazwisko,10), placa_pod from pracownicy where etat = 'ASYSTENT' order by placa_pod desc");) 
     {  
            
            rs.last();
            System.out.println(rs.getString(1) + rs.getInt(2));
            rs.relative(-2);
            System.out.println(rs.getString(1) + rs.getInt(2));
            rs.absolute(2);
            System.out.println(rs.getString(1) + rs.getInt(2));
     }
*/
/*
ZADANIE 3
int [] zwolnienia={150, 200, 230};
String [] zatrudnienia={"Kandefer", "Rygiel", "Boczar"};
Statement stmt = conn.createStatement();
for (int id: zwolnienia){
    int changes;
    changes = stmt.executeUpdate("delete from pracownicy where id_prac = " + id);
    System.out.println("Usunięto poprawnie");       
     }
for (String nazwisko: zatrudnienia){
    int changes;
    changes = stmt.executeUpdate("insert into pracownicy(id_prac, nazwisko)" +
            "values(NOWE_ID.nextval,'" + nazwisko +"')");
    System.out.println("Wstawiono pracownika o nazwisku " + nazwisko);       
     }
     stmt.close();
 try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
      ResultSet rs = stmt.executeQuery(
        "select id_prac, nazwisko from pracownicy");){  
         while(rs.next()){
             System.out.println(rs.getInt(1) + " " + rs.getString(2));
         }
     } 
 catch (SQLException ex) {
 System.out.println("Błąd wykonania polecenia: " + ex.getMessage());
}
*/ 
/*
Zadanie 4
conn.setAutoCommit(false);

try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
        "select nazwa from etaty");){
    while(rs.next()){
        System.out.println(rs.getString(1));
    }
    System.out.println("1--------------------------");
}

try (Statement stmt = conn.createStatement()){
    stmt.executeUpdate("INSERT INTO etaty(nazwa) " +
 "VALUES('STUDENT')");
}
try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
        "select nazwa from etaty");){
    while(rs.next()){
        System.out.println(rs.getString(1));
    }
    System.out.println("2--------------------------");
}

conn.rollback();

try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
        "select nazwa from etaty");){
    while(rs.next()){
        System.out.println(rs.getString(1));
    }
    System.out.println("3--------------------------");
}

try (Statement stmt = conn.createStatement()){
    stmt.executeUpdate("INSERT INTO etaty(nazwa) " +
 "VALUES('STUDENT')");
}
conn.commit();


try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
        "select nazwa from etaty");){
    while(rs.next()){
        System.out.println(rs.getString(1));
    }
    System.out.println("4--------------------------");
}
*/
/* ZADANIE 5
String [] nazwiska={"Woźniak", "Dąbrowski", "Kozłowski"};
int [] place={1300, 1700, 1500};
String []etaty={"ASYSTENT", "PROFESOR", "ADIUNKT"};
int max;

PreparedStatement pstmt = conn.prepareStatement("select * from etaty");
PreparedStatement pstmt2 = conn.prepareStatement("select max(id_prac) from pracownicy");
PreparedStatement pstmt3 = conn.prepareStatement("insert into pracownicy(id_prac,nazwisko, placa_pod, etat) values(?,?,?,?)");

try (ResultSet rs = pstmt2.executeQuery()){
    rs.next();
    max = rs.getInt(1);
    rs.close();
}
pstmt2.close();
for(int i = 0; i< 3; i++){
    pstmt3.setInt(1, max + 10*i);
    pstmt3.setString(2, nazwiska[i]);
    pstmt3.setInt(3, place[i]);
    pstmt3.setString(4,etaty[i]);
    int changes;
    changes = pstmt.executeUpdate();
    System.out.println("Dodano pracownika o nazwisku "+ nazwiska[i]);
}
pstmt3.close();
try (ResultSet rs = pstmt.executeQuery()){
    while(rs.next()){
        System.out.println(rs.getString(1));
    }
    rs.close();
}
pstmt.close();
try (Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
             ResultSet rs = stmt.executeQuery(
        "select nazwa from etaty");){
    while(rs.next()){
        System.out.println(rs.getString(1));
    
    }
}
*/
/* ZADANIE 6
PreparedStatement pstmt = conn.prepareStatement("insert into pracownicy(id_prac,nazwisko) values(?,?)");
        conn.setAutoCommit(false);
        long start = System.nanoTime();
        for (int i = 0; i < 2000; i++){
            pstmt.setInt(1, 300 + 10*i);
            pstmt.setString(2, "pracownik" + i);
            int changes;
            changes = pstmt.executeUpdate();
        }
        long czas = (System.nanoTime() - start); 
        conn.rollback();
        long start2 = System.nanoTime();
        for (int i = 0; i < 2000; i++){
            pstmt.setInt(1, 300000 + 10*i);
            pstmt.setString(2, "pracownik" + i);
            pstmt.addBatch();
        }
        pstmt.executeBatch();
        conn.rollback();
        long czas2 = (System.nanoTime() - start2);
        long d = 1000000;
        System.out.println("Sekwencyjne wykonanie " + czas/d + " ms");
        System.out.println("Wsadowe wykonanie " + czas2/d + " ms");

/*
ZADANIE 7
create or replace function zmiana(vid in integer,vnazwisko out varchar )
RETURN integer 
is
wiersze integer;
nazwisko varchar(30);
begin
select count(*) into wiersze from pracownicy where id_prac=vid;
if wiersze =0 then
return 0;
else
select nazwisko into vnazwisko from pracownicy  where id_prac=vid;
update pracownicy 
set nazwisko=initcap(nazwisko) where id_prac=vid;
vnazwisko := nazwisko;
return 1;
end if;
end;

 try (CallableStatement stmt = conn.prepareCall(
        "{? = call Zmiana(?,?)}")) {
            stmt.setInt(2, 70);        
            stmt.registerOutParameter(1, Types.INTEGER);
            stmt.registerOutParameter(3, Types.VARCHAR);
            stmt.execute();
            int wynik = stmt.getInt(1);
            System.out.println(wynik);
        }