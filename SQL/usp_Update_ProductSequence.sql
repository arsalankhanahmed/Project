/*
 AUTHOR: SIDRA ASIF
 DATED : 14 January
 PURPOSE :  Update New Product Sequence 
*/

CREATE  PROC [dbo].[usp_Update_ProductSequence]
( @tvpTable utt_ProductSequence_TableType READONLY ,@UpdatedBy int, @EditStartTime DATETIME )
 AS 
BEGIN
	IF DATEDIFF(DAY, @EditStartTime, '1900-01-01') <> 0
	AND DATEDIFF(SECOND, ISNULL(( SELECT MAX(ISNULL(T.UpdateDate,@EditStartTime)) FROM Product AS T INNER JOIN @tvpTable AS TVP ON (T.ProductId=TVP.ProductId) ), @EditStartTime), @EditStartTime) < 0	
	--IF DATEDIFF(SECOND, ISNULL(( SELECT MAX(T.UpdateDate) FROM Product AS T INNER JOIN  @tvpTable AS TVP ON   (T.ProductId = TVP.ProductId )), @EditStartTime), @EditStartTime) < 0
	BEGIN 
		RAISERROR('Error On Update! The record cannot be updated because it has been modified by some other user after it was opened for editing by this user.', 16, 1)
	END
	
    
		UPDATE T
		SET    T.ProductSequence = TVP.ProductSequence,
			   T.UpdateDate = GETDATE(),
			   T.UpdatedBy = @UpdatedBy,
			   T.CommunicationId = NULL,
			   T.ToSend = 1
		FROM   Product AS T
		INNER JOIN   @tvpTable AS TVP
		  ON   (T.ProductId = TVP.ProductId )
		
		SELECT @@ROWCOUNT
    
END
