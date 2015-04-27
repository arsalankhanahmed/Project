SELECT * FROM saleorder so WHERE so.LocationId = 14 AND so.SaleTypeId = (SELECT st.saletypeId FROM SaleType st WHERE st.Code = 'SPL')
SELECT * FROM SaleOrderProduct sop WHERE sop.LocationId = 14 AND sop.SaleOrderId = 2156

SELECT * FROM saleorder so --WHERE so.LocationId = 14 AND so.SaleTypeId = (SELECT st.saletypeId FROM SaleType st WHERE st.Code = 'SPL')) 
inner join saleorderscheme sos ON so.locationid = sos.locationid AND  so.saleorderid = sos.saleorderId
INNER JOIN SCHEME s ON sos.schemeId = s.SchemeId 
WHERE sos.locationid = 14 and s.IsDiscountBased = 0 AND s.IsInvoiceBased = 0 AND s.IsMBI=0 

SELECT * FROM schemeDetail sd WHERE sd.appliedQuantity <5 AND sd.appliedQuantity >0

SELECT * FROM saleorder so inner join saleorderscheme sos 
on so.locationid= sos.locationid and sos.saleorderid = so.saleorderid
INNER JOIN SCHEME s ON sos.schemeId = s.schemeId   
WHERE so.locationid = 14 AND so.deliverychallanId =251--IN (88,158,251,255)

SELECT * FROM SaleOrderProduct sop WHERE sop.LocationId = 14 AND sop.SaleOrderId = 251