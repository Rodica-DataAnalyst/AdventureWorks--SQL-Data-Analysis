
Task 1 — Produse active cu preț definit și dată de început validă
📌 Cerință: Afișează ProductID, Name și ListPrice pentru produsele care:
●	au preț > 0
●	sunt active 
●	au dată de început definită 


select * from Production.product ;

select ProductID , Name , ListPrice 
from Production.Product
where ListPrice>0 and SellStartDate is not null and SellEndDate is null ;


Task 2 — Produse cu nume lung, preț mare și cod definit
📌 Cerință: Afișează ProductID, Name, LEN(Name), ListPrice și ProductNumber pentru produsele care:
●	au nume mai lung de 20 caractere
●	au preț mare
●	au ProductNumber definit 


select * from production.Product ;

select ProductID , Name , LEN(Name) as lungime_numar ,ListPrice ,ProductNumber
from production.product 
where ListPrice > (select avg(ListPrice ) from production.Product) 
      and len(Name)>20 
      and ProductNumber is not null ; 


Task 3 — Produse ordonate după preț, filtrate pe status și dată
📌 Cerință: Afișează ProductID, Name și ListPrice pentru produsele care:
●	sunt scoase la vânzare (SellStartDate, SellEndDate) 
●	nu sunt retrase (DiscontinuedDate)
●	au preț între 500 și 1500


select * from production.Product ;

select ProductID , Name , ListPrice 
from production.product
where SellStartDate is not null and SellEndDate is null 
    and DiscontinuedDate is null
    and ListPrice between 500 and 1500
order by ListPrice  ;


Task 4 — Subcategorii cu cel puțin 10 produse, fără NULL și cu preț mediu peste 300
📌 Cerință: Afișează SubcategoryName și COUNT(ProductID) pentru subcategoriile care:
●	au cel puțin 10 produse
●	au produse cu ListPrice definit
●	au preț mediu > 300


select * from production.product ;  --pp
select * from Production.ProductSubcategory;   --pps

select pps.name as nume_subcategorie ,
       count(pp.productID) as nr_produse , 
       avg(pp.ListPrice) as pret_mediu
from production.Product pp
join Production.ProductSubcategory pps
 on pp.ProductSubcategoryID = pps.ProductSubcategoryID
where pp.ListPrice is not null
group by pps.name 
having count(pp.productID) >=10 and avg(pp.ListPrice) > 300
order by pret_mediu desc;



Task 5 — Produse filtrate pe preț, dată și subcategorie
📌 Cerință: Afișează ProductID, Name, ListPrice și SubcategoryName pentru produsele care:
●	au ListPrice > 750
●	au SellStartDate între 2020 și 2024
●	aparțin unei subcategorii care conține „Bike”


select * from production.product ;  --pp
select * from production.ProductSubcategory; --pps

select pp.ProductID ,pp.Name as nume_produs,  pp.ListPrice , pps.Name as nume_subcategorie 
from production.product pp
join Production.ProductSubcategory pps
 on pp.ProductSubcategoryID =pps.ProductSubcategoryID 
where pp.SellStartDate between '2020-01-01' and  '2024-12-31' 
    and pps.name like '%Bike%'
    and pp.ListPrice >750 ;


  Task 6 — Produse din două subcategorii (UNION) cu filtrare
📌 Cerință: Afișează ProductID, Name și SubcategoryName pentru produsele din 'Mountain Bikes' și 'Road Bikes' care:
●	au preț > 500
●	sunt active (sunt scoase la vânzare din ex 3)
●	au cod de produs care începe cu 'BK'


    select * from production.ProductSubcategory; --pps
    select * from production.Product ;   --pp 

    select pp.ProductID , 
           pp.Name as nume_produs ,
           pps.name as nume_subcategorie ,
           pp.ListPrice 
    from production.product pp
    join production.ProductSubcategory pps
     on pp.productSubcategoryId = pps.ProductSubcategoryID 
    where pps.name ='Mountain Bikes' 
      and pp.ListPrice >500
      and pp.SellStartDate is not null
      and pp.SellEndDate is null 
      and pp.ProductNumber like 'BK%'
    union all
    select pp.ProductID , pp.Name as nume_produs ,pps.name as nume_subcategorie ,pp.ListPrice
    from Production.product pp
    join production.ProductSubcategory pps
     on pp.productSubcategoryId = pps.ProductSubcategoryID 
    where pps.name ='Road Bikes' 
      and pp.ListPrice >500 
      and pp.SellStartDate is not null 
      and pp.SellEndDate is null 
      and pp.ProductNumber like 'BK%' ;



Task 7 — Clasificarea produselor pe subcategorie (RANK)
📌 Cerință: Afișează ProductID, Name, SubcategoryName, ListPrice și rangul produsului în funcție de preț, 
pentru produse:
●	cu preț > 100
●	care au subcategorie definită
●	care nu sunt retrase


select * from production.Product ;  --pp
select * from production.ProductSubcategory ;  --pps

select pp.productID, 
       pp.name as nume_produs, 
       pps.name as nume_subcategorie ,
       pp.ListPrice ,
       rank() over (partition by pps.name order by pp.listPrice) as clasificare_produs
from Production.Product pp
join Production.ProductSubcategory pps
  on pp.ProductSubcategoryID =pps.ProductSubcategoryID
where pp.ListPrice >100 
  and pps.ProductSubcategoryID is not null  
  and pp.DiscontinuedDate is  null 
  order by pp.ListPrice ,nume_subcategorie ;


  Task 8 — Produse peste media subcategoriei (subinterogare corelată)
📌 Cerință: Afișează produsele care:
●	au ListPrice > media subcategoriei
●	sunt active
●	au preț definit


select * from production.ProductSubcategory ; --pps
select * from production.Product ;   --pp

 select avg(ListPrice) from Production.Product ; --media pret produse


select pp.productID , pp.name as nume_produs , avg(pp.ListPrice) as media_subcateg
from production.product pp
join Production.ProductSubcategory pps
 on pp.ProductSubcategoryID = pps.ProductSubcategoryID
where pp.ListPrice > (select avg(pp.ListPrice) from Production.Product pp)
 and pp.SellStartDate is not null and pp.ListPrice is not null 
group by pp.ProductID , pp.name 
order by media_subcateg ;
  
  
select * from production.ProductSubcategory ; --pps
select * from production.Product ;   --pp

select pp.productID , pp.name as nume_produs , pp.ListPrice , pp.ProductSubcategoryID
from production.Product pp
where pp.listPrice > (select AVG(pp1.ListPrice) as media_subcateg
                      from Production.Product pp1
                      where pp.ProductSubcategoryID = pp1.ProductSubcategoryID
                      and pp1.ListPrice is not null)
and pp.listPrice is not null 
and pp.SellEndDate is  null ;

 
 Task 9 — Evoluția valorii comenzilor per client (SUM OVER)
📌 Cerință: Afișează CustomerID, OrderDate, TotalDue și suma cumulată pentru clienții:
●	care au plasat comenzi după 2023
●	cu TotalDue > 100
●	care nu sunt NULL

 
 select * from sales.SalesOrderHeader ;

 select CustomerID , OrderDate ,  TotalDue,
        sum(TotalDue) over (partition by CustomerId order by OrderDate) as suma_cumulata 
 from sales.SalesOrderHeader
 where TotalDue >100 and OrderDate >= '2023-01-01' 
       and TotalDue is not null 
       and CustomerID is not null 
 order by customerID ;



Task 10 — Clienți care au plasat comenzi (EXISTS)
📌 Cerință: Afișează CustomerID și AccountNumber pentru clienții care:
●	au cel puțin o comandă
●	sunt persoane fizice (PersonID IS NOT NULL)
●	au AccountNumber definit


select * from sales.Customer ; --sc
select * from sales.SalesOrderHeader ; --soh 


select sc.CustomerID , sc.AccountNumber 
from sales.Customer sc 
where exists (select 1 from sales.SalesOrderHeader soh  
              where sc.CustomerID =soh.CustomerID)
and sc.PersonID is not null 
and sc.AccountNumber is not null ;



Task 11 — CTE: Top 5 produse vândute în ultimele 6 luni disponibile.
cerinta : foloseste CTE pt a calcula cantitatea totala vanduta per produs in ultimile 6 luni disponibile si afiseaza top 5.

select * from Production.Product ; --pp
select * from sales.SalesOrderDetail ; --sod
select * from sales.SalesOrderHeader ;  --soh

with cte as (
select pp.ProductID , 
       pp.name as nume_produs ,
       sum(sod.OrderQty) as cantit_totala 
from Production.Product pp
join Sales.SalesOrderDetail sod
 on pp.ProductID = sod.ProductID 
join Sales.SalesOrderHeader soh 
 on sod.SalesOrderID =soh.SalesOrderID
where soh.orderDate >= DATEADD(MONTH ,-6, (select MAX(orderDate) from Sales.SalesOrderHeader))
group by pp.ProductID ,pp.name  )

select top 5  *
from cte 
order by cantit_totala desc; 



Task 12 — JOIN complex: Detalii comenzi + client + nume + adresă
📌 Cerință: Afișează SalesOrderID, OrderDate, TotalDue, numele complet al clientului și orașul, pentru comenzi:
●	plasate după 2023
●	cu TotalDue > 500
●	de la clienți persoane fizice


select * from sales.SalesOrderHeader ;  --soh    comenzi
select * from Sales.Customer ;  --sc            client 
select * from Person.person ;  --pp   nume client
 
select * from person.BusinessEntityAddress ;  --pbea   (legatura adresa)
select * from Person.Address ; --pa   adresa 



 select  soh.SalesOrderID, 
         soh.OrderDate ,
         soh.TotalDue, 
         concat(pp.FirstName, ' ', pp.LastName) as Nume_Complet,
         pa.City 
 from Sales.SalesOrderHeader soh
 join Sales.Customer sc 
  on soh.CustomerID = sc.CustomerID 
join Person.Person pp
  on sc.PersonID = pp.BusinessEntityID 
 join Person.BusinessEntityAddress pbea 
  on pbea.BusinessEntityID = pp.BusinessEntityID 
join Person.Address pa 
 on pbea.AddressID =pa.AddressID
 where  soh.OrderDate >= '2023-01-01' and soh.TotalDue >500 ; 





Task 13 — CTE: Evoluția lunară a vânzărilor
📌 Cerință: Folosește CTE pentru a calcula totalul vânzărilor pe lună în anul 2023 și afișează luna, anul și 
suma totală(3 coloane).


select * from sales.salesOrderDetail ;
select * from sales.salesOrderHeader ;

with total_vanzari_pe_luna  as (
select year(OrderDate) as an , 
       month(OrderDate)as luna , 
       sum(TotalDue) as suma_totala 
from sales.SalesOrderHeader
group by  year(OrderDate) , month(OrderDate))

select an,luna,suma_totala
from total_vanzari_pe_luna 
where an =2023
order by luna ;



Task 14 — CTE + JOIN: Produse vândute și categoria lor
📌 Cerință: Folosește CTE pentru a calcula cantitatea totală vândută per produs. 
Apoi afișează numele produsului, cantitatea și categoria.


select * from Production.Product ;  --pp
select * from Sales.SalesOrderDetail ;  --sod

select * from Production.ProductSubcategory ; --pps
select * from Production.ProductCategory ; --ppc 

with CTE as (
SELECT pp.productID ,pp.name , sum(sod.OrderQty) as cantitate_totala 
from Production.Product pp
join Sales.SalesOrderDetail sod 
 on pp.ProductID =sod.productID 
group by pp.productID ,pp.name )

select CTE.name as nume_produs ,
       CTE.cantitate_totala ,
       ppc.name as nume_categorie 
from CTE
join production.product pp 
 on CTE.ProductID =pp.ProductID 
join Production.ProductSubcategory pps
 on pp.ProductSubcategoryID = pps.ProductSubcategoryID
join Production.ProductCategory ppc
 on pps.ProductCategoryID =ppc.ProductCategoryID 
order by CTE.cantitate_totala ;


Task 15 — CTE: Clienți cu valoare medie a comenzilor online peste 1000  
📌 Cerință: Afișează CustomerID și valoarea medie a comenzilor online pentru clienții care au o medie > 1000.    TotalDue

select * from sales.Customer ;         --sc 
select * from sales.SalesOrderHeader ;  --soh 

with CTE as (
select sc.customerID , 
       avg(soh.TotalDue) as valoare_medie_comenzi 
from Sales.Customer sc 
join Sales.SalesOrderHeader soh 
 on sc.CustomerID =soh.CustomerID
where soh.OnlineOrderFlag =1
group by sc.CustomerID )

select CustomerID ,
       valoare_medie_comenzi
from cte 
where valoare_medie_comenzi > 1000 
order by valoare_medie_comenzi ;



Task 16 — DML: Adaugă un produs de test
📌 Cerință: Inserează un produs fictiv în tabelul Production.Product cu valori minime necesare cu ProductNumber = 'TEST-001'.

select * from production.Product ;

EXEC sp_help 'Production.Product' ; 

select 
  COLUMN_NAME ,
  IS_NULLABLE 
from INFORMATION_SCHEMA.columns 
where TABLE_NAME = 'Product'
and TABLE_SCHEMA = 'Production'
and IS_NULLABLE ='NO' ;

insert into Production.Product( 
   Name , 
   ProductNumber ,  
   MakeFlag, 
   FinishedGoodsFlag,
   SafetyStockLevel,
   ReorderPoint, 
   StandardCost ,
   ListPrice , 
   DaysToManufacture ,
   SellStartDate,
   ModifiedDate)
values ('New Product', 
        'TEST-001',
         1,
         1,
         1000,
         200,
         108.99,
         133.34,
         4,
        GETDATE(),
        GETDATE()
        );

select * from Production.product ;

✅ Task 17 — DML: Actualizează prețul produsului de test
📌 Cerință: Modifică ListPrice pentru produsul cu ProductNumber = 'TEST-001'.

select * from Production.product 
where ProductNumber = 'TEST-001' ;

update Production.Product 
set ListPrice =150.34
where ProductNumber ='TEST-001' ;

select * from Production.product 



Task 18 — DDL: Creează un tabel pentru import de produse (minim 6 coloane)
📌 Cerință:  Creează un tabel nou numit dbo.ImportProduseProiect cu minim 6 coloane 
si inserează 10 linii de date în acesta 

create table dbo.ImportProduseProiect ( ProductID int primary key identity(1,1) ,
                                        Name varchar(100) not null ,
                                        Stoc_Produs int ,
                                        Pret decimal(10,2),
                                        Furnizor varchar(100),
                                        Categorie varchar(100) 
                                        Data_Vanzare date) ;

 select * from dbo.ImportProduseProiect ;   
 
 insert into dbo.ImportProduseProiect(Name , Stoc_Produs , Pret , Furnizor, Categorie , Data_Vanzare )
 values 
 ('Laptop', 100, 4500, 'Dell', 'Electronice', '2026-01-23'),
 ('Tastatura' , 103 ,145.99 ,'HP', 'Accesorii ','2026-02-20'),
 ('Mouse', 300 , 75.99 , 'HP' ,'Accesorii' , '2025-12-22'),
 ('Monitor' ,150 ,999.99 , 'Samsung ','Electronice ' ,'2025-12-03'),
 ('Casti ',50 ,250.99 ,'Apple','Audio' ,'2025-11-05') ,
 ('Telefon ', 100 , 3500 ,'Apple','Electronice', '2026-02-24'),
 ('Scanner',50 , 350.99 ,'Samsung' ,NULL, NULL);

 insert into dbo.ImportProduseProiect(Name , Stoc_Produs , Pret , Furnizor, Categorie , Data_Vanzare )
 values 
 ('Imprimanta', 120 ,550.89 ,'Samsung' , 'Office', '2026-01-15'),
 ('Boxe ', 150 ,205.99 , 'Sony','Audio', '2026-02-06') ,
 ('Camera Web ', 25 ,249.99 , 'Sony' ,'Accesorii' ,'2026-03-23');

 update dbo.ImportProduseProiect 
 set Categorie ='necunoscut '
 where Categorie is null ; 
 











                                        

                                        





















