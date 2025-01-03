USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_VisitLog]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [IBD600].[v_op_VisitLog] as



WITH VISITLOG AS (
SELECT DISTINCT A.vID
      ,A.SiteID
      ,A.SubjectID
	  ,A.SUBID	
	  ,A.YOB
	  ,A.ProviderID
	  ,A.VisitSequence
	  ,A.VisitDate
	  ,A.[Month]
	  ,A.[Year]
	  ,A.[VisitType]
	  ,DaysSinceLastVisit
	  ,DataCollectionType
	  ,BioRepositoryAssoc
	  ,BioRepositoryVisitType
	  ,INELIGIBLE_DEC AS EnrollEligibility
	  ,INELIGIBLE_EXCEPTION_DEC AS EnrollException
	  ,OOW_FU_DETECTED AS OOW
	  ,OOW_FU_PERMITTED_DEC AS FUException
	  ,CASE WHEN VisitType='Enrollment' AND INELIGIBLE_DEC='No' AND INELIGIBLE_EXCEPTION_DEC='No' THEN 'No'
	   WHEN VisitType='Follow-Up' AND OOW_FU_DETECTED='X' AND (OOW_FU_PERMITTED_DEC IN ('No', '') AND OOW_FU_EXCEPTION_DEC IN ('', 'No')) THEN 'No' 
	   WHEN VisitType='Enrollment' AND INELIGIBLE_DEC='No' AND INELIGIBLE_EXCEPTION_DEC='Yes' THEN 'Yes'
	   WHEN VisitType='Follow-Up' AND OOW_FU_DETECTED='X' AND (OOW_FU_PERMITTED_DEC='Yes' OR OOW_FU_EXCEPTION_DEC='Yes') THEN 'Yes' 
	   ELSE ''
	   END AS EligibleVisit
FROM
(
SELECT DISTINCT DP.vID
      ,CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,DP.SUBNUM AS [SubjectID]
	  ,DP.SUBID
	  ,DS.IDENT2 AS YOB
	  ,CAST(MD.MD_COD AS int) AS [ProviderID]
	  ,CAST(VIS.VISITSEQ AS int) AS [VisitSequence]
	  ,CAST(VIS.VISITDATE AS date) AS [VisitDate]
	  ,SUBSTRING(DATENAME(MONTH, VISITDATE), 1, 3) AS [Month]
	  ,DATEPART(YYYY, VIS.VISITDATE) AS [Year]
	  ,DP.VISNAME AS [VisitType]
	  ,COALESCE(VIS.DAYS_SINCE_ENROLL, VIS.DAYS_SINCE_PREV_VIS) AS DaysSinceLastVisit
	  ,VIS.VIR_3_1000_DEC AS DataCollectionType
	  ,VIS.VISIT_ASSOC_BIO_COLL_DEC AS BioRepositoryAssoc
	  ,VIS.VISIT_TYPE_BIO_COLL AS BioRepositoryVisitType

FROM MERGE_IBD.staging.DAT_PAGS DP  
LEFT JOIN MERGE_IBD.dbo.DAT_SUB DS ON DS.SUBID=DP.SUBID
LEFT OUTER JOIN MERGE_IBD.staging.VISIT AS VIS ON VIS.SUBID = DP.SUBID AND VIS.vID = DP.vID AND VIS.VISITSEQ = DP.VISITSEQ 
LEFT OUTER JOIN MERGE_IBD.staging.MD_DX AS MD ON MD.SUBID = DP.SUBID AND MD.vID = DP.vID AND MD.VISITSEQ = DP.VISITSEQ
WHERE (DP.PAGENAME = 'Visit Date')
) A
LEFT JOIN [MERGE_IBD].[staging].[REIMB] REIMB ON REIMB.SUBNUM=A.SubjectID AND REIMB.vID=A.vID
AND PAGENAME='Visit Date'

UNION

SELECT DISTINCT EXT.vID
      ,CAST(DP.SITENUM AS bigint) AS [SiteID]
      ,DP.SUBNUM AS [SubjectID]
	  ,DP.SUBID
	  ,DS.IDENT2 AS YOB
	  ,CAST(EXT.MD_COD AS int) AS [ProviderID]
	  ,CAST(EXT.VISITSEQ AS int) AS [VisitSequence]
	  ,CAST(EXT.DISCONTINUE_DT AS date) AS [VisitDate]
	  ,SUBSTRING(DATENAME(MONTH, EXT.DISCONTINUE_DT), 1, 3) AS [Month]
	  ,DATEPART(YYYY, EXT.DISCONTINUE_DT) AS [Year]
	  ,DP.VISNAME AS [VisitType]
	  ,NULL AS DaysSinceLastVisit
	  ,NULL AS EnrollEligibility
	  ,NULL AS EnrollException
	  ,NULL AS OOW
	  ,NULL AS FUException
	  ,'Yes' AS EligibleVisit
	  ,NULL AS DataCollectionType
	  ,NULL AS BioRepositoryAssoc
	  ,NULL AS BioRepositoryVisitType
FROM MERGE_IBD.staging.DAT_PAGS AS DP 
LEFT JOIN MERGE_IBD.dbo.DAT_SUB DS ON DS.SUBID=DP.SUBID
LEFT OUTER JOIN MERGE_IBD.staging.[EXIT] AS EXT ON EXT.SUBID = DP.SUBID AND EXT.vid = DP.vid AND EXT.VISITSEQ = DP.VISITSEQ

WHERE (EXT.STATUSID >= 0) AND (DP.PAGENAME like 'Exit Status')
--AND DP.SUBNUM=60001000001
)

,VLOG AS
(
SELECT V.vID
      ,V.[SiteID]
      ,V.[SubjectID]
	  ,V.SUBID
	  ,V.YOB
	  ,V.[ProviderID]
	  ,V.[VisitSequence]
	  ,V.[VisitDate]
	  ,SUBSTRING(DATENAME(MONTH, VISITDATE), 1, 3) AS [Month]
	  ,V.[Year]
	  ,CASE WHEN V.[VisitType] LIKE '%Exit%' THEN 'Exit'
	   ELSE V.[VisitType]
	   END AS [VisitType]
	  ,V.EnrollEligibility
	  ,V.EnrollException
	  ,V.OOW
	  ,V.FUException
	  ,V.EligibleVisit
	  ,V.DaysSinceLastVisit
	  ,V.DataCollectionType
	  ,V.BioRepositoryAssoc
	  ,V.BioRepositoryVisitType
FROM VISITLOG V
--LEFT join months st on st.MonthCode = V.[Month]
WHERE ISNULL(V.[VisitDate],'')<>''
)


, RACE AS (
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_NATIVE_AM='X' THEN 'American Indian or Alaska Native' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_NATIVE_AM='X'
AND VISNAME='Enrollment'
UNION
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_ASIAN='X' THEN 'Asian' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_ASIAN='X'
AND VISNAME='Enrollment'
UNION
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_BLACK='X' THEN 'Black/African American' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_BLACK='X'
AND VISNAME='Enrollment'
UNION
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_PACIFIC='X' THEN 'Native Hawaiian or Other Pacific Islander' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_PACIFIC='X'
AND VISNAME='Enrollment'
UNION
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_WHITE='X' THEN 'White' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_WHITE='X'
AND VISNAME='Enrollment'
UNION
SELECT vID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,CASE WHEN RACE_OTHER='X' THEN  'Other' ELSE '' END AS RACE
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE RACE_OTHER='X'
AND VISNAME='Enrollment'
)

,Demography AS (
SELECT vID
      ,SITENUM AS SiteID
	  ,SUBNUM AS SubjectID
	  ,SUBID
	  ,VISNAME AS VisitType
	  ,VISITSEQ AS VisitSequence
	  ,SEX_DEC AS Gender
	  ,STUFF((
        SELECT ', '+ RACE 
        FROM RACE
		WHERE RACE.vID=DEMOG.vID
		FOR XML PATH('')
        )
        ,1,1,'') AS Race
FROM [MERGE_IBD].[staging].[PT_DEMOG] DEMOG
WHERE VISNAME='Enrollment'
)

SELECT DISTINCT VLOG.vID
      ,VLOG.[SiteID]
      ,SS.[SiteStatus]
	  ,SS.[SFSiteStatus]
      ,VLOG.[SubjectID]
	  ,VLOG.SUBID
	  ,[ProviderID]
	  ,VLOG.[VisitSequence]
	  ,CASE 
		WHEN VLOG.VisitType = 'Exit' THEN 99
		ELSE ROW_NUMBER() OVER (PARTITION BY VLOG.SubjectID ORDER BY VisitDate) - 1 
		END AS [CalcVisitSequence]
	  ,[VisitDate]
	  ,[Month]
	  ,[Year]
	  ,VLOG.[VisitType]
	  ,Gender
	  ,YOB
	  ,Race
	  ,DaysSinceLastVisit
	  ,DataCollectionType
	  ,BioRepositoryAssoc
	  ,BioRepositoryVisitType
	  ,EnrollEligibility
	  ,EnrollException
	  ,OOW
	  ,FUException
	  ,EligibleVisit
	  ,'IBD-600' AS Registry
	  ,'Inflammatory Bowel Disease (IBD-600)' AS RegistryName
FROM VLOG
LEFT JOIN [Reporting].[IBD600].[v_op_SiteStatus] SS ON SS.SiteID=VLOG.SiteID
LEFT JOIN Demography DEMOG ON DEMOG.SUBID=VLOG.SUBID
--WHERE VLOG.VisitType='Enrollment' AND EligibleVisit='No' --AND SiteStatus='Active'



--SELECT * FROM [IBD600].[v_op_VisitLog] WHERE ORDER BY SiteID, SubjectID, VisitDate



GO
