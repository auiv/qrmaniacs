PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
create table "utenti" (
        "id"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        "hash" text unique not null 
        );

insert into "utenti" values(1,'LYL85EwHXYX9PYYkTxFOaW6CHy45ndGUeiG447B0v3E5fcd6Sh');

create table "autori" (
        "id" integer not null unique references utenti(id) on delete cascade,
        "mail" text unique not null
        );

insert into "autori" values(1,'paolo.veronelli@gmail.com');

CREATE TABLE "argomenti" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "argomento" TEXT unique NOT NULL,
    "autore" integer not null references autori(id) on delete cascade,
    "risorsa" text unique not null
);
INSERT INTO "argomenti" VALUES(1,'La focaccia ligure a Camogli',1,'Ctj8aFL19NCmDjh5lc05DLlQexBwmITAF6Ao4Th1P4CyoNyBXK');
INSERT INTO "argomenti" VALUES(2,'Il pesce azzurro ',1,'fmaeBId35Bw0O5PnN2D9GmpTtX1T7SjVzl9ubn90or5sSYIKYg');
INSERT INTO "argomenti" VALUES(3,'Le sagre di paese',1,'3iL6pFtqDGsxvgHqffSMrEM5uiQym3YdFlPIlHJyJDOiG1DJKv');
INSERT INTO "argomenti" VALUES(4,'Il festival della comunicazione corre',1,'Bwp6xo2Mayk33un8uRp0ECeLOUk4oixgbkeHY5eZGk4L2iyVQW');
CREATE TABLE "domande" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "domanda" TEXT unique NOT NULL,
    "argomento" INTEGER NOT NULL references argomenti(id) on delete cascade
);
INSERT INTO "domande" VALUES(1,'Da quanti anni si fa la focaccia in Liguria ?',1);
INSERT INTO "domande" VALUES(2,'Quale percentuale di sale è consigliata nell''impasto ?',1);
CREATE TABLE "risposte" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "risposta" TEXT NOT NULL,
    "valore" TEXT NOT NULL,
    "domanda" INTEGER NOT NULL references domande(id) on delete cascade
);
INSERT INTO "risposte" VALUES(2,'300 anni','accettabile',1);
INSERT INTO "risposte" VALUES(3,'2 %','giusta',2);
        

DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('argomenti',5);
INSERT INTO "sqlite_sequence" VALUES('domande',2);
INSERT INTO "sqlite_sequence" VALUES('risposte',3);
COMMIT;

