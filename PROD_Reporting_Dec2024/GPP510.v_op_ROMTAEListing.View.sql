USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_ROMTAEListing]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [GPP510].[v_op_ROMTAEListing] AS

WITH Salesforce AS
(
SELECT [siteNumber] 
      ,[account] AS siteName
      ,[pmLastName] + ', ' +[pmFirstName] AS RegistryManager
      ,[name] AS Registry
      ,[currentStatus]
  FROM [Salesforce].[dbo].[registryStatus]
  WHERE 1=1
  AND [name]='Generalized Pustular Psoriasis (GPP-510)'
  AND currentStatus<>'Not participating'
  AND ISNULL(siteNumber, '')<>''
)


SELECT [vID]
      ,[SITENUM]
      ,[SiteStatus]
	  ,[RegistryManager]
      ,[SUBID]
      ,[SUBNUM]
      ,[PROVID]
      ,[VISNAME]
      ,[VISITSEQ]
      ,[EventType]
      ,[EventTerm]
      ,[specifyOtherEvent]
      ,[OnsetDate]
      ,[EventFirstReported]
      ,[RptVisitDate]
      ,[confirmationStatus]
      ,[notAnEventExplain]
      ,[OUTCOME_DEC]
      ,[SERIOUS_DEC]
      ,[seriousCriteria]
      ,[IV_antiInfective]
      ,[drugLogTreatments]
      ,[otherDrugLogTreatments]
      ,[drugExposure]
      ,[otherDrugExposure]
      ,[suppDocs]
      ,[suppdocsUpload]
      ,[suppDocsNotSubmReas]
      ,[suppDocsApproved]
      ,[eventPaid]
      ,[suppDocspaid]
      ,[HasData]
      ,[CreatedDate]
      ,[LMDT_confirmationStatus]
      ,[LMDT_eventInformation]
      ,[LMDT_eventDetails]
      ,[LMDT_drugExposure]
      ,[LMDT_otherConcurrentDrugs]
      ,[LMDT_flareVisits]
      ,[LMDT_subjectForm]
      ,[LMDT_testResults]
      ,[LMDT_eventCompletion]
      ,[LMDT_CaseProcessing]
      ,[eventPaymentEligibility]
      ,[EventDataEntryStatus]
  FROM [GPP510].[t_pv_TAEQCListing] T
  LEFT JOIN Salesforce S ON S.siteNumber=T.SITENUM
  WHERE 1=1
  AND T.SITENUM NOT IN (9999, 9998, 9997, 1440)
  --AND confirmationStatus='Confirmed event'

  


GO
