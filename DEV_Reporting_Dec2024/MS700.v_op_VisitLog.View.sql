USE [Reporting]
GO
/****** Object:  View [MS700].[v_op_VisitLog]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*Listing of all visits in the MS EDC that have a visit date regardless of completeness*/

CREATE VIEW [MS700].[v_op_VisitLog] AS

WITH INCORRECTID AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY subjectId ORDER BY subjectId, auditDate DESC) AS ROWNUM
      ,subjectId
      ,auditDate
	  ,oldValue
	  ,newValue AS SubjectIDError
FROM RCC_MS700.api.auditlogs 
WHERE eventTypeId=11893 AND ISNULL(newValue, '')<>''
AND ISDATE(newValue)=0
)


,VISLIST AS
(
SELECT S.SiteID
      ,V.[subNum] AS SubjectID
	  ,S.patientId
	  ,S.yearOfBirth
	  ,(SELECT DISTINCT sex_dec FROM [RCC_MS700].[staging].[subjectdemography] DEM WHERE subNum=V.subNum AND eventId=3042) AS Gender
	  ,'Enrollment' AS VisitType
	  ,V.eventId
	  ,V.visit_virtual_md_dec AS DataCollectionType
	  ,0 AS VisitSequence
	  ,V.[visit_dt] AS VisitDate
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventOccurrence
	  ,'Yes' AS EligibleVisit    
FROM [RCC_MS700].[staging].[visitinformation] V
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON V.subjectId=S.patientId
LEFT JOIN [RCC_MS700].[staging].[visitreimbursement] VR ON VR.subjectId=S.patientId AND VR.eventId=V.eventId AND VR.eventOccurrence=V.eventOccurrence
WHERE --S.SiteID<>1440 AND 
S.SubjectStatus NOT IN ('Removed', 'Incomplete')
AND V.[eventId]=3042
AND ISNULL(V.[visit_dt], '')<>''

UNION

SELECT S.SiteID
      ,V.[subNum] AS SubjectID
	  ,S.patientID
	  ,S.yearOfBirth
	  ,(SELECT DISTINCT sex_dec FROM [RCC_MS700].[staging].[subjectdemography] DEM WHERE subNum=V.subNum AND eventId=3042) AS Gender
	  --'Follow-Up' AS VisitType
	  ,'Follow-up' AS VisitType
	  ,V.eventId
	  ,V.visit_virtual_md_dec AS DataCollectionType
	  ,ROW_NUMBER() OVER(PARTITION BY S.[SiteID], S.SubjectID ORDER BY V.[visit_dt]) AS VisitSequence
	  ,V.[visit_dt] AS VisitDate
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
  	  ,V.eventOccurrence
	  ,CASE WHEN (VR.pay_2_1000=1 AND (VR.pay_2_1001=0 AND VR.pay_2_1002<>1)) THEN 'No' --early FU visit
	   WHEN V.visit_dt >= '2022-02-01' AND VR.pay_2_1400=1 AND pay_2_1401=0 THEN 'No'	--virtual visit
	   WHEN VR.pay_3_1300=0 THEN 'No' -- permanently incomplete visit
	   ELSE 'Yes'
	   END AS EligibleVisit

FROM [RCC_MS700].[staging].[visitinformation] V
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON V.subjectId=S.patientId
LEFT JOIN [RCC_MS700].[staging].[visitreimbursement] VR ON VR.subjectId=S.patientId AND VR.eventId=V.eventId AND VR.eventOccurrence=V.eventOccurrence
WHERE --S.SiteID<>1440 AND 
S.SubjectStatus NOT IN ('Removed', 'Incomplete')
AND V.[eventId]=3043
AND ISNULL(V.[visit_dt], '')<>''

UNION

SELECT S.SiteID
      ,E.[subNum] AS SubjectID
	  ,S.patientId
	  ,S.yearOfBirth
	  ,(SELECT DISTINCT sex_dec FROM [RCC_MS700].[staging].[subjectdemography] DEM WHERE subNum=E.subNum AND eventId=3042) AS Gender
	  ,'Exit' AS VisitType
	  ,E.eventId
	  ,'' AS DataCollectionType
	  ,99 AS VisitSequence
	  ,E.[exit_date] AS VisitDate
	  ,E.[md_cod_exit] AS ProviderID
	  ,E.eventCrfId
	  ,E.eventOccurrence
	  ,'Yes' AS EligibleVisit
FROM [RCC_MS700].[staging].[exitstatus] E
LEFT JOIN [Reporting].[MS700].[v_op_subjects] S ON E.subjectId=S.patientId
WHERE --S.SiteID<>1440 AND
S.SubjectStatus NOT IN ('Removed', 'Incomplete')
AND (ISNULL(E.[exit_date], '')<>'' OR ISNULL(E.exit_reason, '')<>'')
)

SELECT DISTINCT V.SiteID
      ,SS.SiteStatus
	  ,CASE WHEN V.SiteID=1440 THEN 'Approved / Active'
	   ELSE RS.currentStatus 
	   END AS SFSiteStatus
      ,CAST(V.SubjectID AS bigint) AS SubjectID
	  ,V.patientId
	  ,V.yearOfBirth
	  ,V.Gender
	  ,V.VisitType
	  ,V.eventId
	  ,V.DataCollectionType
	  ,V.VisitSequence
	  ,V.VisitDate
	  ,V.ProviderID
	  ,V.eventCrfId
	  ,V.eventOccurrence
	  ,V.EligibleVisit
	  ,I.SubjectIDError
	  ,'MS-700' AS Registry
	  ,'Multiple Sclerosis (MS-700)' AS RegistryName
FROM VISLIST V
LEFT JOIN [Reporting].[MS700].[v_SiteStatus] SS ON SS.SiteID=V.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=V.SiteID and RS.[name]='Multiple Sclerosis (MS-700)'
LEFT JOIN INCORRECTID I ON I.subjectId=V.patientId AND I.ROWNUM=1 AND ISNUMERIC(I.SubjectIDError)=0 


GO
