USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_DataEntryLag]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [PSO500].[v_op_DataEntryLag] as 

/*

**********READ NOTES FROM OC*******************
see email string for incident 69322 from OC
OC Example:
To check if TrlObjectStateBitmask contains flag for signed:
(TrlObjectStateBitmask & 8) <> 0


To check if TrlObjectStateBitmask contains flag for signed or complete:
(TrlObjectStateBitmask & 12) <> 0
Or you can use “|” to create compound states (in this example, we are checking for either signed or complete states):
(TrlObjectStateBitmask & (8|4)) <> 0

To check if TrlObjectStateBitmask contains flag for signed or complete:
(TrlObjectStateBitmask & 12) <> 0
Or you can use “|” to create compound states (in this example, we are checking for either signed or complete states):
(TrlObjectStateBitmask & (8|4)) <> 0

TrlObjectStateId Caption                
---------------- -----------------------
1                No Data                
2                Incomplete             
4                Complete               
8                Signed                 
16               Partial Monitored      
32               Monitored              
64               Reviewed               
128              Locked                 
256              AddNotes               
512              QueryNew               
1024             QueryResponse          
2048             QueryReview            
4096             QueryClose             
8192             QueryReopen            
32768            Comments               
65536            Hidden                 
131072           Disabled               
262144           ReadOnly               
524288           BypassValidation       
1048576          SpecialLocked          
4194304          TemporaryObject        
8388608          ImportTemporaryObject  
16777216         DDEPass1Started        
33554432         DDEPass1Complete       
67108864         DDEPass2Started        
134217728        DDEPass2Complete       
536870912        DeletedItem            
1073741824       DeActive               


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
	AND s.[Sys. SiteNo] NOT IN (999, 998, 997)
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
			ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY /*t1.[WasSigned] desc,*/ t1.[AuditDate] asc) as SignOrder
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
						---,CASE WHEN ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4)) <> 0)
						 ---THEN 1 ELSE 0 END AS [WasSigned]
						,a.[TrlObjectStateBitMask]
					FROM --		select top 100 * from
						[OMNICOMM_PSO].[inbound].[Audits] a  -- where a.trlobjectid = 961 
					WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId] =12   -- and a.trlobjectid = 961  -- all forms including sys forms ss
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4|2)) <> 0)
			) t1
	 ) t2 where SignOrder = 1
)

select st.SiteNumber
    , s.SubjectId
	, CAST(v.VisitDate AS DATE) AS VisitDate
	, v.ProCaption as [VisitType]
	, V2.[Visit_VISVIRMD] AS DataCollectionType
	, CAST(a.AuditDate AS date) AS CompletionDate
	, DATEDIFF(D, v.VisitDate, a.AuditDate) AS DifferenceInDays
	, f.[Description] AS [PageName]
	, v.VisitId
	, a.AuditId
    , a.AuditDate
	---, a.WasSigned as CompleteOrSigned
	/****SignedState will be 8 if Audit Date was Signed; CompleteState will be 4 if Audit Date was Complete]****/
	,ISNULL(a.[TrlObjectStateBitmask], 0) & (8) AS [SignedState]
	,ISNULL(a.[TrlObjectStateBitmask], 0) & (4) AS [CompleteState]
	,ISNULL(a.[TrlObjectStateBitmask], 0) & (2) AS [InCompleteState]
	, a.[TrlObjectStateBitMask]
	---, o.TrlObjectTypeId 
	---, ob.[Caption] as [TrlObjectTypeCaption]
	---, o.TrlObjectVisitId
	---, o.TrlObjectFormId
	---, f.FormI


from RowOrder a

join --		select * from
	[OMNICOMM_PSO].[inbound].[TrlObjects] o  
		on o.TrlObjectId = a.TrlObjectFormId ---where a.trlobjectid = 12  
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
LEFT JOIN [OMNICOMM_PSO].[inbound].[VISIT] V2 ON V2.[PatientId]=V.PatientId AND V2.[Visit Object Caption]=V.[Caption]
WHERE v.ProCaption IN ('Enrollment', 'Follow-up')
AND ISNULL(v.VisitDate, '')<>''
/*						

select * from [reports].[PSO_LOCAL_EverSignedAllForms] --		where TrlObjectVisitId is null and FormsProCaption <> 'PAT'
select * from [reports].[PSO_LOCAL_EverSignedAllForms] --		where TrlObjectVisitId is null and FormsProCaption <> 'PAT'

*/





GO
