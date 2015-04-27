DECLARE @PrimaryKey1 VARCHAR(50),@PrimaryKey2 VARCHAR(50),@TableName VARCHAR(50)
SET @TableName = 'Customer'


SELECT @PrimaryKey1 =  COL_NAME(ic.OBJECT_ID,ic.column_id) 
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic ON i.OBJECT_ID = ic.OBJECT_ID AND i.index_id = ic.index_id
WHERE  i.is_primary_key = 1 AND OBJECT_NAME(ic.OBJECT_ID) =@TableName
AND ic.index_column_id = 1 

SELECT @PrimaryKey2 =  COL_NAME(ic.OBJECT_ID,ic.column_id) 
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic ON i.OBJECT_ID = ic.OBJECT_ID AND i.index_id = ic.index_id
WHERE  i.is_primary_key = 1 AND OBJECT_NAME(ic.OBJECT_ID) =@TableName
AND ic.index_column_id = 2 

PRINT 'PrimaryKey1 = '+@PrimaryKey1
PRINT 'PrimaryKey2 = '+@PrimaryKey2




