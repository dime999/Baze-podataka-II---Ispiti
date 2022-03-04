--1. Kreiranje baze i tabela
/*
a) Kreirati bazu pod vlastitim brojem indeksa.
*/

CREATE DATABASE [19_09_2019]

USE [19_09_2019]

--b) Kreiranje tabela.
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
I. Kreirati tabelu kreditna sljedeće strukture:
	- kreditnaID - cjelobrojna vrijednost, primarni ključ
	- br_kreditne - 25 unicode karatera, obavezan unos
	- dtm_evid - datumska varijabla za unos datuma
*/

CREATE TABLE Kreditna(
	KreditnaID int NOT NULL CONSTRAINT PK_Kreditna PRIMARY KEY(KreditnaID),
	Br_kreditne nvarchar(25) NOT NULL,
	Datum_evid date NULL
)

/*
II. Kreirati tabelu osoba sljedeće strukture:
	osobaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost, obavezan unos
	mail_lozinka - 128 unicode karaktera
	lozinka - 10 unicode karaktera 
	br_tel - 25 unicode karaktera
*/

CREATE TABLE Osoba(
	OsobaID int NOT NULL CONSTRAINT PK_Osoba PRIMARY KEY(OsobaID),
	KreditnaID int NOT NULL CONSTRAINT FK_Osoba_Kreditna FOREIGN KEY(KreditnaID) REFERENCES Kreditna(KreditnaID),
	Mail_lozinka nvarchar(128),
	Lozinka nvarchar(10),
	Br_tel nvarchar(25)
)

/*
III. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
*/

CREATE TABLE Narudzba(
	NarudzbaID int,
	KreditnaID int,
	Br_narudzbe nvarchar(25),
	Br_racuna nvarchar(15),
	ProdavnicaID int ,
	CONSTRAINT PK_Narudzba PRIMARY KEY(NarudzbaID),
	CONSTRAINT FK_Narudzba_Kreditna FOREIGN KEY(KreditnaID) REFERENCES Kreditna(KreditnaID)
)
--10 bodova
-----------------------------------------------------------------------------------------------------------------------------
--2. Import podataka
/*
a) Iz tabele CreditCard baze AdventureWorks2017 importovati podatke u tabelu kreditna na sljedeći način:
	- CreditCardID -> kreditnaID
	- CardNUmber -> br_kreditne
	- ModifiedDate -> dtm_evid
*/
INSERT INTO Kreditna
SELECT CC.CreditCardID, CC.CardNumber, CC.ModifiedDate
FROM AdventureWorks2017.Sales.CreditCard AS CC


/*
b) Iz tabela Person, Password, PersonCreditCard i PersonPhone baze AdventureWorks2017 koje se nalaze u šemama Sales i Person 
importovati podatke u tabelu osoba na sljedeći način:
	- BussinesEntityID -> osobaID
	- CreditCardID -> kreditnaID
	- PasswordHash -> mail_lozinka
	- PasswordSalt -> lozinka
	- PhoneNumber -> br_tel
*/

INSERT INTO Osoba
SELECT P.BusinessEntityID, PCC.CreditCardID, PPSW.PasswordHash, PPSW.PasswordSalt, PP.PhoneNumber
FROM AdventureWorks2017.Person.Person AS P INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP
     ON P.BusinessEntityID = PP.BusinessEntityID INNER JOIN AdventureWorks2017.Sales.PersonCreditCard AS PCC
	 ON P.BusinessEntityID = PCC.BusinessEntityID INNER JOIN AdventureWorks2017.Person.Password AS PPSW
	 ON P.BusinessEntityID = PPSW.BusinessEntityID

SELECT *
FROM Osoba

/*
c) Iz tabela Customer i SalesOrderHeader baze AdventureWorks2017 koje se nalaze u šemi Sales importovati podatke u tabelu 
narudzba na sljedeći način:
	- SalesOrderID -> narudzbaID
	- CreditCardID -> kreditnaID
	- PurchaseOrderNumber -> br_narudzbe
	- AccountNumber -> br_racuna
	- StoreID -> prodavnicaID
*/

INSERT INTO Narudzba
SELECT SOH.SalesOrderID,
	   SOH.CreditCardID,
	   SOH.PurchaseOrderNumber,
	   C.AccountNumber,
	   C.StoreID
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH INNER JOIN AdventureWorks2017.Sales.Customer AS C
	 ON SOH.CustomerID = C.CustomerID

--10 bodova


-----------------------------------------------------------------------------------------------------------------------------
/*
3. Kreirati pogled view_kred_mail koji će se sastojati od kolona: 
	- br_kreditne, 
	- mail_lozinka, 
	- br_tel i 
	- br_cif_br_tel, 
	pri čemu će se kolone puniti na sljedeći način:
	- br_kreditne - odbaciti prve 4 cifre 
 	- mail_lozinka - preuzeti sve znakove od 10. znaka (uključiti i njega) uz odbacivanje znaka jednakosti koji se nalazi na kraju lozinke
	- br_tel - prenijeti cijelu kolonu
	- br_cif_br_tel - broj cifara u koloni br_tel
*/

--10 bodova

CREATE VIEW VIEW_Podaci 
AS
SELECT SUBSTRING(Br_kreditne,4 , 50) AS Br_Kreditne,
	   SUBSTRING(Mail_lozinka, 10, LEN(Mail_lozinka) - 10) AS Mail_lozinka,
	   Br_tel,
	   LEN(Br_tel) AS [BR_CIF]
FROM Kreditna INNER JOIN Narudzba
	 ON Kreditna.KreditnaID = Narudzba.KreditnaID INNER JOIN Osoba 
	 ON Kreditna.KreditnaID = Osoba.KreditnaID

-----------------------------------------------------------------------------------------------------------------------------
/*
4. Koristeći tabelu osoba kreirati proceduru proc_kred_mail u kojoj će biti sve kolone iz tabele. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji 
parametar bez unijete vrijednosti) uz uslov da se prenesu samo oni zapisi u kojima je unijet predbroj u koloni br_tel. 
Npr. (123) 456 789 je zapis u kojem je unijet predbroj. 
Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost:
br_tel = 1 (11) 500 555-0132
*/

CREATE PROCEDURE proc_kred_mail(
	@OsobaID int = NULL,
	@KreditnaID int = NULL, 
	@Mail_lozinka nvarchar(128) = NULL,
	@Lozinka nvarchar(10) = NULL, 
	@Br_tel nvarchar(25) = NULL
)
AS 
BEGIN 
	SELECT *
	FROM Osoba
	WHERE Br_tel LIKE '%(%' 
	AND    (
				OsobaID = @OsobaID OR
				KreditnaID = @KreditnaID OR
				Mail_lozinka = @Mail_lozinka OR
				Lozinka = @Lozinka OR
				Br_tel = @Br_tel
			)
END


EXEC proc_kred_mail 20766,	16095,	'vZd7llN0IBh9AuOC+w6vWfR4gtfPGxoqC6MUSHhnsqY=',	'IHT1e+I=',	'1 (11) 500 555-0127'
EXEC proc_kred_mail @Br_tel = '1 (11) 500 555-0132'
--10 bodova

-----------------------------------------------------------------------------------------------------------------------------
/*
5. 
a) Kopirati tabelu kreditna u kreditna1, 
b) U tabeli kreditna1 dodati novu kolonu dtm_izmjene čija je default vrijednost aktivni datum sa vremenom. Kolona je sa obaveznim unosom.
*/

SELECT * INTO Kreditna1
FROM Kreditna

ALTER TABLE Kreditna1
ADD dtm_izmjene datetime NOT NULL DEFAULT GETDATE()
-----------------------------------------------------------------------------------------------------------------------------
/*
6.
a) U zapisima tabele kreditna1 kod kojih broj kreditne kartice počinje ciframa 1 ili 3 vrijednost broja kreditne kartice zamijeniti 
slučajno generisanim nizom znakova.
b) Dati ifnormaciju (prebrojati) broj zapisa u tabeli kreditna1 kod kojih se datum evidencije nalazi u intevalu do najviše 6 godina 
u odnosu na datum izmjene.
c) Napisati naredbu za brisanje tabele kreditna1
*/
SELECT * 
FROM Kreditna1 AS K 
WHERE K.Br_kreditne LIKE '[13]%'

--a
UPDATE Kreditna1 
SET Br_kreditne = LEFT(NEWID(), LEN(Br_kreditne))
WHERE Br_kreditne LIKE '[13]%'

--b
SELECT COUNT(*) AS Ukupno
FROM Kreditna1
WHERE DATEDIFF (YEAR, Datum_evid, dtm_izmjene) <= 6

--c
DROP TABLE Kreditna1
-----------------------------------------------------------------------------------------------------------------------------
/*
7.
a) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni br_narudzbe slučajno generisanim nizom znakova.
b) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni prodavnicaID po sljedećem pravilu.
	- ako narudzbaID počinje ciframa 4 ili 5 u kolonu prodavnicaID preuzeti posljednje 3 cifre iz kolone narudzbaID  
	- ako narudzbaID počinje ciframa 6 ili 7 u kolonu prodavnicaID preuzeti posljednje 4 cifre iz kolone narudzbaID  
*/
--a
SELECT *
FROM Narudzba 
WHERE Narudzba.Br_narudzbe IS NULL

UPDATE Narudzba
SET Br_narudzbe = LEFT(NEWID(),10)
WHERE Narudzba.Br_narudzbe IS NULL

--b
SELECT * 
FROM Narudzba AS N
WHERE N.NarudzbaID LIKE '[67]%'

UPDATE Narudzba
SET ProdavnicaID = RIGHT(NarudzbaID,3)
WHERE ProdavnicaID IS NULL AND NarudzbaID LIKE '[45]%'

UPDATE Narudzba
SET ProdavnicaID = RIGHT(NarudzbaID,4)
WHERE ProdavnicaID IS NULL AND NarudzbaID LIKE '[67]%'
--12 bodova


-----------------------------------------------------------------------------------------------------------------------------
/*
8.
Kreirati proceduru kojom će se u tabeli narudzba izvršiti izmjena svih vrijednosti u koloni br_narudzbe u kojima se ne nalazi 
slučajno generirani niz znakova tako da se iz podatka izvrši uklanjanje prva dva znaka. 
*/

--8 bodova

SELECT *
FROM Narudzba

CREATE PROCEDURE proc_Narudzbe_Update
as
BEGIN
	UPDATE Narudzba
	SET Br_narudzbe = LEN(Br_narudzbe) - 3
	WHERE LEN(Br_narudzbe) < 25
END

EXEC proc_Narudzbe_Update

-----------------------------------------------------------------------------------------------------------------------------
/*
9.
a) Iz tabele narudzba kreirati pogled koji će imati sljedeću strukturu:
	- duz_br_nar 
	- prebrojano - prebrojati broj zapisa prema dužini podatka u koloni br_narudzbe 
	  (npr. 1000 zapisa kod kojih je dužina podatka u koloni br_narudzbe 10)
Uslov je da se ne prebrojavaju zapisi u kojima je smješten slučajno generirani niz znakova. 
Provjeriti sadržaj pogleda.
b) Prikazati minimalnu i maksimalnu vrijednost kolone prebrojano
c) Dati pregled zapisa u kreiranom pogledu u kojima su vrijednosti u koloni prebrojano veće od srednje vrijednosti kolone prebrojano 
*/

--13 bodova

--a
CREATE VIEW VIEW_prebrojano
AS
SELECT LEN(N.Br_narudzbe) as duz_br_nar,
	   COUNT(LEN(N.Br_narudzbe)) as prebrojano
FROM Narudzba AS N
GROUP BY N.Br_narudzbe

SELECT *
FROM VIEW_prebrojano

--b
SELECT MIN(prebrojano) AS MIN,
	   MAX(prebrojano) AS MAX
FROM VIEW_prebrojano

--c
SELECT prebrojano
FROM VIEW_prebrojano
WHERE prebrojano > (SELECT AVG(prebrojano) FROM VIEW_prebrojano)
-----------------------------------------------------------------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
*/

--2 boda
--a
BACKUP DATABASE [19_09_2019]
TO DISK = '19_09_2019.bak'

--b
USE master
DROP DATABASE [19_09_2019]