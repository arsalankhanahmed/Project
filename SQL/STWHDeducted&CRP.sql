CREATE PROC usp_Report_SalesTaxChallanWHDeduct  
@CompanyId INT,
@LocationIds VARCHAR(250),
@CustomerIds VARCHAR(MAX), 
@FromDate DATETIME,
@ToDate DATETIME,
@Status INT,
@AsOnDate DATETIME
AS
--DECLARE @CompanyId INT,
--@LocationIds VARCHAR(250),
--@CustomerIds VARCHAR(MAX), 
--@FromDate DATETIME,
--@ToDate DATETIME,
--@Status INT,
--@AsOnDate DATETIME

--SET @CompanyId = 1
--SET @LocationIds = ''
--SET @CustomerIds = ''
--SET @ToDate = GETDATE()
--SET @FromDate = GETDATE()- 365
--SET @Status = 0
--SET @AsOnDate = GETDATE()

SELECT  
pay.LocationId,
pay.PaymentTransactionId,
pay.InsertDate,
pay.[PAYMENT ID],
pay.[PAYMENT DATE],
pay.CustomerId [CUSTOMER CODE],
c.Name [CUSTOMER NAME],
pay.AMOUNT,
--pay.[RECEIVING SNDId],
--sdod.SnDId [REMITTED SNDId],
srec.SnDNumber [RECEIVING SND#],
srec.ToDate [RECEIVING SND DATE],
srem.SnDNumber [REMITTANCE SND#],
srem.ToDate [REMITTANCE SND DATE],
DateDiff(d,srec.ToDate,ISNULL(srem.ToDate,@AsOnDate)) [AGE]
INTO #tmpTable
FROM
	(
	SELECT 'CSP-'+Convert(varchar,csp.CashSalePaymentId) [PAYMENT ID],
	csp.TransactionDate [PAYMENT DATE],
	cspd.AdjustedAmount [AMOUNT],
	csp.LocationId,
	cspd.PaymentTransactionId,
	pt.InsertDate,
	null CustomerId,
	sdc.SnDId [RECEIVING SNDId]
	FROM CashSalePayment csp 
	INNER JOIN dbo.[Split](@LocationIds,',') Loc ON (Loc.[Data] = csp.LocationId OR @LocationIds = '')
	--INNER JOIN dbo.[Split](@CustomerIds,',') Cus ON (Cus.[Data] = csp.CustomerId OR @CustomerIds = '')
	inner join CashSalePaymentDocument cspd ON csp.LocationId = cspd.LocationId AND csp.CashSalePaymentId = cspd.CashSalePaymentId 
	INNER JOIN PaymentTransaction pt ON pt.LocationId = cspd.LocationId AND pt.PaymentTransactionId = cspd.PaymentTransactionId AND pt.PaymentModeId = 12
	INNER JOIN SnDCashSalePayment sdc ON sdc.LocationId = csp.LocationId AND sdc.CashSalePaymentId = csp.CashSalePaymentId
	WHERE csp.CompanyId = @CompanyId
	AND csp.IsRollbacked = 0
	AND DATEDIFF(d,@FromDate,csp.TransactionDate)>=0
	AND DATEDIFF(d,csp.TransactionDate,@ToDate)>=0
	
	UNION ALL 

	SELECT 'CC-'+Convert(varchar,csp.CreditCollectionId) [PAYMENT ID],
	csp.TransactionDate [PAYMENT DATE],
	cspd.AdjustedAmount [AMOUNT],
	csp.LocationId,
	cspd.PaymentTransactionId,
	pt.InsertDate,
	csp.CustomerId,
	sdc.SnDId [RECEIVING SNDId]
	FROM CreditCollection csp
	INNER JOIN dbo.[Split](@LocationIds,',') Loc ON (Loc.[Data] = csp.LocationId OR @LocationIds = '')
	INNER JOIN dbo.[Split](@CustomerIds,',') Cus ON (Cus.[Data] = csp.CustomerId OR @CustomerIds = '')
	INNER join CreditCollectionDocument cspd ON csp.LocationId = cspd.LocationId AND csp.CreditCollectionId = cspd.CreditCollectionId 
	INNER JOIN PaymentTransaction pt ON pt.LocationId = csp.LocationId AND pt.PaymentTransactionId = cspd.PaymentTransactionId AND pt.PaymentModeId = 12
	INNER JOIN SnDCreditCollection sdc ON sdc.LocationId = csp.LocationId AND sdc.CreditCollectionId = csp.CreditCollectionId
	WHERE csp.CompanyId = @CompanyId
	AND csp.IsRollbacked = 0
	AND DATEDIFF(d,@FromDate,csp.TransactionDate)>=0
	AND DATEDIFF(d,csp.TransactionDate,@ToDate)>=0
	
)pay
LEFT JOIN Customer c ON c.LocationId = pay.LocationId AND c.CustomerId = pay.CustomerId
LEFT JOIN SND srec ON srec.LocationId = pay.LocationId AND srec.SnDId = pay.[RECEIVING SNDId]
LEFT JOIN SnDRemittanceOtherDoc sdod ON sdod.LocationId = pay.LocationId AND sdod.PaymentTransactionId = pay.PaymentTransactionId
LEFT JOIN SND srem ON srem.LocationId = sdod.LocationId AND srem.SnDId = sdod.SnDId


SELECT * 
FROM #tmpTable t 
WHERE (@Status = 0 
   OR (@Status = 1 AND t.[REMITTANCE SND#] IS NULL) 
   OR (@Status = 2 AND t.[REMITTANCE SND#] IS NOT NULL)
	)
   AND DATEDIFF(d,t.[REMITTANCE SND DATE],@AsOnDate)>=0
  
DROP TABLE #tmpTable