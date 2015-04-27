CREATE PROC [dbo].[usp_Report_CustomerPeriodicalSale] 
	@CompanyIds varchar(20), 
	@LocationIds varchar(200), 
	@PBLIds varchar(100),
	@ProductIds varchar(MAX), 
	@MainAreaIds varchar(MAX),  
	@SubAreaIds varchar(MAX),  
	@CustomerIds varchar(MAX),
	@SaleTypeIds varchar(100),   
	@SaleCriteria int, 
	@FromDate datetime, 
	@ToDate datetime,   	   
	@IsCash bit,
	@IsCredit bit,
	@CustStatus int
AS 
--DECLARE @PBLIds varchar(100),
--@ProductIds nvarchar(MAX),
--        @LocationIds varchar(100),@MainAreaIds NVARCHAR(MAX), @SubAreaIds NVARCHAR(MAX),
--        @CustomerIds varchar(100),
--        @SaleCriteria int,
--        @SaleTypeIds varchar(100),
--        @IsCash bit,
--        @IsCredit bit,
--        @FromDate datetime,
--        @ToDate datetime,@CustStatus int  
--SET @PBLIds =''
--SET @LocationIds = ''
--SET @CustomerIds =''
--SET @MainAreaIds  = '' 
--set @SubAreaIds=''
--SET @SaleCriteria =1
--SET @SaleTypeIds = ''--'1,2,3,4,5'
--SET @IsCash = 1
--SET @IsCredit =1
--SET @FromDate = '2014-04-01 00:00:00'
--SET @ToDate = '2014-06-17 00:00:00'
--SET @CustStatus =0
--SET @ProductIds = ''
/*
Sale Criteria 
0-Gross Sale --Only Value
1-Net Sale -- Value-SLN
2-SLN--Only SLN
*/

SELECT 
    [tbl].LocationId,  
	l.ShortName AS [Location Name], 
	l.SequenceId AS [Loc Seq],
	[tbl].IsCash, 
	[tbl].CustomerId,
	c.[Customer Name],
	c.[Main Area],
	c.[Sub Area],
	[tbl].[Date],
	sum([Amount]) AS [Amount]
	INTO #TEMP
FROM 
(
	SELECT 
	SO.LocationId AS LocationId,  
	so.IsCash,
	so.CustomerId,
	so.PrincipalBusinessLineId, 
	so.ProductId,
	RIGHT(CONVERT(char(11),so.SalePassDate,13),8) AS [Date],
	so.SalePassDate AS TransactionDate,
	so.TP* so.SoldQuantity AS [Amount]
	FROM uv_Sales_SaleOrder so
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON   ( Loc.Data = so.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON   ( PBL.Data = so.PrincipalBusinessLineId OR @PBLIds = '' )
		INNER JOIN 	 DBO.Split(@ProductIds, ',' ) Product ON   ( Product.Data = so.ProductId OR @ProductIds= '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Cus ON   ( Cus.Data = so.CustomerId OR @CustomerIds = '' )
		INNER JOIN   DBO.Split(@SaleTypeIds, ',' ) SaleType ON   ( SaleType.Data = so.SaleTypeId OR @SaleTypeIds = '' )
	WHERE  
		DATEDIFF(DAY, so.SalePassDate,  @FromDate ) <= 0 
		AND  DATEDIFF(DAY,  so.SalePassDate,  @ToDate ) >= 0 	
		AND so.IsRollbacked = 0
		AND ((@IsCash=1 AND so.IsCash=1)  OR (@IsCredit=1 AND so.IsCash=0))
		AND @SaleCriteria <> 2 /*--to show Only SLN--*/
		
		
	/*------ SLN PRODUCT ------*/
	UNION ALL 

	SELECT 
		S.LocationId AS LocationId, 
		S.IsCash,
		s.CustomerId,
		S.PrincipalBusinessLineId,
		s.ProductId, 
		RIGHT(CONVERT(char(11),s.TransactionDate,13),8) AS [Date],
		s.TransactionDate, 
		CASE WHEN s.IsFree=0 THEN (PC.TP * CASE WHEN @SaleCriteria=1 THEN  -1 * s.Quantity ELSE s.Quantity END)	ELSE 0 END  AS [Amount]
	FROM uv_Sales_SLN s
		INNER JOIN   PriceCatalog pc ON   pc.PriceCatalogId = s.PriceId
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON   ( Loc.Data = S.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON   ( PBL.Data = S.PrincipalBusinessLineId OR @PBLIds = '' )
		INNER JOIN 	 DBO.Split(@ProductIds, ',' ) Product ON   ( Product.Data = S.ProductId OR @ProductIds= '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Cus ON   ( Cus.Data = S.CustomerId OR @CustomerIds = '' )
		
	WHERE  
		DATEDIFF(DAY, S.TransactionDate,  @FromDate ) <= 0 
		AND  DATEDIFF(DAY, S.TransactionDate,  @ToDate ) >= 0
		AND s.IsFree = 0
		AND  s.IsRollbacked = 0
		AND @SaleCriteria <> 0
		
			
)AS [tbl]
INNER JOIN Location l ON   l.LocationId = [tbl].LocationId
INNER JOIN uv_CustomerSalesArea c ON c.LocationId=[tbl].LocationId AND c.CustomerId=[tbl].CustomerId
INNER JOIN   DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = c.MainAreaId OR @MainAreaIds = '' )
INNER JOIN   DBO.Split(@SubAreaIds, ',' ) SubArea ON ( SubArea.Data = c.SubAreaId OR @SubAreaIds = '' )
WHERE 
 
		(
			   @CustStatus = 0
		   OR  (
				   @CustStatus = 1
			  AND  (
					   DATEDIFF(day, c.[Cus Effective Date],GETDATE())>= 0
					AND  DATEDIFF(day,GETDATE(), isnull( c.[CSA EndDate],GETDATE()+1))> 0
				   )
			   )
		   OR  (
				   @CustStatus = 2
				   AND  DATEDIFF(day,c.[CSA EndDate],ISNULL(GETDATE(), GETDATE()+1))>0               
			   )
		)	

GROUP BY	
    [tbl].LocationId,  
	l.ShortName , 
	l.SequenceId ,
	[tbl].IsCash, 
	[tbl].CustomerId,
	c.[Customer Name],
	c.[Main Area],
	c.[Sub Area],
	[tbl].[Date]

DECLARE @QUERY VARCHAR(8000),@pvtSumIsNullAmount VARCHAR(MAX),@pvtNonZeroAmountDate VARCHAR(MAX)
		
		SET @pvtNonZeroAmountDate = 
		( 
			SELECT  '[' + A.[Date] + '] , '
			FROM
			(
				SELECT DISTINCT t.[Date]
				FROM 
				#TEMP T
			) A
			ORDER BY Year(A.[Date]), Month(A.[Date])
			FOR XML PATH('' ) 
		)                            
		SET @pvtNonZeroAmountDate = LEFT( @pvtNonZeroAmountDate, LEN(@pvtNonZeroAmountDate )-1 )                          
	
		SET @pvtSumIsNullAmount = 
		( 
			SELECT  'ISNULL(SUM([' + A.[Date] + ']), 0) AS ['+A.[Date] +'],'
			FROM
			(
				SELECT DISTINCT t.[Date]
				FROM #TEMP T
			) A
			ORDER BY Year(A.[Date]), Month(A.[Date])
			FOR XML PATH('' ) 
		)                            
		SET @pvtSumIsNullAmount = LEFT( @pvtSumIsNullAmount, LEN(@pvtSumIsNullAmount )-1 )
		
		SET @QUERY = 
			'
			
				SELECT [Loc Seq],[Location Name],[Main Area],[Sub Area],CustomerId,[Customer Name], '+@pvtSumIsNullAmount+' FROM
				(
					SELECT t.[Loc Seq],t.[Location Name],t.[Main Area],t.[Sub Area],t.CustomerId,t.[Customer Name],  T.[Date], isnull(Amount,0) as [Amount] 
					FROM #TEMP T 
				)ST
				PIVOT
				(SUM(Amount) FOR [Date] IN ('+@pvtNonZeroAmountDate+')) AS PVT	
				GROUP BY [Loc Seq],[Location Name],[Main Area],[Sub Area],CustomerId,[Customer Name]
				Order BY [Loc Seq],[Main Area],[Sub Area],[Customer Name]						
			'
			EXEC (@QUERY)
			PRINT (@QUERY)										
DROP TABLE  #TEMP
