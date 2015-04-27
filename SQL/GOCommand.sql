DECLARE @MyMsg VARCHAR(50)
SELECT @MyMsg = 'Hello, World.'
--GO 
-- @MyMsg is not valid after this GO ends the batch.
-- Yields an error because @MyMsg not declared in this batch.
PRINT @MyMsg
GO
