DECLARE @JULIANDATE INT
SET @JULIANDATE= 2012146
SELECT DATEADD(DAY,@JULIANDATE%1000-1,DATEADD(YEAR,0,LEFT(@JULIANDATE,4))) AS JULIANDATE
