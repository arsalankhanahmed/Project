--CREATE   PROCEDURE dbo.usp_UDLSalesForce_ByStatus @IsBooker bit,@IsSupplier bit,@Status varchar(100) AS  

DECLARE @IsBooker bit,@IsSupplier bit,@LocationId  varchar(100) ,@Status varchar(100)  
SET @IsBooker=1  
SET @IsSupplier=1
SET @LocationId='14'  
SET @Status=''  
  
SELECT DISTINCT uf.UDLSalesForceId, uf.Name  
FROM   UDLSalesForceCategoryTagging ufct  
INNER JOIN UDLSalesForce uf ON uf.UDLSalesForceId = ufct.UDLSalesForceId  
INNER JOIN UDLSalesForceCategory ufc ON ufc.UDLSalesForceCategoryId = ufct.UDLSalesForceCategoryId  
INNER JOIN  DBO.Split(@LocationId, ',') Loc ON  (Loc.Data = uf.LocationId OR @LocationId = '')
WHERE (((@IsBooker=1 AND ufc.IsBooker = @IsBooker )OR (@IsSupplier=1 AND  ufc.IsSupplier=@IsSupplier)) OR ufct.UDLSalesForceCategoryId IN (8,9))
AND   @Status = ''  
   OR  (  
           @Status = '0'  
      AND  DATEDIFF(day,uf.EffectiveDate,GETDATE())>= 0  
      AND  DATEDIFF(day,GETDATE(),ISNULL(uf.EndDate, GETDATE()+1))>0  
      AND  DATEDIFF(day,ufct.EffectiveDate,GETDATE())>= 0  
      AND  DATEDIFF(day,GETDATE(),ISNULL(ufct.EndDate,GETDATE()+1))>0  
       )  
   OR  (  
           @Status = '1'  
      AND  DATEDIFF(day,uf.EndDate,ISNULL(GETDATE(), GETDATE()+1))>0          
  AND  DATEDIFF(day,GETDATE(),ISNULL(ufct.EndDate,GETDATE()+1))>0  
   )  
     
ORDER BY uf.Name
