DECLARE @FromDate DATETIME, @ToDate DATETIME
SET @FromDate = '2009-12-26 00:00:00.000'--'2013-11-01 00:00:00'
SET @ToDate = '2011-01-01 23:59:59.000'

--/*NO CRITERIA*/
--SELECT * FROM SaleOrder so
--INNER JOIN SaleOrderProduct sop ON sop.LocationId = so.LocationId
--AND sop.SaleOrderId = so.SaleOrderId

--/*DATEDIFF*/
--SELECT * FROM SaleOrder so
--INNER JOIN SaleOrderProduct sop ON sop.LocationId = so.LocationId
--AND sop.SaleOrderId = so.SaleOrderId
--WHERE DATEDIFF(DAY, so.SalePassDate,  @FromDate) <= 0
--AND  DATEDIFF(DAY, so.SalePassDate,  @ToDate) >= 0

/*BETWEEN*/
SELECT * FROM SaleOrder so
INNER JOIN SaleOrderProduct sop ON sop.LocationId = so.LocationId
AND sop.SaleOrderId = so.SaleOrderId
WHERE so.SalePassDate BETWEEN @FromDate AND @ToDate



CHECKPOINT; 
GO 
DBCC DROPCLEANBUFFERS; 
GO
DBCC FREEPROCCACHE
GO
