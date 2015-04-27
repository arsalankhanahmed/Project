/************************************************************
SQL Cursor Example
 ************************************************************/

DECLARE @SaleOrderID     INT
DECLARE @getSaleOrderID  CURSOR 

SET @getSaleOrderID = CURSOR FOR
							SELECT SaleOrderID
							FROM   SaleOrder
							WHERE  LocationId = 11
								   AND TransactionDate = dbo.GetDateWithoutTime() -120

OPEN @getSaleOrderID
	FETCH NEXT
	FROM @getSaleOrderID INTO @SaleOrderID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @SaleOrderID
			FETCH NEXT
			FROM @getSaleOrderID INTO @SaleOrderID
		END
CLOSE @getSaleOrderID
DEALLOCATE @getSaleOrderID
