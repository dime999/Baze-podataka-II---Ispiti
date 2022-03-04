
CREATE DATABASE baza1

use baza1

--a) Klijenti
--i. KlijentID, automatski generator vrijednosti i primarni ključ
--ii. Ime, polje za unos 30 UNICODE karaktera (obavezan unos)
--iii. Prezime, polje za unos 30 UNICODE karaktera (obavezan unos)
--iv. Telefon, polje za unos 20 UNICODE karaktera (obavezan unos)
--v. Mail, polje za unos 50 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
--vi. BrojRacuna, polje za unos 15 UNICODE karaktera (obavezan unos)
--vii. KorisnickoIme, polje za unos 20 UNICODE karaktera (obavezan unos)
--viii. Lozinka, polje za unos 20 UNICODE karaktera (obavezan unos)

CREATE TABLE Klijenti(
	KlijentID int identity(1,1) CONSTRAINT PK_Klijenti PRIMARY KEY(KlijentID),
	Ime nvarchar(30) NOT NULL,
	Prezime nvarchar(30) NOT NULL,
	Telefon nvarchar(20) NOT NULL, 
	Mail nvarchar(50) NOT NULL CONSTRAINT UQ_Mail UNIQUE(Mail),
	BrojRacuna nvarchar(15) NOT NULL, 
	KorisnickoIme nvarchar(20) NOT NULL ,
	Lozinka nvarchar(20) NOT NULL
)

SELECT * FROM Klijenti

--b) Transakcije
--i. TransakcijaID, automatski generator vrijednosti i primarni ključ
--ii. Datum, polje za unos datuma i vremena (obavezan unos)
--iii. TipTransakcije, polje za unos 30 UNICODE karaktera (obavezan unos)
--iv. PosiljalacID, referenca na tabelu Klijenti (obavezan unos)
--v. PrimalacID, referenca na tabelu Klijenti (obavezan unos)
--vi. Svrha, polje za unos 50 UNICODE karaktera (obavezan unos)
--vii. Iznos, polje za unos decimalnog broja (obavezan unos)

CREATE TABLE Transakcije(
	TransakcijaID int identity(1,1) CONSTRAINT PK_Transakcije PRIMARY KEY(TransakcijaID),
	Datum datetime NOT NULL, 
	TipTransakcije nvarchar(30) NOT NULL,
	PosiljalacID int CONSTRAINT FK_Transakcije_Posiljalac FOREIGN KEY(PosiljalacID) REFERENCES Klijenti(KlijentID),
	PrimalacID int CONSTRAINT FK_Transkacije_Primalac FOREIGN KEY(PrimalacID) REFERENCES Klijenti(KlijentID),
	Svrha nvarchar(50) NOT NULL,
	Iznos decimal NOT NULL
)

--2. Popunjavanje tabela podacima:
--a) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati 10 kupaca
--u tabelu Klijenti. Ime, prezime, telefon, mail i broj računa (AccountNumber) preuzeti od kupca,
--korisničko ime generisati na osnovu imena i prezimena u formatu ime.prezime, a lozinku generisati na
--osnovu polja PasswordHash, i to uzeti samo zadnjih 8 karaktera.
INSERT INTO  Klijenti
SELECT TOP 10 
	   P.FirstName,
	   P.LastName,
	   PP.PhoneNumber,
	   EA.EmailAddress ,
	   SC.AccountNumber,
	   P.FirstName + '.' + P.LastName,
	   RIGHT(PSW.PasswordHash, 8)
FROM AdventureWorks2017.Person.Person AS P INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2017.Sales.Customer AS SC 
	 ON P.BusinessEntityID = SC.CustomerID INNER JOIN AdventureWorks2017.Person.Password AS PSW 
	 ON P.BusinessEntityID = PSW.BusinessEntityID

SELECT * FROM Klijenti

--b) Putem jedne INSERT komande u tabelu Transakcije dodati minimalno 10 transakcija.
INSERT INTO Transakcije
VALUES 
	   ('20180905','TIP2',2106,2111,'kazna',50),
	   ('20160905','TIP2',2107,2110,'kazna',100),
	   ('20160905','TIP1',2108,2109,'dug',100),
	   ('20190905','TIP2',2109,2108,'kazna',100),
	   ('20190905','TIP1',2110,2107,'dug',500),
	   ('20160905','TIP2',2111,2106,'kazna',100)
select * from Transakcije

--3. Kreiranje indeksa u bazi podataka nada tabelama:
--a) Non-clustered indeks nad tabelom Klijenti. Potrebno je indeksirati Ime i Prezime. Također, potrebno je
--uključiti kolonu BrojRacuna.

CREATE NONCLUSTERED INDEX IX_Klijenti
ON Klijenti(Ime, Prezime)
INCLUDE(BrojRacuna)

--b) Napisati proizvoljni upit nad tabelom Klijenti koji u potpunosti iskorištava indeks iz prethodnog koraka.
--Upit obavezno mora imati filter.
SELECT Ime, Prezime, BrojRacuna
FROM Klijenti
WHERE BrojRacuna like '%1%'

--c) Uraditi disable indeksa iz koraka a)
ALTER INDEX IX_Klijenti ON Klijenti
DISABLE
GO

alter index IX_Klijenti on Klijenti
rebuild

--4. Kreirati uskladištenu proceduru koja će vršiti upis novih klijenata. Kao parametre proslijediti sva polja. Provjeriti
--ispravnost kreirane procedure.

CREATE PROCEDURE proc_Insert(
	@Ime nvarchar(30),
	@Prezime nvarchar(30),
	@Telefon nvarchar(20),
	@Mail nvarchar(50),
	@BrojRacuna nvarchar(15),
	@KorisnickoIme nvarchar(20),
	@Lozinka nvarchar(20)
)
AS 
BEGIN 
	INSERT INTO Klijenti
	VALUES(@Ime, @Prezime, @Telefon, @Mail, @BrojRacuna, @KorisnickoIme, @Lozinka)
END 

exec proc_Insert 'atif', 'delibasic', '062','aa','aa','aa','aa'

select * from Klijenti

--5. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje datum transakcije, tip transakcije, ime i
--prezime pošiljaoca (spojeno), broj računa pošiljaoca, ime i prezime primaoca (spojeno), broj računa primaoca,
--svrhu i iznos transakcije.

CREATE VIEW view_New
AS 
SELECT T.Datum, T.TipTransakcije,
	   PO.Ime + ' ' + PO.Prezime AS Posiljaoc,
	   PR.Ime + ' ' + PR.Prezime AS Primaoc,
	   PR.BrojRacuna [br racuna prim],
	   PO.BrojRacuna [br racuna pos]
FROM Transakcije AS T INNER JOIN Klijenti AS PO
	 ON T.PosiljalacID = PO.KlijentID INNER JOIN Klijenti AS PR
	 ON T.PrimalacID = PR.KlijentID

select *
from view_New

--6. Kreirati uskladištenu proceduru koja će na osnovu unesenog broja računa pošiljaoca prikazivati sve transakcije
--koje su provedene sa računa klijenta. U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane
--procedure.

CREATE PROCEDURE proc_transakcije(
	@BrojRacuna nvarchar(15)
)
AS 
BEGIN
	SELECT *
	FROM view_New
	WHERE [br racuna prim] = @BrojRacuna
END

EXEC proc_transakcije 'AW00000293'

--Kreirati upit koji prikazuje sumaran iznos svih transakcija po godinama, sortirano po godinama. U rezultatu upita
--prikazati samo dvije kolone: kalendarska godina i ukupan iznos transakcija u godini.

SELECT DATEPART(YEAR, Datum) AS Godina,
	  SUM(Iznos) AS 'Ukupan iznos'
FROM Transakcije
GROUP BY DATEPART(YEAR, Datum)
ORDER BY Godina

--Kreirati uskladištenu proceduru koje će vršiti brisanje klijenta uključujući sve njegove transakcije, bilo da je za
--transakciju vezan kao pošiljalac ili kao primalac. Provjeriti ispravnost kreirane procedure.

alter PROCEDURE proc_Delete (
	@KlijentID int
)
AS 
BEGIN 
	DELETE FROM Transakcije
	WHERE PosiljalacID in(
		SELECT PosiljalacID
		FROM Transakcije
		WHERE PosiljalacID = @KlijentID
	) OR
	 PrimalacID in(
		SELECT PrimalacID
		FROM Transakcije
		WHERE PrimalacID = @KlijentID
	)
	DELETE FROM Klijenti
	WHERE KlijentID = @KlijentID
END

exec proc_Delete 2106
SELECT * FROM Transakcije

--9. Kreirati uskladištenu proceduru koja će na osnovu unesenog broja računa ili prezimena pošiljaoca vršiti pretragu
--nad prethodno kreiranim view-om (zadatak 5). Testirati ispravnost procedure u sljedećim situacijama:
--a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
--b) Postavljena je vrijednost parametra broj računa,
--c) Postavljena je vrijednost parametra prezime,
--d) Postavljene su vrijednosti oba parametra.

alter PROCEDURE proc_Pretraga(
	@BrojRacuna nvarchar(15) = NULL,
	@Prezime nvarchar(30) = NULL
)
AS 
BEGIN
	SELECT *
	FROM view_New
	WHERE ([br racuna pos] = @BrojRacuna OR @BrojRacuna IS NULL) AND (
	Posiljaoc like '%' + @Prezime +'%' OR @Prezime IS NULL)
END

exec proc_Pretraga 'AW00000211'

--10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
--a) C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup

BACKUP DATABASE baza1 TO
DISK = 'baza1.bak'

BACKUP DATABASE baza1 TO
DISK = 'baza1.bak'
WITH DIFFERENTIAL