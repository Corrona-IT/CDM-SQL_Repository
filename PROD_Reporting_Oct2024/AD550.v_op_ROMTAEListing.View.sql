USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_ROMTAEListing]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [AD550].[v_op_ROMTAEListing] AS

WITH Salesforce AS
(
SELECT [siteNumber] 
      ,[account] AS siteName
      ,[pmLastName] + ', ' +[pmFirstName] AS RegistryManager
      ,[name] AS Registry
      ,[currentStatus]
  FROM [Salesforce].[dbo].[registryStatus]
  WHERE 1=1
  AND [name]='Atopic Dermatitis (AD-550)'
  AND currentStatus<>'Not participating'
  AND ISNULL(siteNumber, '')<>''
)


SELECT [SiteID]
      ,S.[currentStatus] AS SiteStatus
	  ,S.RegistryManager
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
      ,[EventOnsetDate]
      ,[MDConfirmed]
      ,[ConfirmationStatus]
      ,[noEventExplain]
      ,[hasData]
      ,[Outcome]
      ,[Serious]
      ,[SeriousReason]
      ,[IVAntiInfect]
      ,[FUVisitTreatments]
      ,[OtherFUVisitTreatments]
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
      ,[auditType]
      ,[DateCreated]
      ,[Event Info]
      ,[Fractures]
      ,[Event Details]
      ,[AD Drug Exposure]
      ,[Other concurrent Drugs]
      ,[Data Entry Completion]
      ,[Supporting Documents Approval]
      ,[Case Processing]
  FROM [AD550].[t_pv_TAEQCListing] T
  LEFT JOIN Salesforce S ON S.siteNumber=T.SiteID
  WHERE 1=1
  AND T.SiteID NOT IN (999, 998, 997, 1440)
  --AND confirmationStatus='Confirmed event'



GO
