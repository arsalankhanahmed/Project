--CREATE PROC [dbo].[usp_Report_CustomerPeriodicalSale] 
--	@LocationIds varchar(200), 
--	@CompanyIds varchar(20),  
--	@PBLIds varchar(100),   
--	@SaleTypeIds varchar(100),   
--	@MainAreaIds varchar(MAX),  
--	@SubAreaIds varchar(MAX),  
--	@CustomerIds varchar(MAX),  
--	@ProductIds varchar(MAX), 
--	@FromDate datetime, 
--	@ToDate datetime,   	   
--	@IsCash bit,
--	@IsCredit bit,
--	@CustStatus int
--AS 

DECLARE 
	@LocationIds varchar(1000), 
	@CompanyIds varchar(1000),  
	@PBLIds varchar(1000),   
	@SaleTypeIds varchar(1000),   
	@MainAreaIds varchar(1000),  
	@SubAreaIds varchar(1000),  
	@CustomerIds varchar(1000),  
	@ProductIds varchar(1000),   
	@FromDate datetime, 
	@ToDate datetime,   		      
    @IsCash bit,
	@IsCredit bit,
	@CustStatus INT,
	@Period INT
SET @LocationIds = ''--'11,14'--'11,18,23,28,30,35,37,42,44'  
SET @CompanyIds= '1'
SET @PBLIds = ''--3,4,'--'7,3,5,28,40,4,33,37,38,20,35,41,43,44,45,47,48,49,50,55,57,58,59,60,61,62'
SET @SaleTypeIds = ''--'1,2,3,4,5'
SET @MainAreaIds = ''--'24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43'
SET @SubAreaIds = ''--'149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238'
SET @ProductIds = '' --'2545'
SET @CustomerIds= ''--'2780,2781'
SET @FromDate = '2014-04-01'  
SET @ToDate = GETDATE() 
SET @IsCash= 1
SET @IsCredit= 1
SET @CustStatus = 0
SET @Period  = 0
SELECT 
	L.SequenceId AS [LocationSequence],	
	l.ShortName AS [LOCATION NAME], 	
	A.[SALE DATE],
	Case When @Period = 0 then LEFT(RIGHT(convert(varchar(20),[SALE DATE],06),6),3)+'-'+RIGHT(convert(varchar(20),[SALE DATE],06),2)
	ELSE LEFT(CONVERT(VARCHAR(7), [SALE DATE], 111),4) END 
	AS [PERIOD],            
	A.CustomerId AS [CODE],
	csa.[Customer Name] AS [CUSTOMER NAME],
	csa.[Main Area] AS [MAIN AREA],
	csa.[Sub Area] AS [SUB AREA],
	a.[SALE NATURE] AS [SALE NATURE],	
	up.PBLShortName AS [PBL],
	A.ProductId  AS [PROD ID], 	
	UP.Name  AS [PRODUCT NAME], 		
	sum(a.[TP Value]) [TP VALUE]
	INTO #temp
FROM 
(
	SELECT 
		so.LocationId, 
		SO.SalePassDate AS [SALE DATE],	
		SO.CustomerId,
		sop.PrincipalBusinessLineId, 
		sop.ProductId,  
		CASE WHEN SO.IsCash=1 THEN 'CASH' ELSE 'CREDIT' END AS [SALE NATURE], 			
		ISNULL(sop.SoldQuantity * sop.TP,0)  [TP Value]
	FROM SaleOrder SO INNER JOIN SaleOrderProduct sop ON   sop.LocationId = SO.LocationId 
		 AND   sop.SaleOrderId = SO.SaleOrderId 				
		INNER JOIN   DBO.Split(@CompanyIds, ',' ) Company ON ( Company.Data = SO.CompanyId OR @CompanyIds = '' )	
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON  ( Loc.Data = SO.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Customer ON ( Customer.Data = SO.CustomerId OR @CustomerIds = '' )						
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON (PBL.Data = sop.PrincipalBusinessLineId OR @PBLIds = '' )
		INNER JOIN   DBO.Split(@ProductIds, ',' ) Product ON ( Product.Data = sop.ProductId OR @ProductIds = '' )			 
		INNER JOIN   DBO.Split(@SaleTypeIds, ',' ) SaleTypes ON ( SaleTypes.Data = so.SaleTypeId OR @SaleTypeIds = '' )			 
	
	WHERE  SO.IsRollbacked = 0
		AND sop.EndDate IS NULL 
		AND ( DATEDIFF(DAY,SO.SalePassDate,@FromDate) <= 0 AND  DATEDIFF(DAY,SO.SalePassDate,@ToDate) >= 0)                                              	
		AND((@IsCash=1 AND SO.IsCash=1)  OR (@IsCredit=1 AND SO.IsCash=0)) 
			
	UNION ALL
	
	SELECT 
		S.LocationId, 
		S.TransactionDate AS [SALE DATE],	
		s.CustomerId,
		s.PrincipalBusinessLineId, 
		s2.ProductId, 
		CASE WHEN s.IsCash=1 THEN 'CASH' ELSE 'CREDIT' END  AS [SALE NATURE],		
		-1*s2.Quantity * pc.TP  [TP Value]
	FROM SLN s
		INNER JOIN SLNProduct s2 ON s2.LocationId = s.LocationId AND s2.SLNId = s.SLNId   
		INNER JOIN PriceCatalog pc ON  pc.PriceCatalogId=s2.PriceId
		INNER JOIN   DBO.Split(@CompanyIds, ',' ) Company ON ( Company.Data = s.CompanyId OR @CompanyIds = '' )	
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON  ( Loc.Data = s.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Customer ON ( Customer.Data = s.CustomerId OR @CustomerIds = '' )						
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON (PBL.Data = s.PrincipalBusinessLineId OR @PBLIds = '' )			 
		INNER JOIN   DBO.Split(@ProductIds, ',' ) Product ON ( Product.Data = s2.ProductId OR @ProductIds = '' )			
		
	WHERE s2.Quantity > 0 
		AND (DATEDIFF(DAY,s.TransactionDate,  @FromDate) <= 0 AND DATEDIFF(DAY,s.TransactionDate,  @ToDate) >= 0)
		AND((@IsCash=1 AND s.IsCash=1)  OR (@IsCredit=1 AND s.IsCash=0)) 
		AND s2.IsFree=0
		AND S.IsRollbacked = 0	
) A 
INNER JOIN  uv_Product up ON  up.ProductId = A.ProductId
INNER JOIN  Location l ON  l.LocationId = A.LocationId
INNER JOIN  uv_CustomerSalesArea csa ON csa.LocationId=A.LocationId AND csa.CustomerId=A.CustomerId
INNER JOIN   DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = csa.MainAreaId OR @MainAreaIds = '' )
INNER JOIN   DBO.Split(@SubAreaIds, ',' ) SubArea ON ( SubArea.Data = csa.SubAreaId OR @SubAreaIds = '' )

WHERE
		( @CustStatus = 0 OR ( @CustStatus = 1 AND ( DATEDIFF(day, csa.[Cus Effective Date],GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( csa.[Cus End Date],GETDATE()+1))> 0))
	OR ( @CustStatus = 2 AND  DATEDIFF(day,csa.[Cus End Date],ISNULL(GETDATE(), GETDATE()+1))>0 ))
 	
GROUP BY L.SequenceId ,	
	l.ShortName , 	
	A.[SALE DATE],            
	A.CustomerId,
	csa.[Customer Name] ,
	csa.[Main Area] ,
	csa.[Sub Area] ,
	a.[SALE NATURE],
	up.PBLShortName,
	A.ProductId,   	
	UP.Name    
	
DECLARE @pvtPERIOD NVARCHAR(MAX)
SET @pvtPERIOD = (SELECT DISTINCT '[' +PERIOD+  '], '
					FROM #TEMP 
                    FOR XML PATH(''), root('MyString'), type).value('/MyString[1]','varchar(max)')               
SET @pvtPERIOD= LEFT( @pvtPERIOD,LEN(@pvtPERIOD)-1 )  
--SELECT @pvtPERIOD
DECLARE @Query NVARCHAR(MAX)
SET @Query = '
SELECT [LocationSequence],[LOCATION NAME],[CODE],[CUSTOMER NAME],[MAIN AREA],[SUB AREA],[SALE NATURE],[PBL],[PROD ID],[PRODUCT NAME],'+@pvtPERIOD+'
FROM
(	SELECT	[LocationSequence],[LOCATION NAME],[CODE],[CUSTOMER NAME],[MAIN AREA],[SUB AREA],[SALE NATURE],[PBL],[PROD ID],[PRODUCT NAME],Isnull([TP VALUE],0) as [TP VALUE],PERIOD
	FROM #TEMP 
 	Where [LocationSequence]= 52
)a
PIVOT(SUM([TP VALUE])  FOR a.PERIOD IN ('+@pvtPERIOD+')) as PVT '
 
--SELECT Distinct PERIOD,CONVERT(Date,'01-'+Period,112) AS sodate
--INTO #tblLoop 
--FROM #TEMP
--ORDER BY 
--CONVERT(Date,'01-'+Period,112)

DECLARE @PeriodCount INT
SET @PeriodCount =  1

--WHILE @PeriodCount <= (SELECT COUNT(*) FROM #tblLoop) 
BEGIN
  EXEC(@Query)
  PRINT(@Query)
--SET @PeriodCount = @PeriodCount + 1
END



