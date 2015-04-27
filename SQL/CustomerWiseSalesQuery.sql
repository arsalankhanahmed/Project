CREATE PROCEDURE usp_Report_CustomerWiseSales @LocationId VARCHAR(200),@PBLId VARCHAR(200),
@FromDate DATETIME,@ToDate DATETIME,
@TPValue DECIMAL,@Discount DECIMAL AS
 
--DECLARE @LocationId VARCHAR(200),@PBLId VARCHAR(200),
--@FromDate DATETIME,@ToDate DATETIME,
--@TPValue DECIMAL,@Discount DECIMAL 

SET @LocationId = '14'
SET @PBLId = '28,3'
SET @FromDate = '01/12/2012'
SET @ToDate = '01/3/2014'
SET @TPValue = 1000.00
SET @Discount = 5.00

SELECT l.SequenceId,ucws.LocationId,l.[Name] AS [Location Name],
	   upbla.PBLSequenceId,ucws.PrincipalBusinessLineId,upbla.[NAME] AS [PBL],
	   ucws.CustomerId,
	   ucws.CustomerName,
	   --ucws.TransactionDate,	   
	   SUM(ucws.SaleValue - ucws.SaleReturnValue) AS [SALES VALUE],
	   SUM(ucws.SaleValue - ucws.SaleReturnValue)*(@Discount/100) AS [DISCOUNT],
	   SUM(
	   		(ucws.SaleValue - ucws.SaleReturnValue)
	   		-
	   		(
	   			(ucws.SaleValue - ucws.SaleReturnValue)*(@Discount/100)
	   		)
	   )AS [AFTER Discount]
FROM 
dbo.uv_CustomerWiseSale ucws
INNER JOIN uv_PrincipalBusinessLine_All upbla ON ucws.PrincipalBusinessLineId = upbla.PrincipalBusinessLineId
INNER JOIN dbo.Location l ON ucws.LocationId = l.LocationId
INNER JOIN Dbo.[Split](@LocationId,',')LOC ON LOC.[Data] = ucws.LocationId OR (@LocationId = '')
INNER JOIN dbo.[Split](@PBLId,',')PBL ON PBL.[Data] =  ucws.PrincipalBusinessLineId OR (@PBLId = '')

WHERE (DATEDIFF(DAY,ucws.TransactionDate,  @FromDate) <= 0 
AND  DATEDIFF(DAY,ucws.TransactionDate,  @ToDate) >= 0)
--and ucws.CustomerId = 6156
GROUP BY l.SequenceId,ucws.LocationId,l.[Name],
	   upbla.PBLSequenceId,ucws.PrincipalBusinessLineId,upbla.[NAME],
	   ucws.CustomerId,
	   ucws.CustomerName
	   --ucws.TransactionDate	   
HAVING Sum(ucws.SaleValue - ucws.SaleReturnValue) >= @TPValue

