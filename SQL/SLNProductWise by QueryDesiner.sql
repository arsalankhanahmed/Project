/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 6/18/2014 11:06:23 AM
 ************************************************************/

DECLARE @FromDate     DATETIME,
        @ToDate       DATETIME,
        @IsCash       BIT,
        @IsCredit     BIT,
        @LocationIds  NVARCHAR(MAX),
        @PBLIds       NVARCHAR(MAX),
        @CustomerIds  NVARCHAR(MAX),
        @MainAreaIds  nvarchar(MAX),
        @SubAreaIds   NVARCHAR(MAX),
        @Product      NVARCHAR(MAX),
        @CompanyId    INT,
        @SaleTpyeIds  VARCHAR(50)

SET @FromDate = '2014-06-01'
SET @ToDate = '2014-06-17'
SET @IsCash = 1
SET @IsCredit = 1

SELECT l.ShortName,
       l.Name,
       l.SequenceId,
       sln.CustomerId,
       ucsa.[Customer Name],
       ucsa.[Sub Area],
       ucsa.[Main Area],
       sln.ProductId,
       up.Name AS ProductName,
       sln.PrincipalBusinessLineId,
       sln.PriceId,
       sln.Quantity,
       pc.TP,
       sln.Quantity * pc.TP AS [TP VALUE],
       sln.SLNId,
       sln.CompanyId
FROM   uv_Sales_SLN AS sln
       INNER JOIN Location AS l
            ON  sln.LocationId = l.LocationId
       INNER JOIN uv_CustomerSalesArea AS ucsa
            ON  sln.CustomerId = ucsa.CustomerId
       INNER JOIN uv_Product AS up
            ON  sln.ProductId = up.ProductId
            AND sln.PrincipalBusinessLineId = up.PrincipalBusinessLineId
       INNER JOIN PriceCatalog AS pc
            ON  sln.PriceId = pc.PriceCatalogId
WHERE  (sln.IsCash = 1 AND @IsCash = 1) OR (sln.IsCash = 0 AND @IsCredit = 1)
       AND (sln.IsRollbacked = 0)
       AND DATEDIFF(d, sln.TransactionDate, @FromDate) >= 0
       AND DATEDIFF(d, sln.TransactionDate, @ToDate) <= 0 
ORDER BY l.SequenceId,ucsa.MainAreaId,ucsa.SubAreaId,ucsa.CustomerId
