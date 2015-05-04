CREATE TABLE #products(prod_id INT, prod_name VARCHAR(100))
INSERT INTO #products(prod_id,prod_name)
SELECT 10001,'Samsung' UNION ALL
SELECT 10002,'Sony' UNION ALL
SELECT 10003,'Micromax' UNION ALL
SELECT 10004,'Lava' UNION ALL
SELECT 10005,'LG'

DECLARE @prod_id VARCHAR(100),@prod_Name VARCHAR(15)
SELECT @prod_id = prod_id,@prod_Name = prod_name  FROM #products 
SELECT @prod_id AS prod_id,@prod_Name AS prod_name

DROP TABLE #products
