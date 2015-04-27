/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 5/19/2014 11:42:15 AM
 ************************************************************/

DECLARE @CompanyId      INT,
        @LocationIds    NVARCHAR(MAX),
        @PBLIds         NVARCHAR(MAX),
        @SelectAll      INT,
        @FromDate       DATETIME,
        @ToDate         DATETIME,
        @IsConsignment  BIT,
        @IsCommercial   BIT,
        @StockTypeIds   NVARCHAR(MAX)
 
SET @CompanyId = '1'
SET @LocationIds = '11'
SET @PBLIds = '28'
SET @StockTypeIds = ''
SET @SelectAll = '0'
SET @FromDate = ''
SET @ToDate = ''
SET @IsConsignment = ''
SET @IsCommercial = 1
  
SELECT ussl.LocationId,
       ussl.PrincipalBusinessLineId ,
       ussl.ProductId,
       -SUM(ussl.Quantity) [SoldQuantity],
       0 GRNQuantity
       --ussl.TransactionDate AS [Date]
FROM   uv_Sales_SLN ussl
       INNER JOIN PriceCatalog pc
            ON  ussl.PriceId = pc.PriceCatalogId
       INNER JOIN DBO.Split(@PBLIds, ',') PBL
            ON  (PBL.Data = ussl.PrincipalBusinessLineId OR @PBLIds = '')
       INNER JOIN DBO.Split(@LocationIds, ',') Location
            ON  (Location.Data = ussl.LocationId OR @LocationIds = '')
WHERE  @CompanyId = ussl.CompanyId
       AND (
               @SelectAll = 0
               OR (
                      @SelectAll = 1
                      AND (DATEDIFF(DAY, ussl.TransactionDate, @FromDate) = 0)
                  )
               OR (
                      @SelectAll = 2
                      AND (
                              DATEDIFF(DAY, ussl.TransactionDate, @FromDate) <=
                              0
                              AND DATEDIFF(DAY, ussl.TransactionDate, @ToDate) >
                                  = 0
                          )
                  )
           )
GROUP BY
       ussl.LocationId,
       ussl.PrincipalBusinessLineId,
       ussl.ProductId,
       ussl.TransactionDate


UNION ALL

SELECT usso.LocationId,
       usso.PrincipalBusinessLineId ,
       usso.ProductId,
       SUM(usso.SoldQuantity) [SoldQuantity],
       0 GRNQuantity
       --usso.SalePassDate AS [Date]
FROM   uv_Sales_SaleOrder usso
       INNER JOIN DBO.Split(@PBLIds, ',') PBL
            ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
       INNER JOIN DBO.Split(@LocationIds, ',') Location
            ON  (Location.Data = usso.LocationId OR @LocationIds = '')
WHERE  @CompanyId = usso.CompanyId
       AND (
               @SelectAll = 0
               OR (
                      @SelectAll = 1
                      AND (DATEDIFF(DAY, usso.SalePassDate, @FromDate) = 0)
                  )
               OR (
                      @SelectAll = 2
                      AND (
                              DATEDIFF(DAY, usso.SalePassDate, @FromDate) <= 0
                              AND DATEDIFF(DAY, usso.SalePassDate, @ToDate) >= 0
                          )
                  )
           )
GROUP BY
       usso.LocationId,
       usso.PrincipalBusinessLineId,
       usso.ProductId,
       usso.SalePassDate

UNION ALL   
 
SELECT g.LocationId,
       G.PrincipalBusinessLineId,
       gp.GRNProductId AS ProductId,
       0 SoldQuantity,
       gp.QuantityReceived AS GRNQuantity--,g.TransactionDate
FROM   GRN g
       INNER JOIN DBO.Split(@LocationIds, ',') l
            ON  (l.Data = g.LocationId OR @LocationIds = '')
       INNER JOIN DBO.Split(@PBLIds, ',') pbl
            ON  (pbl.Data = g.PrincipalBusinessLineId OR @PBLIds = '')
       INNER JOIN GRNProduct gp
            ON  gp.GRNId = g.GRNId
            AND gp.LocationId = g.LocationId
WHERE  @CompanyId = g.CompanyId
       AND (
               @SelectAll = 0
               OR (
                      @SelectAll = 1
                      AND (DATEDIFF(DAY, g.TransactionDate, @FromDate) = 0)
                  )
               OR (
                      @SelectAll = 2
                      AND (
                              DATEDIFF(DAY, g.TransactionDate, @FromDate) <= 0
                              AND DATEDIFF(DAY, g.TransactionDate, @ToDate) >= 0
                          )
                  )
           )
       AND g.IsRollbacked = 0
			
			
