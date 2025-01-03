USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_VisitLog]    Script Date: 1/3/2025 4:53:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















/***This view is used in the Visit Log reports, and the Cohort Monitoring Reports for PSA***/





CREATE VIEW [PSA400].[v_op_VisitLog] AS


------------GET PHYSICIAN ID FROM ENROLLMENT AND FU TABLES

WITH PHYS_ID AS
(
---ENR
SELECT EPRO.VID AS VID
     , EPRO.SITENUM AS SiteID
	 , EPRO.SUBID AS SUBID
	 , EPRO.SUBNUM AS SubjectID
	 , EPRO.MD_COD AS ProviderID
FROM MERGE_SPA.STAGING.EPRO_01 AS EPRO
WHERE SITENUM NOT IN (99997, 99998, 99999)

UNION

---FU
SELECT EPA.VID AS VID
      , EPA.SITENUM AS SiteID
      , EPA.SUBID AS SUBID
      , EPA.SUBNUM AS SubjectID
      , EPA.MD_COD AS ProviderID
FROM MERGE_SPA.STAGING.EP_01A AS EPA
WHERE SITENUM NOT IN (99997, 99998, 99999)

UNION

----FU
SELECT FPRO.VID AS VID
      , FPRO.SITENUM AS SiteID
	  , FPRO.SUBID AS SUBID
	  , FPRO.SUBNUM AS SubjectID
	  , FPRO.MD_COD AS ProviderID
FROM MERGE_SPA.STAGING.FPRO_01 AS FPRO
WHERE SITENUM NOT IN (99997, 99998, 99999)

UNION 

---ENR
SELECT EP.VID
     , EP.SITENUM AS SiteID
	 , EP.SUBID
	 , EP.SUBNUM AS SubjectID
	 , EP.MD_COD AS ProviderID
FROM MERGE_SPA.STAGING.EP_01 AS EP
WHERE SITENUM NOT IN (99997, 99998, 99999)

),

---JOIN VISITS FROM VISIT TABLE WITH PHYSICIAN ID AND EXIT VISITS
VLOG AS
(
SELECT VS.vID
      ,VS.SITENUM AS SiteID
	  ,VS.SUBNUM AS SubjectID
	  ,VS.VISITID AS VISITID
	  ,VS.VISITSEQ AS VisitSequence
	  ,CASE WHEN VS.VISITID IN (10, 11) THEN 'Enrollment'
	   WHEN VS.VISITID IN (20, 25, 26) THEN 'Follow-Up'
	   ELSE VS.VISNAME
	   END AS VisitType
	  ,VIR_3_1000_DEC AS DataCollectionType
	  ,CAST(VS.VISITDATE AS DATE) AS VisitDate
	  ,PHYS_ID.ProviderID
FROM MERGE_SPA.STAGING.VS_01 AS VS
LEFT OUTER JOIN PHYS_ID ON PHYS_ID.VID=VS.VID
WHERE ISNULL(VS.VISITDATE, '')<>'' 
AND VS.SITENUM NOT IN (99997, 99998, 99999)


UNION

SELECT EXIT1.vID
     , EXIT1.SITENUM AS SiteID
	 , EXIT1.SUBNUM AS SubjectID
	 , EXIT1.VISITID
	 , EXIT1.VISITSEQ AS VisitSequence
	 , 'Exit' AS VisitType
	 ,'' AS DataCollectionType
	 , CAST (EXIT1.DISCONTINUE_DATE AS DATE) AS VisitDate
	 , EXIT1.MD_COD as ProviderID 
FROM MERGE_SPA.STAGING.EXIT_01 AS EXIT1 
WHERE EXIT1.STATUSID>0
AND ISNULL(EXIT1.DISCONTINUE_DATE, '')<>''
and EXIT1.SITENUM NOT IN (99997, 99998, 99999)

UNION

SELECT EX1.vID
     , EX1.SITENUM AS SiteID
	 , EX1.SUBNUM AS SubjectID
	 , EX1.VISITID
	 , EX1.VISITSEQ VisitSequence
	 , 'Exit' AS VisitType
	 ,'' AS DataCollectionType
	 , CAST (EX1.DISCONTINUE_DATE AS DATE) AS VisitDate
	 , EX1.PHYSICIAN_COD AS ProviderID 
FROM MERGE_SPA.STAGING.EX_01 AS EX1 
WHERE EX1.STATUSID>0
AND ISNULL(EX1.DISCONTINUE_DATE,'')<>''
AND EX1.SITENUM NOT IN (99997, 99998, 99999)
)

---------Add Exit Visits

SELECT DISTINCT
	  vID
     ,VLOG.SiteID
	 ,SS.SiteStatus
	 ,RS.currentStatus AS SFSiteStatus
	 ,SubjectID
	 ,VISITID
	 ,VisitSequence
	 ,CASE 
		WHEN VisitType = 'Exit' THEN 99
		ELSE ROW_NUMBER() OVER (PARTITION BY SubjectID ORDER BY VisitDate) - 1 
		END AS CalcVisitSequence 
	 ,VisitType
	 ,DataCollectionType
	 ,VisitDate
	 ,ProviderID 
	 ,'PSA-400' AS Registry
	 ,'Psoriatic Arthritis & Spondyloarthritis (PSA-400)' AS RegistryName
FROM VLOG 
LEFT JOIN [Reporting].[PSA400].[v_op_SiteStatus] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.[name]='Psoriatic Arthritis & Spondyloarthritis (PSA-400)' AND CAST(RS.[siteNumber] AS int)=CAST(VLOG.SiteID AS int)
WHERE ISNULL(VisitDate, '')<>''




GO
