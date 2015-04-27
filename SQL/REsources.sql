BEGIN TRAN

	INSERT INTO Resource(FormFileName, [Name], ParentId, [Type], Depth,
			SortOrderNo, ShowInMenu, IsCommercial, IsConsignment, ModuleId,
			Parameter, OnLoadBehaviorId, OnSaveBehaviorId, AllowProductOnes,
			AllowDuringDayCycleOnly, InsertedBy)
	VALUES	
	            
/*Change BCG Dispatch Location*/
	--('frmBCGDispatchCorrection','BCG &Dispatch Correction',607,'SCR',2,3,1,1,1,7,NULL,0,1,1,0,1),
/*Add Utility Menu in SND*/
	--( NULL,'&Utility',0,'SCR',1,1,1,1,1,9,NULL,2,2,0,0,1),
/*HO Bank Account Correction in Remittance*/
--('frmBankAccountCorrection','HO Bank Account Correction in &Deposit Slip',
	--(SELECT resourceId FROM Resource WHERE ModuleId = 9 and NAME LIKE '&Utility'),'SCR',1,1,1,1,1,9,'DS',1,1,0,0,1),
/*HO Bank Account Correction in Deposit Slip*/
('frmBankAccountCorrection','HO Bank Account Correction in &Remittance',
	(SELECT resourceId FROM Resource WHERE ModuleId = 9 and NAME LIKE '&Utility'),'SCR',1,2,1,1,1,9,'TT',1,1,0,0,1)

INSERT INTO ResourcePrivilege
(ResourceId, PrivilegeId, EffectiveDate, InsertedBy)
VALUES((SELECT ResourceId FROM Resource WHERE NAME  = 'BCG &Dispatch Correction'),2,GETDATE(),1),
((SELECT ResourceId FROM Resource WHERE NAME = 'HO Bank Account Correction in &Deposit Slip'), 2, GETDATE(), 1 ),
((SELECT ResourceId FROM Resource WHERE NAME = 'HO Bank Account Correction in &Remittance'), 2, GETDATE(), 1 )

--COMMIT TRAN 
         
