DECLARE @CompanyId INT, @LocationIds NVARCHAR(200), @PBLIds NVARCHAR(200), @SchemeBasedOn BIT, @SchemeIds NVARCHAR(MAX),  @FromDate DATETIME, @ToDate DATETIME,
@Sharing INT,@DateStatus INT 

SET @CompanyId = '1'
SET @LocationIds = '14'
SET @PBLIds = '40'

SET @SchemeBasedOn = ''
SET @SchemeIds = ''

/*0-All
* 1-Specific
* 2-Between*/
SET @DateStatus = '2'
SET @FromDate = '2013-11-23 00:00:00.000'
SET @ToDate = '2013-11-26 00:00:00.000'

SET @Sharing = ''

SELECT so.SaleOrderId,
	so.SalePassDate,
	so.CustomerId,
	ISNULL(so.CustomerToBeOpenedName , c.[Name]) AS CustomerName,
	sop.PrincipalBusinessLineId,sop.ProductId,sop.SoldQuantity,
	sos.SchemeId , s.[Description] AS [Scheme Description]

FROM 
dbo.SaleOrder so 
INNER JOIN dbo.SaleorderProduct sop ON so.LocationId = sop.LocationId AND so.SaleOrderId = sop.SaleOrderId
INNER JOIN dbo.SaleOrderScheme sos ON so.LocationId = sos.LocationId AND so.SaleOrderId = sos.SaleOrderId
INNER JOIN dbo.[Scheme] s ON sos.SchemeId = s.SchemeId
INNER JOIN dbo.Customer c ON so.LocationId = c.LocationId AND so.CustomerId = c.CustomerId
INNER JOIN DBO.[Split](@LocationIds,',')LOC ON LOC.[Data] = so.LocationId OR @LocationIds = ''
INNER JOIN DBO.[Split](@SchemeIds,',')SI ON SI.[Data] = sos.SchemeId OR @SchemeIds = ''

WHERE so.CompanyId = @CompanyId
AND sop.PrincipalBusinessLineId =@PBLIds
AND (@DateStatus = 0
     OR (@DateStatus = 1 AND so.SalePassDate = @FromDate)
     OR (@DateStatus = 2 AND so.salePassDate BETWEEN @FromDate AND @ToDate))