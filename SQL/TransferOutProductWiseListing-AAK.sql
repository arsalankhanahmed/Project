DECLARE @PBLIds varchar(1000), @LocationIds varchar(1000), @RecLocationIds varchar(1000),
		@SelectAll int,@FromDate datetime,@ToDate datetime, 
		@TRSelectAll int,@TRFromDate datetime,@TRToDate datetime,
		@SelectAllDoc int,@DocRange  varchar(50),@FromDoc int,@ToDoc int, 
		@TOStatus  varchar(5),
		@Status  varchar(5),
		@IsCombineCorrection bit 

SET @PBLIds = '4'
SET @LocationIds = '11,14,29,17,19,21,28,23,12,38,26,42,15,35,18,37,43,30,36,22,24,44,13,32,27,16'
SET @RecLocationIds = '11,14,29,17,19,21,28,23,12,38,26,42,15,35,18,37,43,30,36,22,24,44,13,32,27,16'
SET @SelectAll=0
SET @FromDate = '2013-11-01 '
SET @ToDate = '2013-11-30 '
SET @TRSelectAll=0
SET @TRFromDate = '2013-11-01'
SET @TRToDate = '2013-12-31'
SET @SelectAllDoc=2
SET @DocRange='162'
SET @FromDoc = '162'
SET @ToDoc = '247' 
SET @TOStatus = 'AP'
SET @Status = ''
SET @IsCombineCorrection = 1

SELECT * FROM TransferOut to1
INNER JOIN   (
           SELECT to1.LocationId,
                  to1.TransferOutId,
                  to1.ReferenceTransferOutId
           FROM   TransferOut to1
           INNER JOIN   DBO.Split(@LocationIds, ',' ) LOC
             ON   (
                      LOC.Data = to1.LocationId OR @LocationIds = ''
                  )
           INNER JOIN   DBO.Split(@RecLocationIds, ',' ) RecLOC
             ON   (
                      RecLOC.Data = to1.ToLocationId OR @RecLocationIds = ''
                  )
           INNER JOIN   DBO.Split(@PBLIds, ',' ) PBL
             ON   (
                      PBL.Data = to1.PrincipalBusinessLineId 
                      OR @PBLIds = ''
                  )
           WHERE 
               (
                      @TOStatus = '' 
					OR (@TOStatus='AP' AND to1.IsRollbacked=0)
					OR (@TOStatus='P' AND to1.IsApproved=0 AND to1.IsRollbacked=0)
					OR (@TOStatus='A' AND to1.IsApproved=1 AND to1.IsRollbacked=0)
					OR (@TOStatus='R' AND to1.IsApproved=0 AND to1.IsRollbacked=1)
                )
            AND (
                      @Status = ''
                  OR  (
                          @Status = 'R'
                     AND  To1.TransferOutId IS NOT 
                     NULL
                      )
                  OR  (
                          @Status = 'I'
                     AND  To1.TransferOutId IS  NULL
                      )
                  OR  (
                          @Status = 'P'
                     AND  to1.TREntryDate IS NULL
                      )
               ) 
           	AND (
					   @SelectAll = 0
				   OR  (
						   @SelectAll = 1 AND  ( DATEDIFF(DAY, to1.TransactionDate,  @FromDate) = 0 /* only FOR one day*/)
					   )
				   OR  (
						   @SelectAll = 2 AND   
							(
								DATEDIFF(DAY, to1.TransactionDate,  @FromDate) <= 0
								AND 
								(
									(@IsCombineCorrection = 1 AND to1.ReferenceTransferOutId IS NOT NULL) 
									OR   datediff (day,to1.TransactionDate, @ToDate) >= 0
								)
							)  				
					   )   
				)    
			AND (
					   @TRSelectAll = 0
				   OR  (
						   @TRSelectAll = 1
					  AND  ( DATEDIFF(DAY,to1.TREntryDate,  @TRFromDate) = 0 /* only FOR one day*/)
					   )
				   OR  (
						   @TRSelectAll = 2
						   AND  (DATEDIFF(DAY,to1.TREntryDate,  @TRFromDate) <= 0AND  DATEDIFF(DAY,to1.TREntryDate,  @TRToDate) >= 0)										
					   )   
				)      			
			AND (
					   @SelectAllDoc = 0 
				   OR (
						@SelectAllDoc = 1 AND  to1.TransferOutId IN (SELECT S.DATA FROM   DBO.Split(@DocRange, ',') S)
					  )
					OR(
					  @SelectAllDoc = 2 AND ( (@FromDoc = '0'OR to1.TransferOutId>= @FromDoc) AND  (@ToDoc = '0' OR to1.TransferOutId <= @ToDoc))
					  )
				)            
       ) AS RefTI
  ON   (
           (
               to1.TransferOutId = RefTI.TransferOutId OR( @IsCombineCorrection = 1 
               AND   to1.ReferenceTransferOutId = RefTI.TransferOutId )
           )AND   to1.LocationId = RefTI.LocationId
  )
WHERE (ISNULL(RefTI.ReferencetransferOutId, 0) = CASE WHEN (@IsCombineCorrection  = 1) THEN  0 ELSE 1 END) 
   OR  
   (ISNULL(RefTI.ReferencetransferOutId, 1) > CASE WHEN (@IsCombineCorrection  = 0) THEN  0 ELSE (refti.transferoutid) END)
  -- AND RefTI.ReferenceTransferOutId IS  NULLIF(@IsCombineCorrection = 1)
  --AND ASE WHEN (@IsCombineCorrection  = 1) THEN refti.referencetransferoutid IS null ELSE refti.referencetransferoutid END 