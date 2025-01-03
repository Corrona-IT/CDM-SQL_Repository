USE [Reporting]
GO
/****** Object:  View [AA560].[v_op_ROMTAEListing]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [AA560].[v_op_ROMTAEListing] AS 

SELECT T.[SiteID]
      ,SFSiteStatus AS SiteStatus
	  ,RegistryManager
      ,[SubjectID]
      ,[PatientID]
      ,[statusCode]
      ,[reviewConfirmed]
      ,[ProviderID]
      ,[firstReportedVia]
      ,[FUVisitDate]
      ,[EventType]
      ,[eventId]
      ,[eventOccurrence]
      ,[crfName]
      ,[eventCrfId]
      ,[EventTerm]
      ,[SpecifyEvent]
      ,[OnsetDate]
      ,[MDConfirmed]
      ,[ConfirmationStatus]
      ,[noEventExplain]
      ,[hasData]
      ,[Outcome]
      ,[Serious]
      ,[SeriousReason]
      ,[IVAntiInfect]
      ,[DrugLogTreatments]
      ,[OtherDrugLogTreatments]
      ,[EventTreatments]
      ,[OtherEventTreatments]
      ,[SupportingDocuments]
      ,[SupportingDocumentsUploaded]
      ,[SupportDocumentsNotUploadedReason]
      ,[SupportDocsApproved]
      ,[EventPaid]
      ,[SourceDocsPaid]
      ,[PayEligibleStatus]
      ,[DataEntryStatus]
      ,[DateCreated]
      ,[Confirmation Status]
      ,[Event Info]
      ,[Event Details]
      ,[Drug Exposure]
      ,[Other Concurrent Drugs]
      ,[Event Completion]
      ,[Case Processing]
  FROM [regetlprod].[Reporting].[AA560].[t_pv_TAEQCListing] T
  LEFT JOIN [AA560].[v_SiteStatus] SS ON SS.SiteID=T.SiteID
  WHERE 1=1
  AND T.SiteID NOT IN (997, 998, 999, 1440)
  --AND ConfirmationStatus='Confirmed event'

GO
