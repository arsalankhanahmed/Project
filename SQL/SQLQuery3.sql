
CREATE PROCEDURE usp_Report_MonthlyManagementReport @CompanyIds INT, @LocationIds VARCHAR(250),@PBLIds VARCHAR(250),@SelectAll INT,@FromDate DATETIME,@ToDate DATETIME
AS
--DECLARE @CompanyIds INT, @LocationIds VARCHAR(250),@PBLIds VARCHAR(250),@SelectAll INT,@FromDate DATETIME,@ToDate DATETIME
--SET @CompanyIds = 1
--SET @LocationIds = ''
--SET @PBLIds = ''
--SET @SelectAll = 2
--SET @FromDate = '2014-04-01 00:00:00.000'
--SET @ToDate = '2014-04-06 00:00:00.000'


SELECT usso.LocationId, usso.SaleOrderId, usso.PrincipalBusinessLineId, usso.IsCash, SUM(usso.soldquantity*usso.tp) [TotalTP]
INTO #TempSO
FROM uv_Sales_SaleOrder usso
INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = usso.LocationId OR @LocationIds = '')
WHERE usso.CompanyId = @CompanyIds
AND 
(
	@SelectAll = 0 
	OR ( @SelectAll = 1 AND DATEDIFF(DAY,usso.SalePassDate,@FromDate)=0) 
	OR ( @SelectAll = 2 AND DATEDIFF(DAY,usso.SalePassDate,@FromDate)<=0 AND DATEDIFF(DAY,usso.SalePassDate,@ToDate)>=0)
)
GROUP BY usso.LocationId, usso.SaleOrderId, usso.PrincipalBusinessLineId, usso.IsCash	

SELECT
l.SequenceId,
a.[LocationId],
l.ShortName AS [LOCATION],
upbla.PBLSequenceId,
a.PrincipalBusinessLineId,
upbla.[Name] AS [PBL],
--SUM(a.[GROSS SALE CASH]) AS [GROSS SALE CASH],
--SUM(a.[GROSS SALE CR]) AS [GROSS SALE CR],
--SUM(a.[GROSS UDL DISCOUNT CASH]) AS [GROSS UDL DISCOUNT CASH],
--SUM(a.[GROSS PBL DISCOUNT CASH]) AS [GROSS PBL DISCOUNT CASH],
--SUM(a.[GROSS UDL DISCOUNT CR]) AS [GROSS UDL DISCOUNT CR],
--SUM(a.[GROSS PBL DISCOUNT CR]) AS [GROSS PBL DISCOUNT CR],
--SUM(a.[SLN CASH]) AS [SLN CASH],
--SUM(a.[SLN CR]) AS [SLN CR], 
--SUM(a.[SLN UDL DISCOUNT CASH]) AS [SLN UDL DISCOUNT CASH], 
--SUM(a.[SLN PBL DISCOUNT CASH]) AS [SLN PBL DISCOUNT CASH],
--SUM(a.[SLN UDL DISCOUNT CR]) AS [SLN UDL DISCOUNT CR],
--SUM(a.[SLN PBL DISCOUNT CR]) AS [SLN PBL DISCOUNT CR]
(SUM(a.[GROSS SALE CASH]) -SUM(a.[GROSS UDL DISCOUNT CASH]) - SUM(a.[GROSS PBL DISCOUNT CASH])) AS [CASH SALE],
(SUM(a.[GROSS SALE CR]) - SUM(a.[GROSS UDL DISCOUNT CR]) - SUM(a.[GROSS PBL DISCOUNT CR])) AS [CREDIT SALE],
(SUM(a.[SLN CASH]) - SUM(a.[SLN UDL DISCOUNT CASH]) - SUM(a.[SLN PBL DISCOUNT CASH])) AS [CASH S.RTN],
(SUM(a.[SLN CR]) - SUM(a.[SLN UDL DISCOUNT CR]) - SUM(a.[SLN PBL DISCOUNT CR])) AS [CREDIT S.RTN],
((SUM(a.[GROSS SALE CASH]) - SUM(a.[GROSS UDL DISCOUNT CASH]) - SUM(a.[GROSS PBL DISCOUNT CASH])) + (SUM(a.[GROSS SALE CR]) - SUM(a.[GROSS UDL DISCOUNT CR]) - SUM(a.[GROSS PBL DISCOUNT CR])) -
(SUM(a.[SLN CASH]) - SUM(a.[SLN UDL DISCOUNT CASH]) - SUM(a.[SLN PBL DISCOUNT CASH])) - (SUM(a.[SLN CR]) - SUM(a.[SLN UDL DISCOUNT CR]) - SUM(a.[SLN PBL DISCOUNT CR]))) 
AS [NET SALE],
SUM((a.[GROSS UDL DISCOUNT CASH])) + SUM(a.[GROSS UDL DISCOUNT CR]) - SUM(a.[SLN UDL DISCOUNT CASH]) - SUM(a.[SLN UDL DISCOUNT CR]) AS [UDL DISCOUNT],
SUM(a.[GROSS PBL DISCOUNT CASH]) + SUM(a.[GROSS PBL DISCOUNT CR]) - SUM(a.[SLN PBL DISCOUNT CASH]) - SUM(a.[SLN PBL DISCOUNT CR]) AS [PBL DISCOUNT],
SUM(a.[GROSS SALE CASH]) + SUM(a.[GROSS SALE CR]) - SUM(a.[SLN CASH]) - SUM(a.[SLN CR]) AS [DSP NET SALE]
FROM

(
      SELECT
            usso.LocationId,
            usso.PrincipalBusinessLineId,
            usso.IsCash,
            CASE 
                 WHEN usso.IsCash = 1 THEN usso.TotalTP
                 ELSE 0
            END AS [Gross Sale Cash],
            CASE 
                 WHEN usso.IsCash = 1 THEN 0
                 ELSE usso.TotalTP
            END AS [Gross Sale Cr],
            (
                CASE 
                     WHEN usso.IsCash = 1 THEN ISNULL(disc.[UDL Discount],0)
                     ELSE 0
                END
            ) AS [Gross UDL Discount Cash],
			(
				CASE 
					 WHEN usso.IsCash = 1 THEN ISNULL(disc.[PBL Discount],0)
					 ELSE 0
				END
			) AS [Gross PBL Discount Cash],
			(
				CASE 
					 WHEN usso.IsCash = 1 THEN 0
					 ELSE ISNULL(disc.[UDL Discount],0)
				END
			) AS [Gross UDL Discount Cr],
			(
				CASE 
					 WHEN usso.IsCash = 1 THEN 0
					 ELSE ISNULL(disc.[PBL Discount],0)
				END
			) AS [Gross PBL Discount Cr], 
            0 AS [SLN Cash],
            0 AS [SLN Cr], 
            0 AS [SLN UDL Discount Cash], 
            0 AS [SLN PBL Discount Cash],
            0 AS [SLN UDL Discount Cr],
            0 AS [SLN PBL Discount Cr] 
      FROM 
      (
		SELECT usso.LocationId, usso.PrincipalBusinessLineId, usso.IsCash, SUM([TotalTP]) [TotalTP]
		FROM #TempSO usso
		GROUP BY usso.LocationId, usso.PrincipalBusinessLineId, usso.IsCash
      ) usso
      LEFT JOIN 
      (
		SELECT usso.LocationId,
		s.PrincipalBusinessLineId,
		usso.IsCash,
		ISNULL(SUM(sos.Discount * ((100 - s.UDLPercentage) / 100)), 0) [PBL Discount],
		ISNULL(SUM(sos.Discount * (s.UDLPercentage / 100)), 0) [UDL Discount]

		FROM
		(
			SELECT DISTINCT usso.LocationId, usso.SaleOrderId, usso.IsCash
			FROM #TempSO usso
		) usso
		INNER JOIN SaleOrderScheme sos ON sos.LocationId = usso.LocationId
		AND sos.SaleOrderId = usso.SaleOrderId
		INNER JOIN [Scheme] s ON s.SchemeId = sos.SchemeId 
		WHERE sos.EndDate IS NULL
		AND s.IsDiscountBased = 1
		GROUP BY usso.LocationId, s.PrincipalBusinessLineId, usso.IsCash
      ) disc ON disc.LocationId = usso.LocationId
       AND disc.PrincipalBusinessLineId = usso.PrincipalBusinessLineId
       AND disc.IsCash = usso.IsCash
      
      

UNION ALL

      SELECT 
            sln.LocationId,
            sln.PrincipalBusinessLineId,
            sln.IsCash,
            0 AS [Gross Sale Cash],
            0 AS  [Gross Sale Cr],
            0 AS [Gross UDL Discount Cash],
            0 AS [Gross PBL Discount Cash],
            0 AS [Gross UDL Discount Cr],
            0 AS [Gross PBL Discount Cr],  
            (case when sln.IsCash = 1 then SUM(sln.TotalTP) else 0 end) AS [SLN Cash],
            (case when sln.IsCash = 1 then 0 else SUM(sln.TotalTP) end) AS [SLN Cr], 
            (case when sln.IsCash = 1 then SUM(sln.DiscountUDLPart) else 0 end) AS [SLN UDL Discount Cash], 
            (case when sln.IsCash = 1 then SUM(sln.DiscountPrincipalPart) else 0 end) AS [SLN PBL Discount Cash],
            (case when sln.IsCash = 1 then 0 else SUM(sln.DiscountUDLPart) end) AS [SLN UDL Discount Cr],
            (case when sln.IsCash = 1 then 0 else SUM(sln.DiscountPrincipalPart) end) AS [SLN PBL Discount Cr] 
      FROM 
      (
      	SELECT sln.LocationId, sln.SLNId, sln.PrincipalBusinessLineId, sln.IsCash, isnull(sln.DiscountUDLPart,0) AS DiscountUDLPart, 
      	isnull(sln.DiscountPrincipalPart,0) AS DiscountPrincipalPart, SUM(sln.Quantity * pc.TP) TotalTP
      	FROM uv_Sales_SLN sln
		INNER JOIN PriceCatalog pc ON pc.PriceCatalogId = sln.PriceId
		INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = sln.PrincipalBusinessLineId OR @PBLIds = '')
		INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = sln.LocationId OR @LocationIds = '')

		WHERE sln.CompanyId = @CompanyIds
		AND (@SelectAll = 0 
			OR ( @SelectAll = 1 AND DATEDIFF(DAY,sln.TransactionDate,@FromDate)=0) 
			OR ( @SelectAll = 2 AND DATEDIFF(DAY,sln.TransactionDate,@FromDate)<=0 AND DATEDIFF(DAY,sln.TransactionDate,@ToDate)>=0))
      	GROUP BY sln.LocationId, sln.SLNId, sln.PrincipalBusinessLineId, sln.IsCash, sln.DiscountUDLPart, 
      	sln.DiscountPrincipalPart			
      ) sln
      GROUP BY sln.IsCash,sln.PrincipalBusinessLineId,sln.LocationId

) a
INNER JOIN Location l ON A.LocationId = l.LocationId
INNER JOIN uv_PrincipalBusinessLine_All upbla ON a.PrincipalBusinessLineId = upbla.PrincipalBusinessLineId
GROUP BY l.SequenceId,
	a.[LocationId],
	l.ShortName,
	upbla.PBLSequenceId,
	a.PrincipalBusinessLineId,
	upbla.[Name] 

ORDER BY l.SequenceId, upbla.PBLSequenceId

DROP TABLE #TempSO