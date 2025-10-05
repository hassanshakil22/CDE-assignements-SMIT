
-- Q1 --
SELECT TOP 5 
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(s.TotalAmount) AS TotalSpent
FROM SalesOrder s
JOIN Customer c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC;


-- Q2 --
SELECT 
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT p.ProductID) AS ProductCount
FROM Supplier s
JOIN PurchaseOrder po ON s.SupplierID = po.SupplierID
JOIN PurchaseOrderDetail pod ON po.OrderID = pod.OrderID
JOIN Product p ON pod.ProductID = p.ProductID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(DISTINCT p.ProductID) > 10;


-- Q3 --
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM SalesOrderDetail sod
JOIN Product p ON sod.ProductID = p.ProductID
WHERE p.ProductID NOT IN (
    SELECT DISTINCT rd.ProductID FROM ReturnDetail rd
)
GROUP BY p.ProductID, p.Name;


SELECT 
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM Product p2
    WHERE p2.CategoryID = p.CategoryID
);


SELECT 
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM SalesOrder so
JOIN Customer c ON so.CustomerID = c.CustomerID
JOIN SalesOrderDetail sod ON so.OrderID = sod.OrderID
JOIN Product p ON sod.ProductID = p.ProductID
JOIN Category cat ON p.CategoryID = cat.CategoryID
JOIN PurchaseOrderDetail pod ON p.ProductID = pod.ProductID
JOIN PurchaseOrder po ON pod.OrderID = po.OrderID
JOIN Supplier s ON po.SupplierID = s.SupplierID;


-- Q6 --
SELECT 
    sh.ShipmentID,
    w.WarehouseID,
    w.ContactInfo AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM Shipment sh
JOIN Warehouse w ON sh.WarehouseID = w.WarehouseID
JOIN Employee e ON w.ManagerID = e.EmployeeID
JOIN ShipmentDetail sd ON sh.ShipmentID = sd.ShipmentID
JOIN Product p ON sd.ProductID = p.ProductID;


-- Q7 --
WITH RankedOrders AS (
    SELECT 
        so.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER (PARTITION BY so.CustomerID ORDER BY so.TotalAmount DESC) AS OrderRank
    FROM SalesOrder so
    JOIN Customer c ON so.CustomerID = c.CustomerID
)
SELECT 
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM RankedOrders
WHERE OrderRank <= 3
ORDER BY CustomerID, TotalAmount DESC;




-- Q8 --
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS NextQuantity
FROM SalesOrderDetail sod
JOIN SalesOrder so ON sod.OrderID = so.OrderID
JOIN Product p ON sod.ProductID = p.ProductID
ORDER BY p.ProductID, so.OrderDate;


-- Q9 --
CREATE VIEW vw_CustomerOrderSummary AS
SELECT 
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(DISTINCT so.OrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM Customer c
LEFT JOIN SalesOrder so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name;


-- Q10 --
CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT 
        s.SupplierID,
        s.Name AS SupplierName,
        SUM(sod.TotalAmount) AS TotalSalesAmount
    FROM Supplier s
    JOIN PurchaseOrder po ON s.SupplierID = po.SupplierID
    JOIN PurchaseOrderDetail pod ON po.OrderID = pod.OrderID
    JOIN Product p ON pod.ProductID = p.ProductID
    JOIN SalesOrderDetail sod ON p.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID, s.Name;
END;


