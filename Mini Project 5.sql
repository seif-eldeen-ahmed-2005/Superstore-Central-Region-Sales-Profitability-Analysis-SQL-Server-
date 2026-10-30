create database CentralSuperstore;
Use CentralSuperstore;
---------------------------------------------------------------------
-- Parts 1, 2, and 3: Dataset Analysis & Database Design - Relational Table Creation - Data Import & Population
-- Creating & Populating Dimension Tables
-- 1. Customer Dimension
CREATE TABLE DimCustomer (
    CustomerID VARCHAR(50) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Segment VARCHAR(50));

-- 2. Product Dimension
CREATE TABLE DimProduct (
    ProductID VARCHAR(50) PRIMARY KEY,
    ProductName VARCHAR(255),
    Category VARCHAR(100),
    SubCategory VARCHAR(100));

-- 3. Geography Dimension
CREATE TABLE DimGeography (
    PostalCode VARCHAR(20) PRIMARY KEY,
    Country VARCHAR(100),
    Region VARCHAR(100),
    State VARCHAR(100),
    City VARCHAR(100),);

-- 4. Order Dimension
CREATE TABLE DimOrder (
    OrderID VARCHAR(50) PRIMARY KEY,
    ShipMode VARCHAR(50));

-- 5. Date Dimension
CREATE TABLE DimDate (
    OrderDate DATE PRIMARY KEY,
    CalendarYear SMALLINT,
    CalendarQuarter TINYINT,
    MonthNumber TINYINT,
    MonthName VARCHAR(20),
    DayNumber TINYINT);
---------------------------------------------------------------------
-- Importing Data from Excel Into dbo.StagingSuperstore
-- Checking the Data 
SELECT COUNT(*) AS TotalRows
FROM dbo.StagingSuperstore;

SELECT TOP 10 *
FROM dbo.StagingSuperstore;
---------------------------------------------------------------------
-- Populate dimension tables
-- 1.Populate Customer Dimension
INSERT INTO dbo.DimCustomer (CustomerID, CustomerName, Segment)
SELECT DISTINCT CustomerID, CustomerName, Segment
FROM dbo.StagingSuperstore;
select * from DimCustomer;

-- 2.Populate Product Dimension
INSERT INTO dbo.DimProduct (ProductID, ProductName, Category, SubCategory)
SELECT DISTINCT [ProductID], [ProductName], Category, [Sub-Category]
FROM dbo.StagingSuperstore;
select * from DimProduct; 
-- Editing DimProducts after found different product name with the same product id
ALTER TABLE dbo.DimProduct
DROP CONSTRAINT PK__DimProdu__B40CC6ED27147FE2;
ALTER TABLE dbo.DimProduct
ALTER COLUMN ProductName NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.DimProduct
ADD CONSTRAINT PK_DimProduct
PRIMARY KEY (ProductName);
Alter table dbo.DimProduct
drop column ProductID;

Select * from DimProduct;

INSERT INTO dbo.DimProduct ( ProductName, Category, SubCategory)
SELECT DISTINCT [ProductName], Category, [Sub-Category]
FROM dbo.StagingSuperstore;

-- 3.Populate Geography Dimension
INSERT INTO dbo.DimGeography (PostalCode, Region, Country, State, City)
Select Distinct PostalCode, Region, Country, State,City
From dbo.StagingSuperstore;
select * from DimGeography;

-- 4. Populate Orders Dimension
INSERT INTO dbo.DimOrder (OrderID, ShipMode)
Select Distinct OrderID, ShipMode 
From dbo.StagingSuperstore;
select * from DimOrder;

-- 5. Populate Date Dimension
INSERT Into dbo.DimDate (OrderDate)
Select Distinct OrderDate
From dbo.StagingSuperstore;
select * from DimDate;

Update dbo.DimDate
Set  CalendarYear = YEAR(OrderDate),
     CalendarQuarter = DATEPART(QUARTER, OrderDate),
     MonthNumber = MONTH(OrderDate),
     MonthName = DATENAME(MONTH, OrderDate),
     DayNumber = DAY(OrderDate);
---------------------------------------------------------------------
-- Creating Sales Fact Table
CREATE TABLE FactSales (
    RowID INT PRIMARY KEY,

    OrderID VARCHAR(50) NOT NULL,
    CustomerID VARCHAR(50) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    PostalCode VARCHAR(20) NOT NULL,
    OrderDate DATE NOT NULL,
    ShipDate DATE NOT NULL,
    Sales DECIMAL(12,2),
    Profit DECIMAL(12,2),
    Quantity INT,
    Discount DECIMAL(5,4),

    CONSTRAINT FK_FactSales_Order
        FOREIGN KEY (OrderID)
        REFERENCES DimOrder(OrderID),

    CONSTRAINT FK_FactSales_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES DimCustomer(CustomerID),

    CONSTRAINT FK_FactSales_Product
        FOREIGN KEY (ProductName)
        REFERENCES DimProduct(ProductName),

    CONSTRAINT FK_FactSales_Geography
        FOREIGN KEY (PostalCode)
        REFERENCES DimGeography(PostalCode),

    CONSTRAINT FK_FactSales_OrderDate
        FOREIGN KEY (OrderDate)
        REFERENCES DimDate(OrderDate)); 

-- Populating Sales Fact Table
INSERT INTO dbo.FactSales ( RowID, OrderID, CustomerID, ProductName, PostalCode, OrderDate, ShipDate, Sales, Profit, Quantity, Discount)
SELECT RowID, OrderID, CustomerID, ProductName, PostalCode, OrderDate, ShipDate, Sales, Profit, Quantity, Discount
FROM dbo.StagingSuperstore;

Select * From FactSales;
---------------------------------------------------------------------
-- Parts 4 and 5: SQL Query Development - Advanced SQL Analysis
-- 1. Overall Sales Performance
select
Count(Distinct OrderID) as No_of_Orders,
Sum(Sales) as Total_Sales,
Sum(Profit) as Total_Profit,
Sum(Quantity) as Sold_Quantity
From FactSales;

-- 2. Annual Sales Performance
select
D.CalendarYear,
Count(Distinct F.OrderID) as No_of_Orders,
Sum(F.Sales) as Total_Sales,
Sum(F.Profit) as Total_Profit
From FactSales as F
Inner Join DimDate as D
on F.OrderDate = D.OrderDate
Group by D.CalendarYear
Order by D.CalendarYear;

-- 3. Monthly Sales Trend
select
D.CalendarYear,
D.MonthNumber,
D.MonthName,
Sum(F.Sales) as Total_Sales,
Sum(F.Profit) as Total_Profit
From FactSales as F
Inner Join DimDate as D
on F.OrderDate = D.OrderDate
Group by D.CalendarYear, D.MonthNumber, D.MonthName
Order by D.CalendarYear, D.MonthNumber;

-- 4. Sales by Product Category
select P.Category, Sum(F.Sales) as Total_Sales, SUM(F.Quantity) as Sold_Quantity
From FactSales as F
inner join DimProduct as P
on F.ProductName = P.ProductName
Group by P.Category
Order by Total_Sales desc;

-- 5. Customer Segment Analysis
select C.Segment, COUNT(distinct F.CustomerID) as No_of_Customers, COUNT(distinct F.OrderID) as No_of_Orders, 
Sum(F.Sales) as Total_Sales,
Sum(F.Profit) as Total_Profit
From FactSales as F
Inner Join DimCustomer as C
on F.CustomerID = C.CustomerID 
Group by C.Segment
Order by Total_Sales; 

-- 6. Which states generate the highest sales?
select G.State, Sum(F.Sales) as Total_Sales, Sum(F.Profit) as Total_Profit
From FactSales as F
Left Join DimGeography as G
on F.PostalCode = G.PostalCode
Group by G.State
Order by Total_Sales desc;

-- 7. Which cities are most profitable?
select G.City, Sum(F.Profit) as Total_Profit, Sum(F.Sales) as Total_Sales
From FactSales as F
Left Join DimGeography as G
on F.PostalCode = G.PostalCode
Group by G.City
Order by Total_Profit desc;

-- 8. Loss-Making Products
select ProductName, Sum(Profit) as Total_Profit, Sum(Sales) as Total_Sales, SUM(Quantity) as Sold_Quantity
From FactSales
Group by ProductName
Having Sum(Profit)<0
Order by Total_Profit asc;

-- 9. Classify products as High Profit, Medium Profit, or Low Profit
select ProductName, Sum(Profit) as Total_Profit, Sum(Sales) as Total_Sales,
case when Sum(Profit)<=0 then 'Low Profit'
     when Sum(Profit)<1000 then ' Medium Profit'
     Else 'High Profit'
end as Profit_Classification
From FactSales
Group by ProductName;

-- 10. Products with profit higher than average
select ProductName, COUNT(distinct OrderID) as No_of_Orders,
Sum(Sales) as Total_Sales, SUM(Quantity) as Sold_Quantity
From FactSales
where Profit>(select AVG(profit) from FactSales)
Group by ProductName
Order by Total_Sales desc;

-- 11. States performing below average
WITH StateSales AS (SELECT
G.State, SUM(F.Sales) AS TotalSales
FROM dbo.FactSales AS F
INNER JOIN dbo.DimGeography AS G
ON F.PostalCode = G.PostalCode
GROUP BY G.State)
SELECT State, TotalSales
FROM StateSales
WHERE TotalSales < (SELECT AVG(TotalSales) FROM StateSales)
ORDER BY TotalSales ASC;

-- 12. Top 10 Products by sales
select Top 10
ProductName, Sum(Profit) as Total_Profit, concat(round(Sum(Sales)/1000,1),'K') as Total_Sales, SUM(Quantity) as Sold_Quantity
from FactSales
Group by ProductName
Order by Total_Sales desc;

-- 13. Product Ranking Within Each Category
WITH ProductSales AS (SELECT P.Category, F.ProductName, SUM(F.Sales) AS TotalSales, SUM(F.Profit) AS TotalProfit
FROM dbo.FactSales AS F
INNER JOIN dbo.DimProduct AS P
ON F.ProductName = P.ProductName
GROUP BY P.Category, F.ProductName),
RankedProducts AS (SELECT Category, ProductName, TotalSales, TotalProfit,
RANK() OVER (
PARTITION BY Category
ORDER BY TotalSales DESc) AS SalesRank
FROM ProductSales)
SELECT Category, ProductName, TotalSales, TotalProfit, SalesRank
FROM RankedProducts
WHERE SalesRank <= 3
ORDER BY Category, SalesRank;

-- 14. Categorize States by Sales Performance
WITH StateSales AS (SELECT G.State, SUM(F.Sales) AS TotalSales
FROM dbo.FactSales AS F
INNER JOIN dbo.DimGeography AS G
ON F.PostalCode = G.PostalCode
GROUP BY G.State)
SELECT State, TotalSales,
CASE WHEN TotalSales < AVG(TotalSales) OVER () THEN 'Below Average'
     ELSE 'Average or Above Average'
END AS SalesPerformance
FROM StateSales
ORDER BY TotalSales DESC;

-- 15. KPI's
SELECT
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS TotalQuantity,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    CAST(
        SUM(Sales) * 1.0 /
        NULLIF(COUNT(DISTINCT OrderID), 0)
        AS DECIMAL(18,2)
    ) AS AverageSalesPerOrder,
    CAST(
        100.0 * SUM(Profit) /
        NULLIF(SUM(Sales), 0)
        AS DECIMAL(10,2)
    ) AS ProfitMarginPercent
FROM dbo.FactSales;