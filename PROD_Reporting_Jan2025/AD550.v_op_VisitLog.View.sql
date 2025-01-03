USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_VisitLog]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















/**Check ID values in Production Database when this is applied to live EDC**/
/**Listing of all visits in the AD EDC that have a visit date regardless of completeness**/


CREATE VIEW [AD550].[v_op_VisitLog] AS


WITH INCORRECTID AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY AL.subjectId ORDER BY AL.subjectId, AL.auditDate DESC) AS ROWNUM
      ,AL.subjectId AS patientId
      ,AL.auditDate
	  ,AL.eventTypeId
	  ,ALET.[name] AS eventName
  	  ,AL.oldValue
	  ,AL.newValue AS SubjectIDError
FROM [RCC_AD550].[api].[auditlogs] AL
JOIN [RCC_AD550].[api].[auditlogs_eventtypes] ALET ON ALET.id=AL.eventTypeId
WHERE  [name] = 'Subject Updated' --eventTypeId=5440 
AND ISNULL(newValue, '')<>''
AND ISDATE(newValue)=0
)

,VISITS AS
(
SELECT DISTINCT ec.SiteID
               ,ec.SubjectID
			   ,ec.patientId
			   ,CASE WHEN ec.eventName='Enrollment Visit' THEN 'Enrollment'
	                 WHEN ec.eventName='Follow-Up Visit' THEN 'Follow-up'
			         WHEN ec.eventName='Subject Exit' THEN 'Exit'
			         ELSE ec.eventName
					 END AS VisitType
			   ,ec.eventDefinitionId AS VisitTypeID
			   ,CASE WHEN ec.eventName='Enrollment Visit' THEN 0
			    WHEN ec.eventName='Subject Exit' THEN 99
				ELSE eventOccurence
				END AS EDCVisitSequence

FROM [Reporting].[AD550].[v_eventcrfs] ec
WHERE ec.eventName IN ('Subject Exit', 'Enrollment Visit', 'Follow-Up Visit')
)

,VISITDATES AS
(
SELECT DISTINCT S.SiteID
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,CASE WHEN V.eventName='Enrollment Visit' THEN 'Enrollment'
	        WHEN V.eventName='Follow-Up Visit' THEN 'Follow-up'
			WHEN V.eventName='Subject Exit' THEN 'Exit'
			ELSE V.eventName
		    END AS VisitType
	  ,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	   WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	   ELSE ''
	   END AS DataCollectionType
	  ,V.[eventOccurrence] AS EDCVisitSequence
	  ,V.[eventOccurrence]
      ,V.[visit_dt] AS VisitDate

  FROM [RCC_AD550].[staging].[provider] V
  JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=V.[subjectId]
  WHERE S.[status] NOT IN ('Removed', 'Incomplete')
  AND ISNULL(V.visit_dt, '')<>''
  AND ISNULL(V.[subNum], '')<>''
  --AND S.[studySiteName]<>'Corrona'
   

  UNION

  SELECT S.SiteID
        ,E.subNum AS SubjectID
		,E.subjectId AS patientId
		,E.exit_md_cod AS ProviderID
		,E.eventCrfId
		,E.eventId
		,'Exit' AS VisitType
		,'' AS DataCollectionType
		,'99' AS EDCVisitSequence
		,E.eventOccurrence
		,E.[exit_date] AS VisitDate
  FROM [Reporting].[AD550].[v_op_subjects] S
  LEFT JOIN [RCC_AD550].[staging].[exitdetails] E ON E.subjectId=S.patientId
  WHERE ISNULL(E.subNum, '')<>''
  AND ISNULL([exit_date], '')<>''
)

,CalcFUSequence AS
(
SELECT DISTINCT S.SiteID
      ,V.[subNum] AS SubjectID
      ,V.[subjectId] AS patientId
	  ,V.[visit_md_cod] AS ProviderID
	  ,V.eventCrfId
	  ,V.eventId
	  ,'Follow-up' AS VisitType
	  ,CASE WHEN V.visit_virtual_md=1 THEN 'In person'
	   WHEN V.visit_virtual_md=2 THEN 'Virtually by phone or video call'
	   ELSE ''
	   END AS DataCollectionType
	  ,ROW_NUMBER() OVER(PARTITION BY V.SubjectID ORDER BY V.[visit_dt]) AS VisitSequence
	  ,V.[eventOccurrence] AS EDCVisitSequence
      ,V.[visit_dt] AS VisitDate

  FROM [RCC_AD550].[staging].[provider] V
  JOIN [Reporting].[AD550].[v_op_subjects] S ON S.patientId=V.[subjectId]
  WHERE V.eventName='Follow-Up Visit'
  AND S.[status] NOT IN ('Removed', 'Incomplete')
  AND ISNULL(V.visit_dt, '')<>''
  AND ISNULL(V.[subNum], '')<>''
  --AND S.[studySiteName]<>'Corrona'
 )

SELECT VD.eventCrfId AS VisitID
      ,V.SiteID
      ,V.SubjectID
	  ,V.patientId
	  ,VD.ProviderID
	  ,V.VisitType
	  ,VD.DataCollectionType
	  ,V.VisitTypeID
	  ,CASE WHEN V.VisitType='Follow-up' THEN CFUS.VisitSequence
	   ELSE V.EDCVisitSequence
	   END AS VisitSequence
	  ,V.EDCVisitSequence
	  ,VD.eventOccurrence
	  ,VD.VisitDate
	  ,SUBSTRING(DATENAME(MONTH, VD.VisitDate), 1, 3) AS VisitMonth
	  ,DATEPART(YEAR, VD.VisitDate) AS VisitYear
	  ,I.SubjectIDError
	  ,'AD-550' AS Registry

FROM VISITS V
LEFT JOIN VISITDATES VD ON VD.patientId=V.patientId AND VD.VisitType=V.VisitType AND VD.EDCVisitSequence=V.EDCVisitSequence
LEFT JOIN CalcFUSequence CFUS ON CFUS.patientId=V.patientId AND CFUS.VisitType=V.VisitType AND CFUS.EDCVisitSequence=V.EDCVisitSequence
LEFT JOIN INCORRECTID I ON I.patientId=V.PatientID AND I.ROWNUM=1 AND ISNUMERIC(I.SubjectIDError)=0 
WHERE ISNULL(VD.VisitDate, '')<>''
AND ISNULL(V.SiteID, '') NOT IN ('', 1440)


GO
