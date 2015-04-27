insert into Resource (FormFileName,Name,Code,ParentId,Type,Depth,SortOrderNo,ShowInMenu,ShortcutKey,SeperatorInMenu,
IsStockReleatedScreen,IsCustomerReleatedScreen,IsConsignment,IsCommercial,IsUsageLoggingRequired,ModuleId,Parameter,
AllowDuringDayCycleOnly,OnLoadBehaviorId,OnSaveBehaviorId,AllowProductOnes,InsertDate,InsertedBy,UpdateDate,UpdatedBy,
ToSend,
CommunicationId
)
VALUES(
'frmNearExpirySalesIntimation','Near Expiry Sales Intimation','R215-',542,'REPORTS',3,13,1,NULL,0,
0,0,1,1,0,6,NULL,0,2,2,0,getDate(),1,null,NULL,1,NULL)
