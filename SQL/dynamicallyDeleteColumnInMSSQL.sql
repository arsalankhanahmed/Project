GO
/****** Object:  StoredProcedure [dbo].[mysp_DropEmptyColumns]    Script Date: 09/05/2013 10:47:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[mysp_DropEmptyColumns]
 DECLARE @tableName nvarchar(max) = 'tmptable'
--as 
begin
  declare @FieldName nvarchar(max)
  declare @SQL nvarchar(max)
  declare @CountDef nvarchar(max)
  declare @FieldCount int

  declare fieldNames cursor  local fast_forward for
    select c.name
      from syscolumns c
        inner join sysobjects o on c.id=o.id
      where o.xtype='U'
        and o.Name=@tableName

  open fieldNames
  fetch next from fieldNames into @FieldName
  while (@@fetch_status=0)
  begin
    set @SQL=N'select @Count=count(*) from "'+@TableName+'" where "'+@FieldName+'" is not null'
    SET @CountDef = N'@Count int output';
    exec sp_executeSQL @SQL, @CountDef, @Count = @FieldCount output
    if (@FieldCount=0)
    begin
      set @SQL = 'alter table '+@TableName+' drop column '+@FieldName
      exec sp_executeSQL @SQL
      print @SQL
    end
    fetch next from fieldNames into @FieldName
  end

  close fieldNames
END