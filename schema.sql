PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "utenti" (
        "id"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        "hash" text unique not null
        , email text 
        , conferma integer not null
        , identification text unique
        , probemail text unique
        );
INSERT INTO "utenti" VALUES(1,'LYL85EwHXYX9PYYkTxFOaW6CHy45ndGUeiG447B0v3E5fcd6Sh','guidorisi@me.com',1,NULL,NULL);
INSERT INTO "utenti" VALUES(8,'lwmb4vxUxv2iScU9q51mbqaVNziQmOpypPArqnHHHLrR58kYtN','paolo.veronelli@gmail.com',1,NULL,NULL);
CREATE TABLE "autori" (
        "id" integer not null unique references utenti(id) on delete cascade,
         logo text not null, begin text not null, expire text not null,place text not null);
INSERT INTO "autori" VALUES(1,'http://www.p46.it/wp-content/uploads/2014/06/logo-p46-70x70@x2-e1405693109885.jpg','2015-09-10T14:00:00.000Z','2015-09-13T21:59:00.000Z','https://goo.gl/maps/n7SEZ');
INSERT INTO "autori" VALUES(8,'http://lambdasistemi.net/logo.png','2015-08-31T10:17:29.000Z','2015-09-13 23:00','https://goo.gl/maps/S2ihw');
CREATE TABLE "realizzatori" (
        "autore" integer not null references autori(id) on delete cascade,
        "utente" integer not null references utenti(id) on delete cascade,
        constraint "uniquerealizzatori" unique ("autore","utente")
        );
CREATE TABLE "identificati" ( 
        "validatore" integer not null references utenti(id) on delete cascade,
        "utente" integer not null references utenti(id) on delete cascade,
        "date" text not null DEFAULT (datetime('now','localtime')),
        constraint "identificati" unique ("validatore","utente")
        );
CREATE TABLE "argomenti" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "argomento" TEXT unique NOT NULL,
    "autore" integer not null references autori(id) on delete cascade,
    "risorsa" text unique not null
);
INSERT INTO "argomenti" VALUES(9,'QR Maniacs',8,'euNKg04ySxDNFHMcZ20xZFTVwVVvta2gWpUNK289s3ZBnv0WV6');
INSERT INTO "argomenti" VALUES(18,'galletta del marinaio',1,'7kQ1jqDmlX3nVN8BNczUkdmv9zkpERL1l2ywZq71MllVDtfa32');
INSERT INTO "argomenti" VALUES(20,'pesto genovese',1,'0VCGK9Kw435FLd7K25e50jeVps3O3Mw8Th1lg1q0lwA1RBdNOe');
INSERT INTO "argomenti" VALUES(22,'farinata',1,'RM66fwDpCmtrzOp4Etdx1vUNIckiShMiKqslfoL2brCU2HDvoY');
INSERT INTO "argomenti" VALUES(23,'acciughe sotto sale',1,'2UEOs5F675LGIgVYvszZCdGKe86bqGOV297IiSV7WoVNDlFYWv');
INSERT INTO "argomenti" VALUES(24,'polpettone alla genovese',1,'iOGtyrcr3ur3jqWJJbSjYwiUKf6NSGioIwlpfbm0sQ0oZ2GnnQ');
INSERT INTO "argomenti" VALUES(25,'torta pasqualina',1,'6PWTUGFEgomAwT6GFjEAr6hGnjggzgAQAzrQ1cknTFbfULwYBH');
INSERT INTO "argomenti" VALUES(26,'pansoti alla salsa di noci',1,'xi0euNDIJziinf79n7NmeaswgvvQxAesZcszU3bit9Ln9RXFGe');
INSERT INTO "argomenti" VALUES(27,'pandolce alla genovese',1,'qGGizztHvoislcDl3ohNixZhEqh6jlLcU1fO6dfdytsPg2gse3');
INSERT INTO "argomenti" VALUES(29,'focaccia di recco',1,'u2rmBIfcHGcUA65cKIU2zu4oNu28JIQsv72vWokrhwfrdMtNwa');
INSERT INTO "argomenti" VALUES(30,'seppie in zimino',1,'4cyS7bXNPH6tW7SYv9IEWcTHUa0M807EQjsyUrI7gPdPPHrD4N');
INSERT INTO "argomenti" VALUES(31,'panissa fritta',1,'4M4UCgxja1HwDYesoo4QKUvaGgCGnace3QOPz3aXorWEiViWnQ');
INSERT INTO "argomenti" VALUES(32,'lasagne di castagne',1,'s8mYWjALCrcJeWOCHIedBdqXVnihoOK63PeK5qvavkbhpVvCLc');
INSERT INTO "argomenti" VALUES(33,'coniglio alla ligure',1,'EbVeWmCvHykuWVm2VDRuphpyEcJyeMWOBbbDSOz9M8P7gSQWMJ');
INSERT INTO "argomenti" VALUES(34,'condiglione',1,'OoTbM8n7hAT7YYK0ZPuxhPSpSea4DF5itZzbJkym0lMwEnYueL');
INSERT INTO "argomenti" VALUES(35,'Cima alla genovese',1,'Lzx4dVWyuIuHgLxmSxeNnzymlOGvNFIHpMGP6BG2U7nf3D3DxH');
INSERT INTO "argomenti" VALUES(36,'verdure ripiene',1,'b4eQxMfZsGmqnDuRtCx3LosnaAXaRnR7GYxqHgkiBFqh4fNpts');
INSERT INTO "argomenti" VALUES(37,'cappon magro',1,'A5JlXfKN04j5E4JMMHizW0OelgKIpqKyaq4zMIBPHuvJwjvcQG');
CREATE TABLE "domande" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "domanda" TEXT  NOT NULL,
    "argomento" INTEGER NOT NULL references argomenti(id) on delete cascade,
    constraint "uniquedomanda2" unique ("domanda","argomento")
);
INSERT INTO "domande" VALUES(16,'Con quale piattaforma accedi?',9);
INSERT INTO "domande" VALUES(19,'L''esperienza risulta',9);
INSERT INTO "domande" VALUES(27,'Per quanto tempo si può conservare una galletta del marinaio?',18);
INSERT INTO "domande" VALUES(29,'Quante foglie di basilico servono per realizzare una porzione di pesto?',20);
INSERT INTO "domande" VALUES(31,'che tipo di farina viene utilizzata per preparare la farinata?',22);
INSERT INTO "domande" VALUES(32,'qual''è il tempo di riposo, prima dell''utilizzo, dopo la preparazione?',23);
INSERT INTO "domande" VALUES(33,'quali sono i principali ingredienti del polpettone alla genovese?',24);
INSERT INTO "domande" VALUES(34,'quale tipo di formaggio viene utilizzato nella preparazione della torta pasqualina?',25);
INSERT INTO "domande" VALUES(35,'che cos''è il ripieno dei pansoti chiamato preboggion?',26);
INSERT INTO "domande" VALUES(36,'quando va messo il lievito?',27);
INSERT INTO "domande" VALUES(38,'quanti minuti deve riposare l''impasto?',29);
INSERT INTO "domande" VALUES(39,'cosa si intende per zimino?',30);
INSERT INTO "domande" VALUES(41,'che cos''è la panissa?',31);
INSERT INTO "domande" VALUES(42,'qual''è il miglior condimento per le lasagne di castagne?',32);
INSERT INTO "domande" VALUES(43,'quali sono i due ingredienti principali per il coniglio alla ligure?',33);
INSERT INTO "domande" VALUES(44,'cos''è il condiglione o condiggion?',34);
INSERT INTO "domande" VALUES(47,'Utilizzeresti il sistema per',9);
INSERT INTO "domande" VALUES(48,'La validazione presenze ti sembra una operazione',9);
INSERT INTO "domande" VALUES(49,'L''accesso tramite QR è',9);
CREATE TABLE "risposte" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "risposta" TEXT NOT NULL,
    "valore" TEXT NOT NULL,
    "domanda" INTEGER NOT NULL references domande(id) on delete cascade
);
INSERT INTO "risposte" VALUES(23,'Android','accettabile',16);
INSERT INTO "risposte" VALUES(26,'iPhone','accettabile',16);
INSERT INTO "risposte" VALUES(27,'Nokia Microsoft','accettabile',16);
INSERT INTO "risposte" VALUES(28,'BlackBerry','accettabile',16);
INSERT INTO "risposte" VALUES(29,'Naturale','accettabile',19);
INSERT INTO "risposte" VALUES(30,'Complessa','accettabile',19);
INSERT INTO "risposte" VALUES(31,'Inaspettata','accettabile',19);
INSERT INTO "risposte" VALUES(43,'un giorno','sbagliata',27);
INSERT INTO "risposte" VALUES(44,'una settimana','sbagliata',27);
INSERT INTO "risposte" VALUES(45,'almeno un mese','giusta',27);
INSERT INTO "risposte" VALUES(47,'5 foglie','sbagliata',29);
INSERT INTO "risposte" VALUES(48,'15 foglie','sbagliata',29);
INSERT INTO "risposte" VALUES(49,'40 foglie','giusta',29);
INSERT INTO "risposte" VALUES(53,'la farina di ceci','giusta',31);
INSERT INTO "risposte" VALUES(54,'la farina di castagne','sbagliata',31);
INSERT INTO "risposte" VALUES(55,'la farina di grano duro','sbagliata',31);
INSERT INTO "risposte" VALUES(56,'15 giorni','sbagliata',32);
INSERT INTO "risposte" VALUES(57,'60 giorni','giusta',32);
INSERT INTO "risposte" VALUES(58,'40 giorni','sbagliata',32);
INSERT INTO "risposte" VALUES(59,'tipi diversi di carne','sbagliata',33);
INSERT INTO "risposte" VALUES(60,'verdure e patate','giusta',33);
INSERT INTO "risposte" VALUES(61,'tipi diversi di pesce','sbagliata',33);
INSERT INTO "risposte" VALUES(62,'pecorino sardo','sbagliata',34);
INSERT INTO "risposte" VALUES(63,'prescinseua','giusta',34);
INSERT INTO "risposte" VALUES(64,'sarasso','sbagliata',34);
INSERT INTO "risposte" VALUES(65,'mazzetto di erbe selvatiche','giusta',35);
INSERT INTO "risposte" VALUES(66,'mistura di carne','giusta',35);
INSERT INTO "risposte" VALUES(67,'lesso di pesce azzurro','sbagliata',35);
INSERT INTO "risposte" VALUES(68,'va aggiunto all''impasto subito prima di mettere il panettone in forno','giusta',36);
INSERT INTO "risposte" VALUES(69,'va messo prima di impastare','sbagliata',36);
INSERT INTO "risposte" VALUES(70,'non va messo lievito nel panettone alla genovese','sbagliata',36);
INSERT INTO "risposte" VALUES(74,'45 minuti','accettabile',38);
INSERT INTO "risposte" VALUES(75,'60 minuti','accettabile',38);
INSERT INTO "risposte" VALUES(76,'90 minuti','accettabile',38);
INSERT INTO "risposte" VALUES(77,'preparazione nella quale rientra l''utilizzo delle bietole','accettabile',39);
INSERT INTO "risposte" VALUES(78,'un tipo di spezia','accettabile',39);
INSERT INTO "risposte" VALUES(79,'un ripieno','accettabile',39);
INSERT INTO "risposte" VALUES(80,'polenta fatta con la farina di ceci, fatta raffreddare, tagliata a pezzi e fritta','giusta',41);
INSERT INTO "risposte" VALUES(81,'pesce azzurro fritto del quale si mangia tutto tranne la testa','sbagliata',41);
INSERT INTO "risposte" VALUES(82,'pane ammorbidito nell''aceto e fritto','sbagliata',41);
INSERT INTO "risposte" VALUES(83,'la salsa di noci','sbagliata',42);
INSERT INTO "risposte" VALUES(84,'il pesto','giusta',42);
INSERT INTO "risposte" VALUES(85,'il ragù con i pinoli','accettabile',42);
INSERT INTO "risposte" VALUES(86,'olive taggiasche e pinoli','giusta',43);
INSERT INTO "risposte" VALUES(87,'castagne e pinoli','sbagliata',43);
INSERT INTO "risposte" VALUES(88,'pinoli e pomodori','sbagliata',43);
INSERT INTO "risposte" VALUES(89,'insalata mista con bottarga','accettabile',44);
INSERT INTO "risposte" VALUES(90,'insalata mista con funghi','accettabile',44);
INSERT INTO "risposte" VALUES(91,'insalata mista con pezzi di carne','accettabile',44);
INSERT INTO "risposte" VALUES(100,'Un''indagine di mercato','accettabile',47);
INSERT INTO "risposte" VALUES(101,'Misurare la soddisfazione dei clienti','accettabile',47);
INSERT INTO "risposte" VALUES(102,'Fare un concorso','accettabile',47);
INSERT INTO "risposte" VALUES(103,'Scorretta','accettabile',19);
INSERT INTO "risposte" VALUES(104,'Corretta','accettabile',48);
INSERT INTO "risposte" VALUES(105,'Inutile','accettabile',48);
INSERT INTO "risposte" VALUES(106,'Pesante','accettabile',48);
INSERT INTO "risposte" VALUES(107,'Una grande rivoluzione','accettabile',49);
INSERT INTO "risposte" VALUES(108,'Un artificio inutile','accettabile',49);
INSERT INTO "risposte" VALUES(109,'Una ovvia evoluzione del web','accettabile',49);
CREATE TABLE feedback (
        "utente" integer not null references utenti(id) on delete cascade,
        "domanda" integer not null references domande(id) on delete cascade,
        "risposta" integer not null references risposte(id)  on delete cascade,
        constraint "uniquedomanda" unique ("utente","domanda")
        );
CREATE TABLE assoc (        
        "utente" integer not null references utenti(id) on delete cascade,
        "argomento" integer not null references argomenti(id) on delete cascade,
        constraint "uniqueassoc" unique ("utente","argomento")
        );
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('utenti',118);
INSERT INTO "sqlite_sequence" VALUES('argomenti',39);
INSERT INTO "sqlite_sequence" VALUES('domande',49);
INSERT INTO "sqlite_sequence" VALUES('risposte',109);
COMMIT;
