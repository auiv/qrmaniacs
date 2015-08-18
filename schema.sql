PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "utenti" (
        "id"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        "hash" text unique not null
        );
INSERT INTO "utenti" VALUES(1,'LYL85EwHXYX9PYYkTxFOaW6CHy45ndGUeiG447B0v3E5fcd6Sh');
INSERT INTO "utenti" VALUES(2,'dnHaJ1OJm1tiZXSVD0dIljK7Gq0fAwCcmbcG1UbHDc6Lmse7Fn');
INSERT INTO "utenti" VALUES(3,'EV0VwQzFK6hlM8dIaDUQ37D1PIUJR2GZkaKxCqJ4vDQnoUt9iY');
INSERT INTO "utenti" VALUES(4,'sc0aZlZPhWLOYgq4sTIYH6R8lf04ldfGGT5DKwtwnRLwBAWeDB');
CREATE TABLE "autori" (
        "id" integer not null unique references utenti(id) on delete cascade,
        "mail" text unique not null
        );
INSERT INTO "autori" VALUES(1,'paolo.veronelli@gmail.com');
CREATE TABLE "realizzatori" (
        "id" integer not null unique references utenti(id) on delete cascade,
        "mail" text unique not null
        );
insert into realizzatori values(1,'paolo.veronelli@gmail.com');
CREATE TABLE "identificati" ( 
        "realizzatore" integer not null unique references realizzatori(id) on delete cascade,
        "utente" integer not null unique references utenti(id) on delete cascade,
        "date" text not null DEFAULT (datetime('now','localtime'))
        );
insert into identificati (utente,realizzatore) values (1,1);
CREATE TABLE "argomenti" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "argomento" TEXT unique NOT NULL,
    "autore" integer not null references autori(id) on delete cascade,
    "risorsa" text unique not null
);
INSERT INTO "argomenti" VALUES(1,'La focaccia della Giulia',1,'Ctj8aFL19NCmDjh5lc05DLlQexBwmITAF6Ao4Th1P4CyoNyBXK');
INSERT INTO "argomenti" VALUES(2,'Il pane scuro del Marion',1,'fmaeBId35Bw0O5PnN2D9GmpTtX1T7SjVzl9ubn90or5sSYIKYg');
INSERT INTO "argomenti" VALUES(3,'Il pesto di Sofia',1,'3iL6pFtqDGsxvgHqffSMrEM5uiQym3YdFlPIlHJyJDOiG1DJKv');
INSERT INTO "argomenti" VALUES(4,'L''intervento di Eco',1,'Bwp6xo2Mayk33un8uRp0ECeLOUk4oixgbkeHY5eZGk4L2iyVQW');
INSERT INTO "argomenti" VALUES(6,'L''illuminazione di Piazza Matteotti',1,'owNzqvnk2GexwPok1M8kmEWOBGJ7sFGyN1oXKHGE28GWCZ3m8H');
INSERT INTO "argomenti" VALUES(7,'QRmaniacs',1,'OCHWkxGDzarvvcqHFsLwR8xcGT0PBKB2iWd0r5vwjeTKfrLfk1');
INSERT INTO "argomenti" VALUES(8,'__prove varie',1,'SsbuBWPqmyud9qTXOVTmXUrlR6lJ8sjk6mqvdyomQ8hzABvARE');
CREATE TABLE "domande" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "domanda" TEXT unique NOT NULL,
    "argomento" INTEGER NOT NULL references argomenti(id) on delete cascade
);
INSERT INTO "domande" VALUES(5,'L''accesso è risultato immediato ?',7);
INSERT INTO "domande" VALUES(7,'Quale piattaforma hai usato?',7);
INSERT INTO "domande" VALUES(8,'Cosa è risultato illeggibile ?',7);
INSERT INTO "domande" VALUES(10,'Prova',8);
INSERT INTO "domande" VALUES(12,'L''intensità è',6);
INSERT INTO "domande" VALUES(13,'Belin',8);
INSERT INTO "domande" VALUES(14,'quanto olio',1);
CREATE TABLE "risposte" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "risposta" TEXT NOT NULL,
    "valore" TEXT NOT NULL,
    "domanda" INTEGER NOT NULL references domande(id) on delete cascade
);
INSERT INTO "risposte" VALUES(4,'Si','accettabile',5);
INSERT INTO "risposte" VALUES(5,'No','accettabile',5);
INSERT INTO "risposte" VALUES(6,'IPhone','accettabile',7);
INSERT INTO "risposte" VALUES(7,'Android','accettabile',7);
INSERT INTO "risposte" VALUES(9,'Microsoft','accettabile',7);
INSERT INTO "risposte" VALUES(11,'Niente','accettabile',8);
INSERT INTO "risposte" VALUES(12,'Le domande','accettabile',8);
INSERT INTO "risposte" VALUES(13,'Le risposte','accettabile',8);
INSERT INTO "risposte" VALUES(15,'Riprova','giusta',10);
INSERT INTO "risposte" VALUES(16,'Buona','accettabile',12);
INSERT INTO "risposte" VALUES(17,'Scarsa','accettabile',12);
INSERT INTO "risposte" VALUES(18,'Giusta','accettabile',12);
INSERT INTO "risposte" VALUES(19,'','giusta',13);
INSERT INTO "risposte" VALUES(20,'5%','giusta',14);
INSERT INTO "risposte" VALUES(21,'15%','sbagliata',14);
CREATE TABLE feedback (
        "utente" integer not null references utenti(id) on delete cascade,
        "domanda" integer not null references domande(id) on delete cascade,
        "risposta" integer not null references risposte(id)  on delete cascade,
        constraint "pkfeedback" unique ("utente","domanda")
        );
CREATE TABLE assoc (        
        "utente" integer not null references utenti(id) on delete cascade,
        "argomento" integer not null references argomenti(id) on delete cascade
        );
INSERT INTO "assoc" VALUES(2,1);
INSERT INTO "assoc" VALUES(3,1);
INSERT INTO "assoc" VALUES(4,1);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('argomenti',8);
INSERT INTO "sqlite_sequence" VALUES('domande',14);
INSERT INTO "sqlite_sequence" VALUES('risposte',21);
INSERT INTO "sqlite_sequence" VALUES('utenti',4);
COMMIT;
