USE [Reporting]
GO
/****** Object:  View [IBD600].[v_pv_117_TAEQCListing_OLD]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [IBD600].[v_pv_117_TAEQCListing_OLD]  as

WITH VDEF AS
(
	SELECT REVNUM
	      ,VISITID
		  ,VISNAME
		  ,VABBREV
		  ,VOBJNAME
		  ,VORDER
		  ,PAGEID
		  ,PAGENAME
		  ,POBJNAME
		  ,PORDER 

	FROM [MERGE_IBD].[dbo].[DES_VDEF]
	WHERE PAGENAME like '%TAE%' OR PAGENAME LIKE '%Pregn%'
)


,D AS
(
	SELECT 
		vID
		,SITENUM
		,VISNAME
		,VOBJNAME
		,POBJNAME
		,PAGENAME
		,REVNUM
		,SUBID
		,SUBNUM
		,VISITID
		,VISITSEQ
		,PAGEID
		,STATUSID
		,EDCFormID
		,PAGELMDT
		,DATALMBY
		,ROW_NUMBER () OVER(PARTITION BY [vID], [PAGENAME]
							    ORDER BY [PAGELMDT] DESC) ROWNUM
											
	FROM 
     (
       SELECT DP.vID
	         ,DP.SITENUM
			 ,DP.VISNAME
			 ,DP.VOBJNAME
			 ,DP.POBJNAME
			 ,DP.PAGENAME AS PAGENAME
			 ,DP.REVNUM
			 ,DP.SUBID
			 ,DP.SUBNUM
			 ,DP.VISITID
			 ,DP.VISITSEQ
			 ,DP.STATUSID
			 ,DP.PAGEID AS PAGEID
			 ,DP.EDCFormID
			 ,DP.PAGELMDT
			 ,DP.DATALMBY
       FROM [MERGE_IBD].[staging].[DAT_PAGS] DP
       INNER JOIN VDEF ON DP.PAGENAME = VDEF.PAGENAME AND DP.REVNUM = VDEF.REVNUM
	   ---WHERE DP.STATUSID>0
      ) T

)


,LastModified AS
(
  SELECT ROW_NUMBER () OVER(PARTITION BY [vID], [SITENUM], [SUBNUM], [VISNAME]
							    ORDER BY [PAGELMDT] DESC) LMROWNUM
		,D.vID
        ,D.SITENUM
		,D.SUBNUM
		,D.VISNAME
		,D.PAGENAME
		,D.VISITID
		,D.VISITSEQ
		,D.PAGEID
		,D.STATUSID
		,D.DATALMBY
		,MAX(D.PAGELMDT) AS PAGELMDT
FROM D
WHERE ROWNUM=1
GROUP BY vID, SITENUM, SUBNUM, VISNAME, VISITID, VISITSEQ, PAGEID, PAGENAME, STATUSID, DATALMBY, PAGELMDT

)

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'CVD' AS EventType
	  ,TAE.AE_CVD_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL AS IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_CVD_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'HEP' AS EventType
	  ,TAE.AE_HEP_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_HEP_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'GI' AS EventType
	  ,TAE.AE_GI_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_GI_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'NEU' AS EventType
	  ,TAE.AE_NEURO_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN MERGE_IBD.staging.VISIT_COMP TAECOMPL ON TAECOMPL.VID=TAE.VID
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_NEURO_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'CAN' AS EventType
	  ,TAE.AE_CM_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN MERGE_IBD.staging.VISIT_COMP TAECOMPL ON TAECOMPL.VID=TAE.VID
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_CM_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'AI' AS EventType
	  ,TAE.AE_AUTO_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_AUTO_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'DRG_RXN' AS EventType
	  ,TAE.AE_HYPS_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedByy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_HYPS_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'INF' AS EventType
	  ,TAE.AE_INF_TYPE_DEC AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,CASE WHEN INF.MTZ_ROUTE_DEC='IV'
			  OR INF.VAN_ROUTE_DEC='IV'
			  OR INF.FDX_ROUTE_DEC='IV'
			  OR INF.OTH_ROUTE_DEC='IV'
			  OR INF.LM_AE_INTRA_DEC = 'Yes' 
	        THEN 'Yes'
	        ELSE 'No'
	   END AS IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN MERGE_IBD.staging.TAE_INF INF ON TAE.VID=INF.VID AND TAE.VISITSEQ=INF.VISITSEQ
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_INF_TYPE_DEC IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'GEN' AS EventType
	  ,TAE.AE_GEN_EVENT_TXT AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus

	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_GEN_EVENT_TXT IS NOT NULL
AND LM.LMROWNUM=1

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]

	  ,CASE WHEN TAE.VISNAME='TAE' then 'TAE'
	   WHEN TAE.VISNAME LIKE '%Infect%' THEN 'INF'
	   WHEN TAE.VISNAME LIKE '%Neuro%' THEN 'NEU'
	   WHEN TAE.VISNAME LIKE '%Cardio%' THEN 'CVD'
	   WHEN TAE.VISNAME LIKE '%Gener%' THEN 'GEN'
	   WHEN TAE.VISNAME LIKE '%GI Per%' THEN 'GI'
	   WHEN TAE.VISNAME LIKE '%Anaph%' THEN 'DRG_RXN'
	   WHEN TAE.VISNAME LIKE '%Autoimm%' THEN 'AI'
	   WHEN TAE.VISNAME LIKE '%Cancer%' THEN 'CAN'
	   WHEN TAE.VISNAME LIKE '%Hepat%' THEN 'HEP'
	   ELSE ''
	   END AS EventType

	  ,NULL AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,NULL AS IVAntibiotics_TAEInf
	  ,TAE.AE_RPT_STATUS_DEC AS EventReportStatus
	  ,TAE.AE_RPT_NOEVENT_TXT AS NoEventExplain
	  ,TAE.AE_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.AE_SOURCE_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.AE_DOCUMENTS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,TAE.AE_RSN_REFUSED_DEC AS ReasonSourceNotProvided
	  ,TAE.AE_RSN_HOSP_NOT_FAX_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy

FROM MERGE_IBD.staging.TAE TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
WHERE TAE.AE_CVD_TYPE_DEC IS  NULL
AND TAE.AE_HEP_TYPE_DEC IS NULL
AND TAE.AE_GI_TYPE_DEC IS NULL
AND TAE.AE_NEURO_TYPE_DEC IS NULL
AND TAE.AE_CM_TYPE_DEC IS NULL
AND TAE.AE_AUTO_TYPE_DEC IS NULL
AND TAE.AE_HYPS_TYPE_DEC IS NULL
AND TAE.AE_INF_TYPE_DEC IS NULL
AND TAE.AE_GEN_EVENT_TXT IS NULL
AND LM.LMROWNUM=1

/*************PREGNANCY*******************/

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [Site ID]
	  ,CAST(TAE.SUBNUM AS bigint) AS [Subject ID]
	  ,TAE.MD_COD AS [Provider ID]
	  ,CASE WHEN TAE.VISNAME='Pregnancy Event' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE '%Pregnancy Event-Patient Reported%' THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [Visit Sequence]
	  ,'PG' AS EventType
	  ,'Pregnancy' AS EventTerm
	  ,NULL AS EventSpecify
	  ,NULL AS OnsetDate
	  ,TAE.PEQ_RPT_DT AS DateReported
	  ,NULL AS EventOutcome
	  ,TAE.PEQ_OUTCOME_SER_DEC AS SeriousOutcome
	  ,NULL as IVAntibiotics_TAEInf
	  ,TAE.PEQ_RPT_TYPE_DEC AS EventReportStatus
	  ,TAE.PEQ_NO_EVENT_TXT AS NoEventExplain
	  ,TAE.PEQ_SOURCE_DOCS_DEC as SupportingDocuments
	  ,CASE WHEN TAE.PEQ_DOCS_ATTACH IS NULL THEN 'No'
	   WHEN TAE.PEQ_DOCS_ATTACH IS NOT NULL THEN 'Yes'
	   ELSE '' 
	   END AS FileAttached
	  ,CASE WHEN TAE.PEQ_DOCS_RECEIVED='X' THEN 'Yes'
	   ELSE 'No' 
	   END AS SupportingDocumentsReceived
	  ,CASE WHEN TAE.PEQ_RSN_REFUSED='X' THEN 'Patient would not authorize release of records'
	   WHEN TAE.PEQ_RSN_HOSP_NOFAX='X' THEN 'Hospital would not fax or release'
	   WHEN TAE.PEQ_RSN_OTH='X' THEN 'Other reason'
	   ELSE ''
	   END AS ReasonSourceNotProvided
	  ,TAE.PEQ_RSN_OTH_TXT AS ExplanationsHospitalOther
	  ,CASE WHEN EXISTS (SELECT VID FROM MERGE_IBD.staging.VISIT_COMP TAECOMPL WHERE TAECOMPL.VID=TAE.VID) THEN 'Complete'
	   ELSE 'Incomplete'
	   END AS PageStatus
	  ,LM.PAGENAME AS LastModifiedTAEPage
	  ,LM.PAGELMDT AS LastModifiedDate
	  ,LM.DATALMBY AS LastModifiedBy
FROM MERGE_IBD.staging.PEQ TAE
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME
AND LM.LMROWNUM=1


GO
