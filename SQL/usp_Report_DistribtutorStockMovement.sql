/************************************************************
 Report Code: R216
 Report Name: Distributor Stock Movement 
 Report Type: Excel 
 M.Ovais Khan (DTL)
 A.Ahmed Khan (JSE)
 * Time: 8/21/2014 10:39:39 AM
 ************************************************************/
--DECLARE drop PROC usp_Report_DistributorStockMovement
CREATE PROC usp_Report_DistributorStockMovement 
@PBLIds VARCHAR(MAX),@DateCriteria INT,@FromDate DATETIME,@ToDate DATETIME,@IsConsignment BIT
AS
--DECLARE @PBLIds VARCHAR(MAX),@DateCriteria INT,@FromDate DATETIME,@ToDate DATETIME,@IsConsignment BIT
--SET @PBLIds = '3'
--SET @DateCriteria = 2
--SET @FromDate = '20140601'
--SET @ToDate = '20140630'
--SET @IsConsignment = 0


/* TABLE-1: SALE --------------------------------------------------------------------------------*/
SELECT a.PrincipalBusinessLineId AS [PBLId],
	   up.PBLShortName AS [PBL],
	   CONVERT(DATE,[DATE],101) AS [DATE],
	   l.ShortName+'-'+convert(VARCHAR(6),a.CustomerId)+'-'+c.[Name] AS [ACCOUNT],
	   a.ProductId AS [UDL SKU CODE],
	   up.PrincipalProductCode AS [PBL SKU CODE],
	   Convert(VARCHAR(6),a.ProductId)+'-'+up.[Name] AS [SKU DESCRIPTION],
	   SUM(CONVERT(INT,[QUANTITY SOLD])) AS [QUANTITY SOLD],
	   SUM(CONVERT(INT,[QUANTITY BONUS])) AS [QUANTITY BONUS],
	   SUM([VALUE]) [VALUE], 
	   SUM([OTHER])[OTHER]
FROM(
	   SELECT so.LocationId,
	   CONVERT(date,so.SalePassDate,101) AS [DATE],
	   so.CustomerId,
	   sop.PrincipalBusinessLineId,
	   sop.ProductId ,
	   case when st.IsFree = 0 THEN sop.SoldQuantity else 0 end AS [QUANTITY SOLD],
	   case when st.IsFree = 1 THEN sop.SoldQuantity else 0 end AS [QUANTITY BONUS],
	   sop.SoldQuantity*sop.TP AS [VALUE],
	   0 AS [OTHER]
FROM   SaleOrder so
       INNER JOIN SaleOrderProduct sop
            ON  so.LocationId = sop.LocationId
            AND so.SaleOrderId = sop.SaleOrderId 
              INNER JOIN dbo.[Split](@PBLIds,',')pbl ON pbl.[Data] = sop.PrincipalBusinessLineId OR @PBLIds = ''
       INNER JOIN StockType st ON st.StockTypeId = sop.StockTypeId 
       
       
WHERE DATEDIFF(DAY,@FromDate,so.SalePassDate)>=0 AND DATEDIFF(DAY,so.SalePassDate,@ToDate)>=0 
AND so.SalePassDate IS NOT NULL AND sop.SoldQuantity>0
AND sop.EndDate IS NULL 

UNION ALL 

SELECT so.LocationId,  
Convert(date,so.SalePassDate,101) AS [DATE],
	   so.CustomerId,
	   s.PrincipalBusinessLineId,
	   s.AppliedProductId AS ProductId,
	   0 AS [QUANTITY SOLD],
	   soc.BonusQuantity AS [QUANTITY BONUS],
	   0 AS [VALUE],
	   0 AS [OTHER]
FROM  SaleOrder so 
INNER JOIN  SaleOrderScheme soc
ON  so.LocationId = soc.LocationId
and so.SaleOrderId = soc.SaleOrderId
INNER JOIN SCHEME s ON s.SchemeId = soc.SchemeId
INNER JOIN dbo.[Split](@PBLIds,',')pbl ON pbl.[Data] = s.PrincipalBusinessLineId

WHERE soc.BonusQuantity>0 AND DATEDIFF(DAY,@FromDate,so.SalePassDate)>=0 AND DATEDIFF(DAY,so.SalePassDate,@ToDate)>=0 
AND s.EndDate IS NULL 
 

UNION ALL 

SELECT s.LocationId, 
	   s.TransactionDate AS [DATE],
	   s.CustomerId,
	   s.PrincipalBusinessLineId,
	   sp.ProductId ,
	   0 AS [QUANTITY SOLD],
	   0 AS [QUANTITY BONUS],
	   0 AS [VALUE],
	   convert(int,sp.Quantity) AS [OTHER]
FROM   SLN s
       INNER JOIN SLNProduct sp
            ON  s.LocationId = sp.LocationId
            AND s.SLNId = sp.SLNId
       INNER JOIN dbo.[Split](@PBLIds,',')pbl ON (pbl.[Data] = s.PrincipalBusinessLineId OR @PBLIds = '')
WHERE  DATEDIFF(DAY,@FromDate,s.TransactionDate)>=0 AND DATEDIFF(DAY,s.TransactionDate,@ToDate)>=0
and sp.Quantity>0 AND s.IsRollbacked = 0
) a
INNER JOIN Location l ON l.LocationId = a.locationId
INNER JOIN customer c ON c.LocationId = a.locationId AND c.CustomerId = a.CustomerId
INNER JOIN uv_product up ON up.ProductId = a.ProductId

GROUP BY 
[DATE],
l.SequenceId,
l.ShortName,
a.CustomerId,
c.[Name],
a.PrincipalBusinessLineId,
up.PBLShortName,
up.PBLSequenceId,
up.ProductSequence,
a.ProductId,
up.[Name],
up.PrincipalProductCode
ORDER BY 
[Date],
l.SequenceId,
a.CustomerId,
up.PBLSequenceId,
up.ProductSequence
/* TABLE-2: STOCK --------------------------------------------------------------------------------*/
--SELECT DSP.LocationId, dsp.TransactionDate [Date], DSP.ProductId,SUM(DSP.Closing) [Quantity],SUM(DSP.INTRAN) INTRAN
--INTO #tmpDSPData
--FROM  dbo.fn_MonthEnd_Get_DSPByDateRange(-1, '', @PBLIds, '', @FromDate, @ToDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 1, 0, 0, 1, 0, 0)  DSP
--GROUP BY DSP.LocationId, dsp.TransactionDate, DSP.ProductId, DSP.StockTypeId, DSP.BatchNumber
--DECLARE @PBLIDs VARCHAR(MAX) = '40',@FromDate DATETIME = '20140601' ,@ToDate DATETIME ='20140630',@IsConsignment BIT = 0
SELECT  dsp.LocationId,
 dsp.ProductId, 
 sum(dsp.Opening) OPENING, 
 sum(dsp.Closing) CLOSING,
 SUM(dsp.GRNPurCon) AS RECEIPTS,
 -SUM(dsp.GRNClaim) AS [RETURNS],
 sum(dsp.INTRAN) INTRAN
INTO #tmpDSPData
FROM  dbo.fn_MonthEnd_Get_ClosingDSP(-1, '', @PBLIds, '', @FromDate, @ToDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 1, 0, 0, 1, 0, 0)  dsp
GROUP BY DSP.LocationId, DSP.ProductId, DSP.StockTypeId, DSP.BatchNumber
--SELECT it.LocationId,
--       CAST(it.TransactionDate AS DATE) [Date],
--       it.ProductId,
--       SUM(it.IN_TRAN) INTRAN
--INTO #TempInTran       
--FROM dbo.fn_DSP_Get_InTransit(-1, '', @PBLIds, '', @ToDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 0, 0, 0) it
--INNER JOIN StockType st ON st.StockTypeId = it.StockTypeId
--CROSS JOIN
--	(
--		SELECT cd.[Date]
--		FROM CalendarDates cd 
--		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
--		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
--	) d
--WHERE st.IsClaimableToSDN = 0
--AND st.IsSystem = 0
--GROUP BY it.LocationId, CAST(it.TransactionDate AS DATE), it.ProductId

--SELECT LocationId, [Date], ProductId,  SUM(Opening) Opening, SUM(Quantity) Closing,SUM(INTRAN) INTRAN
--INTO #tmpDSPWithHolidays
--FROM
--(
--	SELECT DSP.LocationId, d.[Date], DSP.ProductId, dsp.Closing as Opening , DSP.Closing Quantity,DSP.INTRAN
--	FROM dbo.fn_MonthEnd_Get_OpeningDSP(-1, '', @PBLIds, '', @FromDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 0, 0, 1, 0, 0)  DSP
--	CROSS JOIN
--	(
--		SELECT cd.[Date]
--		FROM CalendarDates cd 
--		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
--		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
--	) d
--	UNION ALL

--	SELECT t1.LocationId, t1.[Date], t1.ProductId, 0 Opening, t1.Quantity,T1.INTRAN
--	FROM #tmpDSPData t1
	
--	UNION ALL
	
--	SELECT t1.LocationId, d.[Date], t1.ProductId, t1.Quantity Opening,t1.Quantity,T1.INTRAN
--	FROM 
--	(
--		SELECT cd.[Date]
--		FROM CalendarDates cd 
--		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
--		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
--	) d
--	LEFT JOIN #tmpDSPData t1 ON t1.[Date] < d.[Date]	
--)A
--WHERE a.LocationId IS NOT NULL
----WHERE dbo.fn_Holiday_Check_IsHolidayOrWeekEnd(A.[Date], A.LocationId) = 0
--GROUP BY LocationId, [Date], ProductId


--SELECT d.*
--INTO #tmpDSP
--FROM #tmpDSPWithHolidays d
--INNER JOIN
--(
--	SELECT t.LocationId, t.Date
--	FROM (SELECT DISTINCT LocationId FROM #tmpDSPWithHolidays) d
--	CROSS APPLY dbo.fn_WeekDay_Get_HolidayOrWeekDay(@FromDate, @ToDate, d.LocationId, 1) t
--) w ON w.LocationId = d.LocationId 
-- AND w.Date = d.Date
 


SELECT 
	   Convert(Date,@ToDate,101) AS [DATE],
       UP.PrincipalBusinessLineId AS [PBLId],
       up.PBLShortName AS [PBL],
       STK.ProductId [UDL SKU CODE],
       up.PrincipalProductCode [PBL SKU CODE],
       CONVERT(VARCHAR,stk.ProductId)+'-'+ up.[Name] [SKU DESCRIPTION],
       SUM(STK.Opening) OPENING,
       SUM(STK.Closing) CLOSING,
       SUM(stk.RECEIPTS) AS RECEIPTS,
       SUM(stk.[RETURNS]) AS [RETURNS],
       SUM(stk.INTRAN) AS INTRANSIT
       FROM(

SELECT --up.PrincipalBusinessLineId,
       --t.[Date] [Date],
       t.ProductId,
       t.Opening,
       t.Closing,
       t.RECEIPTS ,
       t.[RETURNS] AS [RETURNS],
       t.INTRAN
FROM #tmpDSPData t
--INNER JOIN uv_Product up ON   up.ProductId = t.ProductId
--GROUP BY  t.ProductId--, t.[Date]

UNION ALL 

SELECT --cc.PrincipalBusinessLineId,
	   --CAST(cc.CounterClaimPassDate AS DATE) [Date],
	   ccs.ProductId, 
	   0 Opening,
       0 Closing,
	   0 AS RECEIPTS,
	   SUM(ccs.ClaimQuantity) [RETURNS],
	   0 INTRAN    
FROM CounterClaim cc 
INNER JOIN CounterClaimStock ccs 
ON cc.LocationId = ccs.LocationId 
AND cc.CounterClaimId = ccs.CounterClaimId 
INNER JOIN dbo.[Split](@PBLIds,',')pbl ON (pbl.Data = cc.PrincipalBusinessLineId OR @PBLIds = '')
WHERE cc.CounterClaimPassDate IS NOT NULL 
AND DATEDIFF(DAY,@FromDate,cc.CounterClaimPassDate)>=0 
AND DATEDIFF(DAY,cc.CounterClaimPassDate,@ToDate)>=0
GROUP BY CCS.ProductId--, CAST(cc.CounterClaimPassDate AS DATE)


--UNION ALL 

--SELECT  [Date],
--		ProductId, 
--	    SUM(0) Opening,
--        SUM(0) Closing, 
--        SUM(0) AS RECEIPTS,
--		SUM(Intran) INTRANSIT 
--FROM (
--SELECT t1.locationId, t1.[Date], t1.ProductId,  t1.INTRAN 
--	FROM #TempInTran t1
--	WHERE DATEDIFF(DAY, @FromDate, t1.[Date]) >= 0
--	AND DATEDIFF(DAY, @ToDate, t1.[Date]) <= 0
		
--	UNION ALL

--	SELECT t1.locationId, d.[Date], t1.ProductId,(t1.INTRAN) INTRAN 
--	FROM 
--	(
--		SELECT cd.[Date]
--		FROM CalendarDates cd 
--		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
--		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
--	) d
--	LEFT JOIN #TempInTran t1 ON t1.[Date] < d.[Date]
--	)a
--	GROUP BY LocationId, [Date], productId
)stk 
INNER JOIN uv_Product up ON up.ProductId = stk.ProductId
GROUP BY  up.PrincipalBusinessLineId, up.PBLShortName,up.PBLSequenceId,
up.ProductSequence ,stk.ProductId, up.[Name],up.PrincipalProductCode --, stk.[Date]
ORDER BY 
up.PBLSequenceId,
up.ProductSequence

--DROP TABLE #TempInTran 
DROP TABLE #tmpDSPData
--DROP TABLE #tmpDSPWithHolidays
--DROP TABLE #tmpDSP
