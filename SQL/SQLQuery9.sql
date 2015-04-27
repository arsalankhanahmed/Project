SELECT
				usso.LocationId,
				usso.PrincipalBusinessLineId,
				usso.ProductId,
				--Case When @SalesCriteria  = 0 then SUM(usso.SoldQuantity) 
				--     When @SalesCriteria  = 1 then SUM(usso.SoldQuantity)
				--     When @SalesCriteria  = 2 then 0 END 
				--AS [Quantity],
				usso.SalePassDate AS [Date],
				pc.PP,				
				pc.TP
			FROM uv_Sales_SaleOrder usso 
			INNER JOIN PriceCatalog pc ON usso.PriceId = pc.PriceCatalogId
		
			--INNER JOIN   DBO.Split(@ProductIds, ',') Product ON  (Product.Data = usso.ProductId OR @ProductIds = '')
			--INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
			--INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = usso.LocationId OR @LocationIds = '')
			--WHERE 
			--(  @SelectAll = 0	  
			-- OR  (@SelectAll = 1 AND ( DATEDIFF(DAY, usso.SalePassDate,  @FromDate) = 0 ))
			-- OR  (@SelectAll = 2 AND ( DATEDIFF(DAY, usso.SalePassDate,  @FromDate) <= 0 AND DATEDIFF(day, usso.SalePassDate, @ToDate) >= 0 ))   
			--) AND usso.IsRollbacked = 0
		  --  GROUP BY 
				--usso.LocationId,
				--usso.PrincipalBusinessLineId,
				--usso.ProductId,
				--usso.SalePassDate,
				--pc.PP,
				
				usp_Report_GrossSaleAndMargin
				--pc.TP