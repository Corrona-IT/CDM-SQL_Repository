USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_VisitLog_rcc]    Script Date: 1/3/2025 4:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ===================================================================================================
-- Author:		Kevin Soe
-- Create date: 08/27/2023
-- Description:	Procedure to create VisitLog table
-- ===================================================================================================

CREATE PROCEDURE [RA100].[usp_op_VisitLog_rcc] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA100].[t_op_VisitLog_rcc] DROP TABLE [RA100].[t_op_VisitLog_rcc]
( 
CREATE TABLE [RA100].[t_op_VisitLog_rcc](
	--[VisitID] [bigint] NULL,
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar] (60) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[eventCrfId] [bigint] NULL,
	[VisitType] [nvarchar](200) NULL,
	--[DataCollectionType] [nvarchar](250) NULL,
	[eventId] [int] NULL,
	[VisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[SubjectIDError] [nvarchar](20) NULL,
	[Registry] [nvarchar](20) NULL,
	[RegistryName] [nvarchar](300) NULL
) ON [PRIMARY]
GO

);
*/

/***** Get incorrectly entered SubjectIDs *****/

IF OBJECT_ID('tempdb.dbo.#INCORRECTID') IS NOT NULL  DROP TABLE #INCORRECTID 

SELECT ROW_NUMBER() OVER (PARTITION BY AL.subjectId ORDER BY AL.subjectId, AL.auditDate DESC) AS ROWNUM
      ,AL.subjectId AS patientId
      ,AL.auditDate
	  ,AL.eventTypeId
	  ,ALET.[name] AS eventName
  	  ,AL.oldValue
	  ,AL.newValue AS SubjectIDError
	  ,IIF(TRY_PARSE(AL.newValue as datetime2) IS NULL, 0,1) AS isItADate
	  --,CAST(AL.newValue AS datetime) AS convertedDate 
	  ,AL.reasonForChange
INTO #INCORRECTID  --SELECT top 1000 *
FROM [RCC_RA100].[api].[auditlogs] AL  --SELECT TOP 100 * FROM [RCC_RA100].[api].[auditlogs_eventtypes]
JOIN [RCC_RA100].[api].[auditlogs_eventtypes] ALET ON ALET.id=AL.eventTypeId
WHERE  [name] = 'Subject Updated' --eventTypeId=5440 
AND ISNULL(newValue, '')<>''
AND ISNULL(oldValue, '')<>''
--AND ISDATE(newValue)=0
AND IIF(TRY_PARSE(AL.newValue as datetime2) IS NULL, 0,1)=0


--SELECT * FROM #INCORRECTID ORDER BY patientId

/***** Get a list of Subject Visits *****/

IF OBJECT_ID('tempdb.dbo.#VISITS') IS NOT NULL  DROP TABLE #VISITS 

SELECT DISTINCT ec.SiteID
               ,ec.SubjectID
			   ,ec.patientId
			   ,CASE WHEN eventDefinitionId=9285 THEN 'Enrollment'
	                 WHEN eventDefinitionId=9286 THEN 'Follow-up'
			         WHEN eventDefinitionId=9301 THEN 'Exit'
			         ELSE ec.eventName
					 END AS VisitType
			   ,ec.eventDefinitionId
			   ,CASE WHEN ec.eventDefinitionId=9285 THEN 0
			    WHEN ec.eventDefinitionId=9301 THEN 99
				ELSE eventOccurence
				END AS EDCVisitSequence
			   ,ec.eventOccurence AS eventOccurrence

INTO #VISITS
FROM [Reporting].[RA100].[v_eventcrfs] ec --SELECT * FROM [Reporting].[RA100].[v_eventcrfs]
WHERE ec.eventDefinitionId IN (9285, 9286, 9301)

--SELECT * FROM #VISITS ORDER BY SiteID, SubjectID

/***** Get the visit dates & type of visit (virtual or in-person) *****/

IF OBJECT_ID('tempdb.dbo.#VISITDATES') IS NOT NULL  DROP TABLE #VISITDATES

SELECT A.SiteID,
	   CASE WHEN A.SiteID IN (1440, 998, 997, 999) THEN 'Active'
	   ELSE SS.SiteStatus
	   END AS SiteStatus,
	   CASE WHEN A.SiteID IN (1440, 998, 997, 999) THEN 'Approved / Active'
	   ELSE SS.SFSiteStatus 
	   END AS SFSiteStatus,
       A.SubjectID,
	   A.patientId,
	   A.birthYear,
	   A.ProviderID,
	   A.eventCrfId,
	   A.eventId,
	   A.VisitType,
	   --A.DataCollectionType,
	   A.VisitSequence,
	   A.eventOccurrence,
	   A.VisitDate
INTO #VISITDATES
FROM
(
SELECT DISTINCT S.SiteID
        ,RIGHT('000' + S.SiteID, 3) AS siteChar
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[yob_2_1000] AS birthYear
	  ,V.[pid_3_1000] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,'Enrollment' AS VisitType
	  --,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	  -- WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	  -- ELSE ''
	  -- END AS DataCollectionType
	  ,0 AS VisitSequence
	  ,V.[eventOccurrence]
      ,V.[vis_3_8000] AS VisitDate
  FROM [RCC_RA100].[staging].[visitdate] V  --SELECT * FROM [RCC_RA100].[staging].[visitdate]
  --JOIN [RCC_RA100].[staging].[providerform] PV ON V.[subjectId] = PV.[subjectId]
  JOIN [Reporting].[RA100].[v_op_subjects_rcc] S ON S.SubjectId=V.[subNum]  --SELECT * FROM [Reporting].[RA100].[v_op_subjects_rcc]
  WHERE S.[status] NOT IN ('Removed', 'Incomplete')
  AND V.eventId=9285
  AND ISNULL(V.[vis_3_8000], '')<>''
  AND ISNULL(V.[subNum], '')<>''


  UNION

  SELECT DISTINCT S.SiteID
        ,RIGHT('000' + S.SiteID, 3) AS siteChar
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[yob_2_1000] AS birthYear
	  ,V.[pid_3_1000] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,'Follow-up' AS VisitType
	  --,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	  -- WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	  -- ELSE ''
	  -- END AS DataCollectionType
	  ,ROW_NUMBER() OVER(PARTITION BY V.subNum ORDER BY V.[vis_3_8000]) AS VisitSequence
	  ,V.[eventOccurrence]
      ,V.[vis_3_8000] AS VisitDate
  FROM [RCC_RA100].[staging].[visitdate] V 
  JOIN [Reporting].[RA100].[v_op_subjects_rcc] S ON S.subjectID=V.[subNum]  --SELECT * FROM [Reporting].[RA100].[v_op_subjects_rcc]
  WHERE S.[status] NOT IN ('Removed', 'Incomplete')
  AND V.eventId=9286
  AND ISNULL(V.[vis_3_8000], '')<>''
  AND ISNULL(V.[subNum], '')<>''

  UNION

  SELECT DISTINCT S.SiteID
        ,RIGHT('000' + S.SiteID, 3) AS siteChar
        ,E.subNum AS SubjectID
		,E.subjectId AS patientId
		,V.[exyob_7_1000] AS birthYear
		,V.[expid_7_1000] AS ProviderID
		,E.eventCrfId
		,E.eventId
		,'Exit' AS VisitType
		--,'' AS DataCollectionType
		,'99' AS VisitSequence
		,E.eventOccurrence
		,V.[exdat_7_8001] AS VisitDate
  FROM [Reporting].[RA100].[v_op_subjects_rcc] S -- SELECT * FROM [Reporting].[RA100].[v_op_subjects_rcc]
		 --SELECT * FROM
  LEFT JOIN [RCC_RA100].[staging].[exitdate] V ON V.subNum = S.subjectID
  LEFT JOIN [RCC_RA100].[staging].[exitdetails] E ON E.subNum=S.SubjectID
  --LEFT JOIN [RCC_RA100].[staging].[provider] V ON V.subNum=E.subNum
  WHERE ISNULL(E.subNum, '')<>''
  AND ISNULL([exdat_7_8001], '')<>''

) A
LEFT JOIN [RA100].[v_op_SiteStatus_rcc] SS ON SS.SiteID=A.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=A.siteChar AND SF.[name]='Rheumatoid Arthritis (RA-100,02-021)'

--SELECT * FROM [Salesforce].[dbo].[registryStatus] SF where SF.[name]='Rheumatoid Arthritis (RA-100,02-021)'
--SELECT * FROM #VISITDATES ORDER BY SiteID, SubjectID DESC

/***** Calculate FU Sequence and get the eligible visit information from visit reimbursement *****/

IF OBJECT_ID('tempdb.dbo.#VisitEligibility') IS NOT NULL  DROP TABLE #VisitEligibility

SELECT SiteID,
	   SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   patientId,
	   ProviderID,
	   eventCrfId,
	   eventId,
	   VisitDate,
	   VisitType,
	   --DataCollectionType,
	   VisitSequence,
	   eventOccurrence,
	   patientEligible,
	   fuEligible,
	   --OOW,
	   exceptionGranted,
	   --earlyFURulesSatisfied,
	   paymentException--,
	   --permIncomplete--,
	   /*CASE WHEN eventId=9301 THEN '-'
	        WHEN eventId=9285 AND (ISNULL(patientEligible, '')='No' AND ISNULL(exceptionGranted, '') IN ('', 'No')) THEN 'No'
			WHEN eventId=9285 AND (ISNULL(patientEligible, '')='No' AND ISNULL(exceptionGranted, '')='Yes') THEN 'Yes'
			WHEN eventId=9285 AND ISNULL(patientEligible, '') IN ('', 'Yes', 'Under review (outcome TBD)')  THEN 'Yes'
			WHEN eventId=9286 AND permIncomplete='Yes' AND ISNULL(paymentException, '') IN ('', 'No') THEN 'No'
			WHEN eventId=9286 AND OOW='Yes' AND ISNULL(earlyFURulesSatisfied, '') IN ('', 'No') AND ISNULL(paymentException,'') IN ('', 'No') THEN 'No'
			WHEN eventId=9286 AND OOW='Yes' AND ISNULL(earlyFURulesSatisfied, '') IN ('', 'No') AND ISNULL(paymentException,'')='Yes' THEN 'Yes'
			ELSE 'Yes'
			END AS EligibleVisit*/

INTO #VisitEligibility
FROM
(
SELECT DISTINCT VD.SiteID
      ,VD.SiteStatus
	  ,VD.SFSiteStatus
      ,VD.SubjectID
      ,VD.patientId
	  ,VD.ProviderID
	  ,VD.eventCrfId
	  ,VD.eventId
	  ,VD.VisitType
	  --,DataCollectionType
	  ,VD.VisitSequence
	  ,VD.[eventOccurrence]
      ,VD.VisitDate
	  ,VR.PAY_1_1000 AS patientEligible
	  ,VR.PAY_2_1500 AS fuEligible
  	  ,VR.PAY_1_1003 AS exceptionGranted
	  --,VR.PAY_2_1001 AS earlyFURulesSatisfied
	  ,VR.PAY_2_1002 AS paymentException
	  --,VR.PAY_3_1100 AS permIncomplete

  FROM #VISITDATES VD
	      --SELECT * FROM
  LEFT JOIN [RA100].[v_op_subjects_rcc] S ON S.subjectId=VD.subjectId
	      --SELECT * FROM
  LEFT JOIN [RCC_RA100].[staging].[visitreimbursement] VR ON VR.subNum=VD.SubjectID AND VR.eventId=VD.eventId AND VR.eventOccurrence=VD.eventOccurrence
  WHERE VD.eventId IN (9285, 9286, 9301)
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  AND ISNULL(VD.VisitDate, '')<>''
  ) A

--SELECT * FROM #VisitEligibility order by SubjectID DESC


TRUNCATE TABLE [Reporting].[RA100].[t_op_VisitLog_rcc];

INSERT INTO [Reporting].[RA100].[t_op_VisitLog_rcc]
(
	[SiteID],
	[SiteStatus],
	[SFSiteStatus],
	[SubjectID],
	[patientId],
	[ProviderID],
	[eventCrfId],
	[eventId],
	[VisitType],
	--[DataCollectionType],
	[eventOccurrence],
	[VisitSequence],
	[VisitDate],
	[VisitMonth],
	[VisitYear],
	[SubjectIDError],
	[Registry],
	[RegistryName]--,
	--[EligibleVisit]
)


/***** Put all gathered data into one table *****/

SELECT DISTINCT V.SiteID
	  ,V.SiteStatus
	  ,V.SFSiteStatus
      ,V.SubjectID
	  ,V.patientId
	  ,V.ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,V.VisitType
	  --,V.DataCollectionType
	  ,V.eventOccurrence
	  ,CASE WHEN V.eventId=9285 THEN V.VisitSequence
	   WHEN V.eventId=9301 THEN 99
	   ELSE V.[eventOccurrence]
	   END AS VisitSequence
	  ,V.VisitDate
	  ,SUBSTRING(DATENAME(MONTH, V.VisitDate), 1, 3) AS VisitMonth
	  ,DATEPART(YEAR,V.VisitDate) AS VisitYear
	  ,I.SubjectIDError
	  ,'RA-100' AS Registry
	  ,'Rheumatoid Arthritis (RA-100)' AS RegistryName
	  --,EligibleVisit

FROM #VisitEligibility V
LEFT JOIN #INCORRECTID I ON I.patientId=V.PatientID AND I.ROWNUM=1 
WHERE ISNULL(V.VisitDate, '')<>''
--AND ISNULL(V.SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[RA100].[t_op_VisitLog_rcc] ORDER BY SubjectID DESC

END

GO
