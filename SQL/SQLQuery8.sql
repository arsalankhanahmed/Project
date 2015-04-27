SELECT *--max(LEN(p.[Name])) 
FROM Product p 
WHERE p.ProductId = 2406

UPDATE product SET [Name] =  [Name] + '1234567890'
WHERE ProductId = 2406  