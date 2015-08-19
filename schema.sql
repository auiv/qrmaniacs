PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "utenti" (
        "id"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        "hash" text unique not null
        );
INSERT INTO "utenti" VALUES(1,'LYL85EwHXYX9PYYkTxFOaW6CHy45ndGUeiG447B0v3E5fcd6Sh');
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
CREATE TABLE "domande" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "domanda" TEXT NOT NULL,
    "argomento" INTEGER NOT NULL references argomenti(id) on delete cascade,
    constraint "uniquedomanda" unique (domanda,argomento)
);
CREATE TABLE "risposte" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "risposta" TEXT NOT NULL,
    "valore" TEXT NOT NULL,
    "domanda" INTEGER NOT NULL references domande(id) on delete cascade
);
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
INSERT INTO "assoc" VALUES(2,1);
INSERT INTO "assoc" VALUES(3,1);
INSERT INTO "assoc" VALUES(4,1);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('argomenti',8);
INSERT INTO "sqlite_sequence" VALUES('domande',14);
INSERT INTO "sqlite_sequence" VALUES('risposte',21);
INSERT INTO "sqlite_sequence" VALUES('utenti',4);
COMMIT;
