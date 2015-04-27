/* TABLE-4: STOCK --------------------------------------------------------------------------------*/
DECLARE @PBLIds VARCHAR(100)= '40,59',@FromDate DATETIME = '2014-06-01',@ToDate DATETIME = '2014-06-30',@IsConsignment BIT = 0


SELECT DSP.LocationId, dsp.TransactionDate [Date], DSP.ProductId,SUM(DSP.Closing) [Quantity]
INTO #tmpDSPData
FROM  dbo.fn_MonthEnd_Get_DSPByDateRange(-1, '', @PBLIds, '', @FromDate, @ToDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 1, 0, 0, 0, 0, 0)  DSP
GROUP BY DSP.LocationId, dsp.TransactionDate, DSP.ProductId, DSP.StockTypeId, DSP.BatchNumber

SELECT LocationId, [Date], ProductId,  SUM(Opening) Opening, SUM(Quantity) Closing
INTO #tmpDSPWithHolidays
FROM
(
	SELECT DSP.LocationId, d.[Date], DSP.ProductId, dsp.Closing as Opening , DSP.Closing Quantity
	FROM dbo.fn_MonthEnd_Get_OpeningDSP(-1, '', @PBLIds, '', @FromDate, @IsConsignment, CASE WHEN @IsConsignment = 0 THEN 1 ELSE 0 END, 1, 0, 0, 0, 0, 0)  DSP
	CROSS JOIN
	(
		SELECT cd.[Date]
		FROM CalendarDates cd 
		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
	) d

	UNION ALL

	SELECT t1.LocationId, t1.[Date], t1.ProductId, 0 Opening, t1.Quantity
	FROM #tmpDSPData t1
	
	UNION ALL
	
	SELECT t1.LocationId, d.[Date], t1.ProductId, t1.Quantity Opening,t1.Quantity
	FROM 
	(
		SELECT cd.[Date]
		FROM CalendarDates cd 
		WHERE DATEDIFF(DAY, @FromDate, cd.[Date]) >= 0
		AND DATEDIFF(DAY, @ToDate, cd.[Date]) <= 0   
	) d
	LEFT JOIN #tmpDSPData t1 ON t1.[Date] < d.[Date]	
)A
WHERE a.LocationId IS NOT NULL
--WHERE dbo.fn_Holiday_Check_IsHolidayOrWeekEnd(A.[Date], A.LocationId) = 0
GROUP BY LocationId, [Date], ProductId


SELECT d.*
INTO #tmpDSP
FROM #tmpDSPWithHolidays d
INNER JOIN
(
	SELECT t.LocationId, t.Date
	FROM (SELECT DISTINCT LocationId FROM #tmpDSPWithHolidays) d
	CROSS APPLY dbo.fn_WeekDay_Get_HolidayOrWeekDay(@FromDate, @ToDate, d.LocationId, 1) t
) w ON w.LocationId = d.LocationId 
 AND w.Date = d.Date
 

SELECT 
       up.PrincipalBusinessLineId,
       t.ProductId [ProductCode],
       up.[Name] [ProductName],
       --t.[Date] [Transaction_Date],
       SUM(t.Opening) Opening,
       SUM(t.Closing) Closing
FROM #tmpDSP t
INNER JOIN uv_Product up ON   up.ProductId = t.ProductId
GROUP BY  up.PrincipalBusinessLineId,t.ProductId, up.[Name]

--DROP TABLE #tmpDSPData
--DROP TABLE #tmpDSPWithHolidays
--DROP TABLE #tmpDSP
