 	

// Zadanie 1 - lacznie 4 i data jest zaprezentowana w sposob taki jak przedstawiony nizej
db.pracownicy.find()
{ "_id" : ObjectId("61d4b13c70044b16bf045e2e"), "id_prac" : 100, "nazwisko" : "WEGLARZ", "placa_pod" : 1730 }
{ "_id" : ObjectId("61d4b17070044b16bf045e2f"), "id_prac" : 100, "nazwisko" : "WEGLARZ", "placa_pod" : 1730 }
{ "_id" : 100, "id_prac" : 100, "nazwisko" : "WEGLARZ", "placa_pod" : 1730 }
{ "_id" : ObjectId("61d4b1e1b88b3d6da34cc8be"), "id_prac" : 110, "nazwisko" : "BLAZEWICZ", "placa_pod" : 1350, "zatrudniony" : ISODate("1973-05-01T00:00:00Z") }


// Zadanie 2
db.zespoly.insert([
    {"id_zesp":10,"nazwa":"ADMINISTRACJA","adres":"PIOTROWO 3A"},
    {"id_zesp":20,"nazwa":"SYSTEMY ROZPROSZONE","adres":"PIOTROWO 3A"},
    {"id_zesp":30,"nazwa":"SYSTEMY EKSPERCKIE","adres":"STRZELECKA 14"},
    {"id_zesp":40,"nazwa":"ALGORYTMY","adres":"WLODKOWICA 16"},
    {"id_zesp":50,"nazwa":"BADANIA OPERACYJNE","adres":"MIELZYNSKIEGO 30"}
])

// Zadanie 3
db.pracownicy.find({"etat":"PROFESOR"}, {"nazwisko":1, "_id":0}) tutaj wyswietlane sa TYLKO nazwiska osob znalezionych
db.pracownicy.find({"etat":"PROFESOR"}, {"nazwisko":0, "_id":0}) tutaj wyswietlana jest kazda informacja razem oprocz ObjectId

db.pracownicy.find({"etat":"PROFESOR"}, {"nazwisko":1, "placa_pod":0})
Error: error: {
    "ok" : 0,
    "errmsg" : "Cannot do exclusion on field placa_pod in inclusion projection",
    "code" : 31254,
    "codeName" : "Location31254"
}

// Zadanie 4
db.pracownicy.find(
    {$or:{"etat":"ASYSTENT"}, {"placa_pod":{$gt:200, $lt:500}}},
    {"nazwisko":1, "etat":1, "placa_pod":1, "_id":0}
).pretty()

// Zadanie 5
db.pracownicy.find(
    {"placa_pod":{$gt:400}},
    {"nazwisko":1, "etat":1, "placa_pod":1, "_id":0}
).sort(
    {"etat":1, "placa_pod":-1}
).pretty()

// Zadanie 6
db.pracownicy.find(
    {"id_zesp":20},
    {"nazwisko":1, "placa_pod":1, "_id":0}
).sort(
    {"placa_pod":-1}
).skip(1).limit(1).pretty()

// Zadanie 7
db.pracownicy.find(
    {"id_zesp": {$in:[20,30]}, "etat":{$not: /ASYSTENT/}, "nazwisko":{$regex: "I$"}},
    {"nazwisko":1, "etat":1, "_id":0}
).pretty()

// Zadanie 8
db.pracownicy.aggregate([
    {$project:{
          "_id":0,
          "stanowisko":"$etat",
          "nazwisko":"$nazwisko",
          "rok_zatrudnienia": {$year:"$zatrudniony"}
        }
    },
    {$sort: {"placa_pod":-1} },
    {$skip : 2},
    {$limit: 1}
]).pretty()

// Zadanie 9
db.pracownicy.aggregate([
    {$group: {
              _id: "$id_zesp",
              "liczba": {$sum: 1},
            }
    },
    {$match: {
              "liczba": {$gt:3}
            }
     }
])

// Zadanie 10
db.pracownicy.aggregate([
{ $match: {
                "id_zesp": {$in:[20,30]}
          }
},
{ $lookup: {
            from: "zespoly",
            localField: "id_zesp",
            foreignField: "id_zesp",
            as: "zespol_pracownika"}
},
{ $project: {
                _id:0,
                "nazwisko":1,
                "dept": {$arrayElemAt:["$zespol_pracownika.adres",0]}
            }
}
])

// Zadanie 11
db.pracownicy.aggregate([
   { $lookup: {
            from: "zespoly",
            localField: "id_zesp",
            foreignField: "id_zesp",
            as: "zespol_pracownika"}
    },
    { $match: {
                "zespol_pracownika.adres": {$regex: "^STRZELECKA [0-9]*"}
               }
    },
    { $project: {
            "_id":0,
            "nazwisko": "$nazwisko",
            "adres": {$arrayElemAt:["$zespol_pracownika.adres",0]},
            "zespol": {$arrayElemAt:["$zespol_pracownika.nazwa",0]}
        }
    }
])

// Zadanie 12
db.pracownicy.aggregate(
    {$lookup:{
        from: "zespoly",
        localField: "id_zesp",
        foreignField: "id_zesp",
        as: "zespol_pracownika"
    }},
    {$project:{
        "nazwisko": "$nazwisko",
        "nazwa_zesp": {$arrayElemAt:["$zespol_pracownika.nazwa", 0]}
    }},
    {$group:{
        _id: "$nazwa_zesp",
        liczba: {$sum:1}
    }}
)

// Zadanie 13
var pracownicy = db.pracownicy.find();
while (pracownicy.hasNext()) {
 prac = pracownicy.next();
 zesp = db.zespoly.findOne({"id_zesp": prac.id_zesp});
 print(prac.nazwisko + ":" + zesp.nazwa);
 db.pracownicy.update(
    {_id: prac._id}
    {id_zesp: zesp._id}
 )
}


// Zadanie 14
db.produkty.find(
    {"oceny.osoba": {$nin: ["Ania", "Karol"]}},
    {_id:0,nazwa:1}
)

// Zadanie 15
db.produkty.aggregate(
    {$unwind: "$oceny"},
    {$group:{
        _id: "$nazwa",
        srednia_ocen: {$avg: "$oceny.ocena"}
    }},
    {$sort: {
        srednia_ocen: -1
    }},
    {$limit: 1},
    {$project:{
        produkt: "$_id",
        _id: 0,
        srednia_ocen: 1
    }}
)

// Zadanie 16
db.produkty.update(
    {nazwa: "Kosiarka elektryczna"},
    {$push: {oceny: {ocena: 4, osoba: "Ania"}}}
)

// Zadanie 18
db.produkty.updateMany(
    {},
    {$pull: {"oceny":{"ocena": {$gt: 3}}}}
)
