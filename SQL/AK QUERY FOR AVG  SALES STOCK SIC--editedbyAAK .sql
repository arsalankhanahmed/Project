/************************************************************
 * MUHAMMAD OVAIS KHAN
 * Time: 2/12/2015 12:35:07 PM
 ************************************************************/

DECLARE @CompanyId		   INT,
		@PBLIds            VARCHAR(200),
        @ProductIds        VARCHAR(MAX),
        @LocationIds       VARCHAR(200),
        @FromDate          DATETIME,
        @ToDate            DATETIME,
        @IsConsignment     BIT
        --,
        --@IsCurrentTP       BIT
SET @CompanyId = 1        
SET @PBLIds = '44'--'40,28,59,3'
SET @ProductIds = ''
SET @LocationIds = ''--'11,14,29,17,19,21,12,23,26,28,38,45,15,18,35,42,30,36,37,43,44,22,24,13,16,27,32'
SET @FromDate = '2014-11-01'
--SET @FromDate = '2015-01-01'
SET @ToDate = '2015-01-31'
SET @IsConsignment = 0
--SET @IsCurrentTP = 1


SELECT dsp.LocationId,
       CAST(dsp.TransactionDate AS DATE) [Date],
       dsp.ProductId,
       dsp.PriceId,
       dsp.IsFree,
       SUM(dsp.Closing) [Quantity]
INTO #tmpDSPData
FROM  dbo.fn_MonthEnd_Get_DSPByDateRange(@CompanyId, @LocationIds, @PBLIds, '', @FromDate, @ToDate, @IsConsignment, CASE WHEN @IsConsignment = 1 THEN 0 ELSE 1 END, 1, 1, 0, 0, 0, 0, 0)  DSP
--INNER JOIN dbo.[Split](@ProductIds, ',') fp ON (fp.[Data] = dsp.ProductId OR @ProductIds = '')
INNER JOIN StockType st ON st.StockTypeId = dsp.StockTypeId
WHERE st.IsClaimableToSDN = 0
AND st.IsSystem = 0
GROUP BY dsp.LocationId, CAST(dsp.TransactionDate AS DATE), dsp.ProductId, dsp.PriceId, dsp.IsFree

--SELECT [Product Code],[Product Name],AVG([Sales Value]),AVG([SIC Value]),AVG([Stock Value]) FROM (
SELECT [Product Code],[Product Name],
AVG([Sales Quantity]) [Average Sales Quantity],
AVG([Sales Value]) [Average Sales Value],
AVG([Sales Weight]) [Average Sales Weight],
AVG([SIC Quantity]) [Average SIC Quantity], 
AVG([SIC Value]) [Average SIC Value],
AVG([SIC Weight]) [Average SIC Weight],
AVG([Stock Quantity]) [Average Stock Quantity],
AVG([Stock Value]) [Average Stock Value],
AVG([Stock Weight]) [Average Stock Weight]
FROM (
SELECT 
	   --l.SequenceId,
	   --l.ShortName [Location],
       
	   --up.PBLSequenceId,
    --   up.PBLShortName [PBL],
    --   up.ProductSequence,
       a.ProductId [Product Code],	
       up.[Name] [Product Name],
       DATENAME(MONTH, a.[Date]) + '-' + CONVERT(VARCHAR(12),DATEPART(YEAR, a.[Date])) [Month],
       
       SUM(a.[SalesQuantity]) [Sales Quantity],
       SUM(CASE WHEN a.IsFree = 0 THEN a.[SalesQuantity] * ISNULL(pc.TP, 0) ELSE 0 END) [Sales Value],
       SUM(a.[SalesQuantity] * ISNULL(up.WeightInGm, 0)) [Sales Weight],
       
	   SUM(a.[SICQuantity]) [SIC Quantity],
	   SUM(CASE WHEN a.IsFree = 0 THEN a.[SICQuantity] * ISNULL(pc.PP, 0) ELSE 0 END) [SIC Value],
	   SUM(a.[SICQuantity] * ISNULL(up.WeightInGm, 0)) [SIC Weight],
	   
       SUM(a.[StockQuantity]) [Stock Quantity],
       SUM(CASE WHEN a.IsFree = 0 THEN a.[StockQuantity] * ISNULL(pc.TP, 0) ELSE 0 END) [Stock Value],
       SUM(a.[StockQuantity] * ISNULL(up.WeightInGm, 0)) [Stock Weight]
FROM
(
	/*CLOSING*/
	SELECT --DSP.LocationId,
	       d.[Date] [Date],
	       DSP.ProductId,
	       DSP.PriceId,
	       DSP.IsFree,
	       0 [SalesQuantity],
	       0 [SICQuantity],
	       DSP.Closing [StockQuantity]
	FROM dbo.fn_MonthEnd_Get_OpeningDSP(@CompanyId, @LocationIds, @PBLIds, '', @FromDate, @IsConsignment, CASE WHEN @IsConsignment = 1 THEN 0 ELSE 1 END , 1, 0, 0, 0, 0, 0)  DSP
	--INNER JOIN dbo.[Split](@ProductIds, ',') fp ON (fp.[Data] = dsp.ProductId OR @ProductIds = '')
	CROSS JOIN
	(
		SELECT cd.[Date]
		FROM CalendarDates cd 
		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
	) d

	UNION ALL

	/*CLOSING*/
	SELECT --t1.LocationId,
	       t1.[Date] [Date],
	       t1.ProductId,
	       t1.PriceId,
	       t1.IsFree,
	       0 [SalesQuantity],
	       0 [SICQuantity],
	       t1.Quantity [StockQuantity] 
	FROM #tmpDSPData t1
	
	UNION ALL
	
	/*CLOSING*/
	SELECT --t1.LocationId,
	       d.[Date] [Date],
	       t1.ProductId,
	       t1.PriceId,
	       t1.IsFree,
	       0 [SalesQuantity],
	       0 [SICQuantity],
	       t1.Quantity [StockQuantity]
	FROM 
	(
		SELECT cd.[Date]
		FROM CalendarDates cd 
		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
	) d
	LEFT JOIN #tmpDSPData t1 ON t1.[Date] < d.[Date]
	
	UNION ALL
	
	SELECT
	    --ussl.LocationId,
	    ussl.TransactionDate AS [Date],
		ussl.ProductId,
		ussl.PriceId,
		ussl.IsFree,
		-SUM(ussl.Quantity) [SalesQuantity],
        0 [SICQuantity],
        0 [StockQuantity]
    FROM 
    uv_Sales_SLN ussl
    INNER JOIN PriceCatalog pc ON ussl.PriceId = pc.PriceCatalogId
    INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = ussl.LocationId OR @LocationIds = '')
    INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = ussl.PrincipalBusinessLineId OR @PBLIds = '')
    INNER JOIN   DBO.Split(@ProductIds, ',') Product ON  (Product.Data = ussl.ProductId OR @ProductIds = '')
	WHERE 
	ussl.CompanyId = @CompanyId
	AND DATEDIFF(DAY, ussl.TransactionDate,  @FromDate) <= 0 
	AND DATEDIFF(day, ussl.TransactionDate, @ToDate) >= 0   
	AND @IsConsignment = 0
    GROUP BY 
		ussl.TransactionDate,
		--ussl.LocationId,
		ussl.ProductId,
		ussl.PriceId,
		ussl.IsFree
		
	UNION ALL
		
	SELECT
		--usso.LocationId,
		CAST(usso.SalePassDate AS DATE) AS [Date],
		usso.ProductId,
		usso.PriceId,
		st.IsFree,
		SUM(usso.SoldQuantity) [SalesQuantity],
        0 [SICQuantity],
        0 [StockQuantity]
	FROM uv_Sales_SaleOrder usso
	INNER JOIN StockType st ON st.StockTypeId = usso.StockTypeId
	--INNER JOIN PriceCatalog pc ON usso.PriceId = pc.PriceCatalogId
	--INNER JOIN DBO.Split(@ProductIds, ',') Product ON  (Product.Data = usso.ProductId OR @ProductIds = '')
	INNER JOIN DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
	INNER JOIN DBO.Split(@LocationIds, ',') Location ON  (Location.Data = usso.LocationId OR @LocationIds = '')
	WHERE 
	usso.CompanyId = @CompanyId 
	AND DATEDIFF(DAY, usso.SalePassDate,  @FromDate) <= 0 
	AND DATEDIFF(day, usso.SalePassDate, @ToDate) >= 0  
	AND @IsConsignment = 0 
	GROUP BY 
		CAST(usso.SalePassDate AS DATE),
		--usso.LocationId,
		usso.ProductId,
		usso.PriceId,
		st.IsFree
		
	
	UNION ALL
	
	SELECT
	    --ussl.LocationId,
	    s.TransactionDate AS [Date],
		s2.ProductId,
		s2.PriceId,
		st.IsFree,
		0 [SalesQuantity],
        SUM(s2.Quantity) [SICQuantity],
        0 [StockQuantity]
	FROM SIC s
	INNER JOIN DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = s.PrincipalBusinessLineId OR @PBLIds = '')
	INNER JOIN DBO.Split(@LocationIds, ',') Location ON  (Location.Data = s.LocationId OR @LocationIds = '')
	INNER JOIN SICProduct s2 ON s2.LocationId = s.LocationId
	 AND s2.SICId = s.SICId
	INNER JOIN StockType st ON st.StockTypeId = s2.StockTypeId 
	--INNER JOIN DBO.Split(@ProductIds, ',') Product ON  (Product.Data = usso.ProductId OR @ProductIds = '')
	WHERE s.CompanyId = @CompanyId
	 AND DATEDIFF(DAY, s.TransactionDate,  @FromDate) <= 0 
	 AND DATEDIFF(day, s.TransactionDate, @ToDate) >= 0   
	 AND s.IsRollbacked = 0
	 AND st.IsConsignment = @IsConsignment
	GROUP BY 
		s.TransactionDate,
		s2.ProductId,
		s2.PriceId,
		st.IsFree 
)A
--INNER JOIN Location l ON l.LocationId = a.LocationId
INNER JOIN uv_Product up ON up.ProductId = a.ProductId
--LEFT JOIN
--(
--	SELECT
--	pc.ProductId,
--	pc.PriceCatalogId [PriceId]
--	FROM PriceCatalog pc 
--	INNER JOIN dbo.[Split](@ProductIds, ',') fup ON (fup.[Data] = pc.ProductId OR @ProductIds = '')			
--	WHERE
--		pc.IsDeleted = 0 
--	AND DATEDIFF(day,pc.EffectiveDate,GETDATE())>= 0
--	AND DATEDIFF(day,GETDATE(),ISNULL(pc.EndDate,GETDATE()+1))>0	
--) cp ON cp.ProductId = up.ProductId
LEFT JOIN PriceCatalog pc ON pc.PriceCatalogId = a.PriceId--CASE WHEN @IsCurrentTP = 0 THEN a.PriceId ELSE CP.PriceId END
--WHERE 
--a.LocationId IS NOT NULL
GROUP BY 
a.ProductId,	
up.[Name],
DATENAME(MONTH, a.[Date]) + '-' + CONVERT(VARCHAR(12),DATEPART(YEAR, a.[Date]))
--HAVING (SUM(CASE WHEN a.IsFree = 0 THEN Quantity * pc.TP ELSE 0 END) <> 0)
--ORDER BY --l.SequenceId, 
--a.[Date], 
--up.PBLSequenceId, 
--up.ProductSequence
--)B
--GROUP BY [Product Code],[Product Name]
 
--DROP TABLE #tmpDSPData
) B
GROUP BY 

[Product Code],[Product Name]

DROP TABLE #tmpDSPData