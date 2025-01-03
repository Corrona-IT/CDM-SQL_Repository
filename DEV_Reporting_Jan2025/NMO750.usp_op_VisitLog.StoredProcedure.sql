USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_VisitLog]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 09/28/2020
-- Description:	Procedure to create table VisitLog
-- ===================================================================================================

CREATE PROCEDURE [NMO750].[usp_op_VisitLog] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_op_VisitLog](
	[SiteID] [int] NOT NULL,
	[EDCSiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](40) NULL,
	[SubjectID] [nvarchar](10) NOT NULL,
	[patientId] [bigint] NOT NULL,
	[birthYear] [int] NULL,
	[gender] [nvarchar] (20) NULL,
	[ProviderID] [int] NULL,
	[VisitType] [nvarchar](200) NULL,
	[eventDefinitionId] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[EDCVisitSequence] [int] NULL,
	[eventOccurrence] [int] NULL,
	[VisitDate] [date] NULL,
	[VisitMonth] [nvarchar](20) NULL,
	[VisitYear] [int] NULL,
	[hasData] [nvarchar](10) NULL,
	[CompletionStatus] [nvarchar](50) NULL,
	[Registry] [nvarchar](20) NULL,
	[RegistryName] [nvarchar](300) NULL,
	[eventCrfId] [bigint] NULL,
	[pay_enr_eligible] [int] NULL,
	[pay_enr_exception_granted] [int] NULL,
	[pay_visit_confirmed_incomplete] [int] NULL,
	[visitRescheduled] [int] NULL,
	[subjectFormNotDone] [int] NULL,
	[TSQM9NotDone] [int] NULL,
	[EDSSPermIncomplete] [int] NULL,
	[pay_earlyfu_oow] [int] NULL,
	[pay_earlyfu_status] [int] NULL,
	[pay_earlyfu_pay_exception] [int] NULL,
	[IncompleteVisit] [nvarchar] (20) NULL,
	[EligibleVisit] [nvarchar](20) NULL
) ON [PRIMARY]
*/



IF OBJECT_ID('tempdb.dbo.#VISITS') IS NOT NULL  DROP TABLE #VISITS 

SELECT DISTINCT ec.SiteID
               ,CASE WHEN ec.eventName='Subject Exit' THEN Ex.exit_md_cod
			    ELSE VD.visit_md_cod 
				END AS ProviderID
               ,ec.SubjectID
			   ,ec.patientId
			   ,CASE WHEN ec.eventName='Subject Exit' THEN 'Exit'
			         ELSE ec.eventName
					 END AS VisitType
			   ,ec.eventDefinitionId
			   ,CASE WHEN ec.eventName IN ('Enrollment', 'Follow-up') THEN VD.visit_dt
			    WHEN ec.eventName='Subject Exit' THEN Ex.[exit_date]
				END AS VisitDate
			   ,CASE WHEN ec.eventName='Enrollment' THEN 0
			    WHEN ec.eventName='Subject Exit' THEN 99
				ELSE eventOccurence
				END AS EDCVisitSequence
			   ,ec.eventOccurence AS eventOccurrence
			   ,ec.[id] AS eventCrfId
		
INTO #VISITS
FROM [Reporting].[NMO750].[v_eventcrfs] ec
JOIN [Reporting].[NMO750].[v_op_subjects] S ON S.patientId=ec.patientId
LEFT JOIN [RCC_NMOSD750].[staging].[visitdate] VD ON VD.subjectId=ec.patientId AND VD.eventName=ec.eventName AND VD.eventOccurrence=ec.eventOccurence
LEFT JOIN [RCC_NMOSD750].[staging].[exitdate] Ex ON Ex.subjectId=ec.patientId
WHERE ec.eventDefinitionId IN (11174, 11175, 11190)
AND ec.crfName IN ('Visit Date', 'Exit Date')
AND S.[status] NOT IN ('Removed', 'Incomplete')


--SELECT * FROM #VISITS ORDER BY SiteID, SubjectID, EDCVisitSequence, VisitDate


IF OBJECT_ID('tempdb.dbo.#CalcFUSequence') IS NOT NULL  DROP TABLE #CalcFUSequence

SELECT DISTINCT V.SiteID
      ,V.SubjectID
      ,V.patientId
	  ,ProviderID
	  ,V.VisitType
	  ,V.eventDefinitionId
	  ,CASE WHEN V.eventDefinitionId=11174 THEN 0
	        WHEN V.eventDefinitionId=11175 THEN ROW_NUMBER() OVER(PARTITION BY V.SubjectID, V.eventDefinitionId ORDER BY V.VisitDate) 
            WHEN V.eventDefinitionId=11190 then 99
			END AS VisitFUSequence
	  ,V.EDCVisitSequence
	  ,V.eventOccurrence
      ,V.VisitDate
	  ,V.eventCrfId
	  ,VR.pay_enr_eligible
	  ,VR.pay_enr_exception_granted
	  ,VR.pay_visit_confirmed_incomplete
	  ,VR.[pay_visit_reschedule] AS visitRescheduled
	  ,VR.pay_subject_incomplete AS subjectFormNotDone
	  ,VR.pay_tsqm9 AS TSQM9NotDone
	  ,VR.pay_edss_incomplete AS EDSSPermIncomplete
	  ,VR.pay_earlyfu_oow
	  ,VR.pay_earlyfu_status
	  ,VR.[pay_earlyfu_pay_exception]
	  ,CASE WHEN V.eventDefinitionId=11175 AND (VR.pay_visit_confirmed_incomplete=1 OR VR.[pay_visit_reschedule]=1 OR VR.pay_subject_incomplete=1 OR VR.pay_tsqm9=1 OR VR.pay_edss_incomplete=1) THEN 'Incomplete'
	   ELSE ''
	   END AS IncompleteVisit
	  ,CASE WHEN V.eventDefinitionId=11190 THEN '-'
	        WHEN V.eventDefinitionId=11174 AND (VR.pay_enr_eligible=0 AND ISNULL(VR.pay_enr_exception_granted, '') IN (0, '')) THEN 'No'
			WHEN V.eventDefinitionId=11174 AND (VR.pay_enr_eligible=1 OR ISNULL(VR.pay_enr_eligible, '')='') THEN 'Yes'
			WHEN V.eventDefinitionId=11174 AND VR.pay_enr_eligible=0 AND VR.pay_enr_exception_granted=1 THEN 'Yes'
	        WHEN V.eventDefinitionId=11175 AND (VR.pay_visit_confirmed_incomplete=1 OR VR.[pay_visit_reschedule]=1 OR VR.pay_subject_incomplete=1 OR VR.pay_tsqm9=1 OR VR.pay_edss_incomplete=1) THEN 'No'
			WHEN V.eventDefinitionId=11175 AND VR.pay_earlyfu_oow=1 AND VR.pay_earlyfu_status=0 AND VR.[pay_earlyfu_pay_exception]=0 THEN 'No'
			ELSE 'Yes'
			END AS EligibleVisit	             
  INTO #CalcFUSequence
  FROM #VISITS V
  LEFT JOIN [RCC_NMOSD750].[staging].[visitreimbursement] VR ON VR.subNum=V.SubjectID AND VR.eventId=V.eventDefinitionId AND VR.eventOccurrence=V.eventOccurrence
  WHERE V.eventDefinitionId IN (11174, 11175, 11190)
  AND ISNULL(V.VisitDate, '')<>''
  AND ISNULL(V.SubjectID, '')<>''
  
--SELECT * FROM #CalcFUSequence WHERE eventDefinitionId=11175 AND EligibleVisit='No' ORDER BY SiteID, SubjectID, VisitFUSequence
--SELECT * FROM [RCC_NMOSD750].[staging].[visitreimbursement] ORDER BY subNum, eventName, eventOccurrence

  IF OBJECT_ID('tempdb.dbo.#Completion') IS NOT NULL  DROP TABLE #Completion

  SELECT subNum AS SubjectID
        ,subjectId AS patientId
		,CASE WHEN eventName='Subject Exit' THEN 'Exit'
		 ELSE eventName
		 END AS VisitType
		,eventId
		,eventOccurrence
		,CASE WHEN hasData=1 THEN 'Yes'
		 WHEN hasData=0 THEN 'No'
		 ELSE ''
		 END AS hasData
		,statusCode AS CompletionStatus
		,eventCrfId
  INTO #Completion
  FROM [RCC_NMOSD750].[staging].[eventcompletion]
  WHERE eventName IN ('Enrollment', 'Follow-up', 'Subject Exit')

--SELECT * FROM #Completion ORDER BY SubjectID, eventId, eventOccurrence

TRUNCATE TABLE [Reporting].[NMO750].[t_op_VisitLog];

INSERT INTO [Reporting].[NMO750].[t_op_VisitLog]
(
	   [SiteID]
      ,[EDCSiteStatus]
      ,[SFSiteStatus]
      ,[SubjectID]
      ,[patientId]
      ,[birthYear]
	  ,[gender]
      ,[ProviderID]
      ,[VisitType]
      ,[eventDefinitionId]
      ,[VisitSequence]
      ,[EDCVisitSequence]
      ,[eventOccurrence]
      ,[VisitDate]
      ,[VisitMonth]
      ,[VisitYear]
      ,[hasData]
      ,[CompletionStatus]
      ,[Registry]
      ,[RegistryName]
      ,[eventCrfId]
      ,[pay_enr_eligible]
      ,[pay_enr_exception_granted]
      ,[pay_visit_confirmed_incomplete]
      ,[visitRescheduled]
      ,[subjectFormNotDone]
      ,[TSQM9NotDone]
      ,[EDSSPermIncomplete]
	  ,[pay_earlyfu_oow]
	  ,[pay_earlyfu_status]
	  ,[pay_earlyfu_pay_exception]
	  ,[IncompleteVisit]
      ,[EligibleVisit]
)

SELECT V.SiteID
      ,SiteStat.SiteStatus AS EDCSiteStatus
	  ,CASE WHEN V.SiteID=1440 THEN 'TestSite'
	   ELSE SF.currentStatus 
	   END AS SFSiteStatus
      ,V.SubjectID
	  ,V.patientId
	  ,SI.subject_yob AS birthYear
	  ,CASE WHEN SI.subject_sex=0 THEN 'Male'
	   WHEN SI.subject_sex=1 THEN 'Female'
	   ELSE CAST(SI.subject_sex AS varchar)
	   END AS gender
	  ,V.ProviderID
	  ,V.VisitType
	  ,V.eventDefinitionId
	  ,CASE WHEN V.VisitType='Follow-up' THEN CFUS.VisitFUSequence
	   ELSE V.EDCVisitSequence
	   END AS VisitSequence
	  ,V.EDCVisitSequence
	  ,V.eventOccurrence
	  ,V.VisitDate
	  ,SUBSTRING(DATENAME(MONTH, V.VisitDate), 1, 3) AS VisitMonth
	  ,DATEPART(YEAR,V.VisitDate) AS VisitYear
	  ,comp.hasData
	  ,CompletionStatus
	  ,'NMOSD-750' AS Registry
	  ,'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)' AS RegistryName
	  ,V.eventCrfId
	  ,CFUS.pay_enr_eligible
	  ,CFUS.pay_enr_exception_granted
	  ,[pay_visit_confirmed_incomplete]
	  ,[visitRescheduled]
	  ,[subjectFormNotDone]
	  ,[TSQM9NotDone]
	  ,[EDSSPermIncomplete]
	  ,[pay_earlyfu_oow]
	  ,[pay_earlyfu_status]
	  ,[pay_earlyfu_pay_exception]
	  ,[IncompleteVisit]
	  ,CFUS.EligibleVisit

FROM #VISITS V
LEFT JOIN [Salesforce].[dbo].[registryStatus] SF ON SF.[name]='Neuromyelitis Optica Spectrum Disorder (NMOSD-750)' AND SF.siteNumber=V.SiteID
LEFT JOIN [RCC_NMOSD750].[staging].[subjectinfo] SI ON SI.[subjectId]=V.[patientId]
LEFT JOIN [Reporting].[NMO750].[v_SiteStatus] SiteStat ON SiteStat.SiteID=V.SiteID
LEFT JOIN #CalcFUSequence CFUS ON CFUS.patientId=V.patientId AND CFUS.eventDefinitionId=V.eventDefinitionId AND CFUS.EDCVisitSequence=V.EDCVisitSequence
LEFT JOIN #Completion comp ON comp.patientId=V.patientId AND comp.visitType=V.VisitType AND comp.eventOccurrence=V.eventOccurrence
WHERE ISNULL(V.VisitDate, '')<>''

--SELECT * FROM [Reporting].[NMO750].[t_op_VisitLog] WHERE eventDefinitionId=11175 AND (IncompleteVisit='Incomplete' Or EligibleVisit='No') ORDER BY SiteID, SubjectID, VisitSequence, eventOccurrence, VisitDate

END

GO
