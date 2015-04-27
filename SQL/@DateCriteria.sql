


DECLARE @DateCriteria  INT, @Status INT
SET @DateCriteria = 2
SET @Status = 2

SELECT 
Case when @DateCriteria = 0 THEN 'All'
	WHEN (@DateCriteria = 1 AND @Status = 2) THEN 'Specific With ca.InsertDate'
	WHEN (@DateCriteria = 1 AND @Status = 1) then 'Specific With ca.EffectiveDate' 
	WHEN (@DateCriteria = 1 AND @Status = 0) THEN 'Specific With ca.EndDate' 
	
	WHEN (@DateCriteria = 2 AND @Status = 2) THEN 'Range With ca.InsertDate'
	WHEN (@DateCriteria = 2 AND @Status = 1) then 'Range With ca.EffectiveDate' 
	WHEN (@DateCriteria = 2 AND @Status = 0) THEN 'Range With ca.EndDate' 
			END AS [DateCriteria] 