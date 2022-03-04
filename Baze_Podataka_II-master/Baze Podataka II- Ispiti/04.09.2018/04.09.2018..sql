CREATE DATABASE baza

USE baza

--Autori
--• AutorID, 11 UNICODE karaktera i primarni ključ
--• Prezime, 25 UNICODE karaktera (obavezan unos)
--• Ime, 25 UNICODE karaktera (obavezan unos)
--• Telefon, 20 UNICODE karaktera, DEFAULT je NULL
--• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL

CREATE TABLE Autori(
	AutorID nvarchar(11) CONSTRAINT PK_Autori PRIMARY KEY(AutorID),
	Prezime nvarchar(25) NOT NULL,
	Ime nvarchar(25) NOT NULL, 
	Telefon nvarchar(20) DEFAULT NULL, 
	DatumKreiranjaZapisa date NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa date DEFAULT NULL
)

--Izdavaci
--• IzdavacID, 4 UNICODE karaktera i primarni ključ
--• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
--• Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
--• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL

CREATE TABLE Izdavaci (
	IzdavacID nvarchar(4) CONSTRAINT PK_Izdavaci PRIMARY KEY(IzdavacID),
	Naziv nvarchar(100) NOT NULL CONSTRAINT UQ_Izdavaci UNIQUE(Naziv),
	Biljeske nvarchar(1000) DEFAULT 'Lorem ipsum',
	DatumKreiranjaZapisa date NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa date DEFAULT NULL
)

--Naslovi
--• NaslovID, 6 UNICODE karaktera i primarni ključ
--• IzdavacID, spoljni ključ prema tabeli „Izdavaci“
--• Naslov, 100 UNICODE karaktera (obavezan unos)
--• Cijena, monetarni tip podatka
--• DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL

CREATE TABLE Naslovi(
	NaslovID nvarchar(6) CONSTRAINT PK_Naslovi PRIMARY KEY(NaslovID),
	IzdavacID nvarchar(4) CONSTRAINT FK_Naslovi_Izdavaci FOREIGN KEY(IzdavacID) 
	REFERENCES Izdavaci(IzdavacID),
	Naslov nvarchar(100) NOT NULL,
	Cijena money,
	DatumIzdavanja date NOT NULL DEFAULT GETDATE(),
	DatumKreiranjaZapisa date NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa date DEFAULT NULL
)

--NasloviAutori (Više autora može raditi na istoj knjizi)
--• AutorID, spoljni ključ prema tabeli „Autori“
--• NaslovID, spoljni ključ prema tabeli „Naslovi“
--• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL

CREATE TABLE NasloviAutori(
	AutorID nvarchar(11),
	NaslovID nvarchar(6),
	DatumKreiranjaZapisa date NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa date DEFAULT NULL,
	CONSTRAINT PK_NasloviAutori PRIMARY KEY(AutorID,NaslovID),
	CONSTRAINT FK_NasloviAutori_Naslovi FOREIGN KEY(NaslovID)
	REFERENCES Naslovi(NaslovID),
	CONSTRAINT FK_NasloviAutori_Autori FOREIGN KEY(AutorID)
	REFERENCES Autori(AutorID)
)

--Generisati testne podatake i obavezno testirati da li su podaci u tabeli za svaki korak posebno :
--• Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ importovati sve slučajno
--sortirane zapise. Vodite računa da mapirate odgovarajuće kolone.

INSERT INTO Autori(AutorID,Prezime, Ime, Telefon)
SELECT A.au_id, A.au_lname, A.au_fname, A.phone
FROM pubs.dbo.authors AS A
ORDER BY NEWID()

SELECT * FROM Autori

--• Iz baze podataka pubs i tabela („publishers“ i pub_info“), a putem podupita u tabelu „Izdavaci“
--importovati sve slučajno sortirane zapise. Kolonu pr_info mapirati kao bilješke i iste skratiti na 100
--karaktera. Vodite računa da mapirate odgovarajuće kolone i tipove podataka.

INSERT INTO Izdavaci(IzdavacID,Naziv, Biljeske)
SELECT P.pub_id,
	   P.pub_name,
	   CAST(PI.pr_info AS nvarchar(100))
FROM pubs.dbo.publishers AS P INNER JOIN pubs.dbo.pub_info AS PI 
	 ON P.pub_id = PI.pub_id	
ORDER BY NEWID()

select * from Izdavaci

--• Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“ importovati sve zapise. Vodite
--računa da mapirate odgovarajuće kolone.

INSERT INTO Naslovi(NaslovID, IzdavacID, Naslov, Cijena, DatumIzdavanja)
SELECT T.title_id, T.pub_id, T.title, T.price, T.pubdate
FROM pubs.dbo.titles AS T

select * from Naslovi

--• Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise. Vodite
--računa da mapirate odgovarajuće kolone

INSERT INTO NasloviAutori(AutorID, NaslovID)
SELECT TA.au_id, title_id
FROM pubs.dbo.titleauthor AS TA

select * from NasloviAutori

--Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:
--Gradovi
--• GradID, automatski generator vrijednost čija početna vrijednost je 5 i uvećava se za 5, primarni ključ
--• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
--• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
--• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL

CREATE TABLE Gradovi(
	GradID int identity(5,5) CONSTRAINT PK_Gradovi PRIMARY KEY(GradID),
	Naziv nvarchar(100) NOT NULL,
	DatumKreiranjaZapisa date NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa date DEFAULT NULL
)

--✓ Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati nazive gradove
--bez duplikata.

INSERT INTO Gradovi(Naziv)
SELECT DISTINCT A.city
FROM pubs.dbo.authors AS A 

select * from Gradovi

--✓ Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:

ALTER TABLE Autori
ADD GradID int CONSTRAINT FK_Autori_Gradovi FOREIGN KEY(GradID) REFERENCES Gradovi(GradID)

--Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
--• Prvih deset autora iz tabele postaviti da su iz grada: San Francisco
--• Ostalim autorima podesiti grad na: Berkeley
--Vodite računa da se u tabeli modifikuju sve potrebne kolone.

CREATE PROCEDURE proc_modfiy1
AS 
BEGIN 
	UPDATE Autori 
	SET GradID = (SELECT GradID FROM Gradovi WHERE Naziv = 'San Francisco')
	WHERE AutorID IN (
		SELECT TOP 10 AutorID
		FROM Autori
	)
END

exec proc_modfiy1

CREATE PROCEDURE proc_modfiy2
AS 
BEGIN 
	UPDATE Autori 
	SET GradID = (SELECT GradID FROM Gradovi WHERE Naziv = 'Berkeley')
	WHERE GradID IS NULL 
END

exec proc_modfiy2
select * from Autori

--Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, cijena, izdavač i bilješke, ali
--samo za one autore čije knjige imaju određenu cijenu i gdje je cijena veća od 10. Također, naziv izdavača u sredini
--imena treba imati slovo „&“ i da su iz grada San Francisco . Obavezno testirati funkcionalnost view objekta.

CREATE VIEW view_1
AS
SELECT A.Prezime + ' ' + A.Ime AS [Ime prezime], 
	   G.Naziv [Grad],
	   N.Naslov,
	   N.Cijena,
	   I.Naziv,
	   I.Biljeske
FROM Izdavaci AS I INNER JOIN Naslovi AS N 
	 ON I.IzdavacID = N.IzdavacID INNER JOIN NasloviAutori AS NA
	 ON N.NaslovID = NA.NaslovID INNER JOIN Autori AS A 
	 ON NA.AutorID = A.AutorID INNER JOIN Gradovi AS G
	 ON A.GradID = G.GradID
WHERE (N.Cijena IS NOT NULL AND N.Cijena > 10) 
	  AND I.Naziv LIKE '%&%' 
	  AND G.Naziv = 'San Francisco'

select * from view_1

--Modifikovati tabelu Autori i dodati jednu kolonu:
--• Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL

ALTER TABLE Autori 
ADD Email nvarchar(100) DEFAULT NULL

--Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori i svim autorima generisati novu
--email adresu:
--• Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada San Francisco
--• Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Berkeley

CREATE PROCEDURE proc_modifiy_email1
AS
BEGIN 
	UPDATE Autori
	SET Email = Ime+'.'+Prezime+'@fit.ba'
	WHERE GradID IN (
		SELECT GradID
		FROM Gradovi
		WHERE Naziv ='San Francisco'
	)
END

exec proc_modifiy_email1

CREATE PROCEDURE proc_modifiy_email2
AS
BEGIN 
	UPDATE Autori
	SET Email = Prezime+'.'+Ime+'@fit.ba'
	WHERE GradID IN (
		SELECT GradID
		FROM Gradovi
		WHERE Naziv ='Berkeley'
	)
END

exec proc_modifiy_email2

select * from Autori

--Iz baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati zapise o
--osobama, a putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber i
--CardNumber. Kreirate dvije dodatne kolone: UserName koja se sastoji od spojenog imena i prezimena (tačka se
--nalazi između) i kolonu Password za lozinku sa malim slovima dugačku 16 karaktera. Lozinka se generiše putem SQL
--funkciju za slučajne i jedinstvene ID vrijednosti. Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem
--„7“. Uslovi su da podaci uključuju osobe koje imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula
--zamjeniti sa podatkom 'N/A'. Sortirati prema prezimenu i imenu. Testirati da li je tabela sa podacima kreirana.

SELECT ISNULL(P.Title, 'N/A') Naslov,
	   P.LastName Prezime,
	   P.FirstName Ime,
	   EA.EmailAddress Email,
	   PP.PhoneNumber Broj,
	   CC.CardNumber Kartica,
	   P.FirstName +'.'+ P.LastName UserName, 
	   LEFT(REPLACE(NEWID(),'-','7'), 16) Lozinka
INTO #temp 
FROM AdventureWorks2017.Person.Person AS P INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID LEFT JOIN AdventureWorks2017.Sales.PersonCreditCard AS PCC
	 ON P.BusinessEntityID = PCC.BusinessEntityID LEFT JOIN AdventureWorks2017.Sales.CreditCard AS CC 
	 ON PCC.CreditCardID = CC.CreditCardID
ORDER BY P.LastName, P.FirstName

select * from #temp

--Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno ubrzati upite koje
--koriste kolonu UserName, a sekundarno nad kolonama LastName i FirstName. Napisati testni upit. 

CREATE NONCLUSTERED INDEX IX_temp
ON #temp (UserName)
INCLUDE (Prezime, Ime)

SELECT Ime, Prezime
FROM #temp
WHERE UserName LIKE '%s'
GO

--Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji nemaju kreditnu karticu Obavezno
--testirati funkcionalnost procedure.

CREATE PROCEDURE proc_deleteAllrecords
AS 
BEGIN 
	DELETE FROM #temp
	WHERE Kartica IS NULL
END

exec proc_deleteAllrecords 
select * from #temp

--Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu. 

BACKUP DATABASE baza TO
disk = 'baza.bak'

DROP TABLE #temp

--10a. Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja. Testirati da li su podaci obrisani.
CREATE PROCEDURE proc_deleteAll
AS
BEGIN
	 DELETE FROM NasloviAutori
     DELETE FROM Autori
     DELETE FROM Gradovi
     DELETE FROM Naslovi
     DELETE FROM Izdavaci
END

exec proc_deleteAll

--Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi podaci u izvornom obliku.
