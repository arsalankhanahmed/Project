
--CREATE PROC usp_Report_PaidDCReport @LocationIds varchar(100),@SupplierIds varchar(100),@SaleTypeIds varchar(100),@FromDate datetime,
--@ToDate datetime,@DCSelectAll int,@DCRange varchar(1000), @FromDCID varchar(100), @ToDCID varchar(100)
--AS 

DECLARE  @LocationIds  varchar(1000),@SupplierIds  varchar(1000),@SaleTypeIds  varchar(1000),@FromDate datetime, @ToDate datetime,@DCSelectAll int,
@DCRange varchar(1000), @FromDCID varchar(100), @ToDCID varchar(100)

SET @LocationIds='14'
SET @SupplierIds=''
SET @SaleTypeIds=''
SET @FromDate='2012-07-20'
SET @ToDate='2014-01-20'
SET @DCSelectAll=0
SET @DCRange = '1'
SET @FromDCID = '1'
SET @ToDCID = '9999'

--SELECT    st.Code AS [Sale Type],
--		A.LocationId, 
--		l.ShortName AS [Location Name],
--		A.DeliveryChallanId AS [DC No], 
--		CONVERT(varchar(12),A.TransactionDate,103)  AS [DC Date],
--		CONVERT(varchar(12),A.ExpectedReturnDate,103) AS [ExpectedReturnDate], 
--		A.[Payment Id],-- AS [Payment Id], 
--		CONVERT(varchar(12),A.[Payment Date],103) AS [Payment Date], 
--		A.SupplierId,
--		us.Name AS [Supplier Name],		
--		sop.PrincipalBusinessLineId,
--		up.PBLShortName AS [PBL Name],
--		sop.ProductId,
--		up.Name AS [Product Name],
--		sop.StockTypeId,st2.Name AS [Stock Type],
--		sum(sop.SoldQuantity) AS SoldQuantity,
--		sum(sop.TP*sop.SoldQuantity) AS [TP Value],
--		sum(sop.Discount) AS [Discount],
--		sum(sop.TotalOutputTaxGST+sop.TotalOutputTaxOther) AS [Tax],
--		sum(A.TotalNet) TotalNet,
--		sum((sop.TP*sop.SoldQuantity)-sop.Discount +(sop.TotalOutputTaxGST+sop.TotalOutputTaxOther)) AS [Total-SOP]
SELECT *		
FROM    
(
	
	SELECT dc.LocationId,
		dc.DeliveryChallanId,
	    dc.TransactionDate,
		dc.ExpectedReturnDate, 
		CSP.TransactionDate AS [Payment Date],
		csp.CashSalePaymentId AS [Payment Id], 
		csp.IsApproved,
		csp.IsRollbacked, 
		dc.SupplierId,
		DC.TotalNet
	FROM DeliveryChallan dc 
	INNER JOIN CashSalePayment csp ON csp.LocationId = dc.LocationId AND csp.DeliveryChallanId = dc.DeliveryChallanId 
	--INNER JOIN Location l ON l.LocationId = dc.LocationId
	INNER JOIN DBO.Split(@LocationIds, ',') LOC ON   (LOC.Data = dc.LocationId OR @LocationIds = '')
	INNER JOIN DBO.Split(@SaleTypeIds, ',') SaleType ON   (SaleType.Data = dc.SaleTypeId OR @SaleTypeIds = '')
	INNER JOIN DBO.Split(@SupplierIds, ',') UDLSupplier ON (UDLSupplier.Data = dc.SupplierId OR @SupplierIds = '')
	WHERE   csp.IsRollbacked = 0
	--AND csp.IsApproved=1
	AND 
	  (
		@DCSelectAll = 0
		OR (@DCSelectAll = 2 AND ((@FromDCID = '0' OR  DC.DeliveryChallanId >= @FromDCID) AND  (@ToDCID = '0' OR  DC.DeliveryChallanId <= @ToDCID)))
		OR (@DCSelectAll = 1 AND  DC.DeliveryChallanId IN (SELECT S.DATA FROM   DBO.Split(@DCRange, ',') S))
	  ) 
	AND (@FromDate='' OR  DATEDIFF(DAY, csp.TransactionDate,  @FromDate) <= 0)
	AND (@ToDate='' OR  DATEDIFF(DAY, csp.TransactionDate,  @ToDate) >= 0)

	UNION ALL 

	SELECT dc.LocationId,
			dc.DeliveryChallanId,
			DC.TransactionDate,
			DC.ExpectedReturnDate,
			CSP.TransactionDate  AS [Payment Date],
			csp.CashSalePaymentId AS [Payment Id], 
			csp.IsApproved,
			csp.IsRollbacked, 
			dc.SupplierId,
			dc.TotalNet
	FROM DeliveryChallan dc 
	INNER JOIN CashSalePaymentShopSale cspss ON cspss.LocationId = dc.LocationId AND cspss.DeliveryChallanId = dc.DeliveryChallanId
	INNER JOIN CashSalePayment csp ON csp.LocationId = cspss.LocationId AND csp.CashSalePaymentId  = cspss.CashSalePaymentId
	--INNER JOIN Location l ON l.LocationId = dc.LocationId
	INNER JOIN DBO.Split(@LocationIds, ',') LOC ON   (LOC.Data = dc.LocationId OR @LocationIds = '')
	INNER JOIN DBO.Split(@SaleTypeIds, ',') SaleType ON   (SaleType.Data = dc.SaleTypeId OR @SaleTypeIds = '')
	WHERE   csp.IsRollbacked = 0
	--AND csp.IsApproved=1
	AND 
	  (
		@DCSelectAll = 0
		OR (@DCSelectAll = 2 AND ((@FromDCID = '0' OR  DC.DeliveryChallanId >= @FromDCID) AND  (@ToDCID = '0' OR  DC.DeliveryChallanId <= @ToDCID)))
		OR (@DCSelectAll = 1 AND  DC.DeliveryChallanId IN (SELECT S.DATA FROM   DBO.Split(@DCRange, ',') S))
	  ) 
	AND (@FromDate='' OR  DATEDIFF(DAY, csp.TransactionDate,  @FromDate) <= 0)
	AND (@ToDate='' OR  DATEDIFF(DAY, csp.TransactionDate,  @ToDate) >= 0)
) A
		INNER JOIN   SaleOrder so ON   so.LocationId = a.LocationId 
		AND   so.DeliveryChallanId = a.DeliveryChallanId
		INNER JOIN   SaleOrderProduct sop ON   sop.LocationId = so.LocationId 
		AND   sop.SaleOrderId = so.SaleOrderId
		
		INNER JOIN SaleType st ON st.SaleTypeId = so.SaleTypeId
		INNER JOIN uv_Product up ON up.ProductId = sop.ProductId
		INNER JOIN StockType st2 ON st2.StockTypeId = sop.StockTypeId
		--INNER JOIN Location l ON l.LocationId = A.LocationId	
		LEFT  JOIN UDLSalesForce us ON us.LocationId = a.LocationId 
		AND us.UDLSalesForceId = a.SupplierId	
		WHERE sop.EndDate IS NULL
		
--GROUP BY
--		a.LocationId,  l.ShortName,l.SequenceId,
--		a.DeliveryChallanId,
--		a.TransactionDate,
--		a.ExpectedReturnDate, 
--		a.[Payment Id], 
--		a.IsApproved,
--		a.IsRollbacked,
--		A.[Payment Date], 
--		a.SupplierId,
--		sop.PrincipalBusinessLineId,
--		up.PBLShortName,
--		sop.ProductId,
--		up.Name,
--		sop.StockTypeId,st2.Name,
--		us.Name,
--		st.Code
		
--		ORDER BY l.SequenceId