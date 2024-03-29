USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_IncompleteVisits]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [IBD600].[v_op_IncompleteVisits] AS

--Taken from IT Payment System View [Reimbursement].[ibd600].[v_ENFU] & [Reimbursement].[ibd600].[v_Exit]
WITH COMPLETEDENFUEX AS (				
               select  [subid],[SITENUM],[SUBNUM],[visitid],[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and visitid in (10, 20, 60)
				and REVISION = 1	
				group by [subid],[SITENUM],[SUBNUM],[visitid],[visitseq]
				)

--Taken from IT Payment System View [Reimbursement].[ibd600].[v_PG]
,COMPLETEDPG AS (			
                select  [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and [PAGENAME] like '%Pregnancy%'
				and REVISION = 1	
				group by [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
				)

--Taken from IT Payment System View [Reimbursement].[ibd600].[v_AE]
,COMPLETEDTAE AS (				select  [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
					, max(case when pagename like '%Completion%' then 'Yes' else 'No' end) as [VC_PRESENT]
					, max(case when pagename like '%Completion%' then [PAGELMDT] else null end) as [PAGELMDT]
				from [MERGE_IBD].[dbo].[DAT_APGS]
				where 1=1
				and [PAGENAME] like '%TAE%'
				and REVISION = 1
				group by [subid],[SITENUM],[SUBNUM], [VISNAME],[visitid],[visitseq]
				)

,INCOMPLETEVISITS AS (

				SELECT V.vID
				      ,CAST(V.SITENUM AS int) AS SiteID
					  ,SS.SiteStatus
					  ,SS.SFSiteStatus
					  ,CAST(V.SUBNUM AS bigint) AS SubjectID
					  ,V.VISNAME AS VisitType
					  ,V.VISITID AS VisitID
					  ,CAST(V.VISITSEQ AS int) AS VisitSequence
					  ,CAST(V.VISITDATE AS date) AS VisitDate
					  ,'Incomplete' AS CompletionStatus
					  , RMB.PAY_3_1100 as PAY_3_1100
					FROM [MERGE_IBD].[staging].[VISIT] V 
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS 
					ON SS.SiteID=V.SITENUM
					LEFT JOIN MERGE_IBD.staging.REIMB RMB ON RMB.vID=V.vID
					WHERE VISITDATE IS NOT NULL
					AND V.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDENFUEX C WHERE [VC_PRESENT] ='Yes' AND C.VisitID = V.VisitID AND C.VisitSeq = V.VisitSeq)
					AND RMB.PAY_3_1100 IS NULL
					AND ISNUMERIC(V.SUBNUM)=1

					
					UNION

					SELECT E.vID
				          ,CAST(E.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,CAST(E.SUBNUM AS bigint) AS SubjectID
						  ,E.VISNAME AS VisitType
						  ,E.VISITID AS VisitID
						  ,CAST(E.VISITSEQ AS int) AS VisitSequence
						  ,CAST(E.DISCONTINUE_DT AS date) AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , RMB.PAY_3_1100 as PAY_3_1100
					FROM [MERGE_IBD].[staging].[EXIT] E
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=E.SITENUM
					LEFT JOIN MERGE_IBD.staging.REIMB RMB ON RMB.vID=E.vID
					WHERE DISCONTINUE_DT IS NOT NULL
					AND E.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDENFUEX C WHERE [VC_PRESENT] ='Yes' AND C.VisitID = E.VisitID AND C.VisitSeq = E.VisitSeq)
					AND RMB.PAY_3_1100 IS NULL

					UNION

					SELECT P.vID
				          ,CAST(P.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,CAST(P.SUBNUM AS bigint) AS SubjectID
						  ,P.VISNAME AS VisitType
						  ,P.VISITID AS VisitID
						  ,CAST(P.VISITSEQ AS int) AS VisitSequence
						  ,NULL AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , RMB.PAY_3_1100 AS PAY_3_1100
					FROM [MERGE_IBD].[staging].[PEQ] P
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=P.SITENUM
					LEFT JOIN MERGE_IBD.staging.REIMB RMB ON RMB.vID = P.vID
					WHERE PEQ_FC_DT IS NOT NULL
					AND PEQ_RPT_TYPE_DEC NOT IN ('Not an event','Pregnancy previously reported to Corrona (duplicate)')
					AND P.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDPG C WHERE [VC_PRESENT] ='Yes' AND P.VisitID = C.VisitID  AND C.VisitSeq = P.VisitSeq)
					AND RMB.PAY_3_1100 IS NULL

					UNION

					SELECT T.vID
				          ,CAST(T.SITENUM AS int) AS SiteID
						  ,SS.SiteStatus
						  ,SS.SFSiteStatus
						  ,CAST(T.SUBNUM AS bigint) AS SubjectID
						  ,CASE
						   WHEN T.VISNAME = 'TAE' THEN T.VISNAME + ' ' + T.AE_EVENT_TYPE_DEC
						   ELSE T.VISNAME
						   END AS VisitType
						  ,T.VISITID AS VisitID
						  ,CAST(T.VISITSEQ AS int) AS VisitSequence
						  ,CAST(T.AE_EVENT_DT AS date) AS VisitDate
						  ,'Incomplete' AS CompletionStatus
						  , RMB.PAY_3_1100 as PAY_3_1100

					FROM [MERGE_IBD].[staging].[TAE] T
					LEFT JOIN MERGE_IBD.staging.REIMB RMB ON RMB.vID=T.vID
					LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=T.SITENUM
					WHERE AE_FORM_COMPLETED_DT IS NOT NULL
					AND AE_RPT_STATUS_DEC NOT IN ('Not an event','Previously reported to Corrona as a TAE (duplicate)')
					AND T.SUBNUM NOT IN (SELECT [SUBNUM] FROM COMPLETEDTAE C WHERE [VC_PRESENT] ='Yes' AND T.VisitID = C.VisitID AND C.VisitSeq = T.VisitSeq)
				)

,NoRecords AS (
					SELECT CAST(NULL AS bigint) AS vID
					      ,SP.SiteID
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


SELECT vID
      ,SiteID
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

SELECT vID
      ,SiteID
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
