--ALTER PROC usp_Report_NearExpirySalesIntimation 
DECLARE
@LocationIds NVARCHAR(MAX),@CustomerIds nvarchar(MAX),
@PBLIds NVARCHAR(MAX), @PrincipalTeamIds nvarchar(MAX),@ProductIds nvarchar(MAX),
@DateCriteria INT, @FromDate DATETIME,@ToDate DATETIME,
@ExpDateCriteria int ,@ExpFromDate DATETIME,@ExpToDate DATETIME
--AS 

SET @LocationIds = '11'
SET @CustomerIds = ''
SET @PBLIds = '3'
SET @PrincipalTeamIds = '34'
SET @ProductIds = ''
SET @DateCriteria = 2
SET @FromDate = '2014-04-01'
SET @ToDate  = '2014-04-30'
SET @ExpDateCriteria = 1
SET @ExpFromDate = '2015-1-1'
SET @ExpToDate  = '2015-06-30'


SELECT	pp.PrincipalBusinessLineId,
		pt.ShortName AS [Principal Team],
		pt.Sequence AS [TeamSequence],
		ptp.ProductId				
INTO #PTeam
FROM
PrincipalTeam pt
INNER JOIN PrincipalTeamPBL pp ON pp.PrincipalTeamId = pt.PrincipalTeamId
INNER JOIN PrincipalTeamProduct ptp ON pt.PrincipalTeamId = ptp.PrincipalTeamId 
INNER JOIN dbo.split(@PBLIds,',')pbl ON pbl.[Data] = pp.PrincipalBusinessLineId OR @PBLIds = ''
INNER JOIN DBO.Split(@PrincipalTeamIds, ',' ) PTId ON ( PTId.DATA = pt.PrincipalTeamId OR @PrincipalTeamIds = '' )
INNER JOIN dbo.Split(@ProductIds,',')Product ON Product.[Data] = ptp.ProductId   OR @PRoductIds = ''
WHERE ptp.ToBeDeleted = 0

SELECT so.[LOC ID],
l.SequenceId [LOC SEQ],
l.ShortName AS [LOCATION],
so.[CUSTOMER ID],
csa.[CUSTOMER NAME],
csa.[MAIN AREA],
csa.[SUB AREA], 
so.[PBL ID],
up.PBLShortName [PBL],
so.[PRINCIPAL TEAM],
so.[PRODUCT CODE],
up.[Name] AS [PRODUCT NAME],
so.[BATCH],
ISNULL(b.ExpiryDate,'1900-01-01') AS [EXPIRY DATE],
so.[SO#],
so.[SALE DATE],
so.[SOLD QTY],
so.TP,
so.[TP VALUE]
FROM 
(
SELECT so.LocationId [LOC ID],
so.CustomerId [CUSTOMER ID], 
so.PrincipalBusinessLineId [PBL ID],so.ProductId [PRODUCT CODE],
so.BatchNumber [BATCH],isnull(p.[PRINCIPAL TEAM],'UNTAGGED') [PRINCIPAL TEAM],
so.SaleOrderId [SO#],so.SalePassDate [SALE DATE],so.SoldQuantity [SOLD QTY],so.TP,(so.SoldQuantity * so.TP) AS [TP VALUE]
FROM uv_SALES_SaleOrder so
INNER JOIN dbo.[Split](@LocationIds,',') loc ON loc.[Data] = so.LocationId OR @LocationIds = ''
INNER JOIN  dbo.Split(@CustomerIds,',')cust ON cust.DATA = so.CustomerId OR @CustomerIds = ''
INNER JOIN #PTEAM p ON p.ProductId = so.ProductId
WHERE 
(@DateCriteria = 0 OR 
(@DateCriteria = 1 AND DATEDIFF(DAY,so.SalePassDate,@FromDate)>= 0) OR 
(@DateCriteria = 2 AND DATEDIFF(DAY,@FromDate,so.SalePassDate)>=0 AND DATEDIFF(DAY,so.SalePassDate,@ToDate)>=0))

UNION ALL 

SELECT so.LocationId [LOC ID],
so.CustomerId [CUSTOMER ID],
so.PrincipalBusinessLineId [PBL ID],so.ProductId [PRODUCT CODE],
so.BatchNumber [BATCH],'UNTAGGED' [PRINCIPAL TEAM],
so.SaleOrderId [SO#],so.SalePassDate [SALE DATE],so.SoldQuantity [SOLD QTY],so.TP,(so.SoldQuantity * so.TP) AS [TP VALUE]
FROM uv_SALES_SaleOrder so
INNER JOIN dbo.[Split](@LocationIds,',') loc ON loc.[Data] = so.LocationId OR @LocationIds = ''
INNER JOIN  dbo.Split(@CustomerIds,',')cust ON cust.DATA = so.CustomerId OR @CustomerIds = ''
INNER JOIN dbo.[Split](@PBLIds,',')pbl ON pbl.[Data] = so.PrincipalBusinessLineId OR @PBLIds = ''
INNER JOIN dbo.[Split](@ProductIds,',')prod ON prod.[Data] = so.PRoductId  OR @ProductIds= ''

WHERE 
(@DateCriteria = 0 OR 
(@DateCriteria = 1 AND DATEDIFF(DAY,so.SalePassDate,@FromDate)>= 0) OR 
(@DateCriteria = 2 AND DATEDIFF(DAY,@FromDate,so.SalePassDate)>=0 AND DATEDIFF(DAY,so.SalePassDate,@ToDate)>=0))

)so
Left JOIN uv_PRoduct up ON up.ProductId = so.[PRODUCT CODE]
Left JOIN BATCH b ON b.ProductId = so.[PRODUCT CODE] AND b.BatchNumber = so.BATCH
Left JOIN Location l ON  l.LocationId = so.[LOC ID]  
Left JOIN uv_CustomerSalesArea csa ON csa.LocationId = so.[LOC ID] AND csa.CustomerId = so.[CUSTOMER ID]

WHERE 
--(@DateCriteria = 0 OR 
--(@DateCriteria = 1 AND DATEDIFF(DAY,@FromDate,so.SalePassDate) = 0) OR 
--(@DateCriteria = 2 AND DATEDIFF(DAY,@FromDate,so.SalePassDate)>=0 AND DATEDIFF(DAY,so.SalePassDate,@ToDate)>=0))
--AND 
(@ExpDateCriteria = 0 OR 
(@ExpDateCriteria = 1 AND DATEDIFF(DAY,b.ExpiryDate,@ExpFromDate)>= 0) OR 
(@ExpDateCriteria = 2 AND DATEDIFF(DAY,@ExpFromDate,b.ExpiryDate)>=0 AND DATEDIFF(DAY,b.ExpiryDate,@ExpToDate)>=0))

ORDER BY l.SequenceId,so.SO#

DROP TABLE #PTeam