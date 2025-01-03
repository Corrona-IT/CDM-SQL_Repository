USE [Reporting]
GO
/****** Object:  View [IBD600].[v_pv_TAEQCListing]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [IBD600].[v_pv_TAEQCListing] AS

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


,D AS (

SELECT  vID
		,ROW_NUMBER () OVER(PARTITION BY [vID], [PAGENAME]
							    ORDER BY [PAGELMDT] DESC) ROWNUM
		,SITENUM
		,VISNAME
		,PAGENAME
		,REVNUM
		,SUBID
		,SUBNUM
		,VISITID
		,VISITSEQ
		,PAGEID
		,STATUSID
		,PAGELMDT
		,DATALMDT
		,DATALMBY
											
	FROM 
     (
       SELECT DA.vID
	         ,DA.SITENUM
			 ,DA.VISNAME
			 ,DA.PAGENAME
			 ,DA.REVNUM
			 ,DA.SUBID
			 ,DA.SUBNUM
			 ,DA.VISITID
			 ,DA.VISITSEQ
			 ,DA.STATUSID
			 ,DA.PAGEID
			 ,DA.PAGELMDT
			 ,DA.DATALMDT
			 ,DATALMBY
       FROM [MERGE_IBD].[staging].[DAT_APGS] DA 
       INNER JOIN VDEF ON DA.PAGENAME = VDEF.PAGENAME AND DA.REVNUM = VDEF.REVNUM

	   /*This 'WHERE' clause handes the MSU done from Jul 13-14, 2023, that pulled in system changes*/

	   WHERE (ISNULL(DA.DATALMBY, '') NOT IN ('Hinton, John', 'Brooks, Patrick', 'Rowe, Andrea'))
	   and DA.PAGENAME NOT LIKE '%Case Processing%'
	   AND CAST(DA.PAGELMDT AS date) <> '2023-07-13'

      ) T
)

 

,LastModified AS (

SELECT ROW_NUMBER () OVER(PARTITION BY [vID], [SITENUM], [SUBNUM], [VISNAME], [VISITSEQ]
							    ORDER BY [PAGELMDT] DESC)  AS LMROWNUM
		,vID
		,SITENUM
		,SUBNUM
		,VISNAME
		,PAGENAME
		,VISITID
		,VISITSEQ
		,PAGEID
		,STATUSID
		,DATALMBY
		,MAX(PAGELMDT) AS PAGELMDT

FROM
(
SELECT	 D.vID
        ,D.SITENUM
		,D.SUBNUM
		,D.VISNAME
		,D.PAGENAME
		,D.VISITID
		,D.VISITSEQ
		,D.PAGEID
		,D.STATUSID
		,CASE WHEN ISNULL(D.DATALMBY, '')='' THEN 'System generated'
		 ELSE D.DATALMBY
		 END AS DATALMBY
		,D.PAGELMDT
FROM D
WHERE ROWNUM=1 
 ) maxd
 GROUP BY vID, SITENUM, SUBNUM, VISNAME, VISITID, VISITSEQ, PAGEID, PAGENAME, STATUSID, DATALMBY, PAGELMDT
)

,COMBINED AS (

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [SiteID]
	  ,TAE.SUBNUM AS [SubjectID]
	  ,TAE.MD_COD AS [ProviderID]
	  ,CASE WHEN TAE.VISNAME='TAE' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE 'TAE%' AND LEN(TAE.VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [VisitSequence]
	  ,CASE 
	   WHEN TAE.VISNAME LIKE '%Infect%' OR ISNULL(TAE.AE_INF_TYPE_DEC, '')<>'' THEN 'INF'
	   WHEN TAE.VISNAME LIKE '%Neuro%' OR ISNULL(TAE.AE_NEURO_TYPE_DEC, '')<>'' THEN 'NEU'
	   WHEN TAE.VISNAME LIKE '%Cardio%' OR ISNULL(TAE.AE_CVD_TYPE_DEC, '')<>'' THEN 'CVD'
	   WHEN TAE.VISNAME LIKE '%Gener%' OR ISNULL(TAE.AE_GEN_EVENT_TXT, '')<>'' THEN 'GEN'
	   WHEN TAE.VISNAME LIKE '%GI Per%' OR ISNULL(TAE.AE_GI_TYPE_DEC, '')<>'' THEN 'GI'
	   WHEN TAE.VISNAME LIKE '%Anaph%' OR ISNULL(TAE.AE_HYPS_TYPE_DEC, '')<>'' THEN 'DRG_RXN'
	   WHEN TAE.VISNAME LIKE '%Autoimm%' OR ISNULL(TAE.AE_AUTO_TYPE_DEC, '')<>'' THEN 'AI'
	   WHEN TAE.VISNAME LIKE '%Cancer%' OR ISNULL(TAE.AE_CM_TYPE_DEC, '')<>'' THEN 'CAN'
	   WHEN TAE.VISNAME LIKE '%Hepat%' OR ISNULL(TAE.AE_HEP_TYPE_DEC, '')<>'' THEN 'HEP'
	   WHEN TAE.VISNAME LIKE '%Venous%' OR ISNULL(TAE.AE_HEP_TYPE_DEC, '')<>'' THEN 'VTE'
	   WHEN TAE.VISNAME LIKE '%Frac%' OR ISNULL(TAE.AE_HEP_TYPE_DEC, '')<>'' THEN 'FRA'
	   WHEN TAE.VISNAME='TAE' THEN 'TAE'
	   ELSE ''
	   END AS EventType
	  ,COALESCE(TAE.AE_CVD_TYPE_DEC, TAE.AE_HEP_TYPE_DEC, TAE.AE_GI_TYPE_DEC, TAE.AE_NEURO_TYPE_DEC,
	   TAE.AE_CM_TYPE_DEC, TAE.AE_AUTO_TYPE_DEC, TAE.AE_HYPS_TYPE_DEC, TAE.AE_INF_TYPE_DEC, TAE.AE_VTE_TYPE_DEC,TAE.AE_FRA_TYP_DEC, TAE.AE_GEN_EVENT_TXT) AS EventTerm
	  ,TAE.AE_TYPE_OTH_TXT AS EventSpecify
	  ,TAE.AE_EVENT_DT AS OnsetDate
	  ,TAE.AE_RPT_DT AS DateReported
	  ,TAE.AE_OUTCOME_DEC AS EventOutcome
	  ,TAE.AE_SERIOUS_DEC AS SeriousOutcome
	  ,CASE WHEN ISNULL(TAE.AE_INF_TYPE_DEC, '')=''  THEN ''
	    WHEN ISNULL(TAE.AE_INF_TYPE_DEC, '')<>'' 
		AND (INF.MTZ_ROUTE_DEC='IV'
		OR INF.VAN_ROUTE_DEC='IV'
		OR INF.FDX_ROUTE_DEC='IV'
		OR INF.OTH_ROUTE_DEC='IV'
		OR INF.LM_AE_INTRA_DEC = 'Yes')
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
LEFT JOIN LastModified LM ON LM.vID=TAE.vID AND LM.VISNAME=TAE.VISNAME AND LM.LMROWNUM=1
WHERE LM.PAGENAME NOT LIKE '%Case Processing%'

/*************PREGNANCY*******************/

UNION

SELECT TAE.vID
      ,CAST(TAE.SITENUM AS int) AS [SiteID]
	  ,TAE.SUBNUM AS [SubjectID]
	  ,TAE.MD_COD AS [ProviderID]
	  ,CASE WHEN TAE.VISNAME='Pregnancy Event' THEN 'Stand Alone'
	   WHEN TAE.VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN TAE.VISNAME LIKE '%Pregnancy Event-Patient Reported%' THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,TAE.VISITSEQ AS [VisitSequence]
	  ,'PG' AS EventType
	  ,'Pregnancy' AS EventTerm
	  ,NULL AS EventSpecify
	  ,NULL AS OnsetDate
	  ,TAE.PEQ_RPT_DT AS DateReported
	  ,NULL AS EventOutcome
	  ,TAE.PEQ_OUTCOME_SER_DEC AS SeriousOutcome
	  ,'' as IVAntibiotics_TAEInf
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
WHERE LM.PAGENAME NOT LIKE '%Case Processing%'

UNION

/***************BLANK TAE FORMS******************/

SELECT NULL AS vID
      ,SITENUM AS [SiteID]
      ,SUBNUM AS [SubjectID]
	  ,NULL AS [ProviderID]
	  ,CASE WHEN VISNAME='TAE' THEN 'Stand Alone'
	   WHEN VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN VISNAME LIKE 'TAE%' AND LEN(VISNAME)>4 THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,VISITSEQ AS [VisitSequence]
	  ,CASE 
	   WHEN TAE3.VISNAME LIKE '%Infect%' THEN 'INF'
	   WHEN TAE3.VISNAME LIKE '%Neuro%' THEN 'NEU'
	   WHEN TAE3.VISNAME LIKE '%Cardio%' THEN 'CVD'
	   WHEN TAE3.VISNAME LIKE '%Gener%' THEN 'GEN'
	   WHEN TAE3.VISNAME LIKE '%GI Per%' THEN 'GI'
	   WHEN TAE3.VISNAME LIKE '%Anaph%' THEN 'DRG_RXN'
	   WHEN TAE3.VISNAME LIKE '%Autoimm%' THEN 'AI'
	   WHEN TAE3.VISNAME LIKE '%Cancer%' THEN 'CAN'
	   WHEN TAE3.VISNAME LIKE '%Hepat%' THEN 'HEP'
	   WHEN TAE3.VISNAME LIKE '%Venous%' THEN 'VTE'
	   WHEN TAE3.VISNAME LIKE '%Frac%' THEN 'FRA'
	   WHEN TAE3.VISNAME='TAE' THEN 'TAE'
	   ELSE ''
	   END AS EventType
	  ,NULL AS [EventTerm]
	  ,NULL AS EventSpecify
	  ,NULL AS OnsetDate
	  ,NULL AS DateReported
	  ,NULL AS EventOutcome
	  ,NULL AS SeriousOutcome
	  ,NULL AS IVAntibiotics_TAEInf
	  ,NULL AS EventReportStatus
	  ,NULL AS NoEventExplain
	  ,NULL as SupportingDocuments
	  ,NULL AS FileAttached
	  ,NULL AS SupportingDocumentsReceived
	  ,NULL AS ReasonSourceNotProvided
	  ,NULL AS ExplanationsHospitalOther
	  ,STATUSID_DEC AS PageStatus
	  ,PAGENAME AS LastModifiedTAEPage
 	  ,COALESCE(MAX(DATALMDT), PAGELMDT) AS LastModifiedDate
	  ,PAGELMBY AS LastModifiedBy

FROM MERGE_IBD.DBO.DAT_PAGS TAE3
WHERE VISNAME LIKE '%TAE%'
AND STATUSID_DEC='No Data'
AND DATALMDT IS NULL
AND PAGENAME NOT LIKE '%Case Processing%'
AND NOT EXISTS (SELECT * FROM MERGE_IBD.staging.TAE TAE2 WHERE TAE2.SITENUM=TAE3.SITENUM AND TAE2.SUBNUM=TAE3.SUBNUM AND TAE2.VISNAME=TAE3.VISNAME AND TAE2.VISITSEQ=TAE3.VISITSEQ)
GROUP BY SITENUM, SUBNUM, VISNAME, VISITSEQ, STATUSID_DEC, PAGELMDT, PAGELMBY, PAGENAME

---order by [Site ID], [Subject ID], [Stand Alone or Auto Generated], [Visit Sequence]

UNION

SELECT NULL AS vID
      ,SITENUM AS [SiteID]
      ,SUBNUM AS [SubjectID]
	  ,NULL AS [ProviderID]
	  ,CASE WHEN VISNAME='Pregnancy Event' THEN 'Stand Alone'
	   WHEN VISNAME LIKE '%Exit%' THEN 'Exit Auto Generated'
	   WHEN VISNAME LIKE '%Pregnancy Event-Patient Reported%' THEN 'FU Auto Generated'
	   ELSE ''
	   END AS [Stand Alone or Auto Generated]
	  ,VISITSEQ AS [VisitSequence]
      ,'PG' AS [EventType]
	  ,'Pregnancy' AS [EventTerm]
	  ,NULL AS EventSpecify
	  ,NULL AS OnsetDate
	  ,NULL AS DateReported
	  ,NULL AS EventOutcome
	  ,NULL AS SeriousOutcome
	  ,NULL AS IVAntibiotics_TAEInf
	  ,NULL AS EventReportStatus
	  ,NULL AS NoEventExplain
	  ,NULL as SupportingDocuments
	  ,NULL AS FileAttached
	  ,NULL AS SupportingDocumentsReceived
	  ,NULL AS ReasonSourceNotProvided
	  ,NULL AS ExplanationsHospitalOther
	  ,STATUSID_DEC AS PageStatus
	  ,PAGENAME AS LastModifiedTAEPage
	  ,COALESCE(MAX(DATALMDT), PAGELMDT) AS LastModifiedDate
	  ,PAGELMBY AS LastModifiedBy

FROM MERGE_IBD.DBO.DAT_PAGS PREG
WHERE VISNAME LIKE '%PREG%'
AND STATUSID_DEC='No Data'
AND DATALMDT IS NULL
AND PAGENAME NOT LIKE '%Case Processing%'
AND NOT EXISTS (SELECT * FROM MERGE_IBD.staging.TAE TAE2 WHERE TAE2.SITENUM=PREG.SITENUM AND TAE2.SUBNUM=PREG.SUBNUM AND TAE2.VISNAME=PREG.VISNAME AND TAE2.VISITSEQ=PREG.VISITSEQ)
GROUP BY SITENUM, SUBNUM, VISNAME, VISITSEQ, STATUSID_DEC, PAGELMDT, PAGELMBY, PAGENAME
)

SELECT DISTINCT * FROM COMBINED




GO
