-- ===========================================================================================
-- Project: Advanced Sales Report with ROLLUP and Analytics
-- Author: Abhay Kumar
-- Final Internship Project | July 2025
-- ===========================================================================================

-- Drop table if it already exists
IF OBJECT_ID('dbo.Sales') IS NOT NULL DROP TABLE dbo.Sales;

-- Create Sales table
CREATE TABLE dbo.Sales (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductCategory VARCHAR(50),
    ProductName VARCHAR(50),
    SaleAmount DECIMAL(10,2),
    SaleDate DATE
);

-- Insert sample data
INSERT INTO dbo.Sales (ProductCategory, ProductName, SaleAmount, SaleDate) VALUES
('Electronics', 'Laptop', 1000, '2025-07-01'),
('Electronics', 'Phone', 800, '2025-07-02'),
('Electronics', 'Tablet', 500, '2025-07-03'),
('Clothing', 'Shirt', 300, '2025-07-01'),
('Clothing', 'Pants', 400, '2025-07-02'),
('Furniture', 'Sofa', 1200, '2025-07-03'),
('Furniture', 'Bed', 900, '2025-07-04');

-- Declare parameters for dynamic filtering
DECLARE @StartDate DATE = '2025-07-01';
DECLARE @EndDate DATE = '2025-07-31';
DECLARE @CategoryFilter VARCHAR(50) = NULL; -- Example: set to 'Electronics' if you want to filter

-- Option 1: Use CTE followed immediately by SELECT
WITH FilteredSales AS (
    SELECT *
    FROM dbo.Sales
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
      AND (@CategoryFilter IS NULL OR ProductCategory = @CategoryFilter)
)

-- 1️⃣ Main sales report: details + subtotals + grand total
SELECT 
    ISNULL(ProductCategory, 'Total') AS ProductCategory,
    CASE 
        WHEN ProductCategory IS NULL THEN 'Total'
        WHEN ProductName IS NULL THEN 'Total'
        ELSE ProductName
    END AS ProductName,
    SUM(SaleAmount) AS TotalSales
FROM FilteredSales
GROUP BY ROLLUP(ProductCategory, ProductName)
ORDER BY 
    GROUPING(ProductCategory),
    ProductCategory,
    GROUPING(ProductName),
    ProductName;

-- Option 2: reuse data → insert into temp table
SELECT *
INTO #FilteredSales
FROM dbo.Sales
WHERE SaleDate BETWEEN @StartDate AND @EndDate
  AND (@CategoryFilter IS NULL OR ProductCategory = @CategoryFilter);

-- 2️⃣ Analytics per category
SELECT
    ProductCategory,
    COUNT(*) AS NumberOfProducts,
    SUM(SaleAmount) AS TotalSales,
    AVG(SaleAmount) AS AverageSale,
    MIN(SaleAmount) AS MinSale,
    MAX(SaleAmount) AS MaxSale
FROM #FilteredSales
GROUP BY ProductCategory
ORDER BY TotalSales DESC;

-- 3️⃣ Ranking of categories by total sales
;WITH CategoryTotals AS (
    SELECT ProductCategory, SUM(SaleAmount) AS TotalSales
    FROM #FilteredSales
    GROUP BY ProductCategory
)
SELECT
    ProductCategory,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS CategoryRank
FROM CategoryTotals;

-- Drop temp table at the end
DROP TABLE #FilteredSales;

-- ===========================================================================================
-- End of script
-- ===========================================================================================
