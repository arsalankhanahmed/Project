


--EXEC usp_Report_SND 5,64,45
--CREATED BY : RIZWAN AHMED KHAN
--DATE       : 16 FEB, 2013
--PURPOSE    : GENERATE SND MAIN REPORT.

--CREATE PROC [dbo].usp_Report_SND @CompanyId int, @LocationId int,@SNDID int AS

DECLARE @CompanyId INT = 1, @LocationId INT = 11,@SNDID INT = 4 

SET @CompanyId = 1--@CompanyId
SET @LocationId = 11--@LocationId
SET @SNDID = 7--@SNDID
--Declaration for Adjustment
--drop table #TempCollectionReceipt

DECLARE
	@Cash					numeric(15,2),
	@Vault					numeric(15,2),
	@Cheque					numeric(15,2),
	@DD_PO					numeric(15,2),
	@TC 					numeric(15,2),
	@RS 					numeric(15,2),
	@DS_HO					numeric(15,2),
	@OtherDocument			numeric(15,2),
	@BalanceDeposited		numeric(15,2),
	@BankBalance			numeric(15,2),
	@TransferBankDOC		numeric(15,2),
	@RertunDocument			numeric(15,2),
	@BankChanrges			numeric(15,2),
	@Customer_ADJ			numeric(15,2),
	@OS_ADV_ADJ				numeric(15,2),
	@SLN_ADJ				numeric(15,2),
	@CN_ADJ					numeric(15,2),
	@WHT_ADJ				numeric(15,2),
	@IBC_ADJ				numeric(15,2),
	@SHORTAGE				numeric(15,2),
	@ROUNDOFF				numeric(15,2),
	@DS_BR					numeric(15,2),
	@ShortageCollection		numeric(15,2),
	@FromDate				datetime,
	@ToDate					datetime,
	
	--Remittance related variable
	@Remittance_OB						numeric(15,2),
	@Remittance_CollAccChqDishonoured	numeric(15,2),
	@Remittance_CollAccChqRedeposited	numeric(15,2),
	@Remittance_CashInHandDepInHOAcc	numeric(15,2),
	@Remittance_HOC						numeric(15,2),
	@Remittance_TC						numeric(15,2),
	@Remittance_DD_PO					numeric(15,2),
	@Remittance_CASH_DD					numeric(15,2),
	@Remittance_BANK_DD					numeric(15,2),
	@Remittance_OtherDocument			numeric(15,2),
	@Remittance_CollAccChqDepInHOAcc	numeric(15,2),
	@Remittance_TTFromCollAcc			numeric(15,2),
	@Remittance_DirectRemToHODS			numeric(15,2),
	@Remittance_DirectRemToHORS			numeric(15,2),
	@Remittance_TOTALREMITTEDTODAY		numeric(15,2),
	@Remittance_CF						numeric(15,2)
	

SELECT	@FromDate=s.FromDate, 
		@ToDate=s.ToDate 
FROM	SnD s
WHERE	s.CompanyId=@CompanyId and s.LocationId=@LocationID AND s.SnDId=@SNDID



SELECT c.Name AS CompanyName,l.ShortName AS LocationName,s.SnDNumber,s.FromDate,s.ToDate 
FROM snd s 
INNER JOIN Company c ON c.CompanyId = s.CompanyId
INNER JOIN Location l ON s.LocationId=l.LocationId
WHERE	s.CompanyId=@CompanyId and s.LocationId=@LocationID AND s.SnDId=@SNDID


--Create table for SND Reconciliation data
CREATE TABLE #SnDReconciliation (GroupID numeric(5,0),GroupDescription Varchar(50),SortID numeric(5,0),SourceReceipt Varchar(100),CompanyID numeric(9,0),LocationID numeric(9,0),SNDID numeric(9,0),
								Cash numeric(15,2),Cheque numeric(15,2),Vault numeric(15,2),DD_PO numeric(15,2),TC numeric(15,2),OtherDocument numeric(15,2)
								,BalanceDeposited numeric(15,2),BankBalance numeric(15,2),TotalBankBalance numeric(15,2),
								ReturnDocument numeric(15,2),BankCharges numeric(15,2),Shortage numeric(15,2),DirectlyRemitted numeric(15,2),
								Customer_ADJ numeric(15,2), OS_ADV_ADJ numeric(15,2), SLN_ADJ numeric(15,2), CN_ADJ numeric(15,2),
								WHT_ADJ numeric(15,2), IBC_ADJ numeric(15,2), ROUNDOFF numeric(15,2), TOTALREMITTABEBALANCE numeric(15,2))

--Create table for SND Remittance data
CREATE TABLE #SnDRemittance    (SortID numeric(5,0),SourceReceipt Varchar(100),CompanyID numeric(9,0),LocationID numeric(9,0),SNDID numeric(9,0),
								TotalAmount numeric(15,2))


----------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - SND COLLECTION
----------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #TempSnDCollection (CompanyID numeric(9,0),LocationID numeric(9,0),SNDID numeric(9,0),SnDNumber numeric(9,0),SortID numeric(5,0),SourceReceipt Varchar(100),
								Cash numeric(15,2),Cheque numeric(15,2),DD_PO numeric(15,2),TC numeric(15,2)
								,RS numeric(15,2),DS_HO numeric(15,2),DS_BR numeric(15,2),OtherDocument  numeric(15,2),
								Customer_ADJ numeric(15,2), OS_ADV_ADJ numeric(15,2), SLN_ADJ numeric(15,2), CN_ADJ numeric(15,2),
								WHT_ADJ numeric(15,2), IBC_ADJ numeric(15,2),Shortage numeric(15,2), ROUNDOFF numeric(15,2), SUBTOTAL numeric(15,2), ALREADYINREMITTABLE numeric(15,2), ADDEDTOREMITTABLE numeric(15,2))

INSERT INTO #TempSnDCollection
exec usp_Report_SNDCollection @CompanyId,@LocationId,@SnDId
SELECT * FROM #TempSnDCollection

----------------------------------------------------------------------------------------------------------------------------------------
-- END - SND COLLECTION
----------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - SND BANK BALANCE
----------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #TempBankBalance (BankAccountID int, ShortName VarChar(75), OB int, BalanceDeposited numeric(15,4),BankBalance numeric(15,4))
INSERT INTO #TempBankBalance
exec usp_Report_SND_BankBalance @CompanyId,@LocationId,@SnDId

SELECT BankAccountID,ShortName,isnull(sum(isnull(BalanceDeposited,0)) ,0) AS BalanceDeposited
								,isnull(sum(isnull(BankBalance,0)) ,0) AS BankBalance
FROM #TempBankBalance
GROUP BY BankAccountID,ShortName
---------------------------------------------------------------------------------------------------------------------------------------
-- END - SND BANK BALANCE
----------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - SND RECONCILLIATION OPENING BALANCE
----------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #TempSnDOpeningBalance (CompanyID numeric(9,0),LocationID numeric(9,0),SNDID numeric(9,0),
								Cash numeric(15,2),Cheque numeric(15,2),Vault numeric(15,2),DD_PO numeric(15,2),TC numeric(15,2),OtherDocument numeric(15,2)
								,BalanceDeposited numeric(15,2),BankBalance numeric(15,2),TotalBankBalance numeric(15,2),
								ReturnDocument numeric(15,2),BankCharges numeric(15,2),Shortage numeric(15,2),DirectlyRemitted numeric(15,2),
								Customer_ADJ numeric(15,2), OS_ADV_ADJ numeric(15,2), SLN_ADJ numeric(15,2), CN_ADJ numeric(15,2),
								WHT_ADJ numeric(15,2), IBC_ADJ numeric(15,2), ROUNDOFF numeric(15,2))
INSERT INTO #TempSnDOpeningBalance
exec usp_Report_SNDOpeningBalance @CompanyId,@LocationId,@SnDId

-- Bank Balance Updates

UPDATE #TempSnDOpeningBalance SET BalanceDeposited =	(SELECT isnull(sum(isnull(BalanceDeposited,0)),0) FROM #TempBankBalance WHERE OB=1)
UPDATE #TempSnDOpeningBalance SET BankBalance =			(SELECT isnull(sum(isnull(BankBalance,0)),0) FROM #TempBankBalance WHERE OB=1)

--Reconciliation OPENING BALANCE
----------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash,Cheque,Vault,DD_PO,TC,OtherDocument
								,BalanceDeposited,BankBalance,TotalBankBalance,ReturnDocument,BankCharges,Shortage,DirectlyRemitted,Customer_ADJ
								,OS_ADV_ADJ,SLN_ADJ,CN_ADJ,WHT_ADJ,IBC_ADJ,ROUNDOFF)	
SELECT		1 AS  GroupID, 'OPENING BALANCE' AS  GroupDescription,1 AS SortID,'OPENING BALANCE' AS SourceReceipt,
			CompanyID,LocationID,SNDID,Cash,Cheque,Vault,DD_PO,TC,OtherDocument,BalanceDeposited,BankBalance,TotalBankBalance = 0--BalanceDeposited + BankBalance
			,ReturnDocument,BankCharges,Shortage,DirectlyRemitted,Customer_ADJ,OS_ADV_ADJ,SLN_ADJ,CN_ADJ,WHT_ADJ,IBC_ADJ,ROUNDOFF
FROM #TempSnDOpeningBalance tsdb
----------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------
-- END - SND RECONCILLIATION OPENING BALANCE
----------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - SND RECONCILLIATION 
----------------------------------------------------------------------------------------------------------------------------------------

---GET RECONCILIATION DATA
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	 @CASH			=	ISNULL(sum(isnull(Cash,0)),0)
		,@CHEQUE		=	ISNULL(sum(isnull(Cheque,0)),0)
		,@DD_PO			=	ISNULL(sum(isnull(DD_PO,0)),0)
		,@TC			=	ISNULL(sum(isnull(TC,0)),0)
		,@OtherDocument	=	ISNULL(sum(isnull(OtherDocument,0)),0)
		,@Shortage		=	ISNULL(sum(isnull(Shortage,0)),0) --+ ISNULL(sum(isnull(ROUNDOFF,0)),0)
		,@RS			=	ISNULL(sum(isnull(RS,0)),0)
		,@DS_HO			=	ISNULL(sum(isnull(DS_HO,0)),0)
		,@DS_BR			=	ISNULL(sum(isnull(DS_BR,0)),0)
		,@Remittance_DirectRemToHODS	=	ISNULL(sum(isnull(DS_HO,0)),0)
		,@Remittance_DirectRemToHORS	=	ISNULL(sum(isnull(RS,0)),0)
FROM	#TempSnDCollection tsd

--GET REMITTANCE DATA
SELECT	@Remittance_OB						= sr.OpeningBalance
		,@Remittance_TTFromCollAcc			= sr.TotalCollectionAccountRemittance
		,@Remittance_DD_PO					= sr.TotalBankDD + sr.TotalCashDD
		,@Remittance_CASH_DD				= sr.TotalCashDD
		,@Remittance_BANK_DD				= sr.TotalBankDD 
		,@Remittance_CollAccChqDishonoured	= sr.TotalCollectionAccountReturned
		,@Remittance_CollAccChqRedeposited	= sr.TotalCollectionAccountRedeposited 

FROM	snd s 
		INNER JOIN SnDRemittance sr ON sr.LocationId = s.LocationId AND sr.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL


--GET OTHER REMITTANCE DATA
SELECT	 @Remittance_DD_PO			= @Remittance_DD_PO + isnull(sum(isnull(DD_PO,0)),0)
		,@Remittance_TC				= isnull(sum(isnull(TC,0)),0)
		,@Remittance_OtherDocument	= isnull(sum(isnull(OtherDocument,0)),0)
		
from	(
		SELECT	DD_PO = (CASE WHEN pm.TypeCode IN ('DD','PO') THEN isnull(sum(isnull(PT.Amount,0)),0) ELSE 0 END)
				,TC = (CASE WHEN pm.TypeCode='TC' THEN isnull(sum(isnull(PT.Amount,0)),0) ELSE 0 END)
				,OtherDocument = (CASE WHEN pm.TypeCode NOT IN ('DD','PO','TC','RS') THEN isnull(sum(isnull(PT.Amount,0)),0) ELSE 0 END)
				
		FROM snd s 
		INNER JOIN SnDRemittanceOtherDoc ROD ON s.LocationId=ROD.LocationId AND s.SnDId=ROD.SnDId
		INNER JOIN PaymentTransaction pt ON pt.LocationId = ROD.LocationId AND pt.PaymentTransactionId = ROD.PaymentTransactionId
		INNER JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
		WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL
		GROUP BY pm.TypeCode
		) tmp



----------------------------------------------------------------------------------------------------------------------------------------
--ADDITION-1: RECEIVED TODAY / DIRECT REMITTED
----------------------------------------------------------------------------------------------------------------------------------------

--ADD: RECEIVED TODAY / DIRECT REMITTED
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID
			,Cash,Cheque,DD_PO,TC,OtherDocument,DirectlyRemitted,BankBalance)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,1 AS SortID,'ADD: RECEIVED TODAY / DIRECT REMITTED' AS SourceReceipt,@CompanyID,@LocationID,@SNDID
		,@CASH,@CHEQUE,@DD_PO,@TC,@OtherDocument,@RS+@DS_HO,@DS_BR
)		



----------------------------------------------------------------------------------------------------------------------------------------
--ADDITION-2: DEPOSITED IN BANK
----------------------------------------------------------------------------------------------------------------------------------------
--		CASH Deposit in Collection A/C

SELECT	@Cash = sum(cash)
		,@Vault = sum(Vault)
FROM
(
SELECT	Cash=(CASE WHEN scd.VaultCompanyId IS NULL then isnull(sum(isnull(DepositAmount ,0)),0) ELSE 0 END),
		Vault=(CASE WHEN scd.VaultCompanyId IS not NULL then isnull(sum(isnull(DepositAmount ,0)),0) ELSE 0 END)
		
FROM	SnD s 
		LEFT Outer JOIN SnDCashDepositBank scd ON s.LocationId = scd.LocationId AND s.SnDId = scd.SnDId
		LEFT Outer JOIN PaymentTransaction pt ON scd.LocationId=pt.LocationId AND scd.PaymentTransactionId=pt.PaymentTransactionId  
		LEFT Outer JOIN BankAccount ba ON  pt.SystemBankAccountId=ba.BankAccountId 
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL AND ba.AccountType='BR'
GROUP BY s.CompanyId,s.LocationId,s.SnDId,scd.VaultCompanyId
) tmp
--ADD: CASH DEPOSITED IN BANK
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,2 AS SortID,'ADD: DEPOSITED IN BANK' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash+@Vault
)
--LESS: DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash,Vault)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,1 AS SortID,'LESS: DEPOSITED IN COLLECTION A/C' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash,@Vault
)





--		DOC Deposit in bank but not credited



SELECT	@Cheque=isnull(sum(isnull(Cheque,0)),0)
		,@DD_PO=isnull(sum(isnull(DD_PO,0)),0)
		,@TC=isnull(sum(isnull(TC,0)),0)
		,@OtherDocument=isnull(sum(isnull(OtherDocument,0)),0)
		,@TransferBankDOC=isnull(sum(isnull(TransferBankDOC,0)),0)
from	(
		SELECT	Cheque = (CASE WHEN sbd.Type='D' AND pm.TypeCode='CHQ' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,DD_PO = (CASE WHEN sbd.Type='D' AND pm.TypeCode IN ('DD','PO') THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,TC = (CASE WHEN sbd.Type='D' AND pm.TypeCode='TC' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,OtherDocument = (CASE WHEN sbd.Type='D' AND pm.TypeCode NOT IN ('CHQ','CASH','DD','PO','TC') THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,TransferBankDOC = (CASE WHEN sbd.Type='T' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
		FROM snd s 
		LEFT Outer  JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
		LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
		LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
		WHERE sbd.Type IN ('D','T') AND pm.IsToBeDeposited=1 
		AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL
		GROUP BY pm.TypeCode,sbd.Type
		) tmp
--ADD: DOC DEPOSITED IN BANK
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BalanceDeposited)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,2 AS SortID,'ADD: DEPOSITED IN BANK' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cheque+@DD_PO+@TC+@OtherDocument+@TransferBankDOC
)
--LESS: DOC DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cheque,DD_PO,TC,OtherDocument,BankBalance)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,1 AS SortID,'LESS: DEPOSITED IN COLLECTION A/C' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cheque,@DD_PO,@TC,@OtherDocument,@TransferBankDOC
)
----------------------------------------------------------------------------------------------------------------------------------------
--ADD: RETURNED CHQ. REDEPOSITED
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	@Cheque=isnull(sum(isnull(Cheque,0)),0)
		,@DD_PO=isnull(sum(isnull(DD_PO,0)),0)
		,@TC=isnull(sum(isnull(TC,0)),0)
		,@OtherDocument=isnull(sum(isnull(OtherDocument,0)),0)
		,@TransferBankDOC=isnull(sum(isnull(TransferBankDOC,0)),0)
from	(
		SELECT	Cheque = (CASE WHEN sbd.Type='D' AND pm.TypeCode='CHQ' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,DD_PO = (CASE WHEN sbd.Type='D' AND pm.TypeCode IN ('DD','PO') THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,TC = (CASE WHEN sbd.Type='D' AND pm.TypeCode='TC' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,OtherDocument = (CASE WHEN sbd.Type='D' AND pm.TypeCode NOT IN ('CHQ','CASH','DD','PO','TC','DS') THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
				,TransferBankDOC = (CASE WHEN sbd.Type='T' THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
		FROM snd s 
		LEFT Outer  JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
		LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
		LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
		WHERE sbd.Type IN ('D','T') AND pm.IsToBeDeposited=1 
		AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND sbd.LastSettlementSnDId=@SNDID AND s.RollbackDate IS NULL
		--All Redeposit Doc
		AND EXISTS (SELECT sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
						WHERE sbd2.PaymentTransactionId=sbd.PaymentTransactionId
						AND sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
		GROUP BY pm.TypeCode,sbd.Type
		) tmp


INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cheque,DD_PO,TC,OtherDocument,BankBalance)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,3 AS SortID,'ADD: RETURNED CHQ. REDEPOSITED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cheque,@DD_PO,@TC,@OtherDocument,@TransferBankDOC
)

INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,10 AS SortID,'LESS: COLLECTION A/C CHEQUE REDEPOSITED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@TransferBankDOC
)
--LESS: RETURN DOCUMENT SETTLEMENT
--INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,ReturnDocument)
--(
--SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,11 AS SortID,'LESS: DEDUCTED / ADJUSTED /CLEARED'  AS SourceReceipt
--		,@CompanyID,@LocationID,@SNDID, @Cheque + @DD_PO + @TC + @OtherDocument
--)
----------------------------------------------------------------------------------------------------------------------------------------
--ADD: CHEQUE CLEARED & REMITTABLE BY BANK
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	@BankBalance = isnull(sum(isnull(sbd.Amount,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.ClearedSnDId
LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
WHERE sbd.Type IN ('D','T') AND pm.IsToBeDeposited=1 
AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,4 AS SortID,'ADD: CHEQUE CLEARED & REMITTABLE BY BANK' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@BankBalance
)
--LESS: DOC DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BalanceDeposited)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,6 AS SortID,'LESS: CHEQUE CLEARED FROM NOT CREDATED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@BankBalance
)
----------------------------------------------------------------------------------------------------------------------------------------
--ADD: CASH DD / BANK DD PREPARED
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	@Cash=(CASE WHEN scd.VaultCompanyId IS NULL then isnull(sum(isnull(SCD.Amount  ,0)),0) ELSE 0 END),
		@Vault=(CASE WHEN scd.VaultCompanyId IS not NULL then isnull(sum(isnull(SCD.Amount ,0)),0) ELSE 0 END)
FROM	SnD s 
		LEFT Outer  JOIN SnDCashDD scd ON s.LocationId = scd.LocationId AND s.SnDId = scd.SnDId
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL 
GROUP BY s.CompanyId,s.LocationId,s.SnDId,scd.VaultCompanyId

SELECT	@BankBalance=isnull(sum(isnull(bd.Amount  ,0)),0)
FROM	SnD s 
		LEFT Outer  JOIN SnDBankDD bd ON s.LocationId = bd.LocationId AND s.SnDId = bd.SnDId
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL 
GROUP BY s.CompanyId,s.LocationId,s.SnDId

--ADD: CASH DEPOSITED IN BANK
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,DD_PO)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,5 AS SortID,'ADD: CASH DD / BANK DD PREPARED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash+@Vault+@BankBalance
)
--LESS: DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash,Vault,BankBalance)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,4 AS SortID,'LESS: CASH DD / BANK DD PREPARED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash,@Vault,@BankBalance
)

----------------------------------------------------------------------------------------------------------------------------------------
--ADD: COLLECTION A/C CHEQUE RETURN
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	@BankBalance = isnull(sum(isnull(sbd.Amount,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.ReturnedSnDId
LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
WHERE sbd.Type IN ('R','T') AND pm.IsToBeDeposited=1 
AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,6 AS SortID,'ADD: COLLECTION A/C CHEQUE RETURN' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@BankBalance
)
----------------------------------------------------------------------------------------------------------------------------------------
--ADD: ADDED / RECEIVED
----------------------------------------------------------------------------------------------------------------------------------------
SET @Customer_ADJ=0
SET @OS_ADV_ADJ=0
SET @WHT_ADJ=0
SET @RertunDocument=0
SET @BankChanrges=0
SET @Cash=0
SET @Vault=0


--RETURN CHQ
SELECT	@RertunDocument = isnull(sum(isnull(sbd.Amount,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.ReturnedSnDId
LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
WHERE sbd.Type IN ('D') AND pm.IsToBeDeposited=1 
AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--Customer Advance , OS Advance  Receiving and WHT deducted
SELECT	@Customer_ADJ = isnull(sum(isnull(sc.CustomerAdvance ,0)),0)
		,@OS_ADV_ADJ = isnull(sum(isnull(sc.OutstationAdvance ,0)),0)
		,@WHT_ADJ = isnull(sum(isnull(sc.WHTDeducted,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDCollection sc ON s.LocationId=sc.LocationId AND s.SnDId=sc.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--Bank Charges
SELECT	@BankChanrges = isnull(sum(isnull(bc.Amount ,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDBankCharges bc ON s.LocationId=bc.LocationId AND s.SnDId=bc.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL


--SND Cash Reduction
SELECT	@Cash = isnull(sum(isnull(cr.ReductionAmount ,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDCashReduction cr ON s.LocationId=cr.LocationId AND s.SnDId=cr.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--Cash Deposit in Vault
SELECT	@Vault = isnull(sum(isnull(cd.DepositedInVault ,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDCashDetail cd ON s.LocationId=cd.LocationId AND s.SnDId=cd.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL


--SLN
SELECT @SLN_ADJ= isnull(sum(isnull(s.TotalNet ,0)),0) --*-1
FROM SLN s
WHERE  s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.BLMApprovalDate BETWEEN @FromDate AND @Todate AND s.totalnet>0

--CN
SELECT @CN_ADJ = isnull(sum(isnull(cn.Amount  ,0)),0) --*-1
FROM CustomerCreditNote cn
WHERE  cn.CompanyId=@CompanyId AND cn.LocationId=@LocationID AND cn.BranchApprovalDate BETWEEN @FromDate AND @Todate AND cn.Amount>0

--IBC --CHANGED BY OVAIS ON 24 OCT 2013
SELECT @IBC_ADJ = isnull(sum(isnull(ibc.TotalAmount  ,0)),0) --* -1
--FROM InterBranchCollection ibc
--WHERE  ibc.CompanyId=@CompanyId AND ibc.LocationId=@LocationID AND ibc.ApprovalDate BETWEEN @FromDate AND @Todate AND ibc.TotalAmount>0
FROM InterBranchCollection ibc
INNER JOIN SnDInterBranchCollection sibc ON sibc.LocationId = ibc.LocationId AND sibc.InterBranchCollectionId = ibc.InterBranchCollectionId
INNER JOIN snd s ON s.LocationId = sibc.LocationId AND s.SnDId = sibc.SnDId AND s.CompanyId=ibc.CompanyId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId = @SNDID AND s.RollbackDate IS NULL


--ADDED / RECEIVED
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Vault,ReturnDocument,BankCharges
								,Shortage,Customer_ADJ,OS_ADV_ADJ,SLN_ADJ,CN_ADJ,WHT_ADJ,IBC_ADJ)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,7 AS SortID,'ADD: ADDED / RECEIVED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Vault,@RertunDocument,@BankChanrges,@SHORTAGE+@CASH,@Customer_ADJ,@OS_ADV_ADJ,@SLN_ADJ,@CN_ADJ,@WHT_ADJ,@IBC_ADJ
)

--LESS: CHEQUE DISHONOURED
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BalanceDeposited)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,7 AS SortID,'LESS: CHEQUE DISHONOURED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@RertunDocument
)
--LESS: BANK CHARGES
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,8 AS SortID,'LESS: BANK CHARGES' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@BankChanrges
)
--LESS: CASH DEPOSIT IN VAULT
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,11 AS SortID,'LESS: DEDUCTED / ADJUSTED /CLEARED'  AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Vault
)


SET @Vault=0
--Cash Received From Vault
SELECT	@Vault = isnull(sum(isnull(cd.ReceivedFromVault ,0)),0)
FROM snd s 
LEFT Outer  JOIN SnDCashDetail cd ON s.LocationId=cd.LocationId AND s.SnDId=cd.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL
--ADDED / RECEIVED
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash)
(
SELECT	2 AS  GroupID, 'ADDITION' AS  GroupDescription,7 AS SortID,'ADD: ADDED / RECEIVED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Vault
)
--LESS: CASH DEPOSIT IN VAULT
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Vault)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,11 AS SortID,'LESS: DEDUCTED / ADJUSTED /CLEARED'  AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Vault
)


----------------------------------------------------------------------------------------------------------------------------------------
--LESS: DEPOSITED IN HO A/C
----------------------------------------------------------------------------------------------------------------------------------------
SET @Cash=0
SET @Vault=0
SET @Remittance_CashInHandDepInHOAcc=0
SET @DD_PO=0
SET @TC=0
SET @OtherDocument=0

SELECT	@Cash=(CASE WHEN scd.VaultCompanyId IS NULL then isnull(sum(isnull(DepositAmount ,0)),0) ELSE 0 END)
		,@Vault=(CASE WHEN scd.VaultCompanyId IS not NULL then isnull(sum(isnull(DepositAmount ,0)),0) ELSE 0 END)
		,@Remittance_CashInHandDepInHOAcc = isnull(sum(isnull(DepositAmount ,0)),0)
		
FROM	SnD s 
		LEFT Outer  JOIN SnDCashDepositBank scd ON s.LocationId = scd.LocationId AND s.SnDId = scd.SnDId
		LEFT Outer  JOIN PaymentTransaction pt ON scd.LocationId=pt.LocationId AND scd.PaymentTransactionId=pt.PaymentTransactionId  
		LEFT Outer  JOIN BankAccount ba ON pt.CompanyId=ba.CompanyId and pt.SystemBankAccountId=ba.BankAccountId  AND ba.CloseDate IS null
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL  AND ba.AccountType IN ('HO','HOBR')
GROUP BY s.CompanyId,s.LocationId,s.SnDId,scd.VaultCompanyId

SET @Cash = isnull(@Cash,0)
SET @Vault = isnull(@Vault,0)
SET @Remittance_CashInHandDepInHOAcc = isnull(@Remittance_CashInHandDepInHOAcc,0)

SELECT	@DD_PO			= isnull(sum((CASE WHEN pm.TypeCode IN ('DD','PO') THEN pt.Amount ELSE 0 END)),0) ,
		@TC				= isnull(sum((CASE WHEN pm.TypeCode='TC' THEN pt.Amount ELSE 0 END)),0),
		@OtherDocument	=	isnull(sum((CASE WHEN pm.TypeCode NOT IN ('DD','PO','TC') THEN pt.Amount ELSE 0 END)),0)
FROM	snd s 
		LEFT OUTER JOIN SnDRemittanceOtherDoc sro ON sro.LocationId = s.LocationId AND sro.SnDId = s.SnDId
		LEFT OUTER JOIN PaymentTransaction pt ON pt.LocationId = sro.LocationId AND pt.PaymentTransactionId = sro.PaymentTransactionId 
		LEFT OUTER JOIN PaymentMode pm ON pm.PaymentModeId= pt.PaymentModeId AND pm.IsToBeRemitted=1 
WHERE	s.CompanyId =@CompanyId and s.LocationId=@LocationID AND s.SnDId = @SNDID


--LESS: DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash,Vault,DD_PO,TC,OtherDocument)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,2 AS SortID,'LESS: DEPOSITED IN HO A/C' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash,@Vault,@DD_PO,@TC,@OtherDocument
)



----------------------------------------------------------------------------------------------------------------------------------------
--LESS: WITHDRAWAL AG. HOC
----------------------------------------------------------------------------------------------------------------------------------------
SELECT	@Cash	=	isnull(sum(isnull(h.Amount ,0)),0) 
		,@Remittance_HOC=	isnull(sum(isnull(h.Amount ,0)),0) 
FROM	HOC h 
WHERE	h.CompanyId=@CompanyId AND h.LocationId=@LocationID AND h.WithdrawSnDId=@SNDID AND h.ApprovalDate IS NOT null


--LESS: DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,3 AS SortID,'LESS: WITHDRAWAL AG. HOC' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash
)


----------------------------------------------------------------------------------------------------------------------------------------
--LESS: COLLECTION A/C CHEQUE DEPOSITED
----------------------------------------------------------------------------------------------------------------------------------------
SELECT @Remittance_CollAccChqDepInHOAcc = sum(Remittance_CollAccChqDepInHOAcc)
		,@Remittance_TTFromCollAcc=sum(Remittance_TTFromCollAcc)
FROM
(
SELECT	--@BankBalance = isnull(sum(isnull(sbd.Amount,0)),0)
		Remittance_CollAccChqDepInHOAcc = (CASE WHEN pm.IsDirectRemitted<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
		,Remittance_TTFromCollAcc = (CASE WHEN pm.IsDirectRemitted=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) ELSE 0 END)
		
FROM snd s 
LEFT Outer JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
LEFT Outer  JOIN PaymentTransaction pt ON pt.LocationId = sbd.LocationId AND pt.PaymentTransactionId = sbd.PaymentTransactionId
LEFT Outer  JOIN PaymentMode pm ON pt.PaymentModeId=pm.PaymentModeId
WHERE sbd.Type IN ('R') --AND pm.IsToBeDeposited=1 
AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL
GROUP BY pm.IsDirectRemitted
) tmp

--LESS: DOC DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,9 AS SortID,'LESS: COLLECTION A/C CHEQUE DEPOSITED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Remittance_CollAccChqDepInHOAcc
)
----------------------------------------------------------------------------------------------------------------------------------------
--LESS: SENT / TRANSFERRED TO HO
----------------------------------------------------------------------------------------------------------------------------------------

--LESS: SENT / TRANSFERRED TO HO
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BankBalance, DD_PO)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,5 AS SortID,'LESS: SENT / TRANSFERRED TO HO' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Remittance_TTFromCollAcc,@Remittance_CASH_DD+@Remittance_BANK_DD
)
--LESS: COLLECTION A/C CHEQUE REDEPOSITED
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,BalanceDeposited)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,10 AS SortID,'LESS: COLLECTION A/C CHEQUE REDEPOSITED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Remittance_CollAccChqRedeposited
)


--SELECT * FROM SnDRemittance sdd


----------------------------------------------------------------------------------------------------------------------------------------
--LESS: DEDUCTED / ADJUSTED / CLEARED
----------------------------------------------------------------------------------------------------------------------------------------
--Bank Charges Recorded
--SELECT	@BankBalance = isnull(sum(isnull(bc.Amount ,0)),0)
--FROM snd s 
--LEFT Outer  JOIN SnDBankCharges bc ON s.LocationId=bc.LocationId AND s.SnDId=bc.SnDId
--WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--Bank Charges Collected
--SELECT	@BankChanrges = isnull(sum(isnull(bc.Amount ,0)),0)
--FROM snd s 
--LEFT Outer JOIN SnDBankCharges bc ON s.LocationId=bc.LocationId AND s.SnDId=bc.CollectionSnDId
--WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--SND Cash Reduction
SELECT	@Cash = isnull(sum(isnull(cr.ReductionAmount ,0)),0)
FROM snd s 
LEFT Outer JOIN SnDCashReduction cr ON s.LocationId=cr.LocationId AND s.SnDId=cr.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL


SELECT	@ShortageCollection = isnull(sum(isnull(SC.CollectedAmount ,0)),0)
FROM snd s 
LEFT Outer JOIN SnDShortageCollection SC ON s.LocationId=SC.LocationId AND s.SnDId=SC.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL



SELECT	 @RS			=	ISNULL(sum(isnull(RS,0)),0)
		,@DS_HO			=	ISNULL(sum(isnull(DS_HO,0)),0)
		,@IBC_ADJ		=	ISNULL(sum(isnull(IBC_ADJ,0)),0)
		,@Customer_ADJ	=	ISNULL(sum(isnull(Customer_ADJ,0)),0)
		,@OS_ADV_ADJ	=	ISNULL(sum(isnull(OS_ADV_ADJ,0)),0)
		,@SLN_ADJ		=	ISNULL(sum(isnull(SLN_ADJ,0)),0)
		--,@WHT_ADJ		=	ISNULL(sum(isnull(WHT_ADJ,0)),0)
		,@CN_ADJ		=	ISNULL(sum(isnull(CN_ADJ,0)),0)
FROM #TempSnDCollection tsd


SELECT @RertunDocument= isnull(sum(isnull(sd.SettlementAmount, 0) ),0)
FROM    SnD s LEFT Outer JOIN
		SnDBankDocSettlement sd ON sd.LocationId = s.LocationId AND sd.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId=@SNDID AND s.RollbackDate IS NULL

--WHT
SELECT @WHT_ADJ = isnull(sum(isnull(wr.AdjustedAmount  ,0)),0)
FROM WHTReversal wr 
WHERE  wr.CompanyId=@CompanyId AND wr.LocationId=@LocationID AND wr.ApprovalDate BETWEEN @FromDate AND @Todate AND wr.AdjustedAmount>0

SELECT @WHT_ADJ =@WHT_ADJ + isnull(sum(isnull(wso.AdjustedAmount  ,0)),0)
FROM WHTChallanSaleOrder wso 
WHERE  wso.LocationId=@LocationID AND CONVERT(datetime,CONVERT(varchar(10),wso.insertdate,101)) BETWEEN @FromDate AND @Todate AND wso.AdjustedAmount>0


--LESS: DOC DEPOSITED IN COLLECTION A/C
INSERT INTO #SnDReconciliation (GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID,Cash,ReturnDocument
								,Shortage,DirectlyRemitted,Customer_ADJ,OS_ADV_ADJ,SLN_ADJ,CN_ADJ,WHT_ADJ,IBC_ADJ)
(
SELECT	3 AS  GroupID, 'DEDUCTION' AS  GroupDescription,11 AS SortID,'LESS: DEDUCTED / ADJUSTED /CLEARED' AS SourceReceipt
		,@CompanyID,@LocationID,@SNDID,@Cash,@RertunDocument,@ShortageCollection,@DS_HO+@RS
		,@Customer_ADJ,@OS_ADV_ADJ,@SLN_ADJ,@CN_ADJ,@WHT_ADJ,@IBC_ADJ
)

SELECT GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID
		,ISNULL(SUM(ISNULL(Cash,0)),0) AS Cash
		,ISNULL(SUM(ISNULL(Cheque,0)),0) AS Cheque
		,ISNULL(SUM(ISNULL(Vault,0)),0) AS Vault
		,ISNULL(SUM(ISNULL(DD_PO,0)),0) AS DD_PO
		,ISNULL(SUM(ISNULL(TC,0)),0) AS TC
		,ISNULL(SUM(ISNULL(OtherDocument,0)),0) AS OtherDocument
		,ISNULL(SUM(ISNULL(BalanceDeposited,0)),0) AS BalanceDeposited
		,ISNULL(SUM(ISNULL(BankBalance,0)),0) AS BankBalance
		,ISNULL(SUM(ISNULL(TotalBankBalance,0)),0) AS TotalBankBalance
		,ISNULL(SUM(ISNULL(ReturnDocument,0)),0) AS ReturnDocument
		,ISNULL(SUM(ISNULL(BankCharges,0)),0) AS BankCharges
		,ISNULL(SUM(ISNULL(Shortage,0)),0) AS Shortage
		,ISNULL(SUM(ISNULL(DirectlyRemitted,0)),0) AS DirectlyRemitted
		,ISNULL(SUM(ISNULL(Customer_ADJ,0)),0) AS Customer_ADJ
		,ISNULL(SUM(ISNULL(OS_ADV_ADJ,0)),0) AS OS_ADV_ADJ
		,ISNULL(SUM(ISNULL(SLN_ADJ,0)),0) AS SLN_ADJ
		,ISNULL(SUM(ISNULL(CN_ADJ,0)),0) AS CN_ADJ
		,ISNULL(SUM(ISNULL(WHT_ADJ,0)),0) AS WHT_ADJ
		,ISNULL(SUM(ISNULL(IBC_ADJ,0)),0) AS IBC_ADJ
		,ISNULL(SUM(ISNULL(ROUNDOFF,0)),0) AS ROUNDOFF
		,ISNULL(SUM(ISNULL(TOTALREMITTABEBALANCE,0)),0) AS TOTALREMITTABEBALANCE
		
FROM #SnDReconciliation
GROUP BY GroupID,GroupDescription,SortID,SourceReceipt,CompanyID,LocationID,SNDID

---------------------------------------------------------------------------------------------------------------------------------------
-- END - SND RECONCILLIATION 
----------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - REIMTTANCE RELATED INFORMATION
----------------------------------------------------------------------------------------------------------------------------------------

	--REMITTANCE-1   (REMITTANCE TO HO B/F)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	1 AS SortID,
			'REMITTANCE TO HO B/F' AS SourceReceipt,
			@CompanyID,
			@LocationID,
			@SNDID,
			isnull(@Remittance_OB,0)
	)
	
	--REMITTANCE-2   (ADD: COLLECTION A/C CHEQUE DISHONOURED)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	2 AS SortID,'ADD: COLLECTION A/C CHEQUE DISHONOURED' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_CollAccChqDishonoured,0)
	)
	
	--REMITTANCE-3   (LESS: COLLECTION A/C CHEQUE REDEPOSITED)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	3 AS SortID,'LESS: COLLECTION A/C CHEQUE REDEPOSITED' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_CollAccChqRedeposited,0)
	)
	
	--REMITTANCE-4   (REMITTABLE BALANCE TOTAL:')
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	4 AS SortID,'TOTAL BEFORE TODAY REMITTANCE:' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_OB,0)  + isnull(@Remittance_CollAccChqDishonoured,0) - isnull(@Remittance_CollAccChqRedeposited,0)
	)
	
	--REMITTANCE-5   (ADD: CASH IN HAND DEPOSITED IN HO A/C)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	5 AS SortID,'CASH IN HAND DEPOSITED IN HO A/C' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_CashInHandDepInHOAcc,0)
	)
	
	--REMITTANCE-6   (REMITTANCE - HOC)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	6 AS SortID,'HOC' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_HOC,0)
	)
	
	--REMITTANCE-7   (TC)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	7 AS SortID,'TC' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_TC,0)
	)
	
	--REMITTANCE-8   (DD / PO)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	8 AS SortID,'DD / PO' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_DD_PO,0)
	)
	
	--REMITTANCE-9   (OTHER DOCUMENT)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	9 AS SortID,'OTHER DOCUMENT' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_OtherDocument,0)
	)
	
	--REMITTANCE-10   (COLLECTION A/C CHEQUE DEPOSITED IN HO A/C)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	10 AS SortID,'COLLECTION A/C CHEQUE DEPOSITED IN HO A/C' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_CollAccChqDepInHOAcc,0)
	)

	--REMITTANCE-11   (REMITTANCE FROM COLLECTION A/C (ET/TT/MT))
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	11 AS SortID,'REMITTANCE FROM COLLECTION A/C (ET/TT/MT)' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_TTFromCollAcc,0)
	)

	--REMITTANCE-12   (DIRECT REMITTANCE TO HO - DEPOSIT SLIP)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	12 AS SortID,'DIRECT REMITTANCE TO HO - DEPOSIT SLIP' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_DirectRemToHODS,0)
	)

	--REMITTANCE-13   (DIRECT REMITTANCE TO HO - REMITTANCE SLIP)
	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	13 AS SortID,'DIRECT REMITTANCE TO HO - REMITTANCE SLIP' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,isnull(@Remittance_DirectRemToHORS,0)
	)
	
	--REMITTANCE-14   (REMITTED TODAY'S TOTAL)

	SET @Remittance_TOTALREMITTEDTODAY =	isnull(@Remittance_CashInHandDepInHOAcc,0)
											+ isnull(@Remittance_HOC,0)
											+ isnull(@Remittance_DD_PO,0)
											+ isnull(@Remittance_TC,0)
											+ isnull(@Remittance_OtherDocument,0)
											+ isnull(@Remittance_CollAccChqDepInHOAcc,0)
											+ isnull(@Remittance_TTFromCollAcc,0)
											+ isnull(@Remittance_DirectRemToHODS,0)
											+ isnull(@Remittance_DirectRemToHORS,0)

	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	14 AS SortID,'TOTAL REMITTED TODAY:' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID, isnull(@Remittance_TOTALREMITTEDTODAY,0)
	)


	--REMITTANCE-15   (REMITTANCE CF)

	SELECT @Remittance_CF = SUM(ADDEDTOREMITTABLE) FROM #TempSnDCollection 
	SET @Remittance_CF = @Remittance_CF + @Remittance_OB + @Remittance_CollAccChqDishonoured - @Remittance_CollAccChqRedeposited - @Remittance_TOTALREMITTEDTODAY

	INSERT INTO #SnDRemittance(SortID,SourceReceipt,CompanyID,LocationID,SNDID,TotalAmount)
	(
	SELECT	15 AS SortID,'TOTAL REMITTANCE TO HO C/F:' AS SourceReceipt
			,@CompanyID,@LocationID,@SNDID,@Remittance_CF
	)


	SELECT * FROM #SnDRemittance

----------------------------------------------------------------------------------------------------------------------------------------
-- END - REIMTTANCE RELATED INFORMATION
----------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - SND BANK DEBIT ADVICE
----------------------------------------------------------------------------------------------------------------------------------------

	Declare		@DepositedDate datetime,
				@TransactionDate datetime,
				@PreviousSNDID	numeric(5,0),
				@DayBeforePreviousSNDID	numeric(5,0),
				@DefaultBank numeric(15,4),
				@OtherBank numeric(15,4)

	set  @PreviousSNDID				=	(SELECT max(sndid) FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL)
	set  @DayBeforePreviousSNDID	=	(SELECT max(sndid) FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @PreviousSNDID AND s.RollbackDate IS NULL)


	--CREATE TABLE FOR SND BANK DEBIT ADVICE
	CREATE TABLE #SnDDebitAdvice    (SortID numeric(5,0),SourceReceipt Varchar(100),DepositedDate datetime,TransactionDate datetime,
									 DefaultBankAmount numeric(15,2),OtherBankAmount numeric(15,2))


--CASH DEPOSITED PREVIOUS DAY

	SET		@DepositedDate=null
	SET		@TransactionDate=NULL
	SET		@DefaultBank=0
	SET		@OtherBank=0
		
	
	SELECT	@DepositedDate		=	s.ToDate,
			@TransactionDate	=	s.ToDate,
			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(scd.DepositAmount,0)),0)  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(scd.DepositAmount,0)),0)  ELSE 0 END)
	FROM snd s 
	INNER JOIN SnDCashDepositBank scd ON s.LocationId=scd.LocationId AND s.SnDId=scd.SnDId
	INNER JOIN PaymentTransaction pt ON pt.LocationId = scd.LocationId AND pt.PaymentTransactionId = scd.PaymentTransactionId
	INNER JOIN uv_SystemBankAccounts sba ON pt.SystemBankAccountId=sba.BankAccountId AND pt.LocationId=sba.LocationId
	INNER JOIN BankAccountSequence bas ON bas.LocationId= sba.LocationId AND bas.BankAccountId= sba.BankAccountId 
	WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID 
	GROUP BY s.ToDate,bas.IsDefault
	
	INSERT INTO #SnDDebitAdvice
	SELECT 1,'CASH DEPOSITED PREVIOUS DAY',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank

uno

	INSERT INTO #SnDDebitAdvice		
	SELECT	1,'CASH DEPOSITED PREVIOUS DAY', DepositedDate		=	s.ToDate,
			TransactionDate	=	s.ToDate,
			DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(spt.AdjustedAmount,0)),0)  ELSE 0 END), 
			OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(spt.AdjustedAmount,0)),0)  ELSE 0 END)
	FROM snd s
	INNER JOIN uv_SNDPaymentTransaction spt ON s.LocationId=spt.LocationId AND s.SnDId=spt.SnDId
	INNER JOIN PaymentTransaction pt ON pt.LocationId = spt.LocationId AND pt.PaymentTransactionId = spt.PaymentTransactionId
	INNER JOIN Paymentmode pm ON pt.PaymentModeId=pm.PaymentModeId
	INNER JOIN uv_SystemBankAccounts sba ON pt.SystemBankAccountId=sba.BankAccountId AND pt.LocationId=sba.LocationId
	INNER JOIN BankAccountSequence bas ON bas.LocationId= sba.LocationId AND bas.BankAccountId= sba.BankAccountId 
	WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID   AND s.RollbackDate IS null
	AND pm.IsDirectDeposited=1
	GROUP BY s.ToDate,bas.IsDefault

--CHQS DEPOSITED DAY BEFORE PREVIOUS DAY

	SET		@DepositedDate		= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @DayBeforePreviousSNDID )
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId = @DayBeforePreviousSNDID   AND s.RollbackDate IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate
	
	INSERT INTO #SnDDebitAdvice
	SELECT 2,'ADD: CHQS DEPOSITED DAY BEFORE PREVIOUS DAY',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank


--LESS: SAME BANK CHQ. CLEARED PREV. DAY

	SET		@DepositedDate		= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @DayBeforePreviousSNDID )
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  * -1  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId = @DayBeforePreviousSNDID AND sbd.ClearedSnDId=@PreviousSNDID  AND s.RollbackDate IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate
	
	INSERT INTO #SnDDebitAdvice
	SELECT 3,'LESS: SAME BANK CHQ. CLEARED PREV. DAY',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank


--ADD: SAME BANK CHQ. DEP. PREV. DAY CLEARED

	SET		@DepositedDate		= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID )
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId = @PreviousSNDID AND sbd.ClearedSnDId = @SNDID  AND s.RollbackDate IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate

	INSERT INTO #SnDDebitAdvice
	SELECT 4,'ADD: SAME BANK CHQ. DEP. PREV. DAY CLEARED',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank


--ADD: SAME BANK CHQ. DEP. PREV. DAY RETURNED

	SET		@DepositedDate		= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID )
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId = @PreviousSNDID AND sbd.ReturnedSnDId = @SNDID  AND s.RollbackDate IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate

	INSERT INTO #SnDDebitAdvice
	SELECT 5,'ADD: SAME BANK CHQ. DEP. PREV. DAY RETURNED',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank

--ADD: CHQS. PRIOR TO DAY BEFORE PREV. DAY
--Those cheques which is Prior to day before deposited day but not clear and return

	SET		@DepositedDate		=  null
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE	sbd.Type = 'D' 
	--AND s.CompanyId=5 AND s.LocationId=58 AND s.SnDId=28 AND s.RollbackDate IS NULL
	AND		s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId < @DayBeforePreviousSNDID   AND s.RollbackDate IS null
	AND		(
			ISNULL(SBD.ClearedSnDId, @SNDID+1)	> @SNDID  
			and ISNULL(SBD.ReturnedSnDId,@SNDID+1) > @SNDID
			)
	
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate

	INSERT INTO #SnDDebitAdvice
	SELECT 6,'ADD: CHQS. PRIOR TO DAY BEFORE PREV. DAY',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank



--LESS: CHQS. RET. ALL PREV. DEPOSIT
--Those cheques which is Prior to day before deposited day but return in current SND

	SET		@DepositedDate		=  null
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1   ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE	sbd.Type = 'D' 
	AND		s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId < @DayBeforePreviousSNDID   AND s.RollbackDate IS null
	AND		SBD.ReturnedSnDId = @SNDID
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate

	INSERT INTO #SnDDebitAdvice
	SELECT 7,'LESS: CHQS. RET. ALL PREV. DEPOSIT',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank


--LESS: UNMARKED CHEQUES
--Those cheques which is Prior to day before deposited day but not clear and return

	SET		@DepositedDate		= Null
	SET		@TransactionDate	= Null
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1   ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE	sbd.Type = 'D' 
	AND		s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId <= @DayBeforePreviousSNDID   AND s.RollbackDate IS null
	AND		(
			ISNULL(SBD.ClearedSnDId, @SNDID+1)	> @SNDID  
			and ISNULL(SBD.ReturnedSnDId,@SNDID+1) > @SNDID
			)
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate
	
	INSERT INTO #SnDDebitAdvice
	SELECT 8,'LESS: UNMARKED CHEQUES',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank


	--GET DATA
	SELECT SortID,SourceReceipt,DepositedDate,TransactionDate,sum(isnull(DefaultBankAmount,0)) AS DefaultBank,sum(isnull(OtherBankAmount,0)) AS OtherBank 
	FROM #SnDDebitAdvice
	GROUP BY SortID,SourceReceipt,DepositedDate,TransactionDate
	
----------------------------------------------------------------------------------------------------------------------------------------
-- END - SND BANK DEBIT ADVICE
----------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - BREAKUP OF DAY BEFORE PREV. DAY DEPOSITED CHQS
----------------------------------------------------------------------------------------------------------------------------------------

	--CREATE TABLE FOR SND BANK DEBIT ADVICE
	CREATE TABLE #SnDepositedChequeDetail(SortID numeric(5,0),SourceReceipt Varchar(100),DepositedDate datetime,TransactionDate datetime,
	DefaultBankAmount numeric(15,2),OtherBankAmount numeric(15,2))

--CHQS DEPOSITED DAY BEFORE PREVIOUS DAY

	SET		@DepositedDate		= Null
	SET		@TransactionDate	= Null
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DepositedDate		=   s.ToDate,
			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1   ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID AND s.SnDId = @DayBeforePreviousSNDID   AND s.RollbackDate IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate
	
	INSERT INTO #SnDepositedChequeDetail
	SELECT 1,'ADD: CHQS DEPOSITED ON',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank
	
--CHQS CLEARED - NORMAL CLEARING

	SET		@DepositedDate		= Null
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DepositedDate		=   s.ToDate,
			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)    ELSE 0 END), 
			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type			=	'D' 
	AND s.CompanyId			=	@CompanyId 
	AND s.LocationId		=	@LocationID 
	AND s.SnDId				=	@DayBeforePreviousSNDID 
	AND sbd.ClearedSnDId	<=	@SNDID 
	AND s.RollbackDate		IS null
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate
	
	INSERT INTO #SnDepositedChequeDetail
	SELECT 2,'LESS: CHQ. CLEARED',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank

----LESS: CHQS CLEARED - SAME BANK

--	SET		@DepositedDate		= Null
--	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID )
--	SET		@DefaultBank		= 0
--	SET		@OtherBank			= 0
			
--	SELECT	@DepositedDate		=   s.ToDate,
--			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1   ELSE 0 END), 
--			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
--	FROM snd s 
--	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
--	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
--	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
--	WHERE sbd.Type = 'D' 
--	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID    AND s.RollbackDate IS null
--	AND s.SnDId = @DayBeforePreviousSNDID 
--	AND sbd.ClearedSnDId = @PreviousSNDID 
--	--Exclude Redeposit Doc
--	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
--					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
--					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
--	GROUP BY bas.IsDefault,s.ToDate
	
--	INSERT INTO #SnDepositedChequeDetail
--	SELECT 3,'LESS: CHQS CLEARED - SAME BANK',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank
	
	--CHQS RETURNED - TODAY snd
	
	SET		@DepositedDate		= Null
	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DepositedDate		=   s.ToDate,
			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)    ELSE 0 END), 
			@OtherBank			=	(CASE WHEN isnull(bas.IsDefault,0)<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)  ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID    AND s.RollbackDate IS NULL 
	AND s.SnDId = @DayBeforePreviousSNDID 
	AND sbd.ReturnedSnDId <= @SNDID 
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate

	INSERT INTO #SnDepositedChequeDetail
	SELECT 4,'LESS: CHQS RETURNED',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank
	
----LESS: CHQS ALREADY RETURNED - SAME BANK

--	SET		@DepositedDate		= Null
--	SET		@TransactionDate	= (SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @PreviousSNDID  )
--	SET		@DefaultBank		= 0
--	SET		@OtherBank			= 0
			
--	SELECT	@DepositedDate		=   s.ToDate,
--			@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1   ELSE 0 END), 
--			@OtherBank			=	(CASE WHEN bas.IsDefault<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0) * -1  ELSE 0 END)
--	FROM snd s 
--	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
--	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
--	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
--	WHERE sbd.Type = 'D' 
--	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID    AND s.RollbackDate IS null
--	AND s.SnDId = @DayBeforePreviousSNDID 
--	AND sbd.ReturnedSnDId = @PreviousSNDID 
--	--Exclude Redeposit Doc
--	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
--					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
--					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
--	GROUP BY bas.IsDefault,s.ToDate		
	
--	INSERT INTO #SnDepositedChequeDetail
--	SELECT 5,'LESS: CHQS RETURNED - SAME BANK',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank
	
	--LESS: CHQS UNMARKED
	
	SET		@DepositedDate		= Null
	SET		@TransactionDate	= Null
	SET		@DefaultBank		= 0
	SET		@OtherBank			= 0
			
	SELECT	@DefaultBank		=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)    ELSE 0 END), 
			@OtherBank			=	(CASE WHEN isnull(bas.IsDefault,0)<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	INNER JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	INNER JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID    AND s.RollbackDate IS null
	AND s.SnDId = @DayBeforePreviousSNDID 
	AND		(
			ISNULL(SBD.ClearedSnDId, @SNDID+1)	> @SNDID  
			and ISNULL(SBD.ReturnedSnDId,@SNDID+1) > @SNDID
			)
	--Exclude Redeposit Doc
	AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
					WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
					AND     sbd2.LocationId = sbd.LocationId
					AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	GROUP BY bas.IsDefault,s.ToDate	
	
	INSERT INTO #SnDepositedChequeDetail
	SELECT 6,'LESS: CHQS UNMARKED',@DepositedDate,@TransactionDate, @DefaultBank, @OtherBank
	
	
--GET DATA
	SELECT SortID,SourceReceipt,DepositedDate,TransactionDate,sum(isnull(DefaultBankAmount,0)) AS DefaultBank,sum(isnull(OtherBankAmount,0)) AS OtherBank 
	FROM #SnDepositedChequeDetail
	GROUP BY SortID,SourceReceipt,DepositedDate,TransactionDate
	
	----------------------------------------------------------------------------------------------------------------------------------------
-- END - BREAKUP OF DAY BEFORE PREV. DAY DEPOSITED CHQS
----------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------
-- BEGIN - ALL INCLEARING CHEQUES
----------------------------------------------------------------------------------------------------------------------------------------
	
	SET  @DepositedDate	= 	(SELECT todate FROM snd s WHERE s.CompanyId =@CompanyId  AND s.LocationId=@LocationId AND s.SnDId = @SNDID )

	SELECT	1 AS SORTID,
			'CHQS DEPOSITED ON:' AS SourceReceipt,
			S.ToDate AS Depositeddate,
			DefaultBank	=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END), 
			OtherBank	=	(CASE WHEN isnull(bas.IsDefault,0)<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	left JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	left JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID   AND s.RollbackDate IS NULL  AND s.SnDId  <= @SNDID
	AND		
	(
			ISNULL(SBD.ClearedSnDId, @SNDID+1)	> @SNDID  
			and ISNULL(SBD.ReturnedSnDId,@SNDID+1) > @SNDID
	)
	AND s.ToDate > @DepositedDate - 3
	--Exclude Redeposit Doc
	--AND NOT EXISTS (SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
	--				WHERE	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
	--				AND     sbd2.LocationId = sbd.LocationId
	--				AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId)
	AND sbd.SnDBankDocMovementId NOT IN 
	(
		SELECT	sbd2.SnDBankDocMovementId 
        FROM SnDBankDocMovement sbd2 
		WHERE sbd2.LocationId = sbd.LocationId
		AND	sbd2.DepositedSnDId=sbd.LastSettlementSnDId
		AND	sbd2.RefSnDBankDocMovementId IS NOT NULL 
	)
	GROUP BY s.ToDate,bas.IsDefault	
	
	
	UNION ALL
	
	
	SELECT  2 AS SORTID,
			'CHQS DEPOSITED LESS THEN:' AS SourceReceipt,
			@DepositedDate AS Depositeddate,
			DefaultBank	=	(CASE WHEN bas.IsDefault=1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END), 
			OtherBank	=	(CASE WHEN isnull(bas.IsDefault,0)<>1 THEN isnull(sum(isnull(sbd.Amount,0)),0)   ELSE 0 END)
	FROM snd s 
	inner JOIN SnDBankDocMovement sbd ON s.LocationId=sbd.LocationId AND s.SnDId=sbd.DepositedSnDId
	left JOIN uv_SystemBankAccounts usba ON usba.LocationId = sbd.LocationId AND usba.BankAccountId = sbd.BankAccountId
	left JOIN BankAccountSequence bas ON bas.LocationId = usba.LocationId AND bas.BankAccountId = usba.BankAccountId
	WHERE sbd.Type = 'D' 
	AND s.CompanyId=@CompanyId AND s.LocationId=@LocationID  AND s.RollbackDate IS NULL   AND s.SnDId  <= @SNDID
	AND		
	(
			ISNULL(SBD.ClearedSnDId, @SNDID+1)	> @SNDID  
			and ISNULL(SBD.ReturnedSnDId,@SNDID+1) > @SNDID
	)
	AND s.ToDate < @DepositedDate - 4
	--Exclude Redeposit Doc
	--AND NOT EXISTS 
	--(
	--	SELECT	sbd2.SnDBankDocMovementId FROM SnDBankDocMovement sbd2 
	--	WHERE	
	--	sbd2.PaymentTransactionId=sbd.PaymentTransactionId
	--	AND sbd2.LocationId = sbd.LocationId
	--	AND		sbd2.DepositedSnDId=sbd.LastSettlementSnDId
	--)
	AND sbd.SnDBankDocMovementId NOT IN 
	(
		SELECT	sbd2.SnDBankDocMovementId 
        FROM SnDBankDocMovement sbd2 
		WHERE sbd2.LocationId = sbd.LocationId
		AND	sbd2.DepositedSnDId=sbd.LastSettlementSnDId
		AND	sbd2.RefSnDBankDocMovementId IS NOT NULL 
	)
					
	GROUP BY bas.IsDefault	
	ORDER BY SORTID ,Depositeddate desc
	
	DROP TABLE #SnDReconciliation
	DROP TABLE #SnDRemittance
	DROP TABLE #TempSnDCollection
	DROP TABLE #TempBankBalance
	DROP TABLE #TempSnDOpeningBalance
	DROP TABLE #SnDDebitAdvice
	DROP TABLE #SnDepositedChequeDetail