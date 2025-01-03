USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_IncompleteVisits_old]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [IBD600].[v_op_IncompleteVisits_old] AS

WITH 
COMPLETEDENFUEX AS --Taken from IT Payment System View [Reimbursement].[ibd600].[v_ENFU] & [Reimbursement].[ibd600].[v_EX] WHICH NO LONGER EXISTS
(				select  [subid],
						[SITENUM],
						[SUBNUM],
						[visitid],
						[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and visitid in (10, 20, 60)
				and REVISION = 1	
				group by [subid],[SITENUM],[SUBNUM],[visitid],[visitseq]
)

,COMPLETEDPG AS ( --Taken from IT Payment System View [Reimbursement].[ibd600].[v_PG] WHICH NO LONGER EXISTS
			select  [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and [PAGENAME] like '%Pregnancy%'
				and REVISION = 1	
				group by [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
)

,COMPLETEDTAE AS ( --Taken from IT Payment System View [Reimbursement].[ibd600].[v_AE] WHICH NO LONGER EXISTS
				select  [subid],
						[SITENUM],
						[SUBNUM], 
						[VISNAME],
						[visitid],
						[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and [PAGENAME] like '%TAE%'
				and REVISION = 1
				group by [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
)

,INCOMPLETEVISITS AS (
				SELECT CAST(V.SITENUM AS int) AS SiteID
					  ,SS.SiteStatus
					  ,SS.SFSiteStatus
					  ,V.SUBNUM AS SubjectID
					  ,V.VISNAME AS VisitType
					  ,V.VISITID AS VisitID
					  ,CAST(V.VISITSEQ AS int) AS VisitSequence
					  ,CAST(V.VISITDATE AS date) AS VisitDate
					  ,'Incomplete' AS CompletionStatus
					  , RMB.PAY_3_1100 as PAY_3_1100
					FROM [MERGE_IBD].[staging].[VISIT] V
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS 
					ON SS.SiteID=V.SITENUM
					left Join MERGE_IBD.staging.REIMB RMB
					on RMB.SUBNUM = V.SUBNUM and RMB.vID = V.vID
					WHERE VISITDATE IS NOT NULL
					AND V.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDENFUEX C WHERE [VC_PRESENT] ='Yes' AND C.VisitID = V.VisitID AND C.VisitSeq = V.VisitSeq)
					and RMB.PAY_3_1100 is NULL
					
					UNION

					SELECT CAST(E.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,E.SUBNUM AS SubjectID
						  ,E.VISNAME AS VisitType
						  ,E.VISITID AS VisitID
						  ,CAST(E.VISITSEQ AS int) AS VisitSequence
						  ,CAST(E.DISCONTINUE_DT AS date) AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , RMB.PAY_3_1100 as PAY_3_1100
					FROM [MERGE_IBD].[staging].[EXIT] E
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=E.SITENUM
					left Join MERGE_IBD.staging.REIMB RMB
					on RMB.SUBNUM = E.SUBNUM and RMB.vID = E.vID
					WHERE DISCONTINUE_DT IS NOT NULL
					AND E.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDENFUEX C WHERE [VC_PRESENT] ='Yes' AND C.VisitID = E.VisitID AND C.VisitSeq = E.VisitSeq)
					and RMB.PAY_3_1100 is NULL

					UNION

					SELECT CAST(P.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,P.SUBNUM AS SubjectID
						  ,P.VISNAME AS VisitType
						  ,P.VISITID AS VisitID
						  ,CAST(P.VISITSEQ AS int) AS VisitSequence
						  ,NULL AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , RMB.PAY_3_1100 as PAY_3_1100
					FROM [MERGE_IBD].[staging].[PEQ] P
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=P.SITENUM
					left Join MERGE_IBD.staging.REIMB RMB
					on RMB.SUBNUM = P.SUBNUM and RMB.vID = P.vID
					WHERE PEQ_FC_DT IS NOT NULL
					AND PEQ_RPT_TYPE_DEC NOT IN ('Not an event','Pregnancy previously reported to Corrona (duplicate)', 'Pregnancy previously reported (duplicate)')
					AND P.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDPG C WHERE [VC_PRESENT] ='Yes' AND P.VisitID = C.VisitID  AND C.VisitSeq = P.VisitSeq)
					and RMB.PAY_3_1100 is NULL

					UNION

					SELECT CAST(T.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,T.SUBNUM AS SubjectID
						  ,CASE
						   WHEN T.VISNAME = 'TAE' THEN T.VISNAME + ' ' + T.AE_EVENT_TYPE_DEC
						   ELSE T.VISNAME
						   END AS VisitType
						  ,T.VISITID AS VisitID
						  ,CAST(T.VISITSEQ AS int) AS VisitSequence
						  ,CAST(T.AE_EVENT_DT AS date) AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , null as PAY_3_1100
					FROM [MERGE_IBD].[staging].[TAE] T
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=T.SITENUM
					WHERE AE_FORM_COMPLETED_DT IS NOT NULL
					AND AE_RPT_STATUS_DEC NOT IN ('Not an event','Previously reported to Corrona as a TAE (duplicate)', 'Previously reported (duplicate)')
					AND T.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDTAE C WHERE [VC_PRESENT] ='Yes' AND T.VisitID = C.VisitID AND C.VisitSeq = T.VisitSeq)
)

,NoRecords AS (
					SELECT SP.SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,NULL AS SubjectID
						  ,NULL AS VisitType
						  ,NULL AS VisitID
						  ,NULL AS VisitSequence
						  ,CAST(NULL AS date) AS VisitDate
						  ,'All records completed' AS [CompletionStatus]
						  , null as PAY_3_1100 

					FROM [IBD600].[v_SiteParameter] SP
					LEFT JOIN [IBD600].[v_SiteStatus] SS ON SS.SiteID=SP.SiteID
					WHERE SP.SiteID NOT IN (SELECT DISTINCT SiteID FROM INCOMPLETEVISITS)
)


SELECT SiteID
      ,SiteStatus
	  ,SFSiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitID
	  ,VisitSequence
	  ,CAST(VisitDate AS DATE) AS VisitDate
	  ,CompletionStatus
	  ,PAY_3_1100

FROM INCOMPLETEVISITS

UNION

SELECT SiteID
      ,SiteStatus
	  ,SFSiteStatus
	  ,SubjectID
	  ,VisitType
	  ,VisitID
	  ,VisitSequence
	  ,CAST(VisitDate AS DATE) AS VisitDate
	  ,CompletionStatus
	  ,PAY_3_1100
FROM NoRecords



GO
