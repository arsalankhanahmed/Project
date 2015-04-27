--CREATE PROCEDURE usp_Report_MonthlyManagementReport @CompanyIds INT, @LocationIds VARCHAR(250),@PBLIds VARCHAR(250),@SelectAll INT,@FromDate DATETIME,@ToDate DATETIME

DECLARE @CompanyIds INT, @LocationIds VARCHAR(250),@PBLIds VARCHAR(250),@SelectAll INT,@FromDate DATETIME,@ToDate DATETIME
SET @CompanyIds = 1
SET @LocationIds = '14'
SET @PBLIds = '28'
SET @SelectAll = 2
SET @FromDate = '2014-04-01 00:00:00.000'
SET @ToDate = '2014-04-19 00:00:00.000'

SELECT
l.SequenceId,
a.[LocationId],
l.[Name] AS [Location],
upbla.PBLSequenceId,
a.PrincipalBusinessLineId,
upbla.[Principal ShortName] AS [PBL],
a.[Gross Sale Cash],
a.[Gross Sale Cr],
--a.[Gross UDL Discount Cash],
--a.[Gross PBL Discount Cash],
--a.[Gross UDL Discount Cr],
--a.[Gross PBL Discount Cr],
a.[SLN Cash],
a.[SLN Cr], 
a.[SLN UDL Discount Cash], 
a.[SLN PBL Discount Cash],
a.[SLN UDL Discount Cr],
a.[SLN PBL Discount Cr],
a.[Gross Sale Cash] - 0/*a.[UDL Discount Cash] - a.[PBL Discount Cash]*/ AS [Cash Sale],
a.[Gross Sale Cr] - 0/*a.[UDL Discount Credit] - a.[PBL Discount Credit]*/ AS [Credit Sale],
a.[SLN Cash] - a.[SLN UDL Discount Cash] - a.[SLN PBL Discount Cash] AS [Cash Sales Return],
a.[SLN Cr] - a.[SLN UDL Discount Cr] - a.[SLN PBL Discount Cr] AS [Credit Sales Return],
((a.[Gross Sale Cash] - 0/*a.[UDL Discount Cash] - a.[PBL Discount Cash]*/ ) + (a.[Gross Sale Cr] - 0/*a.[UDL Discount Cr] - a.[PBL Discount Cr]*/ ) -
(a.[SLN Cash] - a.[SLN UDL Discount Cash] - a.[SLN PBL Discount Cash]) - (a.[SLN Cr] - a.[SLN UDL Discount Cr] - a.[SLN PBL Discount Cr])) 
AS [Net Sale],
--a.[Gross UDL Discount Cash] + a.[Gross UDL Discount Cr] - a.[SLN UDL Discount Cash] - a.[SLN UDL Discount Cr] AS [UDL Discount],
--a.[Gross PBL Discount Cash] + a.[Gross PBL Discount Cr] - a.[SLN PBL Discount Cash] - a.[SLN PBL Discount Cr] AS [PBL Discount],
a.[Gross Sale Cash] + a.[Gross Sale Cr] - a.[SLN Cash] - a.[SLN Cr] AS [DSP Net Sale]
FROM

(
	SELECT
		usso.LocationId,
		usso.PrincipalBusinessLineId,
		usso.IsCash,
		case when usso.IsCash = 1 then SUM(usso.soldquantity*usso.tp) else 0 end AS [Gross Sale Cash],
		case when usso.IsCash = 1 then 0 else SUM(usso.soldquantity*usso.tp) end AS [Gross Sale Cr],
		--(case when usso.IsCash = 1 then (usso.udldiscount) else 0 end) AS [Gross UDL Discount Cash],
		--(case when usso.IsCash = 1 then (usso.pbldiscount) else 0 end) AS [Gross PBL Discount Cash],
		--(case when usso.IsCash = 1 then 0 else (usso.udldiscount) end) AS [Gross UDL Discount Cr],
		--(case when usso.IsCash = 1 then 0 else (usso.pbldiscount) end) AS [Gross PBL Discount Cr]  
		0 AS [SLN Cash],
		0 AS [SLN Cr], 
		0 AS [SLN UDL Discount Cash], 
		0 AS [SLN PBL Discount Cash],
		0 AS [SLN UDL Discount Cr],
		0 AS [SLN PBL Discount Cr] 
	FROM uv_Sales_SaleOrder usso
	INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = usso.PrincipalBusinessLineId OR @PBLIds = '')
	INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = usso.LocationId OR @LocationIds = '')
	
	WHERE usso.CompanyId = @CompanyIds
	AND (@SelectAll = 0 
		OR ( @SelectAll = 1 AND DATEDIFF(DAY,usso.SalePassDate,@FromDate)=0) 
		OR ( @SelectAll = 2 AND DATEDIFF(DAY,usso.SalePassDate,@FromDate)<=0 AND DATEDIFF(DAY,usso.SalePassDate,@ToDate)>=0))
	
	GROUP BY usso.IsCash,usso.PrincipalBusinessLineId,usso.LocationId
 
UNION ALL

	SELECT 
		sln.LocationId,
		sln.PrincipalBusinessLineId,
		sln.IsCash,
		0 AS [Gross Sale Cash],
		0 AS  [Gross Sale Cr],
		--0 AS [Gross UDL Discount Cash],
		--0 AS [Gross PBL Discount Cash],
		--0 AS [Gross UDL Discount Cr],
		--0 AS [Gross PBL Discount Cr],  
		(case when sln.IsCash = 1 then SUM(sln.Quantity * pc.TP) else 0 end) AS [SLN Cash],
		(case when sln.IsCash = 1 then 0 else SUM(sln.Quantity * pc.TP) end) AS [SLN Cr], 
		(case when sln.IsCash = 1 then SUM(sln.DiscountUDLPart) else 0 end) AS [SLN UDL Discount Cash], 
		(case when sln.IsCash = 1 then SUM(sln.DiscountPrincipalPart) else 0 end) AS [SLN PBL Discount Cash],
		(case when sln.IsCash = 1 then 0 else SUM(sln.DiscountUDLPart) end) AS [SLN UDL Discount Cr],
		(case when sln.IsCash = 1 then 0 else SUM(sln.DiscountPrincipalPart) end) AS [SLN PBL Discount Cr] 
	FROM uv_Sales_SLN sln
	INNER JOIN PriceCatalog pc ON pc.PriceCatalogId = sln.PriceId
	INNER JOIN   DBO.Split(@PBLIds, ',') PBL ON  (PBL.Data = sln.PrincipalBusinessLineId OR @PBLIds = '')
    INNER JOIN   DBO.Split(@LocationIds, ',') Location ON  (Location.Data = sln.LocationId OR @LocationIds = '')
	
	WHERE sln.CompanyId = @CompanyIds
	AND (@SelectAll = 0 
		OR ( @SelectAll = 1 AND DATEDIFF(DAY,sln.TransactionDate,@FromDate)=0) 
		OR ( @SelectAll = 2 AND DATEDIFF(DAY,sln.TransactionDate,@FromDate)<=0 AND DATEDIFF(DAY,sln.TransactionDate,@ToDate)>=0))
	
	GROUP BY sln.IsCash,sln.PrincipalBusinessLineId,sln.LocationId

) a
INNER JOIN Location l ON A.LocationId = l.LocationId
INNER JOIN uv_PrincipalBusinessLine_All upbla ON a.PrincipalBusinessLineId = upbla.PrincipalBusinessLineId
