CREATE PROC usp_Report_SalesPromotionDiscount @CompanyId INT, @PBLIds VARCHAR(100), @LocationIds VARCHAR(100), @FromDate DATETIME, @ToDate DATETIME, @SchemeGroupIds VARCHAR(1000), 
@ClaimGroupIds VARCHAR(1000), @SchemeIds VARCHAR(1000), @SharingBy INT, @IncludeReturns BIT, @FromBCGId INT, @ToBCGId INT, @FromBCGDate DATETIME, @ToBCGDate DATETIME, 
@SpecificBCGIds VARCHAR(100) AS

--DECLARE @CompanyId INT, @PBLIds VARCHAR(100), @LocationIds VARCHAR(100), @FromDate DATETIME, @ToDate DATETIME, @SharingBy INT, 
--@IncludeReturns BIT, @SchemeGroupIds VARCHAR(1000), @ClaimGroupIds VARCHAR(1000), @SchemeIds VARCHAR(1000), 
--@FromBCGId INT, @ToBCGId INT, @FromBCGDate DATETIME, @ToBCGDate DATETIME
--SET @CompanyId = 4
--SET @PBLIds = '1'--'1,2,3,10,17,19,20,22,23,24,25'--'27,28,21,22,23,26,29'--
--SET @LocationIds = '32'--'63,64,59,58,62,51,60,54,53,47,50,57'--'2,14,16,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54'
--SET @FromDate = '1900-01-01 00:00:00'--'2011-01-01'
--SET @ToDate = '2013-07-13 00:00:00'
--SET @SharingBy = 0 /*0.)ALL;1.)UDL;2.)PRINCIPAL*/
--SET @IncludeReturns = 1
--SET @SchemeGroupIds = ''--'6,8,11,16,17'
--SET @ClaimGroupIds = ''--'7,9,12,14,16,18'
--SET @SchemeIds = ''--'1,3,4,5,7,8,12,14,15,70,71,75,77,85,86,111,113,114,115,116,117,121,123,124,131,132,133'
--SET @FromBCGId = 142--0
--SET @ToBCGId = 142--999999
--SET @FromBCGDate = '1900-01-01 00:00:00'--'2012-12-08 00:00:00.000'
--SET @ToBCGDate = '2013-07-13 00:00:00'


SELECT so.LocationId,
       so.CustomerId,
       so.CustomerToBeOpenedName,
       so.CustomerToBeOpenedAddress,
       so.CustomerToBeOpenedSubAreaId,
       so.SaleOrderId,
       so.TransactionDate,
       DATEADD(DAY, DATEDIFF(DAY, 0, so.SalePassDate), 0) SalePassDate,
       so.SaleTypeId,
       so.IsCash,
	   s.SchemeGroupId,
	   s.ClaimGroupId,
	   s.SchemeId,
	   s.[Description] [SchemeDescription],
	   s.IsInvoiceBased,
	   bc.BranchClaimId [BCG Id], 
	   bc.TransactionDate [BCG Date],
	   s.PrincipalBusinessLineId,
	   s.AppliedProductId [ProductId],
	   s.AppliedStockTypeId [StockTypeId],
	   SUM(sos.AppliedOnTPValue) AppliedOnTPValue,
	   SUM
	   (
   		sos.Discount * 
		   (
   			(
   				CASE 
   				WHEN @SharingBy = 1 THEN s.UDLPercentage 
   				WHEN @SharingBy = 2 THEN (100 - s.UDLPercentage)
   				ELSE 100 
   				END
   			)/100
		   )
	   ) [Discount]
INTO #TempScheme
	   
FROM SaleOrder so
INNER JOIN SaleOrderScheme sos ON sos.LocationId = so.LocationId AND sos.SaleOrderId = so.SaleOrderId
INNER JOIN Scheme s ON s.SchemeId = sos.SchemeId
INNER JOIN dbo.[Split](@LocationIds, ',') fl ON fl.[Data] = so.LocationId
INNER JOIN dbo.[Split](@PBLIds, ',') fp ON fp.[Data] = s.PrincipalBusinessLineId
INNER JOIN dbo.[Split](@SchemeIds, ',') fs ON (fs.[Data] = s.SchemeId OR @SchemeIds = '')
INNER JOIN dbo.[Split](@SchemeGroupIds, ',') fsg ON (fsg.[Data] = s.SchemeGroupId OR @SchemeGroupIds = '')
INNER JOIN dbo.[Split](@ClaimGroupIds, ',') fsc ON (fsc.[Data] = s.ClaimGroupId OR @ClaimGroupIds = '')
LEFT JOIN BranchClaim bc ON bc.LocationId = sos.LocationId
 AND bc.BranchClaimId = sos.BranchClaimId
INNER JOIN dbo.[Split](@SpecificBCGIds, ',') fbn ON (fbn.[Data] = bc.BranchClaimId OR @SpecificBCGIds = '') 
WHERE so.CompanyId = @CompanyId
AND	(DATEDIFF(DAY, @FromDate, so.SalePassDate) >= 0)
AND (DATEDIFF(DAY, @ToDate, so.SalePassDate) <= 0)	
AND	ISNULL(bc.BranchClaimId, 0) >= @FromBCGId 
AND ISNULL(bc.BranchClaimId, 0) <= @ToBCGId	 
AND	(DATEDIFF(DAY, @FromBCGDate, ISNULL(bc.TransactionDate, '1900-01-01 00:00:00')) >= 0) 
AND (DATEDIFF(DAY, @ToBCGDate, ISNULL(bc.TransactionDate, '1900-01-01 00:00:00')) <= 0)	 
AND s.IsDiscountBased = 1
AND sos.EndDate IS NULL
AND 
(
	@SharingBy = 0
	OR
	(
		@SharingBy = 1 
		AND s.UDLPercentage > 0
	) 
	OR 
	(
		@SharingBy = 2
		AND (100 - s.UDLPercentage) > 0 
	)
)
GROUP BY so.LocationId, so.CustomerId, so.CustomerToBeOpenedName, so.CustomerToBeOpenedAddress, 
so.CustomerToBeOpenedSubAreaId, so.SaleOrderId, so.TransactionDate, DATEADD(DAY, DATEDIFF(DAY, 0, so.SalePassDate), 0), 
so.SaleTypeId, so.IsCash, s.SchemeGroupId, s.ClaimGroupId, s.SchemeId, s.[Description], s.IsInvoiceBased,
bc.BranchClaimId, bc.TransactionDate,
s.PrincipalBusinessLineId, s.AppliedProductId, s.AppliedStockTypeId
HAVING SUM
	   (
   		sos.Discount * 
		   (
   			(
   				CASE 
   				WHEN @SharingBy = 1 THEN s.UDLPercentage 
   				WHEN @SharingBy = 2 THEN (100 - s.UDLPercentage)
   				ELSE 100 
   				END
   			)/100
		   )
	   ) > 0




SELECT l.ShortName [Location],
c.CustomerId [Customer Code], 
ISNULL(a.CustomerToBeOpenedName, c.[Name]) [Customer Name],
ISNULL(a.CustomerToBeOpenedAddress, (c.Address1 + ' ' + c.Address2)) [Customer Address],
ma.[Name] [Customer Main Area],
sa.[Name] [Customer Sub Area],
a.SaleOrderId [Sale Order Id],
a.TransactionDate [Sale Order Date],
a.SalePassDate [Sale Pass Date],
slt.Code [Sale Type],
CASE WHEN a.IsCash = 1 THEN 'CASH' ELSE 'CREDIT' END [Sale Nature],

sg.SchemeGroupId [Scheme Group Id], 
sg.[Name] [Scheme Group Name], 
sg.ShortName [Scheme Group Short Name],
cg.ClaimGroupId [Claim Group Id], 
cg.[Name] [Claim Group Name], 
cg.ShortName [Claim Group Short Name],
a.SchemeId [Scheme Code], 
a.[SchemeDescription] [Scheme Description],
CASE WHEN a.IsInvoiceBased = 1 THEN 'YES' ELSE 'NO' END [Invoice Based],
a.SLNId [SLN Id], 
a.[SLNDate] [SLN Date],

a.[BCG Id],
a.[BCG Date],

pbl.[Name] [PBL],

a.ProductId [Product Code],
up.ShortName [Product Name], 
st.[Name] [Stock Type], 
a.Quantity, 
a.Value [Applied On Value],
a.Discount [Discount Amount],
(a.Discount / a.Value) * 100 [Discount %], 
a.Value - a.Discount [Net Value]

FROM
(
	--SELECT 0 [IsReturn],
	--       so.LocationId,
	--       so.CustomerId,
	--       so.CustomerToBeOpenedName,
	--       so.CustomerToBeOpenedAddress,
	--       so.CustomerToBeOpenedSubAreaId,
	--       so.SaleOrderId,
	--       so.TransactionDate,
	--       so.SalePassDate,
	--       so.SaleTypeId,
	--       so.IsCash,
	--       sc.SchemeGroupId,
	--       sc.ClaimGroupId,
	--       sc.SchemeId,
	--       sc.[SchemeDescription],
	--       NULL SLNId,
	--       NULL [SLNDate],
	--       sc.PrincipalBusinessLineId,
	--       so.ProductId,
	--       so.StockTypeId,
	--       so.Quantity,
	--       so.Value,
	--       so.Discount
	--FROM  #TempScheme so
	--INNER JOIN
	--(
		SELECT 0 [IsReturn],
		       sos.LocationId,
		       sos.CustomerId,
		       sos.CustomerToBeOpenedName,
		       sos.CustomerToBeOpenedAddress,
		       sos.CustomerToBeOpenedSubAreaId,
		       sos.SaleOrderId,
		       sos.TransactionDate,
		       sos.SalePassDate,
		       sos.SaleTypeId,
		       sos.IsCash,
		       sos.SchemeGroupId,
		       sos.ClaimGroupId,
		       sos.SchemeId,
		       sos.[SchemeDescription],
		       sos.IsInvoiceBased,
		       NULL SLNId,
		       NULL [SLNDate],
		       sos.[BCG Id],
		       sos.[BCG Date],
		       sos.PrincipalBusinessLineId,
		       NULL ProductId,
		       NULL StockTypeId,
		       NULL Quantity,
		       sos.AppliedOnTPValue VALUE,
		       sos.Discount
		FROM #TempScheme sos
		WHERE sos.IsInvoiceBased = 1

		UNION ALL
					   
		SELECT 0 [IsReturn],
		       sos.LocationId,
		       sos.CustomerId,
		       sos.CustomerToBeOpenedName,
		       sos.CustomerToBeOpenedAddress,
		       sos.CustomerToBeOpenedSubAreaId,
		       sos.SaleOrderId,
		       sos.TransactionDate,
		       sos.SalePassDate,
		       sos.SaleTypeId,
		       sos.IsCash,
		       sos.SchemeGroupId,
		       sos.ClaimGroupId,
		       sos.SchemeId,
		       sos.[SchemeDescription],
		       sos.IsInvoiceBased,
		       NULL SLNId,
		       NULL [SLNDate],
		       sos.[BCG Id],
		       sos.[BCG Date],
		       sos.PrincipalBusinessLineId,
		       sop.ProductId,
		       sop.StockTypeId,
		       sop.Quantity,
		       sop.Value,
		       sos.Discount
		--SUM(sop.Quantity) Quantity, SUM(sop.Value) Value, SUM(sos.Discount) Discount
		FROM 
		(
			SELECT sop1.LocationId, sop1.SaleOrderId, sop1.ProductId, sop1.StockTypeId, SUM(sop1.SoldQuantity) Quantity, SUM(sop1.SoldQuantity * sop1.TP) VALUE--, SUM(sop1.Discount) Discount
			FROM SaleOrderProduct sop1
			WHERE sop1.EndDate IS NULL
			GROUP BY sop1.LocationId, sop1.SaleOrderId, sop1.ProductId, sop1.StockTypeId
		)
		sop 
		INNER JOIN #TempScheme sos ON sos.LocationId = sop.LocationId
		 AND sos.SaleOrderId = sop.SaleOrderId
		 AND sos.ProductId = sop.ProductId
		 AND sos.StockTypeId = sop.StockTypeId
		WHERE sos.IsInvoiceBased = 0 

		UNION ALL

		SELECT 1 [IsReturn],
			   s.LocationId,
			   s.CustomerId,
			   NULL CustomerToBeOpenedName,
			   NULL CustomerToBeOpenedAddress,
			   NULL CustomerToBeOpenedSubAreaId,
			   s.SaleOrderId,
			   so.TransactionDate,
			   so.SalePassDate,
			   so.SaleTypeId,
			   s.IsCash,
			   NULL SchemeGroupId,
			   NULL ClaimGroupId,
			   NULL SchemeId,
			   NULL [SchemeDescription],
			   0 IsInvoiceBased,
			   s.SLNId,
			   s.TransactionDate [SLNDate],
			   bc.BranchClaimId [BCG Id],
		       bc.TransactionDate [BCG Date],
			   s.PrincipalBusinessLineId,
			   s2.ProductId,
			   s2.StockTypeId,
			   -SUM(s2.Quantity) Quantity,
			   -SUM(s2.Quantity * pc.TP) VALUE,
			   -
			   (
   				--SUM
				   (
					   CASE 
							WHEN @SharingBy = 1 THEN s.DiscountUDLPart
							WHEN @SharingBy = 2 THEN s.DiscountPrincipalPart
							ELSE (s.DiscountUDLPart + s.DiscountPrincipalPart)
					   END
				   )
				   /
				   (SELECT COUNT(*) FROM SLNProduct s3 WHERE s3.LocationId = s.LocationId AND s3.SLNId = s.SLNId AND s3.Quantity > 0 AND s3.IsFree = 0) 
			   ) [Discount]
		FROM SLN s
		INNER JOIN SLNProduct s2 ON s2.LocationId = s.LocationId 
		 AND s2.SLNId = s.SLNId
		INNER JOIN PriceCatalog pc ON pc.PriceCatalogId = s2.PriceId 
		INNER JOIN dbo.[Split](@LocationIds, ',') fl ON fl.[Data] = s.LocationId
		INNER JOIN dbo.[Split](@PBLIds, ',') fp ON fp.[Data] = s.PrincipalBusinessLineId
		LEFT JOIN SaleOrder so ON so.LocationId = s.LocationId
		 AND so.SaleOrderId = s.SaleOrderId
		LEFT JOIN
		(
			SELECT DISTINCT bc.LocationId, bc.BranchClaimId, bc.TransactionDate, bcbd.SLNId 
			FROM BranchClaimBonusDiscount bcbd
			INNER JOIN BranchClaim bc ON bc.LocationId = bcbd.LocationId AND bc.BranchClaimId = bcbd.BranchClaimId
			INNER JOIN dbo.[Split](@SpecificBCGIds, ',') fbn ON (fbn.[Data] = bc.BranchClaimId OR @SpecificBCGIds = '')
			WHERE ISNULL(bcbd.SLNId, 0) > 0
			AND bcbd.ClaimAmount != 0
			AND bc.IsRollbacked = 0	
		) bc ON bc.LocationId = S.LocationId
		 AND bc.SLNId = S.SLNId 
		WHERE s.CompanyId = @CompanyId
		AND	(DATEDIFF(DAY, @FromDate, s.ApprovalDate) >= 0)
		AND (DATEDIFF(DAY, @ToDate, s.ApprovalDate) <= 0)
		AND	ISNULL(bc.BranchClaimId, 0) >= @FromBCGId 
		AND ISNULL(bc.BranchClaimId, 0) <= @ToBCGId	 
		AND	(DATEDIFF(DAY, @FromBCGDate, ISNULL(bc.TransactionDate, '1900-01-01 00:00:00')) >= 0) 
		AND (DATEDIFF(DAY, @ToBCGDate, ISNULL(bc.TransactionDate, '1900-01-01 00:00:00')) <= 0)	 
		AND @IncludeReturns = 1
		AND s2.IsFree = 0
		AND 
			(
				(
					@SharingBy = 0
					AND (ISNULL(s.DiscountUDLPart, 0) > 0 OR ISNULL(s.DiscountPrincipalPart, 0) > 0)
				)
				OR
				(
					@SharingBy = 1 
					AND ISNULL(s.DiscountUDLPart, 0) > 0
				) 
				OR 
				(
					@SharingBy = 2
					AND ISNULL(s.DiscountPrincipalPart, 0) = 0 
				)
			)
		GROUP BY s.LocationId,
			   s.CustomerId,
			   s.SaleOrderId,
			   so.TransactionDate,
			   so.SalePassDate,
			   so.SaleTypeId,
			   s.IsCash,
			   s.SLNId,
			   s.TransactionDate,
			   bc.BranchClaimId,
		       bc.TransactionDate,
			   s.PrincipalBusinessLineId,
			   s2.ProductId,
			   s2.StockTypeId,
			   s.DiscountUDLPart,
			   s.DiscountPrincipalPart
		HAVING SUM(s2.Quantity) > 0
) A
INNER JOIN Location l ON l.LocationId = a.LocationId
INNER JOIN Customer c ON c.LocationId = a.LocationId
 AND c.CustomerId = a.CustomerId
INNER JOIN uv_CustomerSalesArea csa ON csa.LocationId = A.LocationId 
 AND csa.CustomerId = A.CustomerId 
INNER JOIN SubArea sa ON sa.SubAreaId = ISNULL(a.CustomerToBeOpenedSubAreaId, csa.SubAreaId)
INNER JOIN MainArea ma ON ma.MainAreaId = sa.MainAreaId 
INNER JOIN uv_PrincipalBusinessLine_All pbl ON pbl.PrincipalBusinessLineId = a.PrincipalBusinessLineId

LEFT JOIN uv_Product up ON up.ProductId = a.ProductId
LEFT JOIN StockType st ON st.StockTypeId = a.StockTypeId
  
LEFT JOIN SaleType slt ON slt.SaleTypeId = a.SaleTypeId
LEFT JOIN SchemeGroup sg ON sg.SchemeGroupId = a.SchemeGroupId
LEFT JOIN ClaimGroup cg ON cg.ClaimGroupId = a.ClaimGroupId

ORDER BY ISNULL(l.SequenceId, 9999 + L.LocationId), c.CustomerId, a.[IsReturn], a.SaleOrderId, a.SchemeId, a.SLNId

DROP TABLE #TempScheme
