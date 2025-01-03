USE [Reporting]
GO
/****** Object:  View [AD550].[v_eventcrfs_DEV]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [AD550].[v_eventcrfs_DEV] AS


SELECT s.SiteId AS SiteID
      ,s.patientId
      ,s.SubjectID
	  ,s.[status] AS SubjectStatus
      ,ed.[name] AS [eventName] -- study visit type
	  ,ec.[id] 
	  ,ec.[eventDefinitionId]  --study visit type id
	  ,ec.[studyEventId]  -- unique visit type id for subject crfs
      ,ec.[eventOccurence]
	  ,ec.[crfId]  
	  ,cv.[crfName]
	  ,ec.[crfOccurence]
	  ,ec.[eventSequence]
	  ,ec.[statusId]
	  ,ec.[statusCode]

FROM [RCC_AD550].[api].[eventcrfs] ec
JOIN [RCC_AD550].[api].[eventdefinitions] ed ON ed.id = ec.eventDefinitionId
JOIN [RCC_AD550].[api].[crfversions] cv ON cv.id = ec.crfVersionId AND cv.crfId=ec.crfId
JOIN [Reporting].[AD550].[v_op_subjects_DEV] s ON s.patientId = ec.subjectId

--ORDER BY s.SubjectID, ec.[id]



--SELECT * FROM [RCC_AD550].[api].[eventcrfs] ec
--SELECT * FROM [RCC_AD550].[api].[eventdefinitions] ed
--SELECT * FROM [RCC_AD550].[api].[crfversions] cv
--SELECT * FROM [Reporting].[AD550].[v_op_subjects] s

GO
