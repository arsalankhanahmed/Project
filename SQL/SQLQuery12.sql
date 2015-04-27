SELECT SUM(sop.SoldQuantity),sum(so.TotalOutputTax)
FROM saleorder so 
  INNER JOIN SaleOrderProduct sop  on so.locationid= sop.LocationId AND so.saleorderid = sop.SaleOrderId
  --INNER JOIN SaleOrderTax sot ON so.LocationId = sot.LocationId AND so.SaleOrderId = sot.SaleOrderId
  --INNER JOIN ProductTax pt ON sot.ProductTaxId =pt.ProductTaxId AND sop.ProductId = pt.ProductId 
  --INNER JOIN Tax t ON pt.TaxId = t.TaxId
WHERE so.LocationId = 11 AND sop.ProductId = 993 AND so.SalePassDate BETWEEN '2014-04-01 00:00:00.000' AND '2014-04-15 23:59:00.000'

SELECT slnp.productId,SUM(slnp.Quantity),SUM(slnp.InputTaxAmount),SUM(slnp.OutputTaxAmount)
FROM SLN sln 
  INNER JOIN SLNProduct slnp  on sln.locationid= slnp.LocationId AND sln.SLNID= slnp.SLNID
  --INNER JOIN SaleOrderTax sot ON sln.LocationId = sot.LocationId AND sln.SaleOrderId = slnp.SaleOrderId
  --INNER JOIN ProductTax pt ON sot.ProductTaxId =pt.ProductTaxId AND sop.ProductId = pt.ProductId 
  --INNER JOIN Tax t ON pt.TaxId = t.TaxId
WHERE sln.IsRollbacked = 0 and sln.TransactionDate BETWEEN '2014-04-01 00:00:00.000' AND '2014-04-15 23:59:00.000'
GROUP BY slnp.ProductId
HAVING SUM(slnp.InputTaxAmount)> 0 Or SUM(slnp.OutputTaxAmount)>0 

SELECT up.PrincipalBusinessLineId FROM uv_Product up WHERE up.ProductId IN (1523
,1977
,1978
,2161
,2465
,2520
,2526
,2527
,2532
,2545
,2546
,2549
,2555
,2556
,2561
,2566
,2577
,2578
,2698
,2701)




SELECT * FROM uv_Product up WHERE up.ProductId = 2545
