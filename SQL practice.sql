

--1.1--
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName,
    p.LastName,
    e.HireDate
FROM 
    HumanResources.Employee e
JOIN 
    Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE 
    e.HireDate > '2012-01-01'
ORDER BY 
    e.HireDate DESC;

--1.2--
SELECT 
    ProductID,
    Name,
    ListPrice,
    ProductNumber
FROM 
    Production.Product
WHERE 
    ListPrice BETWEEN 100 AND 500
ORDER BY 
    ListPrice ASC;

 --1.3--

    SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.City
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
WHERE 
    a.City IN ('Seattle', 'Portland');

 --1.4--
    SELECT TOP 15 
    pr.Name,
    pr.ListPrice,
    pr.ProductNumber,
    pc.Name AS Category
FROM Production.Product pr
JOIN Production.ProductSubcategory ps ON pr.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pr.SellEndDate IS NULL
ORDER BY pr.ListPrice DESC;


--2--
--2.1--
SELECT 
    ProductID,
    Name,
    Color,
    ListPrice
FROM Production.Product
WHERE Name LIKE '%Mountain%'
  AND Color = 'Black';
  --2.2--
  SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    e.BirthDate,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate BETWEEN '1970-01-01' AND '1985-12-31';

  --2.3--
  SELECT 
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
  AND MONTH(OrderDate) IN (10, 11, 12);

  --2.3--
  SELECT 
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
  AND MONTH(OrderDate) IN (10, 11, 12);

  --2.4--
  SELECT 
    ProductID,
    Name,
    Weight,
    Size,
    ProductNumber
FROM Production.Product
WHERE Weight IS NULL
  AND Size IS NOT NULL;

  --3--
  --3.1--
  SELECT 
    pc.Name AS Category,
    COUNT(p.ProductID) AS ProductCount
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY ProductCount DESC;

  --3.2--
  SELECT 
    ps.Name AS Subcategory,
    AVG(p.ListPrice) AS AvgListPrice,
    COUNT(*) AS ProductCount
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.Name
HAVING COUNT(*) > 5;

  --3.3--
  SELECT TOP 10
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

  --3.4--
  SELECT 
    DATENAME(MONTH, OrderDate) AS MonthName,
    SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

--4--
--4.1--
DECLARE @LaunchYear INT;

SELECT @LaunchYear = YEAR(SellStartDate)
FROM Production.Product
WHERE Name = 'Mountain-100 Black, 42';

SELECT 
    ProductID,
    Name,
    SellStartDate,
    YEAR(SellStartDate) AS LaunchYear
FROM Production.Product
WHERE YEAR(SellStartDate) = @LaunchYear;

--4.2--
SELECT 
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.HireDate,
    COUNT(*) OVER(PARTITION BY e.HireDate) AS HiresOnSameDay
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate IN (
    SELECT HireDate
    FROM HumanResources.Employee
    GROUP BY HireDate
    HAVING COUNT(*) > 1
)
ORDER BY e.HireDate;

--5--
--5.1--
CREATE TABLE Sales.ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATE DEFAULT GETDATE(),
    ReviewText NVARCHAR(MAX),
    VerifiedPurchase BIT DEFAULT 0,
    HelpfulVotes INT DEFAULT 0 CHECK (HelpfulVotes >= 0),
    CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
    CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID),
    CONSTRAINT UQ_Product_Customer UNIQUE (ProductID, CustomerID)
);

--6--
--6.1--
ALTER TABLE Production.Product
ADD LastModifiedDate DATETIME DEFAULT GETDATE();
--6.2--
CREATE NONCLUSTERED INDEX IX_Person_LastName
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);

--6.3--
ALTER TABLE Production.Product
ADD CONSTRAINT CK_ListPrice_StandardCost CHECK (ListPrice > StandardCost);

--7--
--7.1--
INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchase, HelpfulVotes)
VALUES
(707, 11000, 5, 'Excellent quality, highly recommended!', 1, 12),
(709, 11001, 3, 'Average performance, acceptable value.', 1, 5),
(710, 11002, 1, 'Poor product, not satisfied at all.', 0, 0);

--7.2--
INSERT INTO Production.ProductCategory (Name)
VALUES ('Electronics');
INSERT INTO Production.ProductSubcategory (Name, ProductCategoryID)
VALUES ('Smartphones', 
       (SELECT ProductCategoryID FROM Production.ProductCategory WHERE Name = 'Electronics'));

--7.3--
SELECT *
INTO Sales.DiscontinuedProducts
FROM Production.Product
WHERE SellEndDate IS NOT NULL;

--8--
--8.1--
UPDATE Production.Product
SET ModifiedDate = GETDATE()
WHERE ListPrice > 1000
  AND SellEndDate IS NULL;

--8.2--
UPDATE p
SET ListPrice = ListPrice * 1.15,
    ModifiedDate = GETDATE()
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';

--8.3--
UPDATE HumanResources.Employee
SET JobTitle = 'Senior ' + JobTitle
WHERE HireDate < '2010-01-01';

--9--
--9.1--
DELETE FROM Sales.ProductReviews
WHERE Rating = 1 AND HelpfulVotes = 0;

--9.2--
DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail s
    WHERE s.ProductID = Production.Product.ProductID
);

--9.3--
DELETE p
FROM Purchasing.PurchaseOrderHeader p
JOIN Purchasing.Vendor v ON p.VendorID = v.BusinessEntityID
WHERE v.ActiveFlag = 0;

--10--
--10.1--
SELECT 
    YEAR(OrderDate) AS SalesYear,
    SUM(TotalDue) AS TotalSales,
    AVG(TotalDue) AS AvgOrderValue,
    COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

--10.2--
SELECT 
    CustomerID,
    COUNT(SalesOrderID) AS TotalOrders,
    SUM(TotalDue) AS TotalAmount,
    AVG(TotalDue) AS AvgOrderValue,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

--10.3--
SELECT TOP 20
    p.Name AS ProductName,
    c.Name AS Category,
    SUM(sd.OrderQty) AS TotalQuantity,
    SUM(sd.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sd
JOIN Production.Product p ON sd.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY p.Name, c.Name
ORDER BY TotalRevenue DESC;

--10.4--
WITH MonthlySales AS (
    SELECT 
        DATENAME(MONTH, OrderDate) AS MonthName,
        MONTH(OrderDate) AS MonthNumber,
        SUM(TotalDue) AS MonthlyTotal
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
), YearlyTotal AS (
    SELECT SUM(MonthlyTotal) AS YearTotal
    FROM MonthlySales
)
SELECT 
    m.MonthName,
    m.MonthlyTotal,
    CAST(100.0 * m.MonthlyTotal / y.YearTotal AS DECIMAL(5,2)) AS PercentageOfYear
FROM MonthlySales m
CROSS JOIN YearlyTotal y
ORDER BY m.MonthNumber;

--11--
--11.1--
SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
    FORMAT(e.HireDate, 'MMM dd, yyyy') AS FormattedHireDate,
    DATENAME(MONTH, e.BirthDate) AS BirthMonth
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

--11.2--
SELECT 
    UPPER(LastName) + ', ' + 
    UPPER(LEFT(FirstName, 1)) + LOWER(SUBSTRING(FirstName, 2, LEN(FirstName))) + ' ' +
    UPPER(LEFT(MiddleName, 1)) + '.' AS FormattedName,
    RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) AS EmailDomain
FROM Person.Person p
JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID;

--11.3--
SELECT 
    Name,
    ROUND(Weight, 1) AS WeightKg,
    ROUND(Weight * 2.20462, 1) AS WeightLbs,
    CASE 
        WHEN Weight IS NOT NULL AND Weight > 0 THEN ListPrice / (Weight * 2.20462)
        ELSE NULL
    END AS PricePerPound
FROM Production.Product;


--12--
--12.1--
SELECT 
    p.Name AS ProductName,
    c.Name AS Category,
    sc.Name AS Subcategory,
    v.Name AS VendorName
FROM Production.Product p
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID;

--12.2--
SELECT 
    soh.SalesOrderID,
    pp.FirstName + ' ' + pp.LastName AS CustomerName,
    sp.FirstName + ' ' + sp.LastName AS SalespersonName,
    st.Name AS TerritoryName,
    pr.Name AS ProductName,
    sod.OrderQty,
    sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
LEFT JOIN Sales.SalesPerson s ON soh.SalesPersonID = s.BusinessEntityID
LEFT JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID;

--12.3--
SELECT 
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.JobTitle,
    t.Name AS TerritoryName,
    t.[Group] AS TerritoryGroup,
    s.SalesYTD
FROM Sales.SalesPerson s
JOIN HumanResources.Employee e ON s.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p ON s.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesTerritory t ON s.TerritoryID = t.TerritoryID;


--13--
--13.1--
SELECT 
    p.Name AS ProductName,
    c.Name AS Category,
    ISNULL(SUM(sod.OrderQty), 0) AS TotalQtySold,
    ISNULL(SUM(sod.LineTotal), 0) AS TotalRevenue
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY p.Name, c.Name;

--13.2--
SELECT 
    t.Name AS TerritoryName,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    sp.SalesYTD
FROM Sales.SalesTerritory t
LEFT JOIN Sales.SalesPerson sp ON t.TerritoryID = sp.TerritoryID
LEFT JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID;

--13.3--
SELECT 
    v.Name AS VendorName,
    c.Name AS CategoryName
FROM Purchasing.Vendor v
LEFT JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
LEFT JOIN Production.Product p ON pv.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID

UNION

SELECT 
    NULL AS VendorName,
    c.Name AS CategoryName
FROM Production.ProductCategory c
LEFT JOIN Production.ProductSubcategory sc ON c.ProductCategoryID = sc.ProductCategoryID
LEFT JOIN Production.Product p ON sc.ProductSubcategoryID = p.ProductSubcategoryID
LEFT JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
WHERE pv.ProductID IS NULL;


--14--
--14.1--
SELECT 
    ProductID,
    Name,
    ListPrice,
    ListPrice - (SELECT AVG(ListPrice) FROM Production.Product WHERE ListPrice > 0) AS PriceDifference
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product WHERE ListPrice > 0);

--14.2--
SELECT 
    pp.FirstName + ' ' + pp.LastName AS CustomerName,
    COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
    SUM(sod.LineTotal) AS TotalAmountSpent
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON sc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name LIKE '%Mountain%'
GROUP BY pp.FirstName, pp.LastName;

--14.3--
SELECT 
    p.Name AS ProductName,
    pc.Name AS Category,
    COUNT(DISTINCT soh.CustomerID) AS UniqueCustomerCount
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON sc.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY p.Name, pc.Name
HAVING COUNT(DISTINCT soh.CustomerID) > 100;

--14.4--
SELECT 
    c.CustomerID,
    pp.FirstName + ' ' + pp.LastName AS CustomerName,
    COUNT(soh.SalesOrderID) AS OrderCount,
    RANK() OVER (ORDER BY COUNT(soh.SalesOrderID) DESC) AS CustomerRank
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
GROUP BY c.CustomerID, pp.FirstName, pp.LastName;


--15--
--15.1--
ALTER VIEW vw_ProductCatalog AS
SELECT 
    p.ProductID,
    p.Name,
    p.ProductNumber,
    pc.Name AS Category,
    psc.Name AS Subcategory,
    p.ListPrice,
    p.StandardCost,
    CAST(((p.ListPrice - p.StandardCost) / NULLIF(p.StandardCost, 0)) * 100 AS decimal(10,2)) AS ProfitMarginPercentage,
    p.SafetyStockLevel AS InventoryLevel,
    CASE 
        WHEN p.SellEndDate IS NULL THEN 'Active' 
        ELSE 'Discontinued' 
    END AS Status
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID;


--15.2--
CREATE VIEW vw_SalesAnalysis AS
SELECT 
    YEAR(soh.OrderDate) AS SalesYear,
    MONTH(soh.OrderDate) AS SalesMonth,
    st.Name AS Territory,
    SUM(soh.TotalDue) AS TotalSales,
    COUNT(soh.SalesOrderID) AS OrderCount,
    AVG(soh.TotalDue) AS AvgOrderValue,
    (
        SELECT TOP 1 p.Name
        FROM Sales.SalesOrderDetail sd
        JOIN Production.Product p ON sd.ProductID = p.ProductID
        WHERE sd.SalesOrderID = soh.SalesOrderID
        ORDER BY sd.LineTotal DESC
    ) AS TopProduct
FROM Sales.SalesOrderHeader soh
LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), st.Name;

--15.3--
CREATE VIEW vw_EmployeeDirectory AS
SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    e.JobTitle,
    d.Name AS Department,
    pm.FirstName + ' ' + pm.LastName AS ManagerName,
    e.HireDate,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
    ea.EmailAddress,
    pp.PhoneNumber
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
LEFT JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
LEFT JOIN Person.Person pm ON m.BusinessEntityID = pm.BusinessEntityID
LEFT JOIN Person.EmailAddress ea ON e.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON e.BusinessEntityID = pp.BusinessEntityID
WHERE edh.EndDate IS NULL;

--15.4--
USE AdventureWorks2022;
GO
CREATE VIEW vw_ProductCatalog AS
SELECT 
    p.ProductID,
    p.Name,
    p.ProductNumber,
    pc.Name AS Category,
    psc.Name AS Subcategory,
    p.ListPrice,
    p.StandardCost,
    CAST(((p.ListPrice - p.StandardCost) / NULLIF(p.StandardCost, 0)) * 100 AS decimal(10,2)) AS ProfitMarginPercentage,
    p.SafetyStockLevel AS InventoryLevel,
    CASE 
        WHEN p.SellEndDate IS NULL THEN 'Active' 
        ELSE 'Discontinued' 
    END AS Status
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID;

SELECT TOP 5 *
FROM vw_ProductCatalog;


--16--
--16.1--
SELECT 
    CASE 
        WHEN ListPrice > 500 THEN 'Premium'
        WHEN ListPrice BETWEEN 100 AND 500 THEN 'Standard'
        ELSE 'Budget'
    END AS PriceCategory,
    COUNT(*) AS ProductCount,
    AVG(ListPrice) AS AvgPrice
FROM Production.Product
GROUP BY 
    CASE 
        WHEN ListPrice > 500 THEN 'Premium'
        WHEN ListPrice BETWEEN 100 AND 500 THEN 'Standard'
        ELSE 'Budget'
    END;

--16.2--
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 10 THEN 'Veteran'
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 5 THEN 'Experienced'
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 2 THEN 'Regular'
        ELSE 'New'
    END AS ServiceLevel,
    COUNT(*) AS EmployeeCount,
    AVG(p.Rate) AS AvgSalary
FROM HumanResources.Employee e
JOIN HumanResources.EmployeePayHistory p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 10 THEN 'Veteran'
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 5 THEN 'Experienced'
        WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 2 THEN 'Regular'
        ELSE 'New'
    END;

--16.3--
SELECT 
    CASE 
        WHEN TotalDue > 5000 THEN 'Large'
        WHEN TotalDue BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Small'
    END AS OrderSize,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS PercentageDistribution
FROM Sales.SalesOrderHeader
GROUP BY 
    CASE 
        WHEN TotalDue > 5000 THEN 'Large'
        WHEN TotalDue BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Small'
    END;


--17--
--17.1--
SELECT 
    Name,
    ISNULL(CAST(Weight AS VARCHAR), 'Not Specified') AS Weight,
    ISNULL(Size, 'Standard') AS Size,
    ISNULL(Color, 'Natural') AS Color
FROM Production.Product;

--17.2--
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS Name,
    COALESCE(ea.EmailAddress, ph.PhoneNumber, a.AddressLine1) AS BestContact
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone ph ON p.BusinessEntityID = ph.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address a ON bea.AddressID = a.AddressID;

--17.3--
SELECT * 
FROM Production.Product
WHERE (Weight IS NULL AND Size IS NOT NULL)
   OR (Weight IS NULL AND Size IS NULL);


--18--
--18.1--
WITH EmpHierarchy AS (
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmployeeName,
        NULL AS ManagerID,
        0 AS HierarchyLevel,
        CAST(p.FirstName + ' ' + p.LastName AS VARCHAR(MAX)) AS Path
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.OrganizationNode.GetLevel() = 0

    UNION ALL

    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName,
        m.BusinessEntityID,
        eh.HierarchyLevel + 1,
        eh.Path + ' > ' + p.FirstName + ' ' + p.LastName
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
    JOIN EmpHierarchy eh ON m.BusinessEntityID = eh.BusinessEntityID
)
SELECT * FROM EmpHierarchy;

--18.2--
SELECT 
    p.Name,
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) AS Sales2013,
    SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) AS Sales2014,
    CASE 
        WHEN SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) = 0 THEN NULL
        ELSE ROUND(
            (SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) -
             SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)) * 100.0 /
             SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END), 2)
    END AS GrowthPercent,
    CASE 
        WHEN SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) > 
             SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
            THEN 'Growth'
        WHEN SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) < 
             SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
            THEN 'Decline'
        ELSE 'Stable'
    END AS GrowthCategory
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(soh.OrderDate) IN (2013, 2014)
GROUP BY p.Name;


--19--
--19.1--
SELECT 
    Territory,
    ISNULL([2012], 0) AS Sales2012,
    ISNULL([2013], 0) AS Sales2013,
    ISNULL([2014], 0) AS Sales2014
FROM (
    SELECT 
        st.Name AS Territory,
        YEAR(soh.OrderDate) AS SalesYear,
        soh.TotalDue AS SalesAmount
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
) AS SourceTable
PIVOT (
    SUM(SalesAmount) FOR SalesYear IN ([2012], [2013], [2014])
) AS PivotTable
ORDER BY Territory;

--19.2--
SELECT 
    ProductName,
    ISNULL([1], 0) AS Jan,
    ISNULL([2], 0) AS Feb,
    ISNULL([3], 0) AS Mar,
    ISNULL([4], 0) AS Apr,
    ISNULL([5], 0) AS May,
    ISNULL([6], 0) AS Jun,
    ISNULL([7], 0) AS Jul,
    ISNULL([8], 0) AS Aug,
    ISNULL([9], 0) AS Sep,
    ISNULL([10], 0) AS Oct,
    ISNULL([11], 0) AS Nov,
    ISNULL([12], 0) AS Dec
FROM (
    SELECT 
        p.Name AS ProductName,
        MONTH(soh.OrderDate) AS OrderMonth
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
) AS SourceTable
PIVOT (
    COUNT(OrderMonth) FOR OrderMonth IN ([1], [2], [3], [4], [5], [6],
                                         [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY ProductName;

--19.3--
SELECT 
    DepartmentName,
    ISNULL([M], 0) AS MaleCount,
    ISNULL([F], 0) AS FemaleCount
FROM (
    SELECT 
        d.Name AS DepartmentName,
        e.Gender
    FROM HumanResources.Employee e
    JOIN HumanResources.EmployeeDepartmentHistory edh 
        ON e.BusinessEntityID = edh.BusinessEntityID
        AND edh.EndDate IS NULL  
    JOIN HumanResources.Department d 
        ON edh.DepartmentID = d.DepartmentID
    WHERE e.Gender IN ('M', 'F')  
) AS src
PIVOT (
    COUNT(Gender) FOR Gender IN ([M], [F])
) AS pvt
ORDER BY DepartmentName;



--20--
--20.1--
WITH ProductSales AS (
    SELECT 
        pc.Name AS Category,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSales
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name, p.Name
),
RankedSales AS (
    SELECT *,
           RANK() OVER (PARTITION BY Category ORDER BY TotalSales DESC) AS rnk
    FROM ProductSales
)
SELECT * FROM RankedSales WHERE rnk <= 5;


--21.1--
SELECT 
    soh.CustomerID,
    soh.SalesOrderID,
    soh.TotalDue,
    AVG(soh.TotalDue) OVER (PARTITION BY soh.CustomerID) AS AvgOrderAmount,
    soh.TotalDue - AVG(soh.TotalDue) OVER (PARTITION BY soh.CustomerID) AS Deviation
FROM Sales.SalesOrderHeader soh;

--22.1--
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--23.1--
SELECT DISTINCT 
c.CustomerID, pp.FirstName + ' ' + pp.LastName AS CustomerName
FROM Sales.Customer c
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE c.CustomerID NOT IN (
    SELECT CustomerID 
    FROM Sales.SalesOrderHeader
    WHERE OrderDate >= DATEADD(YEAR, -2, GETDATE())
);

--24.1--
SELECT 
    c.CustomerID,
    pp.FirstName + ' ' + pp.LastName AS CustomerName,
    COUNT(soh.SalesOrderID) AS TotalOrders,
    SUM(soh.TotalDue) AS TotalSpent,
    MAX(soh.OrderDate) AS LastOrderDate
FROM Sales.Customer c
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, pp.FirstName, pp.LastName;

--25.1--
SELECT 
    ProductID,
    Name,
    SafetyStockLevel,
    ReorderPoint,
    CASE 
        WHEN SafetyStockLevel > ReorderPoint THEN 'Reorder Recommended'
        ELSE 'Sufficient Stock'
    END AS Recommendation
FROM Production.Product;


--26.1--
WITH CategorySales AS (
    SELECT 
        pc.Name AS Category,
        ps.Name AS Subcategory,
        SUM(sod.LineTotal) AS SubcategorySales
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name, ps.Name
),
TotalSales AS (
    SELECT SUM(SubcategorySales) AS Total FROM CategorySales
)
SELECT 
    cs.Category,
    cs.Subcategory,
    cs.SubcategorySales,
    ROUND(cs.SubcategorySales * 100.0 / ts.Total, 2) AS PercentOfTotal
FROM CategorySales cs
CROSS JOIN TotalSales ts
ORDER BY cs.Category, cs.Subcategory;
