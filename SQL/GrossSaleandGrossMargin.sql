DECLARE @CompanyId INT,@LocationIds NVARCHAR(250),@PBLIds NVARCHAR(500),@ProductIds NVARCHAR(1000),@SelectAll INT,@FromDate DATETIME,@ToDate DATETIME,@SalesCriteria INT 
SET @CompanyId = '1'
SET @LocationIds = '11'
SET @PBLIds = '3'
SET @ProductIds = '172'
SET @FromDate = '2014-04-04'
SET @ToDate = '2014-04-15'
SET @SalesCriteria = 2
SET @SelectAll = 1
/*0-Gross Sale
* 1-Net Sale
* 2-SLN
* */	  

	----------------------------SALE---------------------------
	SELECT
	usso.LocationId,
	l.ShortName AS [Location Name],
	--up.PBLSequenceId,
	usso.PrincipalBusinessLineId,
	up.PBLShortName,
	--up.ProductSequence,
	--usso.SaleOrderId, 
	usso.ProductId,
	up.[Name] AS [Product Name],
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity) - SUM(ussln.[SLNQuantity])
		 WHEN @SalesCriteria=2 THEN -SUM(ussln.[SLNQuantity])
	END 
	AS [Sale Qty],	
	pc.PP,
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity * pc.PP)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity * pc.PP)- SUM(ussln.[SLNQuantity] * pc.PP)
		 WHEN @SalesCriteria=2 THEN -SUM(ussln.[SLNQuantity] * pc.PP)
	END 
	AS [PPValue],	
	pc.TP,
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity * pc.TP)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity * pc.TP) - SUM(ussln.[SLNQuantity] * pc.TP)
		 WHEN @SalesCriteria=2 THEN -sum(ussln.[SLNQuantity] * pc.TP)
	END 
	AS [TPValue]
	INTO TEMPSale
FROM uv_Sales_SaleOrder usso
--INNER JOIN SaleOrderTax sot ON usso.LocationId = sot.LocationId AND usso.SaleOrderId = sot.SaleOrderId
INNER JOIN uv_Product up ON usso.ProductId = up.ProductId 
INNER JOIN PriceCatalog pc ON usso.PriceId = pc.PriceCatalogId
INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = usso.LocationId OR @LocationIds = '')
INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
INNER JOIN   DBO.Split(@ProductIds, ',') Product ON  (Product.Data = usso.ProductId OR @LocationIds = '')
INNER JOIN Location l ON usso.LocationId = l.LocationId

	WHERE (  @SelectAll = 0	  
		   OR  (@SelectAll = 1 AND ( DATEDIFF(DAY, usso.SalePassDate,  @FromDate) = 0 ))
		   OR  (@SelectAll = 2 AND ( DATEDIFF(DAY, usso.SalePassDate,  @FromDate) <= 0 AND DATEDIFF(day, usso.SalePassDate, @ToDate) >= 0 ))   
		  )  
		  AND usso.SalePassDate IS NOT NULL
		  AND usso.IsRollbacked  = 0

	GROUP BY 
	l.ShortName,
	l.SequenceId,
	usso.LocationId,
	up.PBLSequenceId,
	usso.PrincipalBusinessLineId, 
	up.PBLShortName,
	--usso.SaleOrderId,
	up.ProductSequence,
	usso.ProductId,
	up.[Name],
	pc.PP,
	pc.TP
	
ORDER BY 
	l.SequenceId,
	up.PBLSequenceId,
	up.ProductSequence  



/*
	SELECT SUM(Quantity) FROM uv_Sales_SLN usso  WHERE usso.LocationId = 11 AND usso.ProductId = 172 
	SELECT sum(SOLDQUANTITY) FROM uv_Sales_SaleOrder usso  WHERE usso.LocationId = 11 AND usso.ProductId = 172 AND usso.SalePassDate BETWEEN '2014-04-04' AND '2014-04-05'
*/	
	
SELECT
	usso.LocationId,
	l.ShortName AS [Location Name],
	--up.PBLSequenceId,
	usso.PrincipalBusinessLineId,
	up.PBLShortName,
	--up.ProductSequence,
	--usso.SaleOrderId, 
	usso.ProductId,
	up.[Name] AS [Product Name],
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity) - SUM(ussln.[SLNQuantity])
		 WHEN @SalesCriteria=2 THEN -SUM(ussln.[SLNQuantity])
	END 
	AS [Sale Qty],	
	pc.PP,
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity * pc.PP)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity * pc.PP)- SUM(ussln.[SLNQuantity] * pc.PP)
		 WHEN @SalesCriteria=2 THEN -SUM(ussln.[SLNQuantity] * pc.PP)
	END 
	AS [PPValue],	
	pc.TP,
	CASE WHEN @SalesCriteria=0 THEN sum(usso.SoldQuantity * pc.TP)
		 WHEN @SalesCriteria=1 THEN sum(usso.SoldQuantity * pc.TP) - SUM(ussln.[SLNQuantity] * pc.TP)
		 WHEN @SalesCriteria=2 THEN -sum(ussln.[SLNQuantity] * pc.TP)
	END 
	AS [TPValue]
FROM uv_Sales_SLN ussl
GROUP BY 
				ussl.LocationId,
				ussl.PrincipalBusinessLineId,
				ussl.ProductId


	
