CREATE DATABASE baza2
USE baza2
--a)	Proizvodi
--i.	ProizvodID, cjelobrojna vrijednost i primarni ključ
--ii.	Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
--iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
--iv.	Kategorija, polje za unos 50 UNICODE karaktera (obavezan unos)
--v.	Cijena, polje za unos decimalnog broja (obavezan unos)
CREATE TABLE Proizvodi(
	ProizvodID int CONSTRAINT PK_Proizvodi PRIMARY KEY(ProizvodID),
	Sifra nvarchar(25) NOT NULL CONSTRAINT UQ_Sifra UNIQUE(Sifra),
	Naziv nvarchar(50) NOT NULL,
	Kategorija nvarchar(50) NOT NULL, 
	Cijena decimal NOT NULL
)
CREATE TABLE test(
	testID int CONSTRAINT PK_test PRIMARY KEY(testID),
	lozinka nvarchar(25) NOT NULL CONSTRAINT UQ_lozinka UNIQUE(lozinka),
	Naziv nvarchar(50) NOT NULL,
	Kategorija nvarchar(50) NOT NULL, 
	Cijena decimal NOT NULL
)

CREATE TRIGGER trigg_ProizvodiInsert 
ON Proizvodi AFTER INSERT AS
INSERT INTO test 
SELECT i.ProizvodID,i.Sifra,i.Naziv,i.Kategorija,i.Cijena
FROM inserted as i

INSERT INTO Proizvodi
VALUES(123,'123','123','123',123)

SELECT * FROM test

--b)	Narudzbe
--i.	NarudzbaID, cjelobrojna vrijednost i primarni ključ,
--ii.	BrojNarudzbe, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
--iii.	Datum, polje za unos datuma (obavezan unos),
--iv.	Ukupno, polje za unos decimalnog broja (obavezan unos)

CREATE TABLE Narudzbe(
	NarudzbaID int CONSTRAINT PK_Narudzbe PRIMARY KEY(NarudzbaID),
	BrojNarudzbe nvarchar(25) NOT NULL CONSTRAINT UQ_BrojNarudzbe UNIQUE(BrojNarudzbe),
	Datum date NOT NULL,
	Ukupno decimal NOT NULL
)

--c)	StavkeNarudzbe
--i.	ProizvodID, cjelobrojna vrijednost i dio primarnog ključa,
--ii.	NarudzbaID, cjelobrojna vrijednost i dio primarnog ključa,
--iii.	Kolicina, cjelobrojna vrijednost (obavezan unos)
--iv.	Cijena, polje za unos decimalnog broja (obavezan unos)
--v.	Popust, polje za unos decimalnog broja (obavezan unos)
--vi.	Iznos, polje za unos decimalnog broja (obavezan unos)

CREATE TABLE StavkeNarudzbe(
	ProizvodID int,
	NarudzbaID int,
	Kolicina int NOT NULL,
	Cijena decimal NOT NULL,
	Popust decimal NOT NULL,
	Iznos decimal NOT NULL,
	CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (ProizvodID, NarudzbaID),
	CONSTRAINT FK_StavkeNarudzbe_Narudzbe FOREIGN KEY(NarudzbaID) 
	REFERENCES Narudzbe(NarudzbaID),
	CONSTRAINT FK_StavkeNarudzbe_Proizvodi FOREIGN KEY(ProizvodID)
	REFERENCES Proizvodi(ProizvodID)
)

--3.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeće podatke:

--a)	U tabelu Proizvodi dodati sve proizvode koji su prodavani u 2014. godini
--i.	ProductNumber -> Sifra
--ii.	Name -> Naziv
--iii.	ProductCategory (Name) -> Kategorija
--iv.	ListPrice -> Cijena

INSERT INTO Proizvodi
SELECT distinct P.ProductID,
	   P.ProductNumber,
	   P.Name ,
	   PC.Name,
	   P.ListPrice
FROM AdventureWorks2017.Production.Product AS P INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
	 ON P.ProductSubcategoryID = PSC.ProductSubcategoryID INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PSC.ProductCategoryID = PC.ProductCategoryID INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD 
	 ON P.ProductID = SOD.ProductID INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
	 ON SOD.SalesOrderID = SOD.SalesOrderID
WHERE DATEPART(YEAR, SOH.OrderDate) = 2014

SELECT * FROM Proizvodi

--b)	U tabelu Narudzbe dodati sve narudžbe obavljene u 2014. godini
--i.	SalesOrderNumber -> BrojNarudzbe
--ii.	OrderDate - > Datum
--iii.	TotalDue -> Ukupno

INSERT INTO Narudzbe
SELECT SOH.SalesOrderID,
	   SOH.SalesOrderNumber,
	   SOH.OrderDate,
	   SOH.TotalDue
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
WHERE DATEPART(YEAR, SOH.OrderDate) = 2014

SELECT * FROM Narudzbe

--c)	U tabelu StavkeNarudzbe prebaciti sve podatke o detaljima narudžbi urađenih u 2014. godini
--i.	OrderQty -> Kolicina
--ii.	UnitPrice -> Cijena
--iii.	UnitPriceDiscount -> Popust
--iv.	LineTotal -> Iznos 
--	Napomena: Zadržati identifikatore zapisa!	

INSERT INTO StavkeNarudzbe
SELECT SOD.ProductID,
	   SOD.SalesOrderID,
	   SOD.OrderQty,
	   SOD.UnitPrice,
	   SOD.UnitPriceDiscount,
	   SOD.LineTotal
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
	 ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE DATEPART(YEAR, SOH.OrderDate) = 2014 

--4.	U svojoj bazi podataka kreirati novu tabelu Skladista sa poljima SkladisteID i Naziv, a zatim je povezati
--sa tabelom Proizvodi u relaciji više prema više. Za svaki proizvod na skladištu je potrebno čuvati količinu (cjelobrojna vrijednost).	 

CREATE TABLE Skladista (
	SkladisteID int identity(1,1) CONSTRAINT PK_Skladista PRIMARY KEY(SkladisteID),
	Naziv nvarchar(20) NOT NULL
)

CREATE TABLE SkladistaProizvodi(
	SkladisteID int CONSTRAINT FK_SkladistaProizvodi_Skladista FOREIGN KEY(SkladisteID)
	REFERENCES Skladista(SkladisteID),
	ProizvodID int CONSTRAINT FK_SkladistaProizvodi_Proizvodi FOREIGN KEY(ProizvodID)
	REFERENCES Proizvodi(ProizvodID),
	Kolicina int not null
)

--5.	U tabelu Skladista  dodati tri skladišta proizvoljno, a zatim za sve proizvode na svim skladištima postaviti količinu na 0 komada.

INSERT INTO Skladista
VALUES ('Skladiste1'),('Skladiste2'),('Skladiste3')

select * from Skladista

INSERT INTO SkladistaProizvodi
SELECT 
	(
		SELECT SkladisteID
		FROM Skladista
		WHERE SkladisteID = 6
	)
	, ProizvodID, 0
FROM Proizvodi

SELECT * FROM SkladistaProizvodi

--6.	Kreirati uskladištenu proceduru koja vrši izmjenu stanja skladišta (količina). Kao parametre proceduri proslijediti 
--identifikatore proizvoda i skladišta, te količinu.	

CREATE PROCEDURE proc_IzmjenaStanja(
	@ProizvodID int,
	@SkladisteID int,
	@kolicina int 
)
AS 
BEGIN 
	UPDATE	SkladistaProizvodi
	SET Kolicina = Kolicina + @kolicina
	WHERE @ProizvodID = ProizvodID AND @SkladisteID =SkladisteID 
END

EXEC proc_IzmjenaStanja 990,6, 5

--7.	Nad tabelom Proizvodi kreirati non-clustered indeks nad poljima Sifra i Naziv, a zatim napisati proizvoljni 
--upit koji u potpunosti iskorištava kreirani indeks. Upit obavezno mora sadržavati filtriranje podataka.

CREATE NONCLUSTERED INDEX IX_Proizvodi
ON Proizvodi(Sifra, Naziv)

SELECT Sifra, Naziv
FROM Proizvodi
WHERE Naziv LIKE '%s%'

--8.	Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Proizvodi.

CREATE TRIGGER tr_Proizvodi_Delete
ON Proizvodi INSTEAD OF DELETE 
AS 
BEGIN 
	PRINT 'Nije dozvoljeno brisanje zapisa'
	ROLLBACK
END

--DISABLE TRIGGER tr_Proizvodi_Delete ON Proizvodi
--ENABLE TRIGGER tr_Proizvodi_Delete ON Proizvodi

--9.	Kreirati view koji prikazuje sljedeće kolone: šifru, naziv i cijenu proizvoda, ukupnu prodanu količinu i ukupnu zaradu od prodaje.
CREATE VIEW view_1
AS
SELECT P.Sifra,
	   P.Naziv,
	   P.Cijena,
	   SUM(SN.Kolicina) AS 'Ukupna kolicina',
	   SUM((SN.Cijena- (SN.Kolicina * SN.Popust)) * SN.Kolicina) AS 'Ukupna zarada'
FROM Proizvodi AS P INNER JOIN StavkeNarudzbe AS SN
	 ON P.ProizvodID = SN.ProizvodID INNER JOIN Narudzbe AS N
	 ON SN.NarudzbaID = N.NarudzbaID
GROUP BY P.Sifra,
	   P.Naziv,
	   P.Cijena

--10.	Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda prikazivati ukupnu prodanu
--količinu i ukupnu zaradu. Ukoliko se ne unese šifra proizvoda procedura treba da prikaže prodaju svih proizovda.
--U proceduri koristiti prethodno kreirani view.

CREATE PROCEDURE proc_UkupnoProdano(
	@Sifra nvarchar(25) = NULL
)
AS 
BEGIN 
	SELECT *
	FROM view_1
	WHERE Sifra = @Sifra OR @Sifra IS NULL
END

EXEC proc_UkupnoProdano 

--11.	U svojoj bazi podataka kreirati novog korisnika za login student te mu dodijeliti odgovarajuću permisiju
--kako bi mogao izvršavati prethodno kreiranu proceduru

12.	Napraviti full i diferencijalni backup baze podataka na lokaciji D:\BP2\Backup	 

BACKUP DATABASE baza2 TO
DISK = 'BAZA2.bak'

BACKUP DATABASE baza2 TO
DISK = 'BAZA2.bak'
WITH DIFFERENTIAL









INSERT INTO Proizvodi
SELECT P.ProductID,
	   P.ProductNumber Sifra,
	   P.Name Naziv,
	   PC.Name Kategorija,
	   P.ListPrice AS Cijena,
	   SOH.SalesOrderNumber BrojNarudzbe,
	   SOH.OrderDate Datum,
	   SOH.TotalDue Ukupno,
	   SOD.OrderQty Kolicina,
	   SOD.UnitPrice Cijena,
	   SOD.UnitPriceDiscount Popust,
	   SOD.LineTotal Iznos
FROM AdventureWorks2017.Production.Product AS P INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
	 ON P.ProductSubcategoryID = PSC.ProductSubcategoryID INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PSC.ProductCategoryID = PC.ProductCategoryID INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD
	 ON P.ProductID = SOD.ProductID INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH 
	 ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE 