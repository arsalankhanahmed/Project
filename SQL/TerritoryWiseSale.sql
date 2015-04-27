DECLARE @PrincipalTeamIds varchar(max),
		@SalesForce  varchar(max),
		@PBLIds  varchar(max),
		@Locations  varchar(max),
		@IsTemporary bit,
		@IsShopSale bit,
		@IsUnTagg bit,       		        
		@FromDate datetime,
		@ToDate datetime 
SET @PrincipalTeamIds =''--'36,32,33,34,35'
SET @SalesForce = ''--'4,26,28,73,75,95,96,102,108,113,116,118,119,141,146,153,181,196,199,205,11,18,45,47,53,57,66,78,89,93,122,130,133,158,164,171,179,188,191,206,1,12,14,16,34,36,58,63,87,91,120,123,145,170,186,197,202,208,210,219,2,22,27,35,46,49,67,70,107,126,131,134,135,144,149,177,180,182,216,217,'
SET @PBLIds='28,55'
SET @Locations='14'
SET @IsTemporary = 1
SET @IsShopSale = 1
SET @IsUnTagg = 1
SET @FromDate = '2013-11-23 00:00:00.000'
SET @ToDate = '2013-11-26 00:00:00.000'

SELECT 
	L.Name AS [Location Name],
	P.PBLSequenceId,
	P.[Principal Business Line], 
	P.DeliveryChallanId,
	P.PrincipalTeamId,
	P.[Principal Team],
	P.ProductId, 
	P.[Product Name],
	P.ProductSequence,
	P.[SoldQuantity],
	P.[Value],
	P.FFId,
	P.FFName,
	P.FFName AS [FFSeq],
	P.LocationId
	INTO #Temp
FROM 
(
	SELECT upbla.PBLSequenceId,upbla.Name AS [Principal Business Line],SOPROD.DeliveryChallanId, 
	       TeamProduct.PrincipalTeamId,TeamProduct.[Principal Team],
		   TeamProduct.ProductId, 
		   up.ShortName AS [Product Name],up.ProductSequence,
		   SUM(ISNULL(SOProd.SoldQuantity,0)) AS [SoldQuantity],
		   SUM(ISNULL(SOProd.SoldQuantity,0) * ISNULL(SOProd.TP,0)) AS [Value],
		   SOProd.FFId,
		   SOProd.FFName,
		   SOProd.FFName AS [FFSeq],
		   LocationId
	FROM   
	(
		 SELECT  ptp.PrincipalTeamProductId, ptp.PrincipalTeamId,ptt.ShortName AS [Principal Team],
		 ptp.ToBeDeleted,ptp.ProductId
		 FROM PrincipalTeamProduct ptp
		 INNER JOIN PrincipalTeam ptt ON ptt.PrincipalTeamId = ptp.PrincipalTeamId
		 INNER JOIN   DBO.Split(@PrincipalTeamIds, ',' ) PT ON ( PT.Data = ptp.PrincipalTeamId OR @PrincipalTeamIds = '' )         
		 WHERE  ptp.ToBeDeleted = 0          
		 AND DATEDIFF(day, ptt.EffectiveDate,GETDATE())>= 0
		 AND  DATEDIFF(day,GETDATE(), isnull( ptt.EndDate,GETDATE()+1))> 0
	)  TeamProduct
	LEFT JOIN 
	(
			SELECT so.LocationId,so.DeliveryChallanId, so.SaleOrderId,so.SalePassDate, so.IsCash, st.Code AS [Sale Type], sop.ProductId, 
			sop.SoldQuantity, so.CustomerId, sfo.PrincipalTeamId, sop.tp AS [TP],
			( CASE  WHEN st.Code = 'SHP' THEN -1 WHEN c.IsTemporary = 1 THEN -2 ELSE ISNULL(sfo.SalesForceId,-3) END ) AS FFId,
			( CASE  WHEN st.Code = 'SHP' THEN 'SHOP' WHEN c.IsTemporary = 1 THEN 'NEW' ELSE ISNULL(sfo.[FieldForceName],'UNTAG') END ) AS FFName,
			st.Code,
			c.IsTemporary
			FROM   SaleOrder so
			INNER JOIN DBO.Split(@Locations, ',' ) Loc ON   ( Loc.Data = so.LocationId OR @Locations = '' )
			INNER JOIN  SaleType st ON   so.SaleTypeId = st.SaleTypeId
			INNER JOIN  Customer c ON   ( c.CustomerId = so.CustomerId AND   c.LocationId = so.LocationId )
			INNER JOIN  SaleOrderProduct sop ON   ( sop.LocationId = so.LocationId AND   sop.SaleOrderId = so.SaleOrderId  AND sop.EndDate IS NULL )
			LEFT JOIN  
			(
				SELECT DISTINCT sfc.LocationId, sfc.CustomerId, sfc.PrincipalTeamId, sf.SalesForceId, sf.ShortName [FieldForceName],ptp.ProductId
				FROM SalesForceCustomer sfc
				INNER JOIN SalesForce sf ON sf.LocationId = sfc.LocationId
				AND sf.SalesForceId = sfc.SalesForceId
				INNER JOIN PrincipalTeam ptt ON ptt.PrincipalTeamId=sf.PrincipalTeamId
				INNER JOIN PrincipalTeamProduct ptp ON ptt.PrincipalTeamId=ptp.PrincipalTeamId AND ptp.ToBeDeleted=0			
				INNER JOIN DBO.Split(@PrincipalTeamIds, ',' ) PT ON ( PT.Data = sfc.PrincipalTeamId OR @PrincipalTeamIds = '' )  		 
				INNER JOIN DBO.Split(@SalesForce, ',' ) ff ON   ( ff.Data = sfc.SalesForceId OR @SalesForce = '' )	
				INNER JOIN DBO.Split(@Locations, ',' ) Loc ON   ( Loc.Data = sf.LocationId OR @Locations = '' )
				
				WHERE sfc.ToBeDeleted = 0
				    /*AND DATEDIFF(day, sf.EffectiveDate,ISNULL(@FromDate,GETDATE()))>= 0
					AND  DATEDIFF(day,ISNULL(@ToDate,GETDATE()), isnull( sf.EndDate,@ToDate+1))> 0*/
					AND DATEDIFF(day, sf.EffectiveDate,GETDATE())>= 0
					AND  DATEDIFF(day,GETDATE(), isnull( sf.EndDate,GETDATE()+1))> 0					  	
					AND DATEDIFF(day, ptt.EffectiveDate,GETDATE())>= 0
					AND  DATEDIFF(day,GETDATE(), isnull( ptt.EndDate,GETDATE()+1))> 0
					
			) SFO
			ON ( SFO.LocationId = so.LocationId AND SFO.Customerid = so.CustomerId  AND sop.ProductId=SFO.ProductId)
			WHERE   (DATEDIFF(DAY,so.SalePassDate,  @FromDate) <= 0 AND  DATEDIFF(DAY,so.SalePassDate,  @ToDate) >= 0)				   
			AND
			(
					(@IsTemporary = 1	OR (@IsTemporary = 0	AND  c.IsTemporary = 0))
				AND (@IsShopSale = 1	OR (@IsShopSale = 0		AND  st.Code <> 'SHP')	)
				AND (@IsUnTagg = 1		OR (@IsUnTagg = 0		AND  sfo.PrincipalTeamId IS NOT NULL))
			)
			
	) SOProd ON TeamProduct.ProductId = SOProd.ProductId 
	AND (TeamProduct.PrincipalTeamId = SOProd.PrincipalTeamId OR SOProd.PrincipalTeamId IS NULL)	
	INNER JOIN   uv_Product up ON   TeamProduct.ProductId = up.ProductId
    INNER JOIN uv_PrincipalBusinessLine_All upbla ON upbla.PrincipalBusinessLineId = up.PrincipalBusinessLineId   
    INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON   ( PBL.Data = up.PrincipalBusinessLineId OR @PBLIds = '' )
     	
	GROUP BY
	upbla.PBLSequenceId,upbla.Name,
	SOPROD.DeliveryChallanId,
	SOProd.FFId, SOProd.FFName,
	TeamProduct.PrincipalTeamId,
	TeamProduct.[Principal Team],
	up.ProductSequence,
	TeamProduct.ProductId, 
	up.ShortName,
	SOProd.CustomerId,SOProd.LocationId


	UNION ALL

	SELECT upbla.PBLSequenceId,upbla.Name AS [Principal Business Line],so.DeliveryChallanId,99999 AS PrincipalTeamId,
	[Product].[Principal Team], [Product].ProductId,[Product].Name ,[Product].ProductSequence,
	sum(sop.SoldQuantity) AS [SoldQuantity],
	sum(sop.SoldQuantity*sop.TP) AS [Amount],
	( CASE  WHEN st.Code = 'SHP' THEN -1 WHEN c.IsTemporary = 1 THEN -2 ELSE ISNULL(sf.SalesForceId,-3) END ) AS FFId,
	( CASE  WHEN st.Code = 'SHP' THEN 'SHOP' WHEN c.IsTemporary = 1 THEN 'NEW' ELSE ISNULL(sf.Name,'UNTAG') END ) AS FFName,
	( CASE  WHEN st.Code = 'SHP' THEN 'SHOP' WHEN c.IsTemporary = 1 THEN 'NEW' ELSE ISNULL(sf.Name,'UNTAG') END ) AS FFSeq	
	,SO.LocationId
	FROM 
	(
		SELECT up.ProductId, 
		up.Name,
		isnull(up.ProductSequence,99999) AS ProductSequence,
		ISNULL(pt.ShortName,'UNTAGGED PRODUCT') AS [Principal Team],
		up.PrincipalBusinessLineId,pt.PrincipalTeamId
		FROM uv_Product up
		LEFT OUTER JOIN PrincipalTeamProduct ptp ON ptp.ProductId = up.ProductId AND ptp.ProductSequence = up.ProductSequence
		AND ptp.ToBeDeleted = 0
		LEFT OUTER JOIN PrincipalTeam pt ON pt.PrincipalTeamId = ptp.PrincipalTeamId			
	   -- AND DATEDIFF(day, pt.EffectiveDate,ISNULL(@FromDate,GETDATE()))>= 0
	    --AND  DATEDIFF(day,ISNULL(@ToDate,GETDATE()), isnull( pt.EndDate,@ToDate+1))> 0	  
	     AND DATEDIFF(day, pt.EffectiveDate,GETDATE())>= 0
		 AND  DATEDIFF(day,GETDATE(), isnull( pt.EndDate,GETDATE()+1))> 0
		WHERE pt.PrincipalTeamId IS NULL	  
	) AS [Product] 
	INNER JOIN SaleOrderProduct sop ON Product.ProductId=sop.ProductId /*AND sop.EndDate IS NULL*/
	INNER JOIN SaleOrder so ON (so.SaleOrderId = sop.SaleOrderId AND so.LocationId = sop.LocationId)
	INNER JOIN SaleType st ON st.SaleTypeId=so.SaleTypeId
	INNER JOIN Customer c ON   ( c.CustomerId = so.CustomerId AND   c.LocationId = so.LocationId )
	INNER JOIN   DBO.Split(@Locations, ',' ) Loc ON   ( Loc.Data =so.LocationId OR @Locations = '' )
	LEFT OUTER  JOIN   SalesForceCustomer sfc ON   ( sfc.LocationId = so.LocationId AND   sfc.Customerid = so.CustomerId 
	AND sfc.ToBeDeleted=0 AND sfc.SalesForceCustomerId IS  null)
	LEFT OUTER JOIN   SalesForce sf ON   ( sf.LocationId = sfc.LocationId AND   sf.SalesForceId = sfc.SalesForceId )
	--INNER JOIN   DBO.Split(@SalesForce, ',' ) ff ON   ( ff.Data = sfc.SalesForceId OR @SalesForce = '' )
   INNER JOIN uv_PrincipalBusinessLine_All upbla ON upbla.PrincipalBusinessLineId =  [Product].PrincipalBusinessLineId
   INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON   ( PBL.Data = [Product].PrincipalBusinessLineId OR @PBLIds = '' )
    	
    WHERE    
    (DATEDIFF(DAY,so.SalePassDate,  @FromDate) <= 0 
	AND  DATEDIFF(DAY,so.SalePassDate,  @ToDate) >= 0)			      
    AND
		(
			(@IsTemporary=0 OR (@IsTemporary=1 AND c.IsTemporary=1))
		 OR (@IsShopSale=0 OR (@IsShopSale=1 AND st.Code='SHP'))
		 OR (@IsUnTagg=0 OR (@IsUnTagg=1 AND sfc.SalesForceCustomerId IS NULL))		 		
		)
		
	GROUP BY
		upbla.PBLSequenceId,
		upbla.Name,
		SO.DeliveryChallanId,
		[Product].[Principal Team], 
		[Product].ProductId,
		[Product].Name ,
		[Product].ProductSequence,
		st.Code,
		c.IsTemporary,
		sf.Name,
		sf.SalesForceId,
		SO.LocationId
		
	HAVING 
		sum(sop.SoldQuantity)>0 

)AS P
INNER JOIN Location l ON l.LocationId=P.LocationId
	


SELECT 
DISTINCT
IDENTITY(INT, 1,1) Id,
PrincipalTeamId,
[Principal Team]
INTO #tblLoop
FROM #Temp t

DECLARE @Count INT, @QUERY VARCHAR(max), @PrincipalTeam VARCHAR(50), 
@colFF VARCHAR(MAX),@colFFNonZeroQty VARCHAR(MAX),@colFFZeroQty VARCHAR(MAX)
,@PvtSummary VARCHAR(MAX)
,@PvtSummaryThousand VARCHAR(MAX)
,@colTQty varchar(max),@colSUMTQty varchar(max)

SET @Count = 1
WHILE @Count <= (SELECT COUNT(*) FROM #tblLoop)
	BEGIN
		
		SET @PrincipalTeam = (SELECT [Principal Team] FROM #tblLoop WHERE Id = @Count)	   			
		SET @colFF =
		ISNULL(( 
			SELECT DISTINCT '['+FFName + '], '
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')
		SET @colFF = @colFF + ' [SHOP], [NEW], [UNTAG]'		
	
		SET @colFFNonZeroQty = 
		ISNULL(( 
			SELECT DISTINCT '['+FFName + '], 0 [' + FFName + ' Value], ' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')                            
		SET @colFFNonZeroQty =@colFFNonZeroQty + ' [SHOP], 0 [SHOP Value], [NEW], 0 [NEW Value], [UNTAG], 0 [UNTAG Value]'
				
		SET @colFFZeroQty = 
		ISNULL(( 
			SELECT DISTINCT '0 ['+FFName + '], ['+FFName + '] [' + FFName + ' Value], ' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')                            
		SET @colFFZeroQty = @colFFZeroQty + ' 0 [SHOP], [SHOP] [SHOP Value], 0 [NEW], [NEW] [NEW Value], 0 [UNTAG], [UNTAG] [UNTAG Value]'
		
		SET @PvtSummary = 
		ISNULL(( 
			SELECT DISTINCT 'SUM(['+FFName + ']) AS ['+FFName + '],' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')              
		SET @PvtSummary = @PvtSummary+ ' ISNULL(SUM([SHOP]),0) [SHOP], ISNULL(SUM([NEW]),0) [NEW], ISNULL(SUM([UNTAG]),0) [UNTAG]'
	
		SET @PvtSummaryThousand = 
		ISNULL(( 
			SELECT DISTINCT 'SUM(['+FFName + '])/1000 AS ['+FFName + '],' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')              
			
		SET @PvtSummaryThousand =@PvtSummaryThousand + ' SUM([SHOP])/1000 [SHOP], SUM([NEW])/1000 [NEW], SUM([UNTAG])/1000 [UNTAG]'		
		
		SET @colSUMTQty = 'SUM(' +
		ISNULL(( 
			SELECT DISTINCT + 'ISNULL(['+ FFName + '],0)+ ' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')                            
		SET @colSUMTQty = @colSUMTQty+ ' ISNULL([SHOP],0)+ ISNULL([NEW],0)+ ISNULL([UNTAG],0)' + ')'
	
		SET @colTQty =
		ISNULL(( 
			SELECT DISTINCT + 'ISNULL(['+ FFName + '],0)+ ' 
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = @Count
			AND FFName NOT IN ('SHOP', 'NEW', 'UNTAG')
			FOR XML PATH('' ) 
		),'')                            
		SET @colTQty = @colTQty+ ' ISNULL([SHOP],0)+ ISNULL([NEW],0)+ ISNULL([UNTAG],0)'
		
					
		SET @QUERY = 
		(
		'		
		 SELECT * 
		 FROM
		 (			
		 SELECT A.[Location Name],A.DeliveryChallanId, A.ProductSequence ,A.PrincipalTeamId,A.[Principal Team], A.[Code],A.[Product Name],'+@PvtSummary+', SUM(A.[T.QTY]) [T.QTY], SUM(A.[T.VALUE]) [T.VALUE]
		 FROM
		 (
			SELECT [Location Name],st.DeliveryChallanId,PrincipalTeamId,''Team: '+ @PrincipalTeam +''' AS [Principal Team], ProductSequence , ProductId [Code], [Product Name], '+@colFFNonZeroQty+', '+@colTQty+' AS [T.QTY],0 AS [T.VALUE]
			FROM
			(
				SELECT t.[Location Name],t.DeliveryChallanId,t.PrincipalTeamId,
					   t.[Principal Business Line], CONVERT(char(11),t.ProductId) as [ProductId],t.[Product Name],  
					   T.FFName, ISNULL(SoldQuantity,0) as [SoldQuantity] ,
					   T.ProductSequence
				FROM #tblLoop L 
				INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
				WHERE Id = ' + CONVERT(VARCHAR(10), @Count) + '
			)ST
			PIVOT
			(SUM(SOLDQUANTITY) FOR FFName IN ('+@colFF+')) AS PVT
			
			UNION ALL
			
			SELECT [Location Name],st.DeliveryChallanId,,PrincipalTeamId,''Team: '+ @PrincipalTeam +''' AS [Principal Team], ProductSequence , ProductId [Code], [Product Name], '+@colFFZeroQty+', 0 AS [T.QTY], '+@colTQty+' AS [T.VALUE]
			FROM
			(
				SELECT t.[Location Name],t.PrincipalTeamId,
					   t.[Principal Business Line],t.DeliveryChallanId, CONVERT(char(11),t.ProductId) as [ProductId],t.[Product Name],  
					   T.FFName, ISNULL(Value,0) as [Value], 
					   T.ProductSequence
				FROM #tblLoop L 
				INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
				WHERE Id = ' + CONVERT(VARCHAR(10), @Count) + '
			)ST
			PIVOT
			(SUM(Value) FOR FFName IN ('+@colFF+')) AS PVT		
		 ) AS [A]
		 GROUP BY
		 A.[Location Name],A.PrincipalTeamId,A.[Principal Team], A.[Code],A.[Product Name] , A.ProductSequence
		 		 
		 )SA
		 
		 UNION ALL
	
		SELECT [Location Name],st.DeliveryChallanId 99999 ProductSequence ,99999 AS PrincipalTeamId,'''' AS [Principal Team],'''' as  [Code],''Team: '+ @PrincipalTeam +' VALUES(''''000)'' AS [Product Name], '+@PvtSummaryThousand+', 0 AS [T.QTY], '+@colSUMTQty+' AS [T.VALUE]
		FROM
		(
			SELECT t.[Location Name], t.PrincipalTeamId,
				   t.[Principal Business Line],t.DeliveryChallanId, CONVERT(char(11),t.ProductId) as [ProductId],t.[Product Name],  
				   T.FFName, ISNULL(Value,0) as [Value] ,
				   T.ProductSequence
			FROM #tblLoop L 
			INNER JOIN #TEMP T ON l.PrincipalTeamId = t.PrincipalTeamId
			WHERE Id = ' + CONVERT(VARCHAR(10), @Count) + '
			
		)ST
		
		PIVOT
		(SUM(Value) FOR FFName IN ('+@colFF+')) AS PVT
		GROUP BY [Location Name]
		Order by  ProductSequence
		 '
		)
				
		BEGIN TRY
			EXEC (@QUERY)			
		END TRY		
		BEGIN CATCH
			PRINT ('eRROR')
			PRINT (@QUERY)
		END CATCH
			
		
		SET @Count = @Count + 1	
	  	
	END				
	
--DROP TABLE #tblLoop					
--DROP TABLE #Temp
SELECT a.DeliveryChallanId,sum(a.SoldQuantity) AS [R59 Quantity]--SUM(a.SoldQuantity) 
FROM #TEMP a WHERE a.ProductId = 14 AND PrincipalTeamId <> 99999
GROUP BY a.DeliveryChallanId
--AND a.DeliveryChallanId IN  

SELECT so.DeliveryChallanId,SUM(sop.SoldQuantity) AS [DC Quantity]
FROM dbo.SaleOrder so INNER JOIN dbo.SaleOrderProduct sop ON so.LocationId = sop.LocationId AND so.SaleOrderId = sop.SaleOrderId
--GROUP BY so.DeliveryChallanId
WHERE (DATEDIFF(DAY,so.SalePassDate,  '2013/11/23') <= 0 AND  DATEDIFF(DAY,so.SalePassDate,  '2013/11/26') >= 0) AND sop.ProductId = 14 AND sop.SoldQuantity>0
GROUP BY so.DeliveryChallanId