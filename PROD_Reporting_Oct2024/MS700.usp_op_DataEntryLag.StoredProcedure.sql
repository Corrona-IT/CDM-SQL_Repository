USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_DataEntryLag]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 2/11/2020
-- Description:	Procedure for Data Entry Lag Table
-- =================================================


CREATE PROCEDURE [MS700].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [MS700].[t_DataEntryLag]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [VARCHAR] (15) NULL,
	[vID] [varchar] (500) NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[DataCollectionType] [varchar] (300) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
);
*/



/******Get list of Site and Subjects******/

IF OBJECT_ID('tempdb.dbo.#Subjects') IS NOT NULL BEGIN DROP TABLE #Subjects END

SELECT SiteID
      ,SubjectID
	  ,patientId AS PatientID
	  ,SubjectStatus

 INTO #Subjects

FROM [Reporting].[MS700].[v_op_subjects] S
 WHERE SiteID<>1440
 AND SubjectStatus not in ('Removed', 'Incomplete')

--SELECT * FROM #Subjects

/******Get Visits Log******/

IF OBJECT_ID('tempdb.dbo.#VisitLog') IS NOT NULL BEGIN DROP TABLE #VisitLog END

SELECT VL.SiteID 
      ,VL.SubjectID
	  ,S.PatientID
	  ,VL.VisitType
	  ,VL.DataCollectionType
	  ,VL.VisitDate
	  ,VL.ProviderID
	  ,VL.[eventCrfId]
	  ,VL.eventOccurrence

INTO #VisitLog
FROM [MS700].[v_op_VisitLog] VL
JOIN #Subjects S ON S.SubjectID=VL.SubjectID
WHERE VisitType<>'Exit'
AND S.SubjectStatus NOT IN ('Removed', 'Incomplete')


/******Get list Visits and first entry date and if visit is deleted******/

IF OBJECT_ID('tempdb.dbo.#DE') IS NOT NULL BEGIN DROP TABLE #DE END

SELECT ROWNUM
      ,SiteID
	  ,SubjectID
	  ,patientid1
	  ,CASE WHEN VisitTypeID=3042 THEN 'Enrollment'
	   WHEN VisitTypeID=3043 THEN 'Follow-up'
	   ELSE ''
	   END AS VisitType
	  ,DataCollectionType
	  ,VisitDate
	  ,VisitSequence
	  ,PageName
	  ,FirstEntry
	  ,Deleted
	  ,eventCrfId
	  ,eventTypeId

 INTO #DE

 FROM ( 
  SELECT ROW_NUMBER() OVER (PARTITION BY VL.SiteID, VL.SubjectID, EC.eventDefinitionId, VL.eventOccurrence ORDER BY  VL.SiteID, VL.SubjectID, AL.auditDate) AS RowNum
        ,VL.SiteID
        ,VL.SubjectID
		,EC.eventDefinitionId AS VisitTypeID
		,VL.VisitDate
		,VL.eventOccurrence AS VisitSequence
		,VL.DataCollectionType
		,EC.eventSequence
        ,AL.[id] AS auditLogID
        ,AL.crfVersionId
		,EDC.crfCaption AS PageName
		,AL.userId
		,AL.studyEventId
		,AL.eventCrfId  --match this to Visit Information for VisitSequence for follow ups
		,AL.newValue
		,AL.oldValue
		,AL.eventTypeId
		,AL.reasonForChange
		,AL.entityId
		,AL.auditDate AS FirstEntry
		,AL.subjectId as patientid1
		,AL.studySiteId
		,AL.[current]
		,AL.deleted AS Deleted
		,EC.crfId
		,EC.crfVersionId AS crfVersionId2
		,EC.subjectId AS patientid2
		,EC.studyEventId as studyeventid2

  FROM #VisitLog VL
  LEFT JOIN [RCC_MS700].[api].[auditlogs] AL ON AL.subjectId=VL.PatientID AND AL.eventCrfId=VL.eventCrfId AND (AL.newValue<>'Not Started' AND AL.reasonForChange<>'CRF Status Changed')
  LEFT JOIN [RCC_MS700].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_MS700].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId
  WHERE EC.eventDefinitionId IN (3042, 3043)
  AND EDC.crfCaption='VISIT Information'
  AND ISNULL(AL.[deleted], '')=''
  AND VL.VisitDate IS NOT NULL
  AND (AL.newValue<>'Not Started' AND AL.reasonForChange<>'CRF Status Changed')

  ) A WHERE RowNum=1 
  
--SELECT * FROM #DE WHERE SubjectID=70041090008 and eventCRFId=28659545 ORDER BY RowNum
	

TRUNCATE TABLE [Reporting].[MS700].[t_DataEntryLag]

INSERT INTO [Reporting].[MS700].[t_DataEntryLag] 
(
	[SiteID],
	[SubjectID],
	[vID],
	[PageName],
	[VisitType],
	[DataCollectionType],
	[VisitDate],
	[VisitSequence],
	[FirstEntry],
	[DifferenceInDays],
	[EarliestVisitDate],
	[EarliestEntryDate]
)

SELECT DISTINCT SiteID
	  ,SubjectID
	  ,(CAST(SiteID AS nvarchar) + ' ' + CAST(SubjectID AS nvarchar) + ' ' + VisitType + ' ' + CAST(VisitDate AS nvarchar) + ' ' + CAST(VisitSequence as nvarchar)) AS vID
	  ,PageName
	  ,VisitType
	  ,DataCollectionType
	  ,VisitDate
	  ,VisitSequence
	  ,FirstEntry
	  ,CAST(DATEDIFF(d,VisitDate, FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE) AS EarliestVisitDate
	  ,(SELECT MIN(FirstEntry) FROM #DE) AS EarliestEntryDate

FROM #DE DE
WHERE DE.VisitDate IS NOT NULL


--SELECT * FROM [Reporting].[MS700].[t_DataEntryLag] ORDER BY SiteID, SubjectID, VisitDate


END

GO
