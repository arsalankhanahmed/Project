-- Applicable for SQL 2005+
USE dbsv2_6jan2015;
GO
SELECT [Scehma]=schema_name(o.schema_id), o.Name, o.type 
FROM sys.sql_modules m
INNER JOIN sys.objects o
ON o.object_id = m.object_id
WHERE m.definition like '%fn_StockTransactions_Get_ByDateRange%'
GO