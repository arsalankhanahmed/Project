
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Insert_BankAccountSequence')AND type in (N'P', N'PC'))
DROP PROCEDURE usp_Insert_BankAccountSequence
GO

 CREATE PROCEDURE usp_Insert_BankAccountSequence
@out_error_number INT = 0 OUTPUT,
@LocationId int,
@BankAccountId int,
@SequenceId int,
@IsDefault bit,
@InsertDate datetime,
@UserId int
AS

SET @SequenceId  = (SELECT MAX(SequenceId)+ 1 FROM BankAccountSequence WHERE LocationId = @LocationId )
BEGIN
BEGIN TRY
	Insert into BankAccountSequence (LocationId,BankAccountId,SequenceId,IsDefault,InsertDate,InsertedBy)
	values(@LocationId,@BankAccountId,@SequenceId,@IsDefault,@InsertDate,@UserId)
END TRY
BEGIN CATCH
	SELECT @out_error_number=ERROR_NUMBER()
END CATCH
END
GO
