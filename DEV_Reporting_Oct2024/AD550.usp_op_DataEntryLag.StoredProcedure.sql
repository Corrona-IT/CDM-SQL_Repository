USE [Reporting]
GO
/****** Object:  StoredProcedure [AD550].[usp_op_DataEntryLag]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 2/11/2020
-- Description:	Procedure for Data Entry Lag Table
-- =================================================


CREATE PROCEDURE [AD550].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [AD550].[t_DataEntryLag]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar] (30) NULL,
	[vID] [nvarchar] (100) NULL,
	[PageName] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[DataCollectionType] [varchar] (300) NULL,
	[VisitDate] [date] NULL,
	[VisitSequence] [int] NULL,
	[FirstEntry] [datetime] NULL,
	[DifferenceInDays] [int] NULL,
	[EarliestVisitDate] [date] NULL,
	[EarliestEntryDate] [date] NULL
);
*/

--SELECT * FROM [Reporting].[MS700].[t_DataEntryLag]

/******Get list of Site and Subjects******/

IF OBJECT_ID('tempdb.dbo.#Subjects') IS NOT NULL BEGIN DROP TABLE #Subjects END

SELECT DISTINCT SiteID
      ,SubjectID
	  ,patientId
	  ,[status]

 INTO #Subjects

 FROM [Reporting].[AD550].[v_op_subjects] S
 WHERE S.[status] not in ('Removed', 'Incomplete')

--SELECT * FROM #Subjects


/******Get Visits Log******/

IF OBJECT_ID('tempdb.dbo.#VisitLog') IS NOT NULL BEGIN DROP TABLE #VisitLog END

SELECT VL.SiteID 
      ,VL.SubjectID
	  ,S.[status]
	  ,VL.patientId
	  ,VL.VisitType
	  ,VL.DataCollectionType
	  ,VL.VisitDate
	  ,VL.ProviderID
	  ,VL.[eventCrfId]
	  ,VL.eventOccurrence

INTO #VisitLog
FROM [Reporting].[AD550].[t_op_VisitLog] VL
JOIN #Subjects S ON S.SubjectID=VL.SubjectID
WHERE VisitType NOT LIKE 'Exit%'
AND S.[status] NOT IN ('Removed', 'Incomplete')

--SELECT * FROM #VisitLog where SubjectID =57638220010


/******Get list Visits and first entry date and if visit is deleted******/

IF OBJECT_ID('tempdb.dbo.#DE') IS NOT NULL BEGIN DROP TABLE #DE END

SELECT ROWNUM
      ,SiteID
	  ,SubjectID
	  ,vID
	  ,patientid1
	  ,VisitType
	  ,DataCollectionType
	  ,VisitTypeID
	  ,VisitDate
	  ,VisitSequence
	  ,PageName
	  ,FirstEntry
	  ,Deleted
	  ,eventCrfId
	  ,eventTypeId
	  ,reasonForChange
	  ,newValue

 INTO #DE

 FROM ( 
  SELECT ROW_NUMBER() OVER (PARTITION BY VL.SiteID, VL.SubjectID, EC.eventDefinitionId, VL.eventOccurrence ORDER BY  VL.SiteID, VL.SubjectID, AL.auditDate) AS RowNum
        ,(cast(VL.SubjectID AS nvarchar) + CAST(EC.eventDefinitionId AS nvarchar) + CAST(VL.eventOccurrence AS nvarchar)) AS vID
		,VL.SiteID
        ,VL.SubjectID
		,EC.eventDefinitionId AS VisitTypeID
		,VL.VisitType
		,VL.DataCollectionType
		,VL.VisitDate
		,VL.eventOccurrence AS VisitSequence
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
  LEFT JOIN [RCC_AD550].[api].[auditlogs] AL ON AL.subjectId=VL.PatientID AND AL.eventCrfId=VL.eventCrfId 
  LEFT JOIN [RCC_AD550].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_AD550].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId

  WHERE EC.eventDefinitionId IN (8031, 8034)
  AND EDC.crfCaption IN ('Subject', 'Provider')
  AND (AL.newValue<>'Not Started' AND AL.reasonForChange<>'CRF Status Changed')
  AND ISNULL(VL.VisitDate, '')<>''

  ) A WHERE RowNum=1 
  
--SELECT * FROM #DE WHERE SubjectID=57638220010 ORDER BY VisitType, ROWNUM
--SELECT * FROM 


TRUNCATE TABLE [Reporting].[AD550].[t_DataEntryLag]

INSERT INTO [Reporting].[AD550].[t_DataEntryLag] 
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
	  ,vID
	  ,PageName
	  ,VisitType
	  ,DataCollectionType
	  ,VisitDate
	  ,VisitSequence
	  ,CAST(FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d, VisitDate, FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE) AS EarliestVisitDate
	  ,(SELECT MIN(CAST(FirstEntry AS date)) FROM #DE) AS EarliestEntryDate

FROM #DE DE
WHERE DE.VisitDate IS NOT NULL

--SELECT * FROM #DE
--SELECT * FROM [Reporting].[AD550].[t_DataEntryLag] WHERE SiteID<>1440 ORDER BY SUBJECTID, VISITDATE

--Subject 57638220010
END

GO
