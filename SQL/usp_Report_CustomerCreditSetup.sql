/*
Author : Sidra Asif
Dated : 
Purpose :
*/

ALTER PROC dbo.usp_Report_CustomerCreditSetup  @LocationIds varchar(100), @PBLIds varchar(100),@CustomerIds varchar(MAX),@Type varchar(5) ,@CustStatus int, @IsExcelBased BIT    AS 

--DECLARE  @LocationIds varchar(1000),@PBLIds varchar(1000),@Type varchar(5),@CustomerIds varchar(1000),@CustStatus INT,@IsExcelBased BIT 
--SET @LocationIds = '14'
--SET @PBLIds = ''
--SET @Type = ''
--SET @CustomerIds=''
--SET @CustStatus='0'
--SET @IsExcelBased = 1

SELECT ccl.CustomerCreditLimitId,
	   l.SequenceId,
       ccl.LocationId,
       l.ShortName [LOCATION],
       l.Name AS [Location Name],
       upbla.PBLSequenceId,
       ccl.PrincipalBusinessLineId,
       upbla.Name AS [PrincipalBusinessLine],
       upbla.Name+'!CREDIT LIMIT' AS [PBLCreditLimit],
       upbla.Name+'!CREDIT DAYS' AS [PBLCreditDays],
       ccl.CustomerId AS [CUSTOMER!CODE],
       c.Name AS [CUSTOMER!NAME],
       sum(ccl.CreditDays) AS [CreditDays],
       sum(ccl.CreditLimit) AS [CreditLimit]
       INTO #TMP
FROM   CustomerCreditLimit ccl
INNER JOIN   uv_PrincipalBusinessLine_All upbla
  ON   upbla.PrincipalBusinessLineId = ccl.PrincipalBusinessLineId
INNER JOIN   Location l
  ON   l.LocationId = ccl.LocationId
INNER JOIN   Customer c
  ON   c.LocationId = ccl.LocationId
 AND   c.CustomerId = ccl.CustomerId
INNER JOIN   DBO.Split(@PBLIds, ',') PBL
  ON   (PBL.Data = ccl.PrincipalBusinessLineId OR @PBLIds = '' )
INNER JOIN   DBO.Split(@LocationIds, ',') LOC
  ON   (LOC.Data = ccl.LocationId OR @LocationIds = '')
INNER JOIN   DBO.Split(@CustomerIds, ',') cus
  ON   (cus.Data = c.CustomerId OR @CustomerIds = ''  )
  
WHERE  
(@Type = '' OR  (@Type = 'cd' ) OR  (@Type = 'cl' ) )
AND c.IsTemporary=0
AND c.IsShopSale=0
AND  (
	   @CustStatus = 0
   OR  (
		   @CustStatus = 1
	  AND  (
			   DATEDIFF(day, c.EffectiveDate,GETDATE())>= 0
			AND  DATEDIFF(day,GETDATE(), isnull( c.EndDate,GETDATE()+1))> 0
		   )
	   )
   OR  (
		   @CustStatus = 2
		   AND  DATEDIFF(day,c.EndDate,ISNULL(GETDATE(), GETDATE()+1))>0               
	   )
    ) 
AND DATEDIFF(day, ccl.EffectiveDate,GETDATE())>= 0
AND  DATEDIFF(day,GETDATE(), isnull( ccl.EndDate,GETDATE()+1))> 0 
AND DATEDIFF(day, l.EffectiveDate,GETDATE())>= 0
AND  DATEDIFF(day,GETDATE(), isnull( l.EndDate,GETDATE()+1))> 0 
AND DATEDIFF(day, c.EffectiveDate,GETDATE())>= 0
AND  DATEDIFF(day,GETDATE(), isnull( c.EndDate,GETDATE()+1))> 0 

GROUP BY
       ccl.CustomerCreditLimitId,
       ccl.LocationId,
       l.ShortName,
       l.Name,
       ccl.PrincipalBusinessLineId,
       upbla.Name,
       ccl.CustomerId,
       c.Name,
       l.SequenceId,
       upbla.PBLSequenceId

ORDER BY l.SequenceId , upbla.PBLSequenceId

IF @IsExcelBased = 0
	BEGIN
	SELECT * FROM #TMP
		PRINT 'DOS Based'
	END
ELSE 
BEGIN
	SELECT  DISTINCT PBLSequenceId,[PBLCreditLimit],[PBLCreditDays] INTO #PBLCOL FROM #Tmp ORDER BY PBLSequenceId 
	DECLARE @pvtLimitZeroColumns VARCHAR(MAX),
			@pvtDaysZeroColumns VARCHAR(MAX),
			@pvtLimitNonZeroColumns VARCHAR(MAX),
			@pvtDaysNonZeroColumns VARCHAR(MAX),
			@pvtLimitMAXColumns VARCHAR(MAX),
			@Query VARCHAR(MAX)

	SET @pvtLimitZeroColumns = (SELECT '0 [' + [PBLCreditLimit]+ '], ' 
								 FROM #PBLCOL FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')                           
	SET @pvtLimitZeroColumns = LEFT( @pvtLimitZeroColumns, LEN(@pvtLimitZeroColumns )-1 )
	                            
	SET @pvtLimitNonZeroColumns =( SELECT '[' + [PBLCreditLimit]+ '], '
								   FROM #PBLCOL FOR XML PATH('' ),
								  root('MyString'), type).value('/MyString[1]','varchar(max)')
	SET @pvtLimitNonZeroColumns = LEFT( @pvtLimitNonZeroColumns, LEN(@pvtLimitNonZeroColumns )-1 )
	                                                              
	SET @pvtDaysZeroColumns =( SELECT '0 [' + [PBLCreditDays]+ '], ' 
							   FROM #PBLCOL  FOR XML PATH('' ),
								  root('MyString'), type).value('/MyString[1]','varchar(max)')
	SET @pvtDaysZeroColumns = LEFT( @pvtDaysZeroColumns, LEN(@pvtDaysZeroColumns )-1 )
	                                                                 
	SET @pvtDaysNonZeroColumns =( SELECT '[' + [PBLCreditDays]+ '], ' 
								  FROM #PBLCOL FOR XML PATH('' ),
								  root('MyString'), type).value('/MyString[1]','varchar(max)')
	SET @pvtDaysNonZeroColumns = LEFT( @pvtDaysNonZeroColumns, LEN(@pvtDaysNonZeroColumns )-1 )

	SET @pvtLimitMAXColumns =
	(
	 SELECT 'SUM(A.[' + [PBLCreditLimit] + ']) [' + [PBLCreditLimit] + '], ' , 
	 'SUM(A.[' + [PBLCreditDays] + ']) [' + [PBLCreditDays] + '], ' 
	 FROM #PBLCOL
	 FOR XML PATH('')
	,root('MyString'), type).value('/MyString[1]','varchar(max)')
	SET @pvtLimitMAXColumns = LEFT( @pvtLimitMAXColumns, LEN(@pvtLimitMAXColumns )-1 )

	SET @Query ='
		   SELECT LOCATION,[CUSTOMER!CODE],[CUSTOMER!NAME],'+@pvtLimitMAXColumns+
		   '
		   FROM 
		   (
       		SELECT  SequenceId,LOCATION,[CUSTOMER!CODE],[CUSTOMER!NAME], '+@pvtDaysZeroColumns+', '+@pvtLimitNonZeroColumns+'
			   FROM #TMP ST
			   PIVOT
			   (SUM(CreditLimit) FOR [PBLCreditLimit] IN ('+@pvtLimitNonZeroColumns+')) AS PVT
			   UNION ALL
			   SELECT  SequenceId,LOCATION,[CUSTOMER!CODE],[CUSTOMER!NAME],'+@pvtDaysNonZeroColumns+', '+@pvtLimitZeroColumns+'
			   FROM #TMP ST
			   PIVOT
			   (SUM(CreditDays) FOR [PBLCreditDays] IN ('+@pvtDaysNonZeroColumns+')) AS PVT          
		   )A
		   GROUP BY SequenceId, LOCATION, [CUSTOMER!CODE], [CUSTOMER!NAME]
		   ORDER BY SequenceId, [CUSTOMER!CODE], [CUSTOMER!NAME]
		   '                                                                       
			EXEC (@Query)
	END

DROP TABLE #PBLCol
DROP TABLE #tmp
