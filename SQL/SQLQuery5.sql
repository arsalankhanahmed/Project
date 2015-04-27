
--CREATE PROC dbo.usp_Report_AreaWiseSale @LocationIds varchar(100), @PBLIds varchar(100), @PrincipalTeamIds varchar(MAX), @ProductIds varchar(MAX),   
--@AreaIds varchar(MAX), @AreaLevel int, @AreaType int, @WithTeam bit, @FromDate datetime, @ToDate datetime, @BasedOn int, @ReportType int AS  


DECLARE @LocationIds varchar(100), @PBLIds varchar(100), @PrincipalTeamIds varchar(MAX), @ProductIds varchar(MAX),   
@AreaIds varchar(MAX), @AreaLevel int, @AreaType int, @WithTeam bit, @FromDate datetime, @ToDate datetime, @BasedOn int, @ReportType int
SET @LocationIds = '11'--'14'
SET @PBLIds = '3'--3,5,58,67,28,55,37,7,33,64,40,59,61,4,44,48,20,35,62,45,47,49,41,43,60,50,57'--'40'
SET @PrincipalTeamIds = '34'--'40,41,38,37,39,44,46,43,45,42'
SET @ProductIds = ''--'2520,2521,2522,2523,2524,2525,2526,2527,2528,2529,2530,2531,2532,2533,2534,2557,2535,2536,2537,2538,2539,2540,2541,2542,2543,2544,2545,2546,2547,2548,2549,2552,2553,2554,2555,2556,2558,2559,2560,2561,2562,2563,2564,2565,2566,2567,2568,2569,2570,2571,2572,2573,2574,2575,2576,2577,2578,2593,2608'
SET @AreaIds = ''
SET @AreaLevel = 0--1
SET @AreaType = 2
SET @WithTeam = 1
SET @FromDate = '2014-05-01 00:00:00'
SET @ToDate = '2014-05-31 00:00:00'
SET @BasedOn = 1--2
SET @ReportType = 3

/*  
@ReportType=1 PBL wise with team   
@ReportType=2 PBL wise without team  
@ReportType=3 PBL/Product wise with team  
@ReportType=4 PBL/Product wise without team  
*/  
/*  
@AreaLevel=0 City  
@AreaLevel=1 MainArea  
@AreaLevel=2 SubArea  
*/  
/*  
@AreaType=0 Outstation  
@AreaType=1 Local  
@AreaType=2 all  
*/  
/*  
@BasedOn=1 Sale value  
@BasedOn=2 Sold Unit  
@BasedOn=3 Cartons  
@BasedOn=4 Kgs  
*/  


--SELECT *   
--INTO #TEMP
--FROM   
--( 

/*---------------------TAGG PRODUCTS-----------------------------*/   	  
SELECT 
	--pt.PrincipalTeamId AS PrincipalTeamId, 
	ISNULL(pt.ShortName, 'UNTAGGED PRODUCT') AS [TEAM], 
	SOProd.PrincipalBusinessLineId AS PBLId, 
	up.PBLShortName AS [PBL], 
	up.PBLSequenceId,
	ISNULL(pt.Sequence, 999999) AS TeamSequence, 
	ISNULL(ptp.ProductSequence, 999999) AS TeamProductSequence, 
	soprod.ProductId, 
	up.Name AS [Product Name], 
	SOProd.LocationId, 
	l.ShortName [Location Name], 
	l.SequenceId AS [Loc Seq], 
	SOProd.IsLocal, 
	CASE  
		WHEN @AreaLevel=0 THEN isnull(SOProd.LocationCityId,0) 
		WHEN @AreaLevel=1 THEN isnull(SOProd.MainAreaId,0) 
		WHEN @AreaLevel=2 THEN isnull(SOProd.SubAreaId,0) 
	END AS [AreaId], 
	CASE  
		WHEN @AreaLevel=0 THEN isnull(SOProd.City,'UN-DEFINE') 
		WHEN @AreaLevel=1 THEN isnull(SOProd.[Main Area],'UN-DEFINE') 
		WHEN @AreaLevel=2 THEN isnull(SOProd.[Sub Area],'UN-DEFINE') 
	END AS [AreaName], 
	isnull( CASE  
		WHEN @BasedOn=1 THEN /*SUM*/(TP*Quantity)
		WHEN @BasedOn=2 THEN /*SUM*/(Quantity) 		
		WHEN(@BasedOn = 3 AND up.CartonSize > 0) THEN  /*SUM*/(SOProd.Quantity) / up.CartonSize 
		WHEN(@BasedOn = 4 AND up.WeightInGm > 0) THEN  /*SUM*/(SOProd.Quantity) * up.WeightInGm / 1000 				
		END, 
	0 ) AS [Value], 
	CASE  
		WHEN @AreaLevel=0 THEN isnull(SOProd.City,'UN-DEFINE') 
		WHEN @AreaLevel=1 THEN isnull(SOProd.[Main Area],'UN-DEFINE') 
		WHEN @AreaLevel=2 THEN isnull(SOProd.[Sub Area],'UN-DEFINE') 
	END + ' VALUE' AS [AreaNameValue], 
	/*SUM*/(SOProd.TP * SOProd.Quantity) AS [ProductValue]

INTO #TEMP	
FROM   
		( 
			SELECT 
			   DES.CompanyId,
			   DES.LocationId,
			   DES.CityId,
			   DES.City,
			   DES.MainAreaId,
			   DES.[Main Area],
			   DES.SubAreaId,
			   DES.[Sub Area],
			   DES.Date,
			   DES.PrincipalBusinessLineId,
			   DES.ProductId,
			   DES.TP,
			   DES.IsLocal,
			   SUM(DES.SOQuantity - DES.SLNQuantity) AS Quantity,
			   DES.LocationCityId
			
			FROM   uv_Sales_BySubAreaWise DES
				   INNER JOIN DBO.Split(@LocationIds, ',') Loc ON  (Loc.Data = DES.LocationId OR @LocationIds = '')
				   INNER JOIN DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = DES.PrincipalBusinessLineId OR @PBLIds = '')
				   INNER JOIN DBO.Split(@ProductIds, ',') Product ON  (Product.Data = DES.ProductId OR @ProductIds = '')
				   INNER JOIN DBO.Split(@AreaIds, ',') area ON  
				   (
				   		@AreaIds = ''
				   		OR
				   		area.Data = CASE 
				   						WHEN  @AreaLevel = 0 THEN DES.LocationCityId
				   						WHEN  @AreaLevel = 1 THEN DES.MainAreaId
				   						WHEN  @AreaLevel = 2 THEN DES.SubAreaId
				   		            END
				   )
			WHERE  
				DATEDIFF(DAY, DES.Date, @FromDate) <= 0
			AND DATEDIFF(DAY, DES.Date, @ToDate) >= 0
			AND 
			(
				@AreaType = 2 
				OR (@AreaType = 1 AND des.IsLocal = 1) 
				OR (@AreaType = 0 AND des.IsLocal = 0)
			)
			GROUP BY
				   DES.CompanyId, DES.LocationId, DES.CityId, DES.City, DES.MainAreaId, DES.[Main Area], DES.SubAreaId, DES.[Sub Area],
				   DES.PrincipalBusinessLineId, DES.ProductId, DES.Date, DES.TP, DES.IsLocal, DES.LocationCityId
		) SOProd
		INNER JOIN Location l ON l.LocationId = SOProd.LocationId
		INNER JOIN   uv_Product up ON   up.ProductId = SOProd.ProductId
		LEFT OUTER JOIN PrincipalTeamProduct ptp ON  ptp.ProductId = up.ProductId
              AND ptp.ToBeDeleted = 0
         LEFT OUTER JOIN PrincipalTeam pt ON  pt.PrincipalTeamId = ptp.PrincipalTeamId
              AND DATEDIFF(DAY, pt.EffectiveDate, GETDATE()) >= 0
              AND DATEDIFF(DAY, GETDATE(), ISNULL(pt.EndDate, GETDATE() + 1)) > 0

SELECT DISTINCT [Location Name], 
[Loc Seq], 
AreaName, 
AreaNameValue  
INTO #TMPSummary
FROM   #TEMP 
ORDER  BY  [Loc Seq]   

--SELECT * FROM #TMPSummary

DECLARE @pvtLocSaleZeroColumns VARCHAR(MAX),
		@pvtSaleAreaSummaryDivByThousandColumns VARCHAR(MAX),
        @pvtSaleAreaColumns VARCHAR(MAX),
        @pvtSummaryColumns VARCHAR(MAX),
        @WithTeamPBLQuery varchar(MAX),
        @WithOutTeamPBLQuery varchar(max),
        @WithTeamProductQuery varchar(max),
        @WithOutTeamProductQuery varchar(max)  

SET @pvtSaleAreaColumns = ( SELECT DISTINCT '[' +[AreaName] +  '], [' + [AreaNameValue] +  '],' FROM   #TEMP  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')
SET @pvtSaleAreaColumns = LEFT( @pvtSaleAreaColumns,LEN(@pvtSaleAreaColumns )-1 )  

SET @pvtLocSaleZeroColumns = ( SELECT DISTINCT '0 [' +[AreaName] +  '], [' +[AreaNameValue] +  '],'FROM   #TEMP  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')                             
SET @pvtLocSaleZeroColumns = LEFT( @pvtLocSaleZeroColumns,LEN(@pvtLocSaleZeroColumns )-1 )  

SET @pvtSummaryColumns = (SELECT 'SUM(A.['+ AreaName+']) ['+ AreaName + '],SUM(A.['+ AreaNameValue+']) ['+ AreaNameValue + '], '
                          FROM   #TMPSummary  ORDER  BY  [Loc Seq]  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')                              
SET @pvtSummaryColumns = LEFT( @pvtSummaryColumns,LEN(@pvtSummaryColumns )-1 )  

SET @pvtSaleAreaSummaryDivByThousandColumns = ( SELECT DISTINCT 'SUM(A.['+ AreaName+'])/1000 ['+ AreaName + '],SUM(A.['+ AreaNameValue+']) ['+ AreaNameValue + '], ' FROM   #TEMP  FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')  
SET @pvtSaleAreaSummaryDivByThousandColumns = LEFT( @pvtSaleAreaSummaryDivByThousandColumns,LEN(@pvtSaleAreaSummaryDivByThousandColumns )-1 )  

SELECT DISTINCT 
t.LocationId, IDENTITY(INT,1,1) RowID  
INTO #tempLoc
FROM   #TEMP t  

--ALTER TABLE #tempLoc ADD RowID int IDENTITY  
DECLARE @Count int,
        @Loc int,
        @TeamExist bit  

SET @Count = 1  
WHILE (@Count<=(SELECT count(* )
                FROM   #tempLoc))
BEGIN
    SELECT @Loc = LocationId FROM   #tempLoc l WHERE  l.RowID = @Count                      
    
IF (@ReportType=1 )
BEGIN
          
    SET @WithTeamPBLQuery = 
    'SELECT  A.LocationId,A.[Location Name], A.PBLId,PBL,a.TeamSequence,A.TEAM,  '
    + CASE WHEN @ReportType IN (1,2) AND @BasedOn=1 THEN @pvtSaleAreaSummaryDivByThousandColumns ELSE @pvtSummaryColumns END +  
    +
    ',0 AS [TOTAL]
    FROM   
    (    
    SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL, TeamSequence,TEAM, '
    +@pvtSaleAreaColumns  
    +      
    '  
    FROM   
    (   
    SELECT ST.* FROM   #TEMP ST  WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
    '  
    ) AS ST   
    PIVOT  
    (SUM([Value]) FOR [AreaName] IN ('+@pvtSaleAreaColumns+
    ')) AS PVT 
    
    UNION ALL
    
    SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL, TeamSequence,TEAM, '
    +@pvtSaleAreaColumns  
    +      
    '  
    FROM   
    (   
    SELECT ST.* FROM   #TEMP ST WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
    '  
    ) AS ST   
    PIVOT  
    (SUM([ProductValue]) FOR [AreaNameValue] IN ('+@pvtSaleAreaColumns+
    ')) 
    AS PVT 
                           
    )A  
    GROUP BY A.[Loc Seq],A.LocationId,A.[Location Name],A.PBLSequenceId,A.PBLId,A.PBL,a.TeamSequence,A.TEAM  
    ORDER BY A.[Loc Seq],A.PBLSequenceId,a.TeamSequence,A.LocationId,A.[Location Name],A.PBLId,A.PBL,A.TEAM  
    '                                                                 
    EXEC (@WithTeamPBLQuery)      
END  
  
IF (@ReportType=2 )
BEGIN
	      
	SET @WithOutTeamPBLQuery = 
	'SELECT  A.LocationId,A.[Location Name], A.PBLId,PBL,'+
	CASE WHEN @ReportType IN (1,2) AND @BasedOn=1 THEN @pvtSaleAreaSummaryDivByThousandColumns ELSE @pvtSummaryColumns END 
	+  
	+
	',0 AS [TOTAL]  
	FROM   
	(    
	SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL,'+@pvtSaleAreaColumns  
	+  
	'  
	FROM   
	(   
	SELECT ST.*         
	FROM   #TEMP ST      
	WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
	'  
	) AS ST   
	PIVOT  
	(SUM([Value]) FOR [AreaName] IN ('+@pvtSaleAreaColumns+
	')) AS PVT 
	UNION ALL
    
    SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL,'+@pvtSaleAreaColumns  
    +      
    '  
    FROM   
    (   
    SELECT ST.* FROM   #TEMP ST WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
    '  
    ) AS ST   
    PIVOT  
    (SUM([ProductValue]) FOR [AreaNameValue] IN ('+@pvtSaleAreaColumns+
    ')) 
    AS PVT 
                             
	)A  
	GROUP BY A.[Loc Seq],A.LocationId,A.[Location Name],A.PBLSequenceId, A.PBLId,A.PBL  
	ORDER BY A.[Loc Seq],A.PBLSequenceId,A.LocationId,A.[Location Name], A.PBLId,A.PBL  
	'                                                                 
	EXEC (@WithOutTeamPBLQuery)   
END   

IF (@ReportType=3 )
	BEGIN
	      
	SET @WithTeamProductQuery = 
	'  
	SELECT  A.LocationId,A.[Location Name], A.PBLId,A.PBL,a.TeamSequence,a.TeamProductSequence,A.TEAM,a.[ProductId] AS [CODE],A.[PRODUCT NAME],  '
	+@pvtSummaryColumns+  
	+
	',0 AS [TOTAL]
	FROM   
	(    
	SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL, TeamSequence,TeamProductSequence,TEAM, ProductId, [Product Name], '
	+@pvtSaleAreaColumns  
	+  

	'  
	FROM   
	(   
	SELECT ST.*  FROM   #TEMP ST  WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
	'  
	) AS ST   
	PIVOT  
	(SUM([Value]) FOR [AreaName] IN ('+@pvtSaleAreaColumns+
	')) AS PVT 
	
	UNION ALL
    
    SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL, TeamSequence,TeamProductSequence,TEAM, ProductId, [Product Name], '
    +@pvtSaleAreaColumns  
    +      
    '  
    FROM   
    (   
    SELECT ST.* FROM   #TEMP ST WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
    '  
    ) AS ST   
    PIVOT  
    (SUM([ProductValue]) FOR [AreaNameValue] IN ('+@pvtSaleAreaColumns+
    ')) 
    AS PVT 
                             
	)A  
	GROUP BY A.[Loc Seq],A.LocationId,A.[Location Name],A.PBLSequenceId, A.PBLId,A.PBL,a.TeamSequence,a.TeamProductSequence,A.TEAM,A.[ProductId],A.[PRODUCT NAME]  
	ORDER BY A.[Loc Seq],A.PBLSequenceId,A.LocationId,A.[Location Name], A.PBLId,A.PBL,a.TeamSequence,a.TeamProductSequence,A.TEAM,A.[ProductId],A.[PRODUCT NAME]  
	'      
	EXEC (@WithTeamProductQuery)     

END   

IF (@ReportType=4 )
BEGIN
	      
		SET @WithOutTeamProductQuery = 
		'  
		SELECT  A.LocationId,A.[Location Name], A.PBLId,A.PBL,a.[ProductId] AS [CODE],A.[PRODUCT NAME],  '
		+@pvtSummaryColumns+  
		+
		',0 AS [TOTAL]
		FROM   
		(    
		SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL,ProductId, [Product Name], '
		+@pvtSaleAreaColumns  +  
		'  
		FROM   
		(   
		SELECT ST.*         
		FROM   #TEMP ST      
		WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
		'  
		) AS ST   
		PIVOT  
		(SUM([Value]) FOR [AreaName] IN ('+@pvtSaleAreaColumns+
		')) AS PVT    
		
		UNION ALL
    
		SELECT [Loc Seq],LocationId,[Location Name],PBLSequenceId,PBLId,PBL,ProductId, [Product Name], '
		+@pvtSaleAreaColumns  +      
		'  
		FROM   
		(   
		SELECT ST.* FROM   #TEMP ST WHERE  st.LocationId='+CONVERT(varchar(12),@Loc,103)+
		'  
		) AS ST   
		PIVOT  
		(SUM([ProductValue]) FOR [AreaNameValue] IN ('+@pvtSaleAreaColumns+
		')) 
		AS PVT 
	                          
		)A  
		GROUP BY A.[Loc Seq],A.LocationId,A.[Location Name],A.PBLSequenceId, A.PBLId,A.PBL,A.[ProductId],A.[PRODUCT NAME]  
		ORDER BY A.[Loc Seq],A.PBLSequenceId,A.LocationId,A.[Location Name], A.PBLId,A.PBL,A.[ProductId],A.[PRODUCT NAME]  
		'      
		EXEC (@WithOutTeamProductQuery)    
		
 END                 
		  
	SET @Count = @Count + 1
END      


DROP TABLE #tempLoc  
DROP TABLE #TMPSummary            
DROP TABLE #TEMP

