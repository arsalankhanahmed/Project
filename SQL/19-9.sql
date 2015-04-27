/*
Author : Sidra Asif
Dated : 
Purpose :
*/

--CREATE PROC dbo.USP_Report_LocationWiseSale_Product 
--        @CompanyIds varchar(100),
--        @PBLIds varchar(100),
--        @LocationIds varchar(100),
--        @IsCash bit,
--        @IsCredit bit,
--        @IsTP bit,
--        @SaleCriteria int,
--        @SelectAll int,
--        @FromDate datetime,
--        @ToDate datetime,
--	@IsExcelBased BIT     
--AS 

DECLARE @CompanyIds varchar(100),
	@PBLIds varchar(100), @LocationIds varchar(100),
	@IsCash bit,
	@IsCredit bit,
	@IsTP bit,
	@SaleCriteria int,
	@SelectAll int,
	@FromDate datetime,
	@ToDate DATETIME,
	@IsExcelBased BIT      
 
SET @CompanyIds = '1'
SET @PBLIds = '3,4,28,44,59'
SET @LocationIds ='14,11,13,17'
SET @IsCash = 1
SET @IsCredit = 1
SET @IsTP = 1
SET @SaleCriteria = 1
SET @SelectAll=2
SET @FromDate = '2014/04/01'
SET @ToDate = '2014/04/30'
SET @IsExcelBased = 0

/*
Sale Criteria 
0-Gross Sale --Only Value
1-Net Sale -- Value-SLN
2-SLN--Only SLN
*/

SELECT 
	[A].CompanyId,
	l.SequenceId AS [LocSeq],	
	l.ShortName AS [Location Name],
	UPBLA.PBLSequenceId,
	upbla.PrincipalBusinessLineId,
	upbla.Name AS [PBL Name],	
	up.ProductSequence ,
	up.ProductId,
	up.Name AS [Product Name],
	MAX(l.MaxDate) AS [Date],
	CASE WHEN @SaleCriteria=0 THEN sum(A.GrossQuantity)
		 WHEN @SaleCriteria=1 THEN sum(A.GrossQuantity)-SUM(A.SLN)
		 WHEN @SaleCriteria=2 THEN sum(A.SLN)
	END 
	AS [Sale Qty],	
	(CASE WHEN @SaleCriteria=0 THEN sum(A.GrossQuantity * A.Price)
		 WHEN @SaleCriteria=1 THEN sum(A.GrossQuantity * A.Price)-SUM(A.SLN*A.Price)
		 WHEN @SaleCriteria=2 THEN sum(A.SLN * A.Price)
	END 
	)/1000
	AS [Sale Amount]
	INTO #Temp	
FROM   uv_Product up
LEFT OUTER  JOIN   
( 
		SELECT 
		des.CompanyId, 	
		des.LocationId, 			
		des.ProductId,
		CASE WHEN @ISTP=1 THEN (pc.TP) ELSE (PC.PP) END Price,
		SUM
		(
			CASE WHEN @IsCash=1 THEN isnull(des.BookedLocalCash,0) + isnull(des.BookedOSCash,0) + isnull(des.Shop,0)+ isnull(des.SpotLocal,0)+ isnull(des.SpotOS,0)  ELSE 0 END 
			+ CASE WHEN @IsCredit=1 THEN isnull(des.BookedLocalCredit,0)+isnull(des.BookedOSCredit,0) ELSE 0 END
		) AS [GrossQuantity], 					
		SUM(CASE WHEN @IsCash=1 THEN isnull((des.SLNCash),0)  ELSE 0 END + CASE  WHEN @IsCredit=1 THEN isnull((des.SLNCredit),0)  ELSE 0 END ) AS [SLN]					
		FROM uv_DayEndSale des				
		INNER JOIN PriceCatalog pc ON pc.PriceCatalogId=des.PriceId	
		INNER JOIN   DBO.Split(@CompanyIds, ',') Company ON  (Company.Data = des.companyId OR @CompanyIds = '')
		INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = des.LocationId OR @LocationIds = '')		
		WHERE		
		 (
			   @SelectAll = 0
			   OR  (
					   @SelectAll = 1
				  AND  (
						   DATEDIFF(DAY,des.[Date],  @FromDate) >= 0
					   )
				   )
			   OR  (
					   @SelectAll = 2
				  AND  (
						   DATEDIFF(DAY,des.[Date],  @FromDate) <= 0
					  AND  DATEDIFF(DAY,des.[Date],  @ToDate) >= 0
					   )
				   )
			 
		 )
		GROUP BY des.CompanyId, 	
		des.LocationId, 			
		des.ProductId,
		CASE WHEN @ISTP=1 THEN (pc.TP) ELSE (PC.PP) END
) AS [A] ON [A].ProductId = up.ProductId
INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = up.PrincipalBusinessLineId OR @PBLIds = '')
INNER JOIN uv_PrincipalBusinessLine_All upbla ON upbla.PrincipalBusinessLineId=up.PrincipalBusinessLineId
INNER JOIN (
				SELECT l1.SequenceId,l1.LocationId, l1.ShortName, max (des2.Date) AS MaxDate
				FROM Location l1
				INNER JOIN uv_DayEndSale des2 ON des2.LocationId = l1.LocationId
				WHERE DATEDIFF(DAY, des2.[Date],  @ToDate) >= 0
				GROUP BY l1.SequenceId,l1.LocationId, l1.ShortName
			)l 
ON l.LocationId = [A].LocationId
		
WHERE [A].LocationId IS NOT NULL

GROUP BY
	[A].CompanyId,
	l.SequenceId,	
	l.ShortName,
	UPBLA.PBLSequenceId,
	upbla.PrincipalBusinessLineId,
	upbla.Name,	
	up.ProductSequence ,
	up.ProductId,
	up.Name
	
ORDER BY 
l.SequenceId,
UPBLA.PBLSequenceId,
up.ProductSequence
--,[A].MaxDate  DESC
---------------------------------------
IF @IsExcelBased = 0
BEGIN

SELECT CompanyId,
	[LocSeq],	
	[Location Name],
	PBLSequenceId,
	PrincipalBusinessLineId,
	[PBL Name],	
	ProductSequence ,
	ProductId,
	[Product Name],
	[Date],
	[Sale Qty],	
	[Sale Amount]
	
FROM #TEMP
--    GROUP BY
--           [A].PBLSequenceId,
--           [A].PrincipalBusinessLineId,
--           [A].[PBL Name],
--           [A].LocSeq,
--           [A].LocationId,
--           [A].[Location Name]
--    ORDER BY
--           [A].PBLSequenceId,
--           [A].PrincipalBusinessLineId,
--           [A].[PBL Name],
--           [A].LocSeq
END
ELSE
BEGIN
    SELECT DISTINCT IDENTITY(INT, 1, 1) Id,
           [LocSeq],
           [Location Name] AS [Location],
           [Location Name] + ' ! ' + (CONVERT(VARCHAR(11),[DATE],6)) AS [LocWithDate],
           [Location Name] + '!SALEVALUE!' + (CONVERT(VARCHAR(11),[DATE],6)) AS [LocValueWithDate] 
           INTO #Location
	FROM   #Temp
    ORDER BY
           LocSeq 
    
    DECLARE @pvtAllColumn NVARCHAR(MAX), 
    		@pvtLoc       NVARCHAR(MAX),
            @pvtLocation  NVARCHAR(MAX),
            @pvtLocationValue NVARCHAR(MAX),
            @Count        INT,
            @Query        VARCHAR(MAX)
    
    SET @pvtLocation = (
            SELECT 'ISNULL(SUM([' + l.[Location] + ']), 0) AS [' + l.[LocWithDate]
                   + '],',
                   '0 as [' + l.[LocValueWithDate]+ '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
    )
     SET @pvtLocation = LEFT(@pvtLocation, LEN(@pvtLocation) -1)
     SET @pvtLocationValue= (
            SELECT '0 AS ['+l.[LocWithDate]+'],'
                   + 'ISNULL(SUM([' + l.[Location] + ']), 0) AS [' + l.[LocValueWithDate]
                   + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtLocationValue = LEFT(@pvtLocationValue, LEN(@pvtLocationValue) -1)
    
         SET @pvtAllColumn= (
            SELECT  'isnull(Sum(['+l.[LocWithDate]+']),0) as ['+[LocWithDate]+'],',
                    'isnull(Sum(['+l.[LocValueWithDate]+']),0) as ['+[LocValueWithDate]+'],'
                   
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtAllColumn = LEFT(@pvtAllColumn, LEN(@pvtAllColumn) -1)
    
    SET @pvtLoc = (
            SELECT '[' + l.[Location] + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtLoc = LEFT(@pvtLoc, LEN(@pvtLoc) -1)
    
    SET @Query = 'select PBL, Product, '+@pvtAllColumn+' From(
				SELECT PBLSequenceId, [PBL Name] as [PBL], ProductSequence, [Product],' + @pvtLocation +'
				From(
					SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId)+''-''+t.[Product Name] as Product,t.[Location Name],T.[Sale Qty]
					FROM #TEMP T 
				)ST
				PIVOT
				(SUM([Sale Qty]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
				GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product]
				
				Union all
				
				SELECT PBLSequenceId, [PBL], ProductSequence, [Product],'+@pvtLocationValue+'
				FROM
				(
					SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name] as [PBL],t.ProductSequence, Convert(varchar,t.ProductId)+''-''+t.[Product Name] as Product,t.[Location Name],T.[Sale Amount]
					FROM #TEMP T 
				)ST
				PIVOT
				(SUM([Sale Amount]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
				GROUP BY PBLSequenceId,[PBL],ProductSequence,[Product]
				)a
				GROUP BY PBLSequenceId,[PBL],ProductSequence,[Product]
                Order by PBLSequenceId, ProductSequence'
    PRINT(@Query)
    EXEC (@Query)
END

--DROP TABLE #Location
--DROP TABLE #Temp

------------
select PBL, Product, isnull(Sum([KHE ! 30 Apr 14]),0) as [KHE ! 30 Apr 14],isnull(Sum([KHE!SALEVALUE!30 Apr 14]),0) as [KHE!SALEVALUE!30 Apr 14],isnull(Sum([KHN ! 30 Apr 14]),0) as [KHN ! 30 Apr 14],isnull(Sum([KHN!SALEVALUE!30 Apr 14]),0) as [KHN!SALEVALUE!30 Apr 14],isnull(Sum([HYD ! 30 Apr 14]),0) as [HYD ! 30 Apr 14],isnull(Sum([HYD!SALEVALUE!30 Apr 14]),0) as [HYD!SALEVALUE!30 Apr 14],isnull(Sum([NWHK ! 30 Apr 14]),0) as [NWHK ! 30 Apr 14],isnull(Sum([NWHK!SALEVALUE!30 Apr 14]),0) as [NWHK!SALEVALUE!30 Apr 14] From(
				SELECT PBLSequenceId, [PBL Name] as [PBL], ProductSequence, [Product],ISNULL(SUM([KHE]), 0) AS [KHE ! 30 Apr 14],0 as [KHE!SALEVALUE!30 Apr 14],ISNULL(SUM([KHN]), 0) AS [KHN ! 30 Apr 14],0 as [KHN!SALEVALUE!30 Apr 14],ISNULL(SUM([HYD]), 0) AS [HYD ! 30 Apr 14],0 as [HYD!SALEVALUE!30 Apr 14],ISNULL(SUM([NWHK]), 0) AS [NWHK ! 30 Apr 14],0 as [NWHK!SALEVALUE!30 Apr 14]
				From(
					SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId)+'-'+t.[Product Name] as Product,t.[Location Name],T.[Sale Qty]
					FROM #TEMP T 
				)ST
				PIVOT
				(SUM([Sale Qty]) FOR [Location Name] IN ([KHE],[KHN],[HYD],[NWHK])) AS PVT
				GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product]
				
				Union all
				
				SELECT PBLSequenceId, [PBL], ProductSequence, [Product],0 AS [KHE ! 30 Apr 14],ISNULL(SUM([KHE]), 0) AS [KHE!SALEVALUE!30 Apr 14],0 AS [KHN ! 30 Apr 14],ISNULL(SUM([KHN]), 0) AS [KHN!SALEVALUE!30 Apr 14],0 AS [HYD ! 30 Apr 14],ISNULL(SUM([HYD]), 0) AS [HYD!SALEVALUE!30 Apr 14],0 AS [NWHK ! 30 Apr 14],ISNULL(SUM([NWHK]), 0) AS [NWHK!SALEVALUE!30 Apr 14]
				FROM
				(
					SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name] as [PBL],t.ProductSequence, Convert(varchar,t.ProductId)+'-'+t.[Product Name] as Product,t.[Location Name],T.[Sale Amount]
					FROM #TEMP T 
				)ST
				PIVOT
				(SUM([Sale Amount]) FOR [Location Name] IN ([KHE],[KHN],[HYD],[NWHK])) AS PVT
				GROUP BY PBLSequenceId,[PBL],ProductSequence,[Product]
				)a
				GROUP BY [PBL],[Product]
                Order by PBLSequenceId, ProductSequence
Msg 8127, Level 16, State 1, Line 24
Column "a.PBLSequenceId" is invalid in the ORDER BY clause because it is not contained in either an aggregate function or the GROUP BY clause.
