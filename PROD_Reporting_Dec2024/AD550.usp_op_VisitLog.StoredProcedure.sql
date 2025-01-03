USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_VisitLog]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 09/28/2020
-- Description:	Procedure to create table VisitLog
-- ===================================================================================================

CREATE PROCEDURE [AD550].[usp_op_VisitLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*

CREATE TABLE [AD550].[t_op_VisitLog](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar] (60) NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[ProviderID] [int] NULL,
	[eventCrfId] [bigint] NULL,
	[VisitType] [nvarchar](200) NULL,
	[DataCollectionType] [nvarchar](250) NULL,
	[eventId] [int] NULL,
	[VisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[Registry] [nvarchar](20) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[EligibleVisit] [nvarchar] (75) NULL
) ON [PRIMARY]
GO

);
*/


/***** Get a list of Subject Visits *****/

IF OBJECT_ID('tempdb.dbo.#VISITS') IS NOT NULL  DROP TABLE #VISITS 

SELECT DISTINCT ec.SiteID
               ,ec.SubjectID
			   ,ec.patientId
			   ,CASE WHEN eventDefinitionId=8031 THEN 'Enrollment'
	                 WHEN eventDefinitionId=8034 THEN 'Follow-up'
			         WHEN eventDefinitionId=8045 THEN 'Exit'
			         ELSE ec.eventName
					 END AS VisitType
			   ,ec.eventDefinitionId
			   ,CASE WHEN ec.eventDefinitionId=8031 THEN 0
			    WHEN ec.eventDefinitionId=8045 THEN 99
				ELSE eventOccurence
				END AS EDCVisitSequence
			   ,ec.eventOccurence AS eventOccurrence

INTO #VISITS
FROM [Reporting].[AD550].[v_eventcrfs] ec
WHERE ec.eventDefinitionId IN (8031, 8034, 8045)

--SELECT * FROM #VISITS ORDER BY SiteID, SubjectID

/***** Get the visit dates & type of visit (virtual or in-person) *****/

IF OBJECT_ID('tempdb.dbo.#VISITDATES') IS NOT NULL  DROP TABLE #VISITDATES

SELECT A.SiteID,
	   CASE WHEN A.SiteID=1440 THEN 'Active'
	   ELSE SS.SiteStatus
	   END AS SiteStatus,
	   CASE WHEN A.SiteID=1440 THEN 'Approved / Active'
	   ELSE SF.currentStatus 
	   END AS SFSiteStatus,
       A.SubjectID,
	   A.patientId,
	   A.birthYear,
	   A.ProviderID,
	   A.eventCrfId,
	   A.eventId,
	   A.VisitType,
	   A.DataCollectionType,
	   A.VisitSequence,
	   A.eventOccurrence,
	   A.VisitDate
INTO #VISITDATES
FROM
(
SELECT DISTINCT S.SiteID
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[yob] AS birthYear
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,'Enrollment' AS VisitType
	  ,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	   WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	   ELSE ''
	   END AS DataCollectionType
	  ,0 AS VisitSequence
	  ,V.[eventOccurrence]
      ,V.[visit_dt] AS VisitDate
  FROM [RCC_AD550].[staging].[provider] V
  JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=V.[subjectId]
  WHERE S.[status] = 'Enrolled'
  AND V.eventId=8031
  AND ISNULL(V.visit_dt, '')<>''
  AND ISNULL(V.[subNum], '')<>''

  UNION

  SELECT DISTINCT S.SiteID
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[yob] AS birthYear
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,'Follow-up' AS VisitType
	  ,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	   WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	   ELSE ''
	   END AS DataCollectionType
	  ,ROW_NUMBER() OVER(PARTITION BY V.subNum ORDER BY V.visit_dt) AS VisitSequence
	  ,V.[eventOccurrence]
      ,V.[visit_dt] AS VisitDate
  FROM [RCC_AD550].[staging].[provider] V
  JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=V.[subjectId]
  WHERE S.[status] = 'Enrolled'
  AND V.eventId=8034
  AND ISNULL(V.visit_dt, '')<>''
  AND ISNULL(V.[subNum], '')<>''

  UNION

  SELECT DISTINCT S.SiteID
        ,E.subNum AS SubjectID
		,E.subjectId AS patientId
		,V.yob AS birthYear
		,E.exit_md_cod AS ProviderID
		,E.eventCrfId
		,E.eventId
		,'Exit' AS VisitType
		,'' AS DataCollectionType
		,'99' AS VisitSequence
		,E.eventOccurrence
		,E.[exit_date] AS VisitDate
  FROM [Reporting].[AD550].[v_op_subjects] S
  LEFT JOIN [RCC_AD550].[staging].[exitdetails] E ON E.subjectId=S.patientId
  LEFT JOIN [RCC_AD550].[staging].[provider] V ON V.subjectId=E.subjectID
  WHERE ISNULL(E.subNum, '')<>''
  AND ISNULL([exit_date], '')<>''

) A
LEFT JOIN [AD550].[v_SiteStatus] SS ON SS.SiteID=A.SiteID
LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.siteNumber=A.SiteID AND SF.[name]='Atopic Dermatitis (AD-550)'

--SELECT * FROM #VISITDATES ORDER BY SubjectID DESC

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
	   DataCollectionType,
	   VisitSequence,
	   eventOccurrence,
	   patientEligible,
	   OOW,
	   exceptionGranted,
	   earlyFURulesSatisfied,
	   paymentException,
	   permIncomplete,
	   CASE WHEN eventId=8045 THEN '-'
	        WHEN eventId=8031 AND (ISNULL(patientEligible, '')='No' AND ISNULL(exceptionGranted, '') IN ('', 'No')) THEN 'No'
			WHEN eventId=8031 AND (ISNULL(patientEligible, '')='No' AND ISNULL(exceptionGranted, '')='Yes') THEN 'Yes'
			WHEN eventId=8031 AND ISNULL(patientEligible, '') IN ('', 'Yes', 'Under review (outcome TBD)')  THEN 'Yes'
			WHEN eventId=8034 AND permIncomplete='Yes' AND ISNULL(paymentException, '') IN ('', 'No') THEN 'No'
			WHEN eventId=8034 AND OOW='Yes' AND ISNULL(earlyFURulesSatisfied, '') IN ('', 'No') AND ISNULL(paymentException,'') IN ('', 'No') THEN 'No'
			WHEN eventId=8034 AND OOW='Yes' AND ISNULL(earlyFURulesSatisfied, '') IN ('', 'No') AND ISNULL(paymentException,'')='Yes' THEN 'Yes'
			ELSE 'Yes'
			END AS EligibleVisit

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
	  ,DataCollectionType
	  ,VD.VisitSequence
	  ,VD.[eventOccurrence]
      ,VD.VisitDate
	  ,VR.[pay_enr_eligible_dec] AS patientEligible
	  ,VR.[pay_earlyfu_oow_dec] AS OOW
  	  ,VR.[pay_enr_exception_granted_dec] AS exceptionGranted
	  ,VR.[pay_earlyfu_status_dec] AS earlyFURulesSatisfied
	  ,VR.[pay_earlyfu_pay_exception_dec] AS paymentException
	  ,VR.[pay_visit_perm_incomplete_dec] AS permIncomplete

--Updated Variable Naming
	  --,VR.[pay_visit_perm_incomplete] AS permIncomplete

  FROM #VISITDATES VD
  LEFT JOIN [AD550].[v_op_subjects] S ON S.patientId=VD.patientId
  LEFT JOIN [RCC_AD550].[staging].[visitreimbursement] VR ON VR.subNum=VD.SubjectID AND VR.eventId=VD.eventId AND VR.eventOccurrence=VD.eventOccurrence
  WHERE VD.eventId IN (8031, 8034, 8045)
  AND S.[status] = 'Enrolled'
  AND ISNULL(VD.VisitDate, '')<>''
  ) A

--SELECT * FROM #VisitEligibility order by SubjectID DESC


TRUNCATE TABLE [Reporting].[AD550].[t_op_VisitLog];

INSERT INTO [Reporting].[AD550].[t_op_VisitLog]
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
	[DataCollectionType],
	[eventOccurrence],
	[VisitSequence],
	[VisitDate],
	[VisitMonth],
	[VisitYear],
	[Registry],
	[RegistryName],
	[EligibleVisit]
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
	  ,V.DataCollectionType
	  ,V.eventOccurrence
	  ,CASE WHEN V.eventId=8034 THEN V.VisitSequence
	   WHEN V.eventId=8045 THEN 99
	   ELSE V.[eventOccurrence]
	   END AS VisitSequence
	  ,V.VisitDate
	  ,SUBSTRING(DATENAME(MONTH, V.VisitDate), 1, 3) AS VisitMonth
	  ,DATEPART(YEAR,V.VisitDate) AS VisitYear
	  ,'AD-550' AS Registry
	  ,'Atopic Dermatitis (AD-550)' AS RegistryName
	  ,EligibleVisit

FROM #VisitEligibility V
WHERE ISNULL(V.VisitDate, '')<>''
--AND ISNULL(V.SiteID, '') NOT IN ('', 1440)

--SELECT * FROM [Reporting].[AD550].[t_op_VisitLog] ORDER BY SubjectID DESC

END

GO
