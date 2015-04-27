/************************************************************
 * Arsalan Ahmed Khan
 * Time: 10/29/2014 11:25:24 AM
 ************************************************************/
CREATE PROC usp_Report_CustomerCreditLimitValidation
		@LocationIds varchar(MAX),
		@PBLIds VARCHAR(MAX),
		@CustomerIds VARCHAR(MAX),
		@FromDate DATETIME,
		@ToDate DATETIME,
		@ReportType INT
		AS
--DECLARE @LocationIds  VARCHAR(MAX),
--        @PBLIds       VARCHAR(MAX),
--        @CustomerIds  VARCHAR(MAX),
--        @FromDate     DATETIME,
--        @ToDate       DATETIME,
--        @ReportType   INT
--SET @LocationIds = '11'
--SET @PBLIds = ''
--SET @CustomerIds = '7'
--SET @FromDate = '20140401'
--SET @ToDate = '20141030'
--SET @ReportType = 0

SELECT 
l.SequenceId,
so.LocationId,
l.ShortName [LOCATION],
so.CustomerId [CUSTOMER ID],
c.[Name] AS [CUSTOMER NAME],
upbla.PBLSequenceId,
so.PrincipalBusinessLineId,
upbla.[Name] [PBL], 
so.CreditDays [CREDIT DAYS],
so.CreditLimit [CREDIT LIMIT],
so.EffectiveDate [EFFECTIVE DATE],
so.Period,
Case when @ReportType = 0 then SUM(so.Amount) ELSE SUM(so.AVGAmount) END as [AMOUNT]
INTO #TEMP
FROM Customer c
INNER JOIN dbo.[Split](@LocationIds,',')Loc ON (Loc.Data = c.LocationId OR @LocationIds='')
INNER JOIN dbo.[Split](@CustomerIds,',')Cus ON (Cus.Data = c.CustomerId OR @CustomerIds='')
INNER JOIN Location l ON l.LocationId = c.LocationId
LEFT JOIN (
SELECT so.LocationId,
	 so.CustomerId,
	 ccl.CreditDays, 
	 ccl.CreditLimit, 
	 ccl.EffectiveDate,
	 ccl.PrincipalBusinessLineId,
	CAST(
	   CONVERT(VARCHAR(4), YEAR(so.SalePassDate)) + '-' + 
	   CONVERT(VARCHAR(2), MONTH(so.SalePassDate)) + '-01' 
	   AS DATE
	) AS Period,
	 AVG(so.SoldQuantity * so.TP) [AVGAmount],
	 SUM(so.SoldQuantity * so.TP) [Amount]
  FROM CustomerCreditLimit ccl
INNER JOIN dbo.[Split](@PBLIds, ',') PBL
ON  (PBL.[Data] = ccl.PrincipalBusinessLineId OR @PBLIds = '') 
INNER JOIN uv_Sales_SaleOrder so  
ON ccl.LocationId = so.LocationId  
AND ccl.CustomerId = so.CustomerId 
AND ccl.CustomerCreditLimitId= so.CustomerCreditLimitId
WHERE so.IsCash = 0 
AND DATEDIFF(dd, @FromDate, so.SalePassDate) >= 0
AND DATEDIFF(dd, @ToDate, so.SalePassDate) <= 0
GROUP BY 
so.LocationId,
	 so.CustomerId,
	 ccl.CreditDays, 
	 ccl.CreditLimit, 
	 ccl.EffectiveDate,
	 ccl.PrincipalBusinessLineId,
	 CAST(
	   CONVERT(VARCHAR(4), YEAR(so.SalePassDate)) + '-' + 
	   CONVERT(VARCHAR(2), MONTH(so.SalePassDate)) + '-01' 
	   AS DATE
	) 
	 
UNION all

SELECT ccl.LocationId,
	 ccl.CustomerId,
	 ccl.CreditDays, 
	 ccl.CreditLimit, 
	 ccl.EffectiveDate,
	 ccl.PrincipalBusinessLineId,
	 NULL Period,
	 0 [AVGAmount],
	 0 [Amount] 
  FROM CustomerCreditLimit ccl
  INNER JOIN dbo.[Split](@PBLIds, ',') PBL
ON  (PBL.[Data] = ccl.PrincipalBusinessLineId OR @PBLIds = '')
--LEFT JOIN uv_Sales_SaleOrder so  
--ON ccl.LocationId = so.LocationId  
--AND ccl.CustomerId = so.CustomerId 
--AND ccl.CustomerCreditLimitId= so.CustomerCreditLimitId
--WHERE /*so.IsCash = 0 AND*/ (so.SoldQuantity * so.TP)  = 0
--AND DATEDIFF(dd, @FromDate, so.SalePassDate) >= 0
--AND DATEDIFF(dd, @ToDate, so.SalePassDate) <= 0

  
UNION all

SELECT so.LocationId,
	 so.CustomerId,
	 0 CreditDays, 
	 0 CreditLimit, 
	 null EffectiveDate,
	 so.PrincipalBusinessLineId,
	  CAST(
		   CONVERT(VARCHAR(4), YEAR(so.SalePassDate)) + '-' + 
		   CONVERT(VARCHAR(2), MONTH(so.SalePassDate)) + '-01' 
		   AS DATE
	   ) AS Period,
	 AVG(so.SoldQuantity * so.TP) [AVGAmount],
	 SUM(so.SoldQuantity * so.TP) [Amount]
  FROM uv_Sales_SaleOrder so
  INNER JOIN dbo.[Split](@PBLIds, ',') PBL
ON  (PBL.[Data] = so.PrincipalBusinessLineId OR @PBLIds = '') 
LEFT JOIN  CustomerCreditLimit ccl
ON ccl.LocationId = so.LocationId  
AND ccl.CustomerId = so.CustomerId 
AND so.PrincipalBusinessLineId = ccl.PrincipalBusinessLineId 
WHERE so.IsCash = 0 AND ccl.CreditLimit IS null
AND DATEDIFF(dd, @FromDate, so.SalePassDate) >= 0
AND DATEDIFF(dd, @ToDate, so.SalePassDate) <= 0
GROUP BY 
so.LocationId,
	 so.CustomerId,
	 so.PrincipalBusinessLineId,
	 CAST(
	   CONVERT(VARCHAR(4), YEAR(so.SalePassDate)) + '-' + 
	   CONVERT(VARCHAR(2), MONTH(so.SalePassDate)) + '-01' 
	   AS DATE
	) 
) so
ON so.LocationId = c.LocationId AND so.CustomerId = c.CustomerId
LEFT JOIN uv_PrincipalBusinessLine_All upbla ON upbla.PrincipalBusinessLineId = so.PrincipalBusinessLineId
WHERE so.CreditLimit>0 OR so.Amount>0

GROUP BY 
l.SequenceId,
so.LocationId,
l.ShortName ,
so.CustomerId ,
c.[Name] ,
upbla.PBLSequenceId,
so.PrincipalBusinessLineId,
upbla.[Name] ,
so.CreditDays,
so.CreditLimit,
so.EffectiveDate,
so.Period
ORDER BY 
l.SequenceId,
so.CustomerId,
upbla.PBLSequenceId

     
SELECT DISTINCT IDENTITY(INT, 1, 1) Id,
       Period,
       RIGHT(CONVERT(VARCHAR, [Period], 6), 6) [MONTH],
       CAST(Period AS Date) PeriodDate 
       INTO #Period
FROM   #Temp t
ORDER BY
       t.Period

DECLARE @Query         VARCHAR(MAX),
        @pvtPeriodVal  VARCHAR(MAX),
        @pvtPeriodCol  VARCHAR(MAX)

SET @pvtPeriodVal = (
        SELECT '[' + CONVERT(VARCHAR, p.[Period]) + '],'
        FROM   #Period p
        ORDER BY
               p.PeriodDate
               FOR XML PATH('')
    )

SET @pvtPeriodVal = LEFT(@pvtPeriodVal, LEN(@pvtPeriodVal) -1) 

SET @pvtPeriodCol = (
        SELECT 'Isnull(SUM([' + CONVERT(VARCHAR, p.[Period]) + ']),0) as [' + p.[Month]
               + '],'
        FROM   #Period p
        ORDER BY
               p.PeriodDate
               FOR XML PATH('')
    )

SET @pvtPeriodCol = LEFT(@pvtPeriodCol, LEN(@pvtPeriodCol) -1) 
SET @Query = 
    'Select [LOCATION],[CUSTOMER ID],[CUSTOMER NAME],PBL,[CREDIT DAYS],[CREDIT LIMIT],[EFFECTIVE DATE],' 
    + @pvtPeriodCol + 
    ',0 [AVERAGE TOTAL]
			from (
				select SequenceId,[LOCATION],[CUSTOMER ID],[CUSTOMER NAME],PBLSequenceId,PBL,[CREDIT DAYS],[CREDIT LIMIT],[EFFECTIVE DATE],Amount,Period
				From #Temp 
				)st
				PIVOT
				(SUM([Amount]) FOR [Period] IN (' + @pvtPeriodVal + ')) AS PVT
			    Group by SequenceId,[LOCATION],[CUSTOMER ID],[Customer Name],[CREDIT DAYS],PBLSequenceId,PBL,[CREDIT LIMIT],[EFFECTIVE DATE]
              order by SequenceId,[CUSTOMER ID],PBLSequenceId'

PRINT(@QUERY)
EXEC (@Query)

--DROP TABLE #Temp
--DROP TABLE #Period

