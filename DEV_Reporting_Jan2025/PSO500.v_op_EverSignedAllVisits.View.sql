USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_EverSignedAllVisits]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSO500].[v_op_EverSignedAllVisits] as 
/*
*/

select sf.[TrlObjectVisitID]
	  ,sf.[VisitId]
      ,sf.[VisitsProCaption]	as [VisitType]
      ,sf.[SubjectId]			as [Subject_Id]
      ,sf.[SiteNumber]			as SiteNo
      ,min(sf.[WasSigned]) [EverAllSigned]
from --		select * from
	[Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms] sf
inner join --		select * from
	[Reimbursement].[Reference].[t_SourceStringConv] sc
		on sf.FormsDescription = sc.[SourceString]
-- select * from [Reimbursement].[Reference].[t_SourceStringConv] where [ConversionType] like '%SignStatus'
where sc.SourceRegistryID = 'PSORIASIS' and sf.[VisitsProCaption]+'SignStatus' = sc.[ConversionType] and sc.[CorronaString] = '1'
group by 
	sf.[TrlObjectVisitID]
	,sf.[VisitId]
    ,sf.[VisitsProCaption]
    ,sf.[SubjectId]		
    ,sf.[SiteNumber]		-- 5162 -- 20160829

/* -- original script until 20160330
select sf.[TrlObjectVisitID]
      ,sf.[VisitType]
      ,sf.[Subject_Id]
      ,sf.[SiteNo]
      ,min(sf.[WasSigned]) [EverAllSigned]
from --		select * from
	[Reimbursement].[reports].[PSO_LOCAL_EverSignedAllForms] sf
inner join --		select * from
	[Reimbursement].[Reference].[t_SourceStringConv] sc
		on sf.[iCRF] = sc.[SourceString]
-- select * from [Reimbursement].[Reference].[t_SourceStringConv] where [ConversionType] like '%SignStatus'
where sc.SourceRegistryID = 'PSORIASIS' and sf.[VisitType]+'SignStatus' = sc.[ConversionType] and sc.[CorronaString] = '1'
group by sf.[TrlObjectVisitID]
      ,sf.[VisitType]
      ,sf.[Subject_Id]
      ,sf.[SiteNo]
	*/


GO
