CREATE DATABASE p
USE p

--a) Proizvodi:
--I. ProizvodID, automatski generatpr vrijednosti i primarni ključ
--II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
--III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
--IV. Cijena, polje za unos decimalnog broja (obavezan unos)

CREATE TABLE Proizvodi(
	ProizvodiID int identity(1,1) CONSTRAINT PK_Proizvodi PRIMARY KEY(ProizvodiID),
	Sifra nvarchar(10) NOT NULL CONSTRAINT UQ_Sifra UNIQUE(Sifra),
	Naziv nvarchar(50) NOT NULL,
	Cijena decimal(8,2) NOT NULL
)

--b) Skladista
--I. SkladisteID, automatski generator vrijednosti i primarni ključ
--II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
--III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
--IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)

CREATE TABLE Skladista(
	SkladisteID int identity(1,1) CONSTRAINT PK_skladista PRIMARY KEY(SkladisteID),
	Naziv nvarchar(50) NOT NULL,
	Oznaka nvarchar(10) NOT NULL CONSTRAINT UQ_Oznaka UNIQUE(Oznaka),
	Lokacija nvarchar(50) NOT NULL
)

--c) SkladisteProizvodi
--I) Stanje, polje za unos decimalnih brojeva (obavezan unos)
--Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti
--uskladišten na više različitih skladišta. Onemogućiti da se isti proizvod na skladištu može pojaviti više
--puta.

CREATE TABLE SkladisteProizvodi(
	SkladisteID int,
	ProizvodiID int, 
	Stanje decimal(8,2) NOT NULL,
	CONSTRAINT PK_SkladisteProizvodi PRIMARY KEY(SkladisteID, ProizvodiID),
	CONSTRAINT FK_SkladisteProizvodi_Skladista FOREIGN KEY(SkladisteID)
	REFERENCES Skladista(SkladisteID),
	CONSTRAINT FK_SkladisteProizvodi_Proizvodi FOREIGN KEY(ProizvodiID)
	REFERENCES Proizvodi(ProizvodiID)
)

--2. Popunjavanje tabela podacima
--a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.
INSERT INTO Skladista
VALUES('Skladiste1', 'O1', 'Kakanj'),
	  ('Skladiste2', 'O2', 'Zenica'),
	  ('Skladiste3', 'O3', 'Sarajevo')

--b) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
--10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeće kolone:
--I. Broj proizvoda (ProductNumber) - > Sifra,
--II. Naziv bicikla (Name) -> Naziv,
--III. Cijena po komadu (ListPrice) -> Cijena,

INSERT INTO Proizvodi
SELECT TOP 10 P.ProductNumber AS Sifra,
	   P.Name,
	   P.ListPrice AS Cijena
FROM AdventureWorks2017.Production.Product AS  P INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
	 ON P.ProductSubcategoryID = PSC.ProductSubcategoryID INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	 ON PC.ProductCategoryID = PSC.ProductCategoryID INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD
	 ON P.ProductID = SOD.ProductID
WHERE PC.Name LIKE '%Bikes%'
GROUP BY P.ProductNumber, P.Name, P.ListPrice
ORDER BY SUM(SOD.OrderQty) DESC

SELECT * FROM Proizvodi

--c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
--importovati sve proizvode tako da stanje bude 100

insert INTO SkladisteProizvodi
SELECT (SELECT SkladisteID FROM Skladista WHERE SkladisteID = 3),ProizvodiID,100
FROM Proizvodi

select * from SkladisteProizvodi

-- Kreirati uskladištenu proceduru koja će vršiti povećanje stanja skladišta za određeni proizvod na
--odabranom skladištu. Provjeriti ispravnost procedure.

CREATE PROCEDURE proc_stanje(
	@Stanje decimal(8,2),
	@ProizvodID int,
	@SkladisteID int 
)
AS 
BEGIN 
	UPDATE SkladisteProizvodi
	SET Stanje = Stanje + @Stanje
	WHERE @ProizvodID = ProizvodiID AND @SkladisteID = SkladisteID
END

EXEC proc_stanje 1,2,3

select * from SkladisteProizvodi

--4. Kreiranje indeksa u bazi podataka nad tabelama
--a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također,
--potrebno je uključiti kolonu Cijena

CREATE NONCLUSTERED INDEX IX_Proizvodi
ON Proizvodi(Sifra, Naziv)
INCLUDE(Cijena)

--b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
--prethodnog koraka

SELECT Sifra, Naziv, Cijena
FROM Proizvodi
WHERE Cijena > 20
ORDER BY Sifra, Naziv

--c) Uradite disable indeksa iz koraka a)
ALTER INDEX IX_Proizvodi ON Proizvodi DISABLE

--5. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
--oznaku, naziv i lokaciju skladišta, te stanje na skladištu.

CREATE VIEW view_1
AS 
	SELECT P.Sifra,
		   P.Naziv AS Proizvod,
		   P.Cijena,
		   S.Oznaka,
		   S.Naziv Skladiste,
		   S.Lokacija,
		   SP.Stanje
	FROM SkladisteProizvodi AS SP INNER JOIN Skladista AS S
	ON SP.SkladisteID = S.SkladisteID INNER JOIN Proizvodi AS P
	ON SP.ProizvodiID = P.ProizvodiID

--6. Kreirati uskladištenu proceduru koja će na osnovu unesene šifre proizvoda prikazati ukupno stanje
--zaliha na svim skladištima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
--U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure. 

CREATE PROCEDURE proc_Stanje(
	@Sifra nvarchar(10)
)
AS
BEGIN
	SELECT Sifra, Proizvod, Cijena, Stanje
	FROM view_1
	WHERE Sifra = @Sifra
END

EXEC proc_Stanje 'BK-M68B-38'

--7. Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, te kao stanje zaliha za uneseni
--proizvod postaviti na 0 za sva skladišta. Provjeriti ispravnost kreirane procedure.

alter PROCEDURE proc_Insert (
	  @Sifra NVARCHAR(10),
    @Naziv NVARCHAR(50),
    @Cijena DECIMAL(8,2)
)
as 
BEGIN 
	INSERT INTO Proizvodi(Sifra, Naziv, Cijena)
	VALUES(@Sifra, @Naziv, @Cijena)

	INSERT INTO SkladisteProizvodi 
	SELECT SkladisteID, (SELECT Sifra FROM Proizvodi WHERE Sifra = @Sifra), 0
	FROM Skladista
END 

EXEC proc_Insert 'atif123', 'najnoviji', 15

select * from Proizvodi

--8. Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda vršiti brisanje proizvoda
--uključujući stanje na svim skladištima. Provjeriti ispravnost procedure.

CREATE PROCEDURE proc_Sifra(
	@Sifra nvarchar(10)
)
as 
begin 
	delete from SkladisteProizvodi 
	where ProizvodiID in(
			select ProizvodiID 
			from Proizvodi 
			where Sifra = @Sifra
	)

	DELETE FROM Proizvodi
	WHERE Sifra = @Sifra
end

select * from Proizvodi

/*9.
 Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda, oznaku skladišta ili lokaciju
skladišta vršiti pretragu prethodno kreiranim VIEW-om (zadatak 5). Procedura obavezno treba da
vraća rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija
nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta
nije
e) Postavljene su vrijednosti sva tri parametra
*/

CREATE PROCEDURE proc_Last(
	@Sifra nvarchar(10) = NULL,
	@Oznaka nvarchar(10) = NULL,
	@Lokacija nvarchar(50) = NULL
)
AS
BEGIN
	SELECT *
	FROM view_1
	WHERE (@Sifra IS NULL OR Sifra = @Sifra)
	AND (@Oznaka IS NULL OR Oznaka = @Oznaka) 
	AND (@Lokacija IS NULL OR Lokacija = @Lokacija)
END

exec proc_Last 

--10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:

BACKUP DATABASE p TO 
DISK = 'p.bak'

BACKUP DATABASE p TO 
DISK = 'p.bak'
WITH DIFFERENTIAL