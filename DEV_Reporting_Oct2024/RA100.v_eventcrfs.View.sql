USE [Reporting]
GO
/****** Object:  View [RA100].[v_eventcrfs]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [RA100].[v_eventcrfs] AS


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

FROM [RCC_RA100].[api].[eventcrfs] ec
JOIN [RCC_RA100].[api].[eventdefinitions] ed ON ed.id = ec.eventDefinitionId
JOIN [RCC_RA100].[api].[crfversions] cv ON cv.id = ec.crfVersionId AND cv.crfId=ec.crfId
JOIN [Reporting].[RA100].[v_op_subjects_rcc] s ON s.patientId = ec.subjectId

--ORDER BY s.SubjectID, ec.[id]



--SELECT * FROM [RCC_AD550].[api].[eventcrfs] ec
--SELECT * FROM [RCC_AD550].[api].[eventdefinitions] ed
--SELECT * FROM [RCC_AD550].[api].[crfversions] cv
--SELECT * FROM [Reporting].[AD550].[v_op_subjects] s

GO
