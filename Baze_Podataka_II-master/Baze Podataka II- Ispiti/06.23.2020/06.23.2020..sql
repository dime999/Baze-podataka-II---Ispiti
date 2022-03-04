----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/
CREATE DATABASE [Ispit]
USE Ispit
-----------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
-----------------------------------------------------------------------
/*
a) 
Kreirati tabelu dobavljac sljedeće strukture:
	- dobavljac_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_br_rac - 50 unicode karaktera
	- naziv_dobavljaca - 50 unicode karaktera
	- kred_rejting - cjelobrojna vrijednost
*/
CREATE TABLE dobavljac (
	dobavljac_id INT CONSTRAINT PK_dobavljac PRIMARY KEY(dobavljac_id), 
	dobavljac_br_rac NVARCHAR(50),
	naziv_dobavljaca NVARCHAR(50), 
	kred_rejting INT
)

/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/
CREATE TABLE narudzba(
	narudzba_id INT,
	narudzba_detalj_id INT,
	dobavljac_id INT ,
	dtm_narudzbe DATE,
	naruc_kolicina INT, 
	cijena_proizvoda MONEY,
	CONSTRAINT PK_narudzba PRIMARY KEY(narudzba_id, narudzba_detalj_id),
	CONSTRAINT FK_narudzba_dobavljac FOREIGN KEY(dobavljac_id) 
	REFERENCES dobavljac(dobavljac_id)
)
/*
c)
Kreirati tabelu dobavljac_proizvod sljedeće strukture:
	- proizvod_id cjelobrojna vrijednost, primarni ključ
	- dobavljac_id cjelobrojna vrijednost, primarni ključ
	- proiz_naziv 50 unicode karaktera
	- serij_oznaka_proiz 50 unicode karaktera
	- razlika_min_max cjelobrojna vrijednost
	- razlika_max_narudzba cjelobrojna vrijednost
*/

CREATE TABLE dobavljac_proizvod(
	proizvod_id INT,
	dobavljac_id INT,
	proiz_naziv NVARCHAR(50),
	serij_oznaka_proiz NVARCHAR(50),
	razlika_min_max INT,
	razlika_max_narudzba INT ,
	CONSTRAINT PK_dobavljac_proizvod PRIMARY KEY(proizvod_id, dobavljac_id),
	CONSTRAINT FK_dobavljac_proizvod_dobavljac FOREIGN KEY(dobavljac_id)
	REFERENCES dobavljac(dobavljac_id)
)
DROP TABLE dobavljac_proizvod
--10 bodova



----------------------------
--2. Insert podataka
----------------------------
/*
a) 
U tabelu dobavljac izvršiti insert podataka iz tabele Purchasing.Vendor prema sljedećoj strukturi:
	BusinessEntityID -> dobavljac_id 
	AccountNumber -> dobavljac_br_rac 
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/
INSERT INTO dobavljac
SELECT BusinessEntityID AS dobavljac_id, 
	   AccountNumber AS dobavljac_br_rac ,
	   Name AS naziv_dobavljaca,
	   CreditRating AS kred_rejting
FROM AdventureWorks2017.Purchasing.Vendor AS V

SELECT * FROM dobavljac

/*
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/
INSERT INTO narudzba
SELECT POH.PurchaseOrderID AS narudzba_id,
	   POD.PurchaseOrderDetailID AS narudzba_detalj_id, 
	   POH.VendorID AS dobavljac_id,
	   POH.OrderDate AS dtm_narudzbe, 
	   POD.OrderQty AS naruc_kolicina,
	   POD.UnitPrice AS cijena_proizvoda
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH INNER JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS POD 
	 ON POH.PurchaseOrderID = POD.PurchaseOrderID

SELECT * 
FROM narudzba

/*
c) 
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela Purchasing.ProductVendor i Production.Product prema sljedećoj strukturi:
	ProductID -> proizvod_id 
	BusinessEntityID -> dobavljac_id 
	Name -> proiz_naziv 
	ProductNumber -> serij_oznaka_proiz
	MaxOrderQty - MinOrderQty -> razlika_min_max 
	MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se povuku samo oni zapisi u kojima ProductSubcategoryID nije NULL vrijednost.
*/

INSERT INTO dobavljac_proizvod
SELECT PV.ProductID AS proizvod_id, 
	   PV.BusinessEntityID AS dobavljac_id, 
	   PP.Name AS proiz_naziv,
	   PP.ProductNumber AS serij_oznaka_proiz,
	   PV.MaxOrderQty - PV.MinOrderQty AS razlika_min_max ,
	   PV.MaxOrderQty - PV.OnOrderQty AS razlika_max_narudzba
FROM AdventureWorks2017.Purchasing.ProductVendor AS PV INNER JOIN AdventureWorks2017.Production.Product AS PP
	 ON PV.ProductID = PP.ProductID
WHERE PP.ProductSubcategoryID IS NOT NULL

SELECT * FROM dobavljac_proizvod
--10 bodova

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_god sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- ukupno, kao proizvod naručene količine i cijene proizvoda
Uslov je da se dohvate samo oni zapisi u kojima je narudžba obavljena 2013. ili 2014. godine i da se broj računa dobavljača završava cifrom 1.
*/

CREATE VIEW view_dob_god
AS
SELECT D.dobavljac_id,
	   DP.proizvod_id,
	   N.naruc_kolicina,
	   N.cijena_proizvoda,
	   N.naruc_kolicina * N.cijena_proizvoda AS ukupno
FROM dobavljac AS D INNER JOIN dobavljac_proizvod AS DP 
	 ON D.dobavljac_id = DP.dobavljac_id INNER JOIN narudzba AS N 
	 ON D.dobavljac_id = N.dobavljac_id
WHERE (DATEPART(YEAR, N.dtm_narudzbe) = 2013 OR DATEPART(YEAR, N.dtm_narudzbe) = 2014) AND D.dobavljac_br_rac LIKE '%1'
GROUP BY D.dobavljac_id,
		 DP.proizvod_id,
		 N.naruc_kolicina,
		 N.cijena_proizvoda

SELECT *
FROM view_dob_god
--10 bodova

----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_dob_god koja će sadržavati parametar naruc_kolicina i imati sljedeću strukturu:
	- dobavljac_id
	- proizvod_id
	- suma_ukupno, sumirana vrijednost kolone ukupno po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je naručena količina trocifreni broj.
Nakon kreiranja pokrenuti proceduru za vrijednost naručene količine 300.
*/
--10 bodova

CREATE PROCEDURE proc_dob_god
	@naruc_kolicina INT
AS 
BEGIN 
	SELECT dobavljac_id, 
		   proizvod_id,
		   SUM(ukupno) AS suma_ukupno
	FROM view_dob_god 
	WHERE (naruc_kolicina > 99 AND naruc_kolicina < 1000) AND naruc_kolicina = @naruc_kolicina
	GROUP BY dobavljac_id, proizvod_id
END

EXEC proc_dob_god 300
----------------------------
--5.
----------------------------
/*
a)
Tabelu dobavljac_proizvod kopirati u tabelu dobavljac_proizvod_nova.
b) 
Iz tabele dobavljac_proizvod_nova izbrisati kolonu razlika_min_max.
c)
U tabeli dobavljac_proizvod_nova kreirati novu kolonu razlika. 
Kolonu popuniti razlikom vrijednosti kolone razlika_max_narudzba i srednje vrijednosti ove kolone,
uz uslov da ako se u zapisu nalazi NULL vrijednost u kolonu razlika smjestiti 0.
*/
--15 bodova

SELECT *
INTO dobavljac_proizvod_nova
FROM dobavljac_proizvod

ALTER TABLE dobavljac_proizvod_nova
DROP COLUMN razlika_min_max

ALTER TABLE dobavljac_proizvod_nova
ADD razlika INT

select * from dobavljac_proizvod_nova

UPDATE dobavljac_proizvod_nova
SET razlika = ISNULL(razlika_max_narudzba - (SELECT AVG(razlika_max_narudzba) FROM dobavljac_proizvod_nova),0)


----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda koje završavaju 
bilo kojim slovom engleskog alfabeta, a koliko ima onih koji ne završavaju bilo kojim slovom engleskog alfabeta. Upit treba da vrati poruke:
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa 
	i
	'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa
*/
--10 bodova

SELECT 'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima:' + 
	    CAST(COUNT(serij_oznaka_proiz) as nvarchar) AS Informacija
FROM dobavljac_proizvod
WHERE serij_oznaka_proiz LIKE '%[A-Z]'
union
SELECT 'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima:' +
CAST(COUNT(serij_oznaka_proiz) as nvarchar) AS Informacija
FROM dobavljac_proizvod
WHERE serij_oznaka_proiz NOT LIKE '%[A-Z]'

----------------------------
--7.
----------------------------
/*
a)
Dati informaciju o dužinama podatka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
b)
Dati informaciju o broju različitih dužina podataka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
Poruka treba biti u obliku: 'Kolona serij_oznaka_proiz ima ___ različite dužinr podataka.' Na mjestu donje crte se nalazi izračunati brojčani podatak.
*/
--10 bodova
SELECT serij_oznaka_proiz, 
	   LEN(serij_oznaka_proiz) AS Duzina
FROM dobavljac_proizvod

SELECT 'Kolona serij_oznaka_proiz ima ' + CAST(COUNT(DISTINCT LEN(serij_oznaka_proiz)) AS nvarchar) + ' različite dužine podataka.'
FROM dobavljac_proizvod 

----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača. 
Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/

SELECT COUNT(*) as prebrojano
FROM dobavljac
WHERE LEN(SUBSTRING(naziv_dobavljaca,0, CHARINDEX(' ', naziv_dobavljaca))) < 
	   LEN(SUBSTRING(dobavljac_br_rac,0, CHARINDEX('0', dobavljac_br_rac))) AND CHARINDEX(' ', naziv_dobavljaca) != 0

--10 bodova

----------------------------
--9.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_djeljivi koja će sadržavati parametar prebrojano i kojom će se prebrojati broj pojavljivanja vrijednosti u koloni naruc_kolicina koje su djeljive sa 100. Sortirati po koloni prebrojano. Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost parametra prebrojano = 10
*/
--13 bodova


----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/
--2 boda
backup database Ispit
to disk = 'Ispit.bak'

use master
go 
drop database Ispit

restore database Ispit
from disk = 'Ispit.bak'

use Ispit
go
select *
from dobavljac