SELECT pt.PrincipalTeamId, pt.[Name], pt.ShortName, pt.Sequence,
ptp.ProductId, ptp.ProductSequence
  FROM PRincipalTeam pt
INNER JOIN PrincipalTeamProduct ptp ON pt.PrincipalTeamId = ptp.PrincipalTeamId 
WHERE pt.PrincipalTeamId = 34