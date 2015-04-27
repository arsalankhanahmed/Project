SELECT SUM(sop.TP*sop.SoldQuantity) 
FROM saleorder so INNER JOIN SaleOrderProduct sop on so.locationid = sop.locationid AND so.saleorderid = sop.saleorderid
WHERE so.LocationId = 14 AND so.SalePassDate between '2013-11-23 00:00:00' and '2013-11-26 23:59:59'AND sop.PrincipalBusinessLineId = 28 
AND so.IsCash = 0 and sop.SoldQuantity > 0 
--GROUP BY so.DeliveryChallanId

SELECT 408405-208470.19
