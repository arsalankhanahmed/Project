SELECT ptp.PrincipalBusinessLineId,up.PBLShortName ,pt.Name AS PrincipalTeam,
 ptp2.ProductId , up.[Name] AS ProductName
 INTO #Temp
 FROM PrincipalTeam pt 
INNER JOIN PrincipalTeamPBL ptp ON pt.PrincipalTeamId = ptp.PrincipalTeamId
INNER JOIN uv_Product up ON ptp.PrincipalBusinessLineId = up.PrincipalBusinessLineId
INNER JOIN PrincipalTeamProduct ptp2 ON pt.PrincipalTeamId = ptp2.PrincipalTeamId AND up.ProductId = ptp2.ProductId 
