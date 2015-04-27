SELECT s.SICId
	,s.PrincipalBusinessLineId
	,sp.SICProductId
	,sp.Quantity
  FROM SIC s inner join SICProduct sp on s.LocationId = sp.LocationId AND s.SICId = sp.SICId
  INNER JOIN SICType sict ON s.SICTypeId= sict.SICTypeId
  INNER JOIN StockType st ON st.StockTypeId = s.ToStockTypeId
  INNER JOIN uv_product up ON up.ProductId = sp.ProductId
  INNER JOIN batch b ON b.ProductId = sp.ProductId AND b.BatchNumber = sp.BatchNumber
--INNER JOIN PriceCatalog pc ON pc.PriceCatalogId = sp.PriceId
--INNER JOIN Location l ON l.LocationId = s.LocationId
  WHERE s.locationid = 14 AND s.PrincipalBusinessLineId = 3
  SELECT * FROM SICProduct s WHERE s.SICId = 18
  SELECT * FROM sic WHERE LocationId = 14 AND PrincipalBusinessLineId = 3 AND IsRollbacked = 0