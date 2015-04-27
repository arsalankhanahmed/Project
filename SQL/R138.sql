ALTER PROC [dbo].[usp_Report_GenericDataSetSales] 
	@LocationIds varchar(200), 
	@CompanyIds varchar(20),  
	@PBLIds varchar(100),   
	@SaleTypeIds varchar(100),   
	@MainAreaIds varchar(MAX),  
	@SubAreaIds varchar(MAX),  
	@CustomerIds varchar(MAX),  
	@ProductIds varchar(MAX),  	
	@BatchNo varchar(50), 
	@SelectAll int,
	@FromDate datetime, 
	@ToDate datetime,   	   
	@IsCash bit,
	@IsCredit bit,
	@CustStatus int ,
	@MAreaStatus INT,
	@SAreaStatus INT,
	@BookerStatus INT,
	@SupplierStatus INT,
    @IsinvoiceDate BIT,
    @PBLWise BIT
AS 

--DECLARE 
--	@LocationIds varchar(1000), 
--	@CompanyIds varchar(1000),  
--	@PBLIds varchar(1000),   
--	@SaleTypeIds varchar(1000),   
--	@MainAreaIds varchar(1000),  
--	@SubAreaIds varchar(1000),  
--	@CustomerIds varchar(1000),  
--	@ProductIds varchar(1000),   
--	@BatchNo varchar(10),  
--	@SelectAll int, 
--	@FromDate datetime, 
--	@ToDate datetime,   		      
--    @IsCash bit,
--	@IsCredit bit,
--	@MAreaStatus INT,
--	@SAreaStatus INT,
--	@BookerStatus INT,
--	@SupplierStatus INT,
--	@CustStatus INT,
--	@IsinvoiceDate  BIT ,
--  @PBLWise BIT 
--SET @LocationIds = '11'--'11,14'--'11,18,23,28,30,35,37,42,44'  
--SET @CompanyIds= '1'
--SET @PBLIds = '3'--3,4,'--'7,3,5,28,40,4,33,37,38,20,35,41,43,44,45,47,48,49,50,55,57,58,59,60,61,62'
--SET @SaleTypeIds = ''--'1,2,3,4,5'
--SET @MainAreaIds = ''--'24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43'
--SET @SubAreaIds = ''--'149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238'
--SET @ProductIds = '' --'2545'
--SET @BatchNo = ''
--SET @CustomerIds= ''--'2780,2781'
--SET @SelectAll=2
--SET @FromDate = '2014-05-01'  
--SET @ToDate = '2014-05-31' 
--SET @IsCash= 1
--SET @IsCredit= 1
--SET @CustStatus = 0
--SET @IsinvoiceDate = 0
--SET @MAreaStatus = 0
--SET @SAreaStatus = 0
--SET @BookerStatus = 0
--SET @SupplierStatus = 0
--SET @PBLWise = 0
--SELECT * 
--INTO #CUSTOMER 
--FROM
--(
--	SELECT so.LocationId,
--		   SO.SaleOrderId,
--		   so.TransactionDate,
--		   SO.SalePassDate,
--		   so.SaleTypeId,
--		   SO.BookerId,
--		   SO.SupplierId,
--		   so.IsCash,
--		   csa.Customerid,
--		   csa.[Customer Name],
--		   csa.[Address],
--		   sa.MainAreaId,
--		   csa.SubAreaId,
--		   csa.[Sub Area]
--	FROM SALEORDER SO 
--	INNER JOIN uv_CustomerSalesArea csa ON SO.LocationId = CSA.LocationId 
--	 AND SO.CustomerId = CSA.CUSTOMERID 
--	INNER JOIN SubArea sa ON sa.SubAreaId = csa.SubAreaId
--	INNER JOIN   DBO.Split(@CompanyIds, ',' ) Company ON ( Company.Data = so.CompanyId OR @CompanyIds = '' )
--	INNER JOIN   DBO.Split(@CustomerIds, ',' ) Customer ON ( Customer.Data = so.CustomerId OR @CustomerIds = '' )
--	INNER JOIN DBO.Split(@LocationIds, ',' ) Loc ON ( Loc.Data = csa.LocationId OR @LocationIds = '')
--	INNER JOIN DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = csa.MainAreaId OR @MainAreaIds = '')
--	INNER JOIN DBO.Split(@SubAreaIds, ',' )  SubArea  ON ( SubArea.Data = csa.SubAreaId   OR @SubAreaIds = '' )


--	WHERE SO.IsRollbacked = 0 AND  so.CustomerToBeOpenedSubAreaId IS NULL AND 
--	(
--		@MAreaStatus = 0
--		OR (
--			   @MAreaStatus = 1
--			   AND (
--					   DATEDIFF(DAY, csa.[Main Area EffectiveDate], GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(csa.[Main Area EndDate], GETDATE() + 1)) > 0
--				   )
--		   )
--		OR (
--			   @MAreaStatus = 2
--			   AND DATEDIFF(DAY, csa.[Main Area EndDate], ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)	
--		AND 
--	(
--		@SAreaStatus = 0
--		OR (
--			   @SAreaStatus = 1
--			   AND (
--					   DATEDIFF(DAY, sa.EffectiveDate, GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(sa.EndDate, GETDATE() + 1)) > 0
--				   )
--		   )
--		OR (
--			   @SAreaStatus = 2
--			   AND DATEDIFF(DAY, sa.EndDate, ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)
--		AND 
--	(
--		@CustStatus = 0
--		OR (
--			   @CustStatus = 1
--			   AND (
--					   DATEDIFF(DAY, csa.[Cus Effective Date], GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(csa.[Cus End Date], GETDATE() + 1)) > 0
--				   )
--		   )
--		OR (
--			   @CustStatus = 2
--			   AND DATEDIFF(DAY, csa.[Cus End Date], ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)

--	UNION ALL

--	SELECT so.LocationId,
--		   SO.SaleOrderId,
--		   so.TransactionDate,
--		   SO.SalePassDate,
--		   so.SaleTypeId,
--		   SO.BookerId,
--		   SO.SupplierId,
--		   so.IsCash,
--		   csa.Customerid,
--		   SO.CustomerToBeOpenedName [Customer Name],
--		   so.CustomerToBeOpenedAddress [Address],
--		   sa.MainAreaId,
--		   sa.SubAreaId,
--		   sa.[Name] [Sub Area]
--	FROM SaleOrder so 
--	INNER JOIN  Customer csa ON so.LocationId = csa.LocationId 
--	 AND so.CustomerId = csa.CustomerId
--	INNER JOIN SubArea sa ON sa.SubAreaId = so.CustomerToBeOpenedSubAreaId
--	INNER JOIN MainArea ma ON ma.MainAreaId = sa.MainAreaId
--	INNER JOIN location l ON csa.LocationId = l.LocationId
--	INNER JOIN DBO.Split(@LocationIds, ',' ) Loc ON ( Loc.Data = csa.LocationId OR @LocationIds = '')
--	INNER JOIN DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = sa.MainAreaId OR @MainAreaIds = '')
--	INNER JOIN DBO.Split(@SubAreaIds, ',' )  SubArea  ON ( SubArea.Data = sa.SubAreaId   OR @SubAreaIds = '' )

--	WHERE SO.IsRollbacked = 0   
--	AND so.CustomerToBeOpenedSubAreaId IS NOT NULL 
--	AND 
--	(
--		@MAreaStatus = 0
--		OR (
--			   @MAreaStatus = 1
--			   AND (
--					   DATEDIFF(DAY, ma.EffectiveDate, GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(ma.EndDate, GETDATE() + 1)) > 0
--				   )
--		   )
--		OR (
--			   @MAreaStatus = 2
--			   AND DATEDIFF(DAY, ma.EndDate, ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)	
--		AND 
--	(
--		@SAreaStatus = 0
--		OR (
--			   @SAreaStatus = 1
--			   AND (
--					   DATEDIFF(DAY, sa.EffectiveDate, GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(sa.EndDate, GETDATE() + 1)) > 0
--				   )
--		   )
--		OR (
--			   @SAreaStatus = 2
--			   AND DATEDIFF(DAY, sa.EndDate, ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)
--		AND 
--	(
--		@CustStatus = 0
--		OR (
--			   @CustStatus = 1
--			   AND (
--					   DATEDIFF(DAY, csa.EffectiveDate, GETDATE()) >= 0
--					   AND DATEDIFF(DAY, GETDATE(), ISNULL(csa.EndDate, GETDATE() + 1))
--						   > 0
--				   )
--		   )
--		OR (
--			   @CustStatus = 2
--			   AND DATEDIFF(DAY, csa.EndDate, ISNULL(GETDATE(), GETDATE() + 1)) > 0
--		   )
--	)
--)C


SELECT 	
	l.ShortName AS [LOCATION NAME], 	
	A.SaleOrderId AS [SO NO],
	a.[SO DATE] ,
	convert(VARCHAR(10),A.[SALE DATE],103) AS [SALE DATE],
	right(convert(varchar(20),[SALE DATE],06), len(convert(varchar(20),[SALE DATE],06)) -3)AS [PERIOD],            
	A.CustomerId AS [CODE],
	csa.[Customer Name] AS [CUSTOMER NAME],
	csa.Address AS [ADDRESS],
	csa.[Main Area] AS [MAIN AREA],
	csa.[Sub Area] AS [SUB AREA],
	a.[SALE NATURE] AS [SALE NATURE],
	a.SaleTypeId,
	A.[SALE TYPE],	
	us.Name AS [BOOKER],	
	US1.Name AS [SUPPLIER],
	up.PBLShortName AS [PBL],
	Case when @PBLWise = 0 then  pl.[Description] ELSE '' END AS [PRODUCT LINE],
	Case when @PBLWise = 0 then A.ProductId ELSE '' END AS [PROD ID], 	
	Case when @PBLWise = 0 then UP.Name ELSE '' END AS [PRODUCT NAME], 		
	Case when @PBLWise = 0 then A.BatchNumber ELSE '' END AS [BATCH NO],
	Case when @PBLWise = 0 then B.ExpiryDate ELSE '1900-01-01' END AS [BATCH EXPIRY],
	Case when @PBLWise = 0 then isnull(A.[ORDER Quantity],0) ELSE 0 END AS [ORDER QUANTITY],
	Case when @PBLWise = 0 then isnull(A.[Invoice Quantity],0) ELSE 0 END AS [INVOICE QUANTITY],
	Case when @PBLWise = 0 then A.TP ELSE 0 END AS [TP],  
	-- pl.[Description] [PRODUCT LINE],
	--A.ProductId [PROD ID], 	
	--UP.Name AS [PRODUCT NAME], 		
	--A.BatchNumber AS [BATCH NO],
	--B.ExpiryDate AS [BATCH EXPIRY],
	--isnull(A.[ORDER Quantity],0) AS [ORDER QUANTITY],
	--isnull(A.[Invoice Quantity],0) AS [INVOICE QUANTITY],
	--A.TP AS [TP], 
	CONVERT(DECIMAL(18, 4),CASE WHEN ST.IsFree = 1 THEN 0 ELSE a.[TP Value] END) [TP VALUE],
	A.[Discount Value], 
	A.[Tax Value]
	INTO #temp
FROM 
(
	SELECT 
		so.LocationId, 
		CONVERT(VARCHAR(10),SO.SaleOrderId) AS SaleOrderId,
		SO.TransactionDate AS [SO DATE],
		SO.SalePassDate AS [SALE DATE],
		SO.SaleTypeId, 	
		st1.Name AS [SALE TYPE],			
--		C.MainAreaId,
--		C.SubAreaId,	
--		C.[Sub Area] AS [Sub Area],	
		SO.BookerId, 
		SO.SupplierId,
		SO.CustomerId,
--		C.[Customer Name] AS [Customer],
--		C.Address AS [Address],
		sop.PrincipalBusinessLineId, 
		sop.ProductId, 
		sop.StockTypeId, 
		sop.BatchNumber, 
		sop.TP,
		CASE WHEN SO.IsCash=1 THEN 'CASH' ELSE 'CREDIT' END AS [SALE NATURE], 
		sop.OrderQuantity  AS [ORDER Quantity],
		sop.SoldQuantity AS [Invoice Quantity],			
		ISNULL(sop.SoldQuantity * sop.TP,0)  [TP Value],
		sop.TotalOutputTaxGST + sop.TotalOutputTaxOther AS [Tax],
		(sop.SoldQuantity * sop.TP) + (sop.TotalOutputTaxGST + sop.TotalOutputTaxOther) [Amount],
		CASE WHEN ((sop.SoldQuantity * sop.TP) = 0) THEN 0 ELSE ISNULL(sop.Discount,0)/*/(sop.SoldQuantity * sop.TP) END * 100 */ END AS [Discount Value],
		CASE WHEN ((sop.SoldQuantity * sop.TP) = 0) THEN 0 ELSE (isnull(sop.TotalOutputTaxGST,0) + isnull(sop.TotalOutputTaxOther,0)) /*/ (sop.SoldQuantity * sop.TP)   END * 100 */ END [Tax Value],
		SO.SaleOrderId AS [SO]
	FROM SaleOrder SO INNER JOIN SaleOrderProduct sop ON   sop.LocationId = SO.LocationId 
		 AND   sop.SaleOrderId = SO.SaleOrderId 				
		INNER JOIN SaleType st1 ON st1.SaleTypeId = SO.SaleTypeId 
		INNER JOIN   DBO.Split(@CompanyIds, ',' ) Company ON ( Company.Data = SO.CompanyId OR @CompanyIds = '' )	
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON  ( Loc.Data = SO.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Customer ON ( Customer.Data = SO.CustomerId OR @CustomerIds = '' )						
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON (PBL.Data = sop.PrincipalBusinessLineId OR @PBLIds = '' )
		INNER JOIN   DBO.Split(@ProductIds, ',' ) Product ON ( Product.Data = sop.ProductId OR @ProductIds = '' )			 
		INNER JOIN   DBO.Split(@SaleTypeIds, ',' ) SaleTypes ON ( SaleTypes.Data = so.SaleTypeId OR @SaleTypeIds = '' )			 
	
	WHERE  SO.IsRollbacked = 0
		AND sop.EndDate IS NULL 
		AND (@SelectAll = 0 OR (@SelectAll = 1 AND ( DATEDIFF(DAY,CASE WHEN @IsinvoiceDate = 1 THEN SO.TransactionDate ELSE SO.SalePassDate END ,  @FromDate) = 0))
        OR (@SelectAll = 2 AND ( DATEDIFF(DAY,CASE WHEN @IsinvoiceDate = 1 THEN SO.TransactionDate ELSE SO.SalePassDate END ,  @FromDate) <= 0
              AND  DATEDIFF(DAY,CASE WHEN @IsinvoiceDate = 1 THEN SO.TransactionDate ELSE SO.SalePassDate END ,  @ToDate) >= 0)))
		                                              	
		AND((@IsCash=1 AND SO.IsCash=1)  OR (@IsCredit=1 AND SO.IsCash=0)) 
		AND (@BatchNo = '' OR SOP.BatchNumber = @BatchNo)		


		
	UNION ALL
	
	SELECT 
		S.LocationId, 
		'SLN-'+ CONVERT(VARCHAR(10),s.SLNId) AS SaleOrderId,
		s.TransactionDate AS [SO DATE],
		S.TransactionDate AS [SALE DATE],
		NULL AS SaleTypeId, 
		'' [SALE TYPE],			
--		sa.MainAreaId, 
--		SA.SubAreaId,
--		sa.Name AS [Sub Area],
		s.UDLSalesForceId AS [BookerId], 
		s.UDLSalesForceId AS SupplierId,
		s.CustomerId,
--		csa.[Customer Name] AS [Customer],
--		csa.Address AS [Address],
		s.PrincipalBusinessLineId, 
		s2.ProductId, 
		s2.StockTypeId, 
		s2.BatchNumber, 
		pc.TP, 
		CASE WHEN s.IsCash=1 THEN 'CASH' ELSE 'CREDIT' END  AS [SALE NATURE],
		-1*s2.Quantity AS [ORDER Quantity],
		-1*s2.Quantity AS [Invoice Quantity],		
		-1*s2.Quantity * pc.TP  [TP Value],
		-1*S2.OutputTaxAmount AS [Tax],
		-1*(S2.Quantity * pc.TP) + S2.OutputTaxAmount [Amount],		
		CASE WHEN (s2.Quantity * pc.TP) = 0 THEN 0 ELSE (s.DiscountUDLPart + s.DiscountPrincipalPart)/*/(s.TotalTP) END  * 100 */ END AS [Discount],
		CASE WHEN (s2.Quantity * pc.TP) = 0 THEN 0 ELSE (S2.OutputTaxAmount/*/(s2.Quantity * pc.TP)) END * 100 */ ) END AS [Tax],		
		9999999 AS [SO]
	FROM SLN s
		INNER JOIN SLNProduct s2 ON s2.LocationId = s.LocationId AND s2.SLNId = s.SLNId   
--		INNER JOIN uv_CustomerSalesArea csa ON csa.CustomerId=S.CustomerId AND csa.LocationId=S.LocationId
--		INNER JOIN SubArea sa ON sa.SubAreaId=csa.SubAreaId
		INNER JOIN PriceCatalog pc ON  pc.PriceCatalogId=s2.PriceId
		INNER JOIN   DBO.Split(@CompanyIds, ',' ) Company ON ( Company.Data = s.CompanyId OR @CompanyIds = '' )	
		INNER JOIN   DBO.Split(@LocationIds, ',' ) Loc ON  ( Loc.Data = s.LocationId OR @LocationIds = '' )
		INNER JOIN   DBO.Split(@CustomerIds, ',' ) Customer ON ( Customer.Data = s.CustomerId OR @CustomerIds = '' )						
		INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL ON (PBL.Data = s.PrincipalBusinessLineId OR @PBLIds = '' )			 
		INNER JOIN   DBO.Split(@ProductIds, ',' ) Product ON ( Product.Data = s2.ProductId OR @ProductIds = '' )			
--		INNER JOIN   DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = sa.MainAreaId OR @MainAreaIds = '' )
--		INNER JOIN   DBO.Split(@SubAreaIds, ',' ) SubArea ON ( SubArea.Data = sa.SubAreaId OR @SubAreaIds = '' )
	WHERE s2.Quantity > 0 AND
		(
           @SelectAll = 0
       OR  (
               @SelectAll = 1
          AND  (   
                   DATEDIFF(DAY,s.TransactionDate,  @FromDate) = 0
               )
           )
       OR  (
               @SelectAll = 2
          AND  (
                   DATEDIFF(DAY,s.TransactionDate,  @FromDate) <= 0
              AND  DATEDIFF(DAY,s.TransactionDate,  @ToDate) >= 0
               )
           )
		)	
	
		AND((@IsCash=1 AND s.IsCash=1)  OR (@IsCredit=1 AND s.IsCash=0)) 
		AND (@BatchNo = '' OR s2.BatchNumber = @BatchNo )
		AND s2.IsFree=0
		AND S.IsRollbacked = 0	
)
 AS A 
INNER JOIN  Batch b ON ( b.BatchNumber = A.BatchNumber AND   b.ProductId = A.ProductId )
INNER JOIN  uv_Product up ON  up.ProductId = A.ProductId
INNER JOIN ProductLine pl ON up.ProductLineId = pl.ProductLineId
INNER JOIN  Location l ON  l.LocationId = A.LocationId
INNER JOIN  StockType st ON  st.StockTypeId = A.StockTypeId
INNER JOIN uv_CustomerSalesArea csa ON csa.LocationId=A.LocationId AND csa.CustomerId=A.CustomerId
INNER JOIN   DBO.Split(@MainAreaIds, ',' ) MainArea ON ( MainArea.Data = csa.MainAreaId OR @MainAreaIds = '' )
INNER JOIN   DBO.Split(@SubAreaIds, ',' ) SubArea ON ( SubArea.Data = csa.SubAreaId OR @SubAreaIds = '' )

--TO INCLUDE SPOT AND SHOP SALE 
LEFT JOIN  UDLSalesForce us ON US.UDLSalesForceId = a.BookerId AND ( @BookerStatus = 0 OR ( @BookerStatus = 1 AND ( DATEDIFF(day, us.EffectiveDate,GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( us.EndDate,GETDATE()+1))> 0))
	OR ( @BookerStatus = 2 AND  DATEDIFF(day,us.EndDate,ISNULL(GETDATE(), GETDATE()+1))>0 ))
LEFT JOIN  UDLSalesForce us1 ON US1.UDLSalesForceId = a.SupplierId AND ( @SupplierStatus = 0 OR ( @SupplierStatus = 1 AND ( DATEDIFF(day, us1.EffectiveDate,GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( us1.EndDate,GETDATE()+1))> 0))
	OR ( @SupplierStatus = 2 AND  DATEDIFF(day,us1.EndDate,ISNULL(GETDATE(), GETDATE()+1))>0 ))
WHERE
		( @CustStatus = 0 OR ( @CustStatus = 1 AND ( DATEDIFF(day, csa.[Cus Effective Date],GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( csa.[Cus End Date],GETDATE()+1))> 0))
	OR ( @CustStatus = 2 AND  DATEDIFF(day,csa.[Cus End Date],ISNULL(GETDATE(), GETDATE()+1))>0 ))
	AND  
	( @MAreaStatus = 0 OR ( @MAreaStatus = 1 AND ( DATEDIFF(day, csa.[Main Area EffectiveDate],GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( csa.[Main Area EndDate],GETDATE()+1))> 0))
	OR ( @MAreaStatus = 2 AND  DATEDIFF(day,csa.[Main Area EndDate],ISNULL(GETDATE(), GETDATE()+1))>0 ))	
	AND  
	( @SAreaStatus = 0 OR ( @SAreaStatus = 1 AND ( DATEDIFF(day, csa.[Sub Area EffectiveDate],GETDATE())>= 0 AND DATEDIFF(day,GETDATE(), isnull( csa.EndDate,GETDATE()+1))> 0))
	OR ( @SAreaStatus = 2 AND  DATEDIFF(day,csa.EndDate,ISNULL(GETDATE(), GETDATE()+1))>0 ))

 	
ORDER  BY   
	L.SequenceId ,
	A.LocationId,
	[Location Name],
	a.[SO DATE],	
	A.CustomerId, 
	csa.[Customer Name],
	A.PrincipalBusinessLineId, 	 	
	A.ProductId
	
	
--DECLARE @PBLWise BIT 
--SET @PBLWise = 1
SELECT [LOCATION NAME], 	
	[SO NO],
	[SO DATE],
	[PERIOD],
	[SALE DATE],
	[CODE],
	[CUSTOMER NAME],
	[ADDRESS],
	[MAIN AREA],
	[SUB AREA],
	[SALE NATURE],
	SaleTypeId,
	[SALE TYPE],	
	[BOOKER],	
	[SUPPLIER],
	[PBL], 
	[PRODUCT LINE],
	[PROD ID], 	
	[PRODUCT NAME], 		
	[BATCH NO],
	[BATCH EXPIRY],
	[ORDER QUANTITY],
	[INVOICE QUANTITY],
	[TP],  
	SUM([TP VALUE]) AS [TP VALUE],
	SUM([Discount Value]) AS [Discount Value], 
	SUM([Tax Value]) AS [Tax Value]
FROM #Temp
GROUP BY 
[LOCATION NAME], 	
	[SO NO],
	[SO DATE] ,
	[PERIOD],
	[SALE DATE],
	[CODE],
	[CUSTOMER NAME],
	[ADDRESS],
	[MAIN AREA],
	[SUB AREA],
	[SALE NATURE],
	SaleTypeId,
	[SALE TYPE],	
	[BOOKER],	
	[SUPPLIER],
	[PBL], 
	[PRODUCT LINE],
	[PROD ID], 	
	[PRODUCT NAME], 		
	[BATCH NO],
	[BATCH EXPIRY],
	[ORDER QUANTITY],
	[INVOICE QUANTITY],
	[TP]
--DROP TABLE #Temp
 