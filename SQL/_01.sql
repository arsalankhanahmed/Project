DECLARE @CompanyIds varchar(1000),@PBLIds  varchar(1000),@LocationIds  varchar(1000),@SelectAll int,@FromDate datetime, @ToDate datetime
SET @CompanyIds='1' 
SET @PBLIds='28'
SET @LocationIds='14' 
SET @SelectAll=2
SET @FromDate='2013-11-23 00:00:00'
SET @ToDate='2013-11-26 00:00:00'

DECLARE @pvtTotalSaleColumns VARCHAR(MAX),
        @pvtTotalSaleNonZeroColumns VARCHAR(MAX),
        @pvtTotalCreditColumns VARCHAR(MAX),
        @pvtTotalCreditNonZeroColumns VARCHAR(MAX),
        @pvtTotalPercColumns VARCHAR(MAX),
        @pvtTotalPercNonZeroColumns VARCHAR(MAX),
        @pvtMAXColumns VARCHAR(MAX)
        
SELECT
a.LocationId,l.ShortName AS [Location Name],a.PrincipalBusinessLineId,upbla.Name AS [Principal Business Line],
upbla.Name + '!Total Sale' AS [Principal Business Line Total Sale],
upbla.Name + '!Total Credit Sale' AS [Principal Business Line Total Credit Sale],
upbla.Name + '!Total Percentage' AS [Principal Business Line Total Percentage],

--sum(A.[Total Sale]) AS [Total Sale],
--sum(A.[Credit Total Net]) AS [Total Credit Net],
--CASE WHEN isnull(sum(A.[Total Sale]),sum(a.[Credit Total Net])) = 0 THEN 0 ELSE
--Sum(A.[Credit Total Net]) / isnull(sum(A.[Total Sale]),sum(a.[Credit Total Net])) END  AS [Total Percentage]
--INTO #TEMP  
FROM 
(
	SELECT udes.LocationId, udes.Date, udes.CompanyId,up.PrincipalBusinessLineId,udes.
       isnull((udes.GrossValue - udes.SLNCash-udes.SLNCredit),0)*udes.TP AS [Total Sale],
       isnull((udes.BookedLocalCredit+udes.BookedOSCredit - udes.SLNCredit),0)*udes.TP  AS [Credit Total Net]       
	FROM uv_DayEndSale udes
	INNER JOIN uv_Product up ON up.ProductId = udes.ProductId 

	UNION ALL

	SELECT s.LocationId, s.TransactionDate AS [Date],s.CompanyId, s.PrincipalBusinessLineId,
			s.[Total Net] AS [Total Sale],s.[Credit Total Net]
	FROM UV_SLN S	
) A 
	INNER JOIN DBO.Split(@CompanyIds, ',') Company ON   (Company.Data = A.CompanyId OR @CompanyIds = '')  
	INNER JOIN DBO.Split(@LocationIds, ',') LOC ON   (LOC.Data = A.LocationId OR @LocationIds = '')  
	INNER JOIN DBO.Split(@PBLIds, ',') PBL  ON   (PBL.Data = A.PrincipalBusinessLineId OR @PBLIds = '')  
	INNER JOIN uv_PrincipalBusinessLine_All upbla ON upbla.PrincipalBusinessLineId =A.PrincipalBusinessLineId
	INNER JOIN Location l ON l.LocationId=a.LocationId
WHERE
(
	@SelectAll=0 OR
	(
		@SelectAll=2 
		AND (DATEDIFF(DAY, A.Date,  @FromDate) <= 0   AND DATEDIFF(DAY,A.Date,  @ToDate) >= 0)
	)	
)
	
GROUP BY
A.CompanyId,a.LocationId,l.ShortName, A.PrincipalBusinessLineId,upbla.Name--,A.Date

HAVING sum(a.[Total Sale])>0

--SELECT * FROM #TEMP
-----------------------------------Total Sale-------------------------------------
SET @pvtTotalSaleColumns =( SELECT DISTINCT '0 [' +  [Principal Business Line Total Sale] + '], ' FROM   #TEMP FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')                            
SET @pvtTotalSaleColumns = LEFT(@pvtTotalSaleColumns, LEN(@pvtTotalSaleColumns )-1)

SET @pvtTotalSaleNonZeroColumns =( SELECT DISTINCT '[' +  [Principal Business Line Total Sale] + '], ' FROM   #TEMP FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtTotalSaleNonZeroColumns = LEFT(@pvtTotalSaleNonZeroColumns, LEN(@pvtTotalSaleNonZeroColumns )-1)

-----------------------------------Total Credit-----------------------------------
SET @pvtTotalCreditColumns =( SELECT DISTINCT '0 [' + [Principal Business Line Total Credit Sale] + '], ' FROM   #TEMP  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtTotalCreditColumns = LEFT(@pvtTotalCreditColumns, LEN(@pvtTotalCreditColumns )-1)
                           
SET @pvtTotalCreditNonZeroColumns =( SELECT DISTINCT '[' + [Principal Business Line Total Credit Sale] + '], 'FROM   #TEMP FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtTotalCreditNonZeroColumns = LEFT(@pvtTotalCreditNonZeroColumns, LEN(@pvtTotalCreditNonZeroColumns )-1)

---------------------------------------Total Discount-----------------------------
SET @pvtTotalPercColumns =(SELECT DISTINCT '0 [' + [Principal Business Line Total Percentage] + '], ' FROM   #TEMP  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtTotalPercColumns = LEFT(@pvtTotalPercColumns, LEN(@pvtTotalPercColumns )-1)
                           
SET @pvtTotalPercNonZeroColumns =(SELECT DISTINCT '[' + [Principal Business Line Total Percentage] + '], 'FROM   #TEMP FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtTotalPercNonZeroColumns = LEFT( @pvtTotalPercNonZeroColumns, LEN(@pvtTotalPercNonZeroColumns )-1)                                                                                                                             
----------------------------------------------------------------------------------

SET @pvtMAXColumns = 
(	
	SELECT DISTINCT 
	'SUM(A.[' + [Principal Business Line] + A + ']) [' + [Principal Business Line] + A + '], ',
	'SUM(A.[' + [Principal Business Line] + B + ']) [' + [Principal Business Line] + B + '], ', 
	'SUM(A.[' + [Principal Business Line] + C + ']) [' + [Principal Business Line] + C + '], '
	FROM #TEMP T
	CROSS JOIN (SELECT '!Total Sale' A, '!Total Credit Sale' B, '!Total Percentage' C) A FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtMAXColumns = LEFT( @pvtMAXColumns, LEN(@pvtMAXColumns )-1 )
----------------------------------------------
DECLARE @Query varchar(max)
SET @Query ='
       SELECT  A.[Location Name],  '+@pvtMAXColumns+
       '
       FROM 
       (
		   SELECT  [Location Name],'+@pvtTotalSaleNonZeroColumns+', '+@pvtTotalCreditColumns+', '+@pvtTotalPercColumns+'
		   FROM #TEMP  ST
		   PIVOT
		   (SUM([Total Sale]) FOR [Principal Business Line Total Sale] IN ('+@pvtTotalSaleNonZeroColumns+')) AS PVT       	
		   
		   UNION ALL
		   
		   SELECT  [Location Name],'+@pvtTotalSaleColumns+', '+@pvtTotalCreditNonZeroColumns+', '+@pvtTotalPercColumns+'
		   FROM #TEMP  ST
		   PIVOT
		   (SUM([Total Credit Net]) FOR [Principal Business Line Total Credit Sale] IN ('+@pvtTotalCreditNonZeroColumns+')) AS PVT       	
		  
		   UNION ALL
		   
		   SELECT  [Location Name],'+@pvtTotalSaleColumns+', '+@pvtTotalCreditColumns+', '+@pvtTotalPercNonZeroColumns+'
		   FROM #TEMP  ST
		   PIVOT
		   (SUM([Total Percentage]) FOR [Principal Business Line Total Percentage] IN ('+@pvtTotalPercNonZeroColumns+')) AS PVT		      	
       )A
       GROUP BY A.[Location Name]
       '                                                                       
EXEC (@Query)

----------------------------------------------
DROP TABLE #TEMP