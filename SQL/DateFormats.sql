select left(right(convert(varchar(20),getdate(),06),6),3)+'-'+right(convert(varchar(20),getdate(),06),2), DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0),convert(varchar(20),getdate(),06)