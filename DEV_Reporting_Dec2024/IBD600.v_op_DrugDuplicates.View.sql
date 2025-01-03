USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_DrugDuplicates]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- does not return first occurance of the drug. If plaquenil is entered 5 times, only the 2dn, 3rd, 4rth, and 5th occurances are shown in this report. 

CREATE view [IBD600].[v_op_DrugDuplicates] as 


select 
	  t.[CorronaRegistryID]                              
    , t.[SourceVisitID]     
	, s.[SITENUM]  	
	, s.[SUBNUM]  	
	, t.REVNUM
	, t.SUBID
	, t.PAGEID
	, t.Page1
	, t.VISITID
	, t.VISITSEQ
	, t.PAGESEQ	   
	, t.[VOBJNAME]       
	, t.[POBJNAME]       
	, t.[PAGEDISPLAY]     
    , t.[REPORTINGT]       
    , t.[REPORTINGC]                                           
    , t.[Datamart_Variable]                                
    , t.[SourceValue]    	  
	, t.[ValTrimmed]
from ( 
select
	 vd.[CorronaRegistryID]                                     as [CorronaRegistryID]                                  
    ,l.[vID]											        as [SourceVisitID]   	
	, l.REVNUM, l.SUBID, l.PAGEID, l.VISITID, l.VISITSEQ, l.PAGESEQ	   
	,vd.[VOBJNAME]       
	,vd.[POBJNAME]       
	,vd.[PAGENAME] as [PAGEDISPLAY]   
	,vd.[Page1]                                         
    ,pd.[TableName]											as [REPORTINGT]       
    ,pd.[FieldName]											as [REPORTINGC]       
    ,pd.[BSNameTrans]											as [Datamart_Variable]                                
    ,left(l.AttributeValue, 100)                                as [SourceValue]    
	,l.[ValTrimmed]
	,RN = ROW_NUMBER() OVER (PARTITION BY  vd.[CorronaRegistryID] 
										  ,vd.[SourceRegistryID]  
										  ,vd.[SourceSystemID]    
										  ,l.[vID]			
										  ,pd.[QuestionID]	
										  ,vd.[Page1]
	 ORDER BY l.PAGESEQ)                                                           
FROM  --		select * from
		[MERGE_IBD].[staging].[Staged_Responses] l
	join --			select * from
		[EDC_ETL].[load].[DES_VDEFwIDs] vd       
			on	vd.VISITID							= l.VISITID			
			and vd.PAGEID							= l.PAGEID
			and vd.REVNUM							= l.REVNUM
			and vd.[EnforceRelationship]			= 1	
			and vd.[SourceRegistryID]				= '6'
	join --		select * from 
		[EDC_ETL].[load].[DES_PDEFwIDs] pd
			on  pd.TableName						= l.SourceTable		
			and pd.FieldName						= l.Attribute
			and vd.POBJNAME							= pd.PAGENAME	
	--		and pd.PageSeq							= l.PAGESEQ						-- only expected to loading first occurance of each drug-- will need an exception report
			and pd.SourceRegistryID					= vd.SourceRegistryID		
			and pd.CODENAME							= l.NamedPivotCodeName	 collate Latin1_General_CS_AS
where pd.[Pivoted] = 1
) t
	join --		select * from
		[MERGE_IBD].[dbo].[DAT_SUB] s
			on t.[SUBID] = s.[SUBID]
where rn > 1
--		select DRUG_NAME, DRUG_HX_ST_RSN, * from merge_ibd.staging.drug where vid = '109999994048' and drug_name = 125




GO
