USE [Reporting]
GO
/****** Object:  StoredProcedure [NMO750].[usp_op_DataEntryLag]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 6/24/2021
-- Description:	Procedure for Data Entry Lag Table
-- =================================================


CREATE PROCEDURE [NMO750].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [NMO750].[t_DataEntryLag]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [VARCHAR] (15) NULL,
	[crfCaption] [varchar](250) NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[eventOccurrence] [int] NULL,
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

FROM [Reporting].[NMO750].[v_op_subjects] S
 WHERE S.[status] not in ('Removed', 'Incomplete')

--SELECT * FROM #Subjects


/******Get Visits Log******/

IF OBJECT_ID('tempdb.dbo.#VisitLog') IS NOT NULL BEGIN DROP TABLE #VisitLog END

SELECT VL.SiteID 
      ,VL.SubjectID
	  ,VL.PatientID
	  ,VL.VisitType
	  ,VL.eventDefinitionId
	  ,VL.VisitDate
	  ,VL.ProviderID
	  ,VL.eventOccurrence
	  ,VL.eventCrfId

INTO #VisitLog
FROM [Reporting].[NMO750].[t_op_VisitLog] VL
WHERE VisitType NOT LIKE 'Exit%'


--SELECT COUNT(DISTINCT(eventCrfId)) FROM #VisitLog 


/******Get list Visits and first entry date and if visit is deleted******/

IF OBJECT_ID('tempdb.dbo.#DE') IS NOT NULL BEGIN DROP TABLE #DE END

SELECT ROWNUM
      ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,eventDefinitionId
	  ,VisitDate
	  ,eventOccurrence
	  ,crfCaption
	  ,FirstEntry
	  ,Deleted
	  ,eventCrfId
	  ,eventTypeId
	  ,reasonForChange
	  ,newValue

 INTO #DE

 FROM ( 
  SELECT ROW_NUMBER() OVER (PARTITION BY VL.SiteID, VL.SubjectID, EC.eventDefinitionId, VL.eventOccurrence ORDER BY  VL.SiteID, VL.SubjectID, AL.auditDate) AS RowNum
		,VL.SiteID
        ,VL.SubjectID
		,EC.eventDefinitionId
		,VL.VisitType
		,VL.VisitDate
		,VL.eventOccurrence
		,VL.eventCrfId
		,EC.eventSequence
		,EDC.crfCaption
		,AL.studyEventId
		,AL.newValue
		,AL.oldValue
		,AL.eventTypeId
		,AL.reasonForChange
		,AL.entityId
		,AL.auditDate AS FirstEntry
		,AL.[current]
		,AL.deleted
		,EC.crfId

  FROM #VisitLog VL
  LEFT JOIN [RCC_NMOSD750].[api].[auditlogs] AL ON AL.subjectId=VL.PatientID AND AL.eventCrfId=VL.eventCrfId AND (AL.newValue<>'Not Started' AND AL.reasonForChange<>'CRF Status Changed')
  LEFT JOIN [RCC_NMOSD750].[api].[eventcrfs] EC ON EC.studyEventId=AL.studyEventID AND EC.subjectid=AL.subjectId
  LEFT JOIN [RCC_NMOSD750].[api].[eventdefinitions_crfs] EDC ON EDC.versionId=EC.crfVersionId and edc.crfId=EC.crfId

  WHERE EC.eventDefinitionId IN (11174, 11175)
  AND EDC.crfCaption IN ('Subject Form', 'Provider')
  --AND AL.reasonForChange='CRF Status Changed'
  AND (AL.newValue<>'Not Started' AND AL.reasonForChange<>'CRF Status Changed')
  --AND AL.newValue='Data Entry Started'
  --AND AL.oldValue='Not Started'
  --AND ISNULL(AL.[deleted], '')=''
  AND ISNULL(VL.VisitDate, '')<>''

  ) A WHERE RowNum=1 
  
--SELECT * FROM #DE ORDER BY SiteID, SubjectID, VisitType, ROWNUM
--SELECT * FROM 


TRUNCATE TABLE [Reporting].[NMO750].[t_DataEntryLag]

INSERT INTO [Reporting].[NMO750].[t_DataEntryLag] 
(
	[SiteID],
	[SubjectID],
	[eventCrfId],
	[crfCaption],
	[VisitType],
	[VisitDate],
	[EventOccurrence],
	[FirstEntry],
	[DifferenceInDays],
	[EarliestVisitDate],
	[EarliestEntryDate]
)

SELECT DISTINCT SiteID
	  ,SubjectID
	  ,eventCrfId
	  ,crfCaption
	  ,VisitType
	  ,VisitDate
	  ,eventOccurrence
	  ,CAST(FirstEntry AS date) AS FirstEntry
	  ,CAST(DATEDIFF(d, VisitDate, FirstEntry) AS decimal(6,0)) AS DifferenceInDays
	  ,(SELECT MIN(VisitDate) FROM #DE) AS EarliestVisitDate
	  ,(SELECT MIN(CAST(FirstEntry AS date)) FROM #DE) AS EarliestEntryDate

FROM #DE DE
WHERE DE.VisitDate IS NOT NULL

--SELECT * FROM #DE
--SELECT * FROM [Reporting].[NMO750].[t_DataEntryLag] ORDER BY SiteID, SubjectID, VisitDate

END

GO
