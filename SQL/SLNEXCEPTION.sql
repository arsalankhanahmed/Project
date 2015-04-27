--SELECT so.LocationId,so.SaleorderId,so.TotalNet AS SOAmount,SUM((sop.SoldQuantity * sop.TP)+(sop.TP/(sop.WHTRate*100))) AS SOProductAmount
--FROM Saleorder so 
--INNER JOIN SaleOrderProduct sop 
--	ON so.locationId = sop.LocationId
--	AND so.SaleOrderId = sop.SaleOrderId
--INNER JOIN PriceCatalog pc 
--	ON pc.PriceCatalogId = sop.PriceId
--WHERE   so.IsRollbacked = 0 
--		AND sop.SoldQuantity > 0
--		AND so.SalePassDate IS NOT NULL 
--		AND sop.EndDate IS  NULL
--		AND sop.WHTRate > 0 
--GROUP BY so.LocationId,so.SaleOrderId,so.TotalNet,sop.TP,sop.WHTRate
--HAVING  sum(so.TotalNet) <> SUM((sop.SoldQuantity * sop.TP)+ (sop.TP/(sop.WHTRate*100)))

SELECT * FROM (
SELECT sln.LocationId,sln.SLNId,sln.TransactionDate,sln.TotalNet as SLNAmount,SUM(sln.Quantity * pc.TP) AS SLNProductAmount,(sln.TotalNet+sln.DiscountUDLPart+sln.DiscountPrincipalPart) - SUM((sln.Quantity * pc.TP)+sln.OutputTaxAmount)  AS AmountDiff
FROM uv_sales_SLN sln 
INNER JOIN PriceCatalog pc 
	ON pc.PriceCatalogId = sln.PriceId
WHERE   sln.IsRollbacked = 0 
		AND sln.Quantity > 0 
		--AND locationId = 36 AND SLNID = 6
GROUP BY sln.LocationId,sln.SLNId,sln.TransactionDate,sln.TotalNet,sln.DiscountUDLPart,sln.DiscountPrincipalPart
)
a
WHERE a.AmountDiff>1
ORDER BY a.LocationId,a.SLNId

SELECT * FROM uv_Sales_SLN uss WHERE locationId = 12 AND SLNID = 18 