--usp_Report_SNDOpeningBalance

--exec usp_Report_SNDOpeningBalance 5,58,29
CREATE PROC dbo.usp_Report_SNDOpeningBalance @CompanyId int, @LocationId int,@SNDID int
AS

Declare		@PreviousSNDID		numeric(5,0),
			@PreviousSndToDate	datetime,
			@OB_DD				numeric(15,2)
	
SELECT @PreviousSNDID = MAX(sndid),
		@PreviousSndToDate = ISNULL(MAX(s.ToDate), (SELECT MIN(sd.ToDate) FROM SnD sd WHERE sd.CompanyId = @CompanyId  
AND sd.LocationId = @LocationId AND sd.RollbackDate IS NULL))
FROM snd s WHERE s.CompanyId = @CompanyId  
AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL


--Create temp table
CREATE TABLE #TempSNDOpeningBalance (CompanyID numeric(9,0),LocationID numeric(9,0),SNDID numeric(9,0),
								Cash numeric(15,2),Cheque numeric(15,2),Vault numeric(15,2),DD_PO numeric(15,2),TC numeric(15,2),OtherDocument numeric(15,2)
								,BalanceDeposited numeric(15,2),BankBalance numeric(15,2),TotalBankBalance numeric(15,2),
								ReturnDocument numeric(15,2),BankCharges numeric(15,2),Shortage numeric(15,2),DirectlyRemitted numeric(15,2),
								Customer_ADJ numeric(15,2), OS_ADV_ADJ numeric(15,2), SLN_ADJ numeric(15,2), CN_ADJ numeric(15,2),
								WHT_ADJ numeric(15,2), IBC_ADJ numeric(15,2), ROUNDOFF numeric(15,2))


--Working for opening balance
--===========================
--Cash and Vault
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,Cash,Vault)
(
SELECT	@CompanyId,@LocationId,@SNDID,
		OpeningBalanceSafe,OpeningBalanceVault 
FROM	SnD s inner JOIN SnDCashDetail scd ON s.LocationId = scd.LocationId AND s.SnDId = scd.SnDId
WHERE	s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId=@SNDID AND s.RollbackDate IS NULL
)


--CHEQUE,DD_PO,TC,OTHER
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,CHEQUE,DD_PO,TC,OtherDocument)
(
SELECT	@CompanyId,@LocationId,@SNDID,
		ISNULL(sum((CASE WHEN pm.typecode='CHQ' AND sdm.Type='D' THEN sdm.Amount ELSE 0 END)),0) AS CHEQUE,
		ISNULL(sum((CASE WHEN pm.typecode IN ('DD','PO') AND sdm.Type='D' THEN sdm.Amount ELSE 0 END)),0) AS DD,
		ISNULL(sum((CASE WHEN pm.typecode IN ('TC') AND sdm.Type='D' THEN sdm.Amount ELSE 0 END)),0) AS TC,
		ISNULL(sum((CASE WHEN pm.typecode NOT IN ('TC','CHQ','DD','PO','TC') AND sdm.Type='D' THEN sdm.Amount ELSE 0 END)),0) AS OTHER

FROM snd s
		INNER JOIN SnDBankDocMovement sdm ON sdm.LocationId = s.LocationId AND sdm.SnDId = s.SnDId
		INNER JOIN PaymentTransaction pt ON pt.LocationId = sdm.LocationId AND pt.PaymentTransactionId = sdm.PaymentTransactionId
		INNER JOIN PaymentMode pm ON pm.PaymentModeId=pt.PaymentModeId
WHERE	s.CompanyId=@CompanyId and	s.LocationId=@LocationId AND s.SnDId < @SNDID AND (sdm.DepositedSnDId >=@SNDID OR sdm.DepositedSnDId IS null) 
		AND s.RollbackDate IS null
)

--DD_PO,TC,OTHER (Other Doc Remit to HO)
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,DD_PO,TC,OtherDocument)
(
SELECT @CompanyId,@LocationId,@SNDID,
		ISNULL(sum((CASE WHEN pm.typecode IN ('DD','PO') THEN v.AdjustedAmount ELSE 0 END)),0) AS DD,
		ISNULL(sum((CASE WHEN pm.typecode IN ('TC') THEN v.AdjustedAmount ELSE 0 END)),0) AS TC,
		ISNULL(sum((CASE WHEN pm.typecode NOT IN ('TC','DD','PO') THEN v.AdjustedAmount ELSE 0 END)),0) AS OTHER 
FROM snd s
		INNER JOIN uv_SNDPaymentTransaction v ON v.CompanyId=s.CompanyId AND  v.LocationId = s.LocationId AND v.SnDId = s.SnDId 
INNER JOIN PaymentTransaction pt ON pt.CompanyId = v.CompanyId AND pt.LocationId = v.LocationId AND pt.PaymentTransactionId = v.PaymentTransactionId
INNER JOIN PaymentMode pm ON pm.PaymentModeId = pt.PaymentModeId
WHERE  s.CompanyId=@CompanyId and	s.LocationId=@LocationId AND s.SnDId < @SNDID AND pm.IsToBeRemitted=1 AND s.RollbackDate IS null
AND Not exists (SELECT PaymentTransactionId FROM SnDRemittanceOtherDoc sdod  INNER JOIN SnD sdo ON sdo.LocationId = sdod.LocationId AND sdo.SnDId = sdod.SnDId
                WHERE  sdod.LocationId=v.LocationId and v.PaymentTransactionId=sdod.PaymentTransactionId   AND sdod.SnDId < @SNDID  AND sdo.RollbackDate IS null)
)

--CASH DD OB
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,DD_PO)
(
SELECT	@CompanyId,@LocationId,@SNDID,
		ISNULL(sum(sdd.Amount),0)
FROM snd s
		INNER JOIN SnDCashDD sdd ON sdd.LocationId = s.LocationId AND sdd.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId and	s.LocationId=@LocationId AND s.SnDId < @SNDID  AND s.RollbackDate IS null
)
--BANK DD OB
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,DD_PO)
(
SELECT	@CompanyId,@LocationId,@SNDID,
		ISNULL(sum(sdd.Amount),0)
FROM snd s
		INNER JOIN SnDBankDD sdd ON sdd.LocationId = s.LocationId AND sdd.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId and	s.LocationId=@LocationId AND s.SnDId < @SNDID  AND s.RollbackDate IS null
)
--CASH DD & BANK DD Remittance OB
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,DD_PO)
(
SELECT	@CompanyId,@LocationId,@SNDID,
		(ISNULL(sum(sr.TotalCashDD),0)*-1 ) + (ISNULL(sum(sr.TotalbankDD),0)*-1 )
FROM snd s
		INNER JOIN SnDRemittance sr ON sr.LocationId = s.LocationId AND sr.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId and	s.LocationId=@LocationId AND s.SnDId < @SNDID  AND s.RollbackDate IS null
)





--BalanceDeposited, BankBalance
--INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,BalanceDeposited,BankBalance)
--(
--SELECT	@CompanyId,@LocationId,@SNDID,	
--		isnull(sum(isnull(BalanceDeposited,0)),0) ,isnull(sum(isnull(BankBalance,0)),0)
--FROM	#TempBankBalance 
--WHERE	OB = 1
--)


--RETURN CHQ, BANK CHARGES
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,ReturnDocument,BankCharges)
(
SELECT	@CompanyId,@LocationId,@SNDID,	
		sdb.BalanceReturned,sdb.TotalBankCharges
FROM	snd s inner JOIN SnDBankDetail sdb ON sdb.LocationId = s.LocationId AND sdb.SnDId = s.SnDId 
WHERE	s.CompanyId=@CompanyId and sdb.LocationId=@LocationId AND s.SnDId = @PreviousSNDID AND s.RollbackDate IS null
)

--Shortage OB from O/B Shortage

--Shortage OB from cash sale payment
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,Shortage)
(
SELECT	@CompanyId,@LocationId,@SNDID,	
		SHORTAGE=ISNULL(sum(ISNULL(csp.Shortage,0)),0)
FROM	CashSalePayment csp 
		INNER JOIN SnDCashSalePayment sdsp ON sdsp.LocationId=csp.LocationId AND sdsp.CashSalePaymentId=csp.CashSalePaymentId
		INNER JOIN snd s ON s.LocationId = sdsp.LocationId AND s.SnDId = sdsp.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL AND csp.Shortage>0


--Shortage OB from credit collection

UNION all
SELECT	@CompanyId,@LocationId,@SNDID,	
		SHORTAGE=ISNULL(sum(ISNULL(cc.Shortage,0)),0)
FROM	CreditCollection cc 
		INNER JOIN SnDCreditCollection scc ON scc.LocationId=cc.LocationId AND scc.CreditCollectionId=cc.CreditCollectionId
		INNER JOIN snd s ON s.LocationId = scc.LocationId AND s.SnDId = scc.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL AND cc.Shortage>0
--Shortage OB from cash reduction
UNION all
SELECT	@CompanyId,@LocationId,@SNDID,	
		SHORTAGE=ISNULL(sum(ISNULL(cr.ReductionAmount,0)),0) 
FROM	SnDCashReduction cr
		INNER JOIN snd s ON s.LocationId = cr.LocationId AND s.SnDId = cr.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL 
--		SND Refrence table missing with opening balance shortage

UNION all
		SELECT  @CompanyId,@LocationId,@SNDID,
				SHORTAGE=ISNULL(sum(ISNULL(obs.Shortageamount,0)),0) FROM obSMShortage obs
		WHERE   obs.LocationId = @LocationId AND obs.CompanyId =@CompanyId 
--Shortage OB from Adjustment
UNION all
SELECT	@CompanyId,@LocationId,@SNDID,	
		SHORTAGE=ISNULL(sum(ISNULL(sc.CollectedAmount,0)),0) * -1 
FROM	SnDShortageCollection sc
		INNER JOIN snd s ON s.LocationId = sc.LocationId AND s.SnDId = sc.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.RollbackDate IS NULL
)

-- Adjustment SLN, CN, WHT, Advance, OS Advance, IBC
-----------------------------------------------------------------------------------------------
INSERT INTO #TempSNDOpeningBalance (CompanyID,LocationID,SNDID,Customer_ADJ,OS_ADV_ADJ,SLN_ADJ,CN_ADJ,WHT_ADJ,IBC_ADJ)
(

SELECT	@CompanyId,@LocationId,@SNDID,
		ISNULL(sum(sd.CustomerAdvanceAdjusted),0) * -1,
		ISNULL(sum(sd.OutstationAdvanceAdjusted),0) *-1,
		ISNULL(sum(sd.SLNAdjusted),0),
		ISNULL(sum(sd.CustomerCNAdjusted),0),
		ISNULL(sum(sd.WHTDeducted ),0),
		ISNULL(sum(sd.InterBranchCollectionAdjusted ),0) * -1
FROM snd s 
		INNER JOIN SnDCollection sd ON sd.LocationId = s.LocationId AND sd.SnDId = s.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID    AND s.RollbackDate IS null		
GROUP BY s.CompanyId,s.LocationId,s.SnDId

--SELECT	@CompanyId,@LocationId,@SNDID,	
--		ISNULL(sum(ISNULL(csp.CustomerAdvanceAdjusted,0)),0)  * -1 
--		,ISNULL(sum(ISNULL(csp.OSAdvanceAdjusted,0)),0) * -1
--		,ISNULL(sum(ISNULL(csp.SLNAdjusted,0)),0)
--		,ISNULL(sum(ISNULL(csp.CreditNoteAdjusted,0)),0)
--		,ISNULL(sum(ISNULL(csp.WHTAdjusted,0)),0)
--		,0 --IBC
--FROM	CashSalePayment csp 
--		INNER JOIN SnDCashSalePayment sdsp ON sdsp.LocationId=csp.LocationId AND sdsp.CashSalePaymentId=csp.CashSalePaymentId
--		INNER JOIN snd s ON s.LocationId = sdsp.LocationId AND s.SnDId = sdsp.SnDId
--WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID    AND s.RollbackDate IS null
--		AND s.RollbackDate IS null
--GROUP BY s.CompanyId,s.LocationId,s.SnDId
--UNION all

--SELECT	@CompanyId,@LocationId,@SNDID,	
--		sum(ISNULL(cc.CustomerAdvanceAdjusted,0))  * -1
--		,sum(ISNULL(cc.OSAdvanceAdjusted,0))  * -1
--		,sum(ISNULL(cc.SLNAdjusted,0))
--		,sum(ISNULL(cc.CreditNoteAdjusted,0))
--		,sum(ISNULL(cc.WHTAdjusted,0))
--		,sum(ISNULL(cc.InterBranchCollectionAmount,0)) * -1
--FROM	CreditCollection cc 
--		INNER JOIN SnDCreditCollection scc ON scc.LocationId=cc.LocationId AND scc.CreditCollectionId=cc.CreditCollectionId
--		INNER JOIN snd s ON s.LocationId = scc.LocationId AND s.SnDId = scc.SnDId
--WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID  AND s.RollbackDate IS null
--GROUP BY s.CompanyId,s.LocationId,s.SnDId

UNION ALL

SELECT	@CompanyId,@LocationId,@SNDID,	
		sum(ISNULL(da.TotalAdvance,0))  * -1
		,0 --OSAdvanceAdjusted
		,sum(ISNULL(da.TotalSLN,0))
		,sum(ISNULL(da.TotalCreditNote,0))
		,0 --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM DirectAdjustment da
WHERE da.CompanyId=@CompanyId and da.LocationId=@LocationId AND da.TransactionDate <@PreviousSndToDate AND da.ApprovalDate IS NOT null

UNION ALL
SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,sum(ISNULL(ow.Amount,0))   --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM obWHT ow
WHERE ow.CompanyId=@CompanyId  AND ow.LocationId=@LocationId 


--======================================
--Credit Entry -- Customer CN Adjustment
--======================================

UNION ALL
--Credit Entry -- CN Adjustment
SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 -- SLN Adjusted
		,sum(ISNULL(cn.amount,0)) * -1
		,0 --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM CustomerCreditNote cn
WHERE cn.CompanyId=@CompanyId and cn.LocationId=@LocationId AND cn.BranchApprovalDate <@PreviousSndToDate AND cn.BranchApprovalDate IS NOT NULL

--Credit Entry -- SLN Adjustment
UNION all
SELECT	@CompanyId,@LocationId,@SNDID,	
		 0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,sum(ISNULL(s.TotalNet,0)) * -1 
		,0 --CN Adjusted
		,0 --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM SLN s
WHERE s.CompanyId=@CompanyId and s.LocationId=@LocationId AND s.ApprovalDate <@PreviousSndToDate  AND s.RollbackDate IS NULL
UNION ALL

--Credit Entry -- Customer ADV Adjustment
SELECT	@CompanyId,@LocationId,@SNDID,	
		sum(ISNULL(ca.Amount,0)) -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,0 --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM CustomerAdvance ca
INNER JOIN SnDCustomerAdvance sd ON sd.LocationId = ca.LocationId AND sd.CustomerAdvanceId = ca.CustomerAdvanceId
INNER JOIN snd s ON s.LocationId = sd.LocationId AND s.SnDId = sd.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND  s.RollbackDate IS null

UNION ALL

--Credit Entry -- OS ADV Adjustment
SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,sum(ISNULL(oa.Amount,0)) --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,0 --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM OutstationAdvance oa
INNER JOIN SnDOutstationAdvance sd ON sd.LocationId = oa.LocationId AND sd.OutstationAdvanceId = oa.OutstationAdvanceId
INNER JOIN snd s ON s.LocationId = sd.LocationId AND s.SnDId = sd.SnDId
WHERE	s.CompanyId=@CompanyId  AND s.LocationId=@LocationId AND s.SnDId < @SNDID AND s.ApprovalDate IS NOT NULL  AND s.RollbackDate IS null

UNION ALL
--Credit Entry -- WHT Adjustment

SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,sum(ISNULL(ws.adjustedAmount,0))   * -1   --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM WHTChallan w
INNER JOIN WHTChallanSaleOrder ws ON ws.LocationId = w.LocationId AND ws.WHTChallanId = w.WHTChallanId
INNER JOIN CashSalePayment csp ON csp.LocationId = ws.LocationId AND csp.CashSalePaymentId = ws.CashSalePaymentId
INNER JOIN SnDCashSalePayment scsp ON scsp.LocationId = csp.LocationId AND scsp.CashSalePaymentId = csp.CashSalePaymentId
INNER JOIN snd s ON s.LocationId = scsp.LocationId AND s.SnDId = scsp.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId<@SNDID AND ws.CashSalePaymentId IS NOT NULL  AND s.RollbackDate IS null

UNION ALL

SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,sum(ISNULL(ws.adjustedAmount,0))   * -1   --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM WHTChallan w
INNER JOIN WHTChallanSaleOrder ws ON ws.LocationId = w.LocationId AND ws.WHTChallanId = w.WHTChallanId
INNER JOIN CreditCollection cc ON cc.LocationId = ws.LocationId AND cc.CreditCollectionId = ws.CreditCollectionId
INNER JOIN SnDCreditCollection scc ON scc.LocationId = cc.LocationId AND scc.CreditCollectionId = cc.CreditCollectionId
INNER JOIN snd s ON s.LocationId = scc.LocationId AND s.SnDId = scc.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId<@SNDID AND ws.CreditCollectionId IS NOT NULL  AND s.RollbackDate IS null

UNION all
SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,sum(ISNULL(wr.AdjustedAmount,0))   * -1   --WHTAdjusted
		,0 --InterBranchCollectionAmount
FROM WHTReversal wr 
INNER JOIN SnDWHTReversal sd ON sd.LocationId = wr.LocationId AND sd.WHTReversalId = wr.WHTReversalId
INNER JOIN snd s ON s.LocationId = sd.LocationId AND s.SnDId = sd.SnDId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId<@SNDID  AND s.RollbackDate IS null




UNION all

SELECT	@CompanyId,@LocationId,@SNDID,	
		0 -- AdvanceAdjusted
		,0 --OSAdvanceAdjusted
		,0 --SLN Adjusted
		,0 --CN Adjusted
		,0 --WHTAdjusted
		,sum(ISNULL(ibc.TotalAmount,0))  --InterBranchCollectionAmount
FROM InterBranchCollection ibc
INNER JOIN SnDInterBranchCollection sibc ON sibc.LocationId = ibc.LocationId AND sibc.InterBranchCollectionId = ibc.InterBranchCollectionId
INNER JOIN snd s ON s.LocationId = sibc.LocationId AND s.SnDId = sibc.SnDId AND s.CompanyId=ibc.CompanyId
WHERE s.CompanyId=@CompanyId AND s.LocationId=@LocationId AND s.SnDId<@SNDID AND s.RollbackDate IS NULL

)

SELECT CompanyID,LocationID,SNDID
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
--INTO #SNDOpeningBalance	
FROM #TempSNDOpeningBalance
GROUP BY CompanyID,LocationID,SNDID

--DELETE FROM #TempSNDOpeningBalance

--INSERT INTO #TempSNDOpeningBalance
--SELECT * FROM #SNDOpeningBalance

--DROP TABLE #SNDOpeningBalance
--SELECT * FROM #TempSNDOpeningBalance
DROP TABLE #TempSNDOpeningBalance
