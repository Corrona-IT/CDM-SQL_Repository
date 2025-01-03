USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_EverSignedAllForms]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [PSO500].[v_op_EverSignedAllForms] as 

/*
select * from [reports].[v_EverSignedForms]
select * from [reports].[v_EverSignedVisits]
**********READ NOTES FROM OC*******************
see email string for incident 69322 from OC
OC Example:
To check if TrlObjectStateBitmask contains flag for signed:
(TrlObjectStateBitmask & 8) <> 0


To check if TrlObjectStateBitmask contains flag for signed or complete:
(TrlObjectStateBitmask & 12) <> 0
Or you can use “|” to create compound states (in this example, we are checking for either signed or complete states):
(TrlObjectStateBitmask & (8|4)) <> 0

*/

with Subjects as (
	select s.PatientId, s.[Sys. PatientNo] as [SubjectId], o.TrlObjectPatientId
	--into #Subjects
	from --		select * from
		[OMNICOMM_PSO].[inbound].[G_Subject Information] s
	join --		select * from
		[OMNICOMM_PSO].[inbound].[TrlObjects] o  
			on o.TrlObjectId = s.TrlObjectId
	where TrlObjectTypeId = 17
)

, Sites as (
	select s.SiteId, s.[Sys. SiteNo] as [SiteNumber], o.TrlObjectSiteId
	--into #Sites
	from --		select * from
		[OMNICOMM_PSO].[inbound].[G_Site Information] s
	join --		select * from
		[OMNICOMM_PSO].[inbound].[TrlObjects] o  
			on o.TrlObjectId = s.TrlObjectId
	where TrlObjectTypeId = 16
)

/*
select * from [OMNICOMM_PSO].[inbound].[TrlObjects] o  where trlobjectid  = 18 -- [Site Number] = 999
select * from [CVG-PD-CORSQL04.CORRONA.LOCAL].[TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[TrlObjects] where trlobjectid  = 18 -- trlobjectTypeid  = 16 and TrlObjectSiteId = 16
select * from [CVG-PD-CORSQL04.CORRONA.LOCAL].[TMCORRONA_PSORIASIS_PRODUCTION].[dbo].[TrlObjectTypes] where trlobjectTypeid  = 16 -- Caption = 'SiteFormGroup'
select * from	[OMNICOMM_PSO].[inbound].[G_Site Information] st
*/


, RowOrder as (
	select * from (
		select 
			*,
			ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[WasSigned] desc, t1.[AuditDate] asc) as SignOrder
			from (
					SELECT
						 a.AuditId
						,a.[StateChangeDateTime]		as [AuditDate]
						--,ft.[Description]				as [iCRF]
						--,ft.[ProCaption]				as [FormProCaption]
						,a.[TrlObjectFormId]
						,a.[TrlObjectTypeId]
						--,s.*
						--,ob.[Caption]					as [FormType]
						--,vv.[VisitId]
						--,o.TrlObjectVisitID
						--,vv.[Visit Object Description]	as [VisitType]
						--,vv.[Visit_subject_id_TAE]		as [Subject_Id]
						--,vv.[Visit_SITENO]				as [SiteNo]
						,CASE WHEN ((ISNULL(a.[TrlObjectStateBitMask],0) & 8) <> 0) THEN 1 ELSE 0 END AS [WasSigned]
					FROM --		select top 100 * from
						[OMNICOMM_PSO].[inbound].[Audits] a  -- where a.trlobjectid = 961 
					where a.[TrlObjectFormId] is not null
					--WHERE a.[TrlObjectTypeId] IN (8,9,10,11,12)   -- and a.trlobjectid = 961  -- all forms including sys forms ss
			) t1
	 ) t2 where SignOrder = 1
)

select a.AuditId, a.AuditDate, a.WasSigned
	, o.TrlObjectTypeId, ob.[Caption] as [TrlObjectTypeCaption]
	, s.*
	, st.*
	, o.TrlObjectVisitId, v.VisitId, v.ProCaption as [VisitsProCaption], v.[Description] as [VisitsDescription]
	, o.TrlObjectFormId, f.FormId, f.ProCaption as [FormsProCaption], f.[Description] as [FormsDescription]
from RowOrder a
join --		select * from
	[OMNICOMM_PSO].[inbound].[TrlObjects] o  
		on o.TrlObjectId = a.TrlObjectFormId --  where a.trlobjectid = 961  
join 	--		select * from
	Subjects s
		on s.TrlObjectPatientId = o.TrlObjectPatientId
join --		select * from 
	Sites st
		on st.TrlObjectSiteId = o.TrlObjectSiteId
join --		select * from 
	[OMNICOMM_PSO].[inbound].[TrlObjectTypes] ob
		on ob.[TrlObjectTypeId] = a.[TrlObjectTypeId]  -- where a.trlobjectid = 961    
left join 	--		select * from
	[OMNICOMM_PSO].[inbound].[Forms] f		--		where trlobjectid = 961
		on f.TrlObjectID = o.TrlObjectFormID  --	where a.trlobjectid = 961 
left join 	--		select * from
	[OMNICOMM_PSO].[inbound].[visits] v --  where a.trlobjectid = 961  
		on v.TrlObjectID = o.TrlObjectVisitID  --	where a.trlobjectid = 961 
/*						

select * from [reports].[PSO_LOCAL_EverSignedAllForms] --		where TrlObjectVisitId is null and FormsProCaption <> 'PAT'
select * from [reports].[PSO_LOCAL_EverSignedAllForms] --		where TrlObjectVisitId is null and FormsProCaption <> 'PAT'

*/





GO
