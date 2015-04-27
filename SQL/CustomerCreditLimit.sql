SELECT ccl.LocationId,
		ccl.CustomerId,
		ccl.PrincipalBusinessLineId,
		pbl.[Name],
		ccl.CreditDays,
		ccl.CreditLimit
		
 FROM CustomerCreditLimit ccl 
INNER JOIN uv_PrincipalBusinessLine_all pbl ON ccl.PrincipalBusinessLineId = pbl.PrincipalBusinessLineId
WHERE ccl.LocationId = 14 AND ccl.CustomerId = 288 
