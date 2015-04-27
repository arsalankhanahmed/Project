
/*
Author : Sidra Asif
Dated : 
Purpose :
*/
CREATE PROC dbo.usp_Report_LocationWiseSale_Product 
        @CompanyIds varchar(100),
        @PBLIds varchar(100),
        @LocationIds varchar(100),
        @IsCash bit,
        @IsCredit bit,
        @IsTP bit,
        @SaleCriteria int,
        @SelectAll int,
        @FromDate datetime,
        @ToDate datetime,
	@IsExcelBased BIT     
AS 

--DECLARE @CompanyIds varchar(100),
--	@PBLIds varchar(100), @LocationIds varchar(100),
--	@IsCash bit,
--	@IsCredit bit,
--	@IsTP bit,
--	@SaleCriteria int,
--	@SelectAll int,
--	@FromDate datetime,
--	@ToDate DATETIME,
--	@IsExcelBased BIT      
 
--SET @CompanyIds = '1'
--SET @PBLIds = ''
--SET @LocationIds = '11'--'14,11,13,17'
--SET @IsCash = 1
--SET @IsCredit = 1
--SET @IsTP = 1
--SET @SaleCriteria = 1
--SET @SelectAll=2
--SET @FromDate = '2014/09/01'
--SET @ToDate = '2014/09/20'
--SET @IsExcelBased = 1

/*
Sale Criteria 
0-Gross Sale --Only Value
1-Net Sale -- Value-SLN
2-SLN--Only SLN
*/

IF @SelectAll = 0
BEGIN
	SET @FromDate = '1900-01-01'
	SET @ToDate = GETDATE()
END
ELSE IF @SelectAll = 1
BEGIN
	SET @ToDate = @FromDate
END

SELECT LocationId, MAX(MaxDate) MaxDate
INTO #TempDate 
FROM
(
	SELECT usso.LocationId, CAST(usso.SalePassDate AS DATE) MaxDate--MAX(CAST(usso.SalePassDate AS DATE)) MaxDate
	FROM uv_Sales_SaleOrder usso
	INNER JOIN DBO.[Split](@LocationIds,',') fl ON (fl.[Data] = usso.LocationId OR @LocationIds = '')
	WHERE DATEDIFF(DAY, usso.SalePassDate,  @ToDate) >= 0
	--GROUP BY usso.LocationId

	UNION ALL

	SELECT usso.LocationId, usso.TransactionDate MaxDate--MAX(usso.TransactionDate) MaxDate
	FROM uv_Sales_SLN usso
	INNER JOIN DBO.[Split](@LocationIds,',') fl ON (fl.[Data] = usso.LocationId OR @LocationIds = '')
	WHERE DATEDIFF(DAY, usso.TransactionDate,  @ToDate) >= 0
	--GROUP BY usso.LocationId
)A
GROUP BY LocationId
SELECT 
	[A].CompanyId,
	l.SequenceId AS [LocSeq],	
	l.ShortName AS [Location Name],
	up.PBLSequenceId,
	up.PrincipalBusinessLineId,
	up.PBLShortName AS [PBL Name],	
	up.ProductSequence ,
	up.ProductId,
	up.Name AS [Product Name],
	--(de.MaxDate) 
	de.MaxDate AS [Date],
	CASE 
	     WHEN @SaleCriteria = 0 THEN SUM(A.GrossQuantity)
	     WHEN @SaleCriteria = 1 THEN SUM(A.GrossQuantity) -SUM(A.SLN)
	     WHEN @SaleCriteria = 2 THEN SUM(A.SLN)
	END AS [Sale Qty],	
	CASE 
	     WHEN @SaleCriteria = 0 THEN SUM(A.GrossQuantity * A.Price)
	     WHEN @SaleCriteria = 1 THEN SUM(A.GrossQuantity * A.Price) -SUM(A.SLN * A.Price)
	     WHEN @SaleCriteria = 2 THEN SUM(A.SLN * A.Price)
	END AS [Sale Amount]
	INTO #Temp	
FROM   uv_Product up
--INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = up.PrincipalBusinessLineId OR @PBLIds = '')
INNER JOIN   
( 
	SELECT 
	des.CompanyId, 	
	des.LocationId, 			
	des.ProductId,
	CASE WHEN @ISTP = 1 THEN pc.TP ELSE PC.PP END Price,
	SUM
	(
		CASE WHEN @IsCash=1 THEN isnull(des.BookedLocalCash,0) + isnull(des.BookedOSCash,0) + isnull(des.Shop,0)+ isnull(des.SpotLocal,0)+ isnull(des.SpotOS,0)  ELSE 0 END 
		+ CASE WHEN @IsCredit=1 THEN isnull(des.BookedLocalCredit,0)+isnull(des.BookedOSCredit,0) ELSE 0 END
	) AS [GrossQuantity], 					
	SUM(CASE WHEN @IsCash=1 THEN isnull((des.SLNCash),0)  ELSE 0 END + CASE  WHEN @IsCredit=1 THEN isnull((des.SLNCredit),0)  ELSE 0 END ) AS [SLN]					
	FROM dbo.fn_DayEndSale_Get_ByDateRange(@CompanyIds, @LocationIds, @PBLIds,'', @FromDate, @ToDate,1,1,1,0) des 
	INNER JOIN PriceCatalog pc ON pc.PriceCatalogId = DES.PriceId	
	GROUP BY des.CompanyId, des.LocationId, des.ProductId, CASE WHEN @ISTP = 1 THEN pc.TP ELSE PC.PP END
) AS [A] ON [A].ProductId = up.ProductId
INNER JOIN Location l ON l.LocationId = a.locationid
INNER JOIN #TempDate de ON de.LocationId = [A].LocationId
--INNER JOIN 
--(
--	SELECT LocationId, MAX(MaxDate) MaxDate 
--	FROM
--	(
--		SELECT usso.LocationId, CAST(usso.SalePassDate AS DATE) MaxDate--MAX(CAST(usso.SalePassDate AS DATE)) MaxDate
--		FROM uv_Sales_SaleOrder usso
--		INNER JOIN DBO.[Split](@LocationIds,',') fl ON (fl.[Data] = usso.LocationId OR @LocationIds = '')
--		WHERE DATEDIFF(DAY, usso.SalePassDate,  @ToDate) >= 0
--		--GROUP BY usso.LocationId

--		UNION ALL

--		SELECT usso.LocationId, usso.TransactionDate MaxDate--MAX(usso.TransactionDate) MaxDate
--		FROM uv_Sales_SLN usso
--		INNER JOIN DBO.[Split](@LocationIds,',') fl ON (fl.[Data] = usso.LocationId OR @LocationIds = '')
--		WHERE DATEDIFF(DAY, usso.TransactionDate,  @ToDate) >= 0
--		--GROUP BY usso.LocationId
--	)A
--	GROUP BY LocationId
--)de ON de.LocationId = [A].LocationId

--WHERE [A].LocationId IS NOT NULL

GROUP BY
	[A].CompanyId,
	l.SequenceId,	
	l.ShortName,
	up.PBLSequenceId,
	up.PrincipalBusinessLineId,
	up.PBLShortName,	
	up.ProductSequence ,
	up.ProductId,
	up.Name,
	de.MaxDate
	
ORDER BY 
l.SequenceId,
up.PBLSequenceId,
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

END
ELSE
BEGIN
    SELECT DISTINCT IDENTITY(INT, 1, 1) Id,
           [LocSeq],
           [Location Name] AS [Location],
           [Location Name] + ' ! ' + (CONVERT(VARCHAR(11),[DATE],6)) AS 
           [LocWithDate] 
           INTO #Location
	FROM   #Temp
    ORDER BY
           LocSeq 
    
    DECLARE @pvtLoc       NVARCHAR(MAX),
            @pvtLocation  NVARCHAR(MAX),
            @ZeroQty NVARCHAR(MAX),
            @pvtQty NVARCHAR(MAX),
            @pvtAmount NVARCHAR(MAX),
            @SumOfValue NVARCHAR(MAX),
            @SumOfQty NVARCHAR(MAX),
            @ZeroAmount NVARCHAR(MAX),
            @Query        VARCHAR(MAX)
 
    
    SET @SumOfQty = (
            SELECT 'ISNULL(SUM([' + l.[Location] + ']), 0)+'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @SumOfQty = LEFT(@SumOfQty, LEN(@SumOfQty) -1)
    
    SET @SumOfValue = (
            SELECT 'ISNULL(SUM([' + l.[Location] + ']), 0) +'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @SumOfValue = LEFT(@SumOfValue, LEN(@SumOfValue) -1)
    
     SET @pvtLocation = (
            SELECT 'ISNULL(SUM([' + l.[LocWithDate] + ']), 0) AS [' + l.[LocWithDate]
                   + '],ISNULL(SUM([' + l.[Location] + '!SALEVALUE]), 0) AS [' + l.[Location]+'!SALEVALUE'
                   + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtLocation = LEFT(@pvtLocation, LEN(@pvtLocation) -1)+',Isnull(Sum([Total!]),0) as [Total!],Isnull(Sum([Total!VALUE]),0) as [Total!VALUE]'
     
    SET @pvtQty = (
             SELECT 'ISNULL(SUM([' + l.[Location] + ']), 0) AS [' + l.[LocWithDate]
                   + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtQty = LEFT(@pvtQty, LEN(@pvtQty) -1)  
    
    SET @ZeroQty = (
             SELECT '0 AS [' + l.[LocWithDate]
                   + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @ZeroQty = LEFT(@ZeroQty, LEN(@ZeroQty) -1)
    
     SET @pvtAmount = (
             SELECT 'ISNULL(SUM([' + l.[Location] + ']), 0) AS [' + l.[Location]
                   + '!SALEVALUE],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtAmount = LEFT(@pvtAmount, LEN(@pvtAmount) -1)
        
    SET @ZeroAmount = (
             SELECT '0 AS [' + l.[Location]+'!SALEVALUE'
                   + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @ZeroAmount = LEFT(@ZeroAmount, LEN(@ZeroAmount) -1)
    
    SET @pvtLoc = (
            SELECT '[' + l.[Location] + '],'
            FROM   #Location l
            ORDER BY
                   l.LocSeq
                   FOR XML PATH('')
        )
    
    SET @pvtLoc = LEFT(@pvtLoc, LEN(@pvtLoc) -1)
    
    SET @Query = ' Select [PBL Name] as [PBL],[Product!Code],[Product!Name],'+ @pvtLocation +' 
                   From(
						/*SELECT PBLSequenceId,[PBL Name],ProductSequence,[Product!Code],[Product!Name],' + @pvtQty +','+@ZeroAmount+' ,0 as [Total!],0 as [Total!VALUE]
						FROM
							(
							SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId) [Product!Code],t.[Product Name] as [Product!Name],t.[Location Name],[Sale Qty]
							FROM #TEMP T 
							)ST
							PIVOT (SUM([Sale Qty]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
						GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product!Code],[Product!Name]
						
						union all 
						
						SELECT PBLSequenceId,[PBL Name],ProductSequence,[Product!Code],[Product!Name],' + @ZeroQty +','+@ZeroAmount+',' + @SumOfQty +'as [Total!] ,0 as [Total!VALUE]
						FROM
							(
							SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId) [Product!Code],t.[Product Name] as [Product!Name],t.[Location Name],[Sale Qty]
							FROM #TEMP T 
							)ST
							PIVOT (SUM([Sale Qty]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
						GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product!Code],[Product!Name]
						
						union all */
						
						SELECT PBLSequenceId,[PBL Name],ProductSequence,[Product!Code],[Product!Name],' + @ZeroQty +' ,'+@pvtAmount+',0 as [Total!],0 as [Total!VALUE]
						FROM
							(
							SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId) [Product!Code],t.[Product Name] as [Product!Name],t.[Location Name],[Sale Amount]
							FROM #TEMP T 
							)ST
							PIVOT (SUM([Sale Amount]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
						GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product!Code],[Product!Name]
						
						union all 
					    
					    SELECT PBLSequenceId,[PBL Name],ProductSequence,[Product!Code],[Product!Name],' + @ZeroQty +','+@ZeroAmount+',0 as [Total!],' + @SumOfValue +' as [Total!VALUE]
						FROM
							(
							SELECT t.PBLSequenceId, t.PrincipalBusinessLineId,t.[PBL Name],t.ProductSequence, Convert(varchar,t.ProductId) [Product!Code],t.[Product Name] as [Product!Name],t.[Location Name],[Sale Amount]
							FROM #TEMP T 
							)ST
							PIVOT (SUM([Sale Amount]) FOR [Location Name] IN (' + @pvtLoc + ')) AS PVT
						GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product!Code],[Product!Name]
               )a
               GROUP BY PBLSequenceId,[PBL NAME],ProductSequence,[Product!Code],[Product!Name] '
    
    PRINT(@Query)
    EXEC (@Query)
END

--DROP TABLE #Location
--DROP TABLE #Temp
--DROP TABLE #TempDate