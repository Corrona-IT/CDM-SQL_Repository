USE [Reporting]
GO
/****** Object:  StoredProcedure [MS700].[usp_op_E&E]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 9/28/2020
-- Description:	Procedure to create table for MS700 Enrollment & Eligibility (E&E)
-- ==================================================================================

CREATE PROCEDURE [MS700].[usp_op_E&E] AS



BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* 

CREATE TABLE [MS700].[t_op_E&E](
	[SiteID] [int] NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](30) NULL,
	[SubjectID] [nvarchar](30) NOT NULL,
	[ProviderID] [int] NULL,
	[PatientYOB] [int] NULL,
	[AgeAtEnrollment] [float] NULL,
	[VisitDate] [date] NULL,
	[DateofDiagnosis] [date] NULL,
	[TreatmentName] [nvarchar](255) NULL,
	[OtherTreatment] [nvarchar](255) NULL,
	[TreatmentNameFull] [nvarchar](255) NULL,
	[EligibleTreatment] [nvarchar](20) NULL,
	[TreatmentStatus] [nvarchar](255) NULL,
	[StartDate] [date] NULL,
	[enteredStartDate] [nvarchar] (30) NULL,
	[DataCollectionType] [nvarchar](200) NULL,
	[RegistryEnrollmentStatus] [nvarchar](255) NULL,
	[EligibilityReview] [nvarchar](100) NULL,
	[VisitCompletion] [nvarchar](255) NULL

) ON [PRIMARY];
*/

/*****Get Enrollment Drugs*****/

IF OBJECT_ID('tempdb.dbo.#EnrollDrugs') IS NOT NULL BEGIN DROP TABLE #EnrollDrugs END;

SELECT DISTINCT SiteID,
       SiteStatus,
	   SFSiteStatus,
       SubjectID,
	   PatientYOB,
	   AgeAtEnrollment,
	   ProviderID,
	   VisitDate,
	   eventId,
	   eventOccurrence,
	   DateofDiagnosis,
	   VisitCompletion,
	   TreatmentName,
	   OtherTreatment,
	   EligibleTreatment,
	   TreatmentStatus,
	   CASE WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND TreatmentStatus='prescribed' THEN 10
	   WHEN EligibleTreatment='Yes' AND ISNULL(AgeAtEnrollment, '')='' AND TreatmentStatus='prescribed' THEN 20 -- Needs review
	   WHEN EligibleTreatment='Pending' THEN 50  --Needs review
	   WHEN EligibleTreatment='Yes' AND AgeAtEnrollment>17 AND TreatmentStatus IN ('current', 'past use', 'n/a') THEN 60
	   WHEN (TreatmentName = 'No treatment') THEN 90
	   ELSE CAST(NULL AS int)
	   END AS EligibilityHierarchy,
	   StartDate,
	   enteredStartDate,
	   FirstDoseReceivedToday,
	   DataCollectionType,

	   CASE WHEN VisitDate < '2022-02-01' THEN 'Eligible'
	   WHEN VisitDate >= '2022-02-01' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND TreatmentStatus='prescribed' AND ISNULL(DateOfDiagnosis, '')<>'' AND ISNULL(DataCollectionType, '')=('in-person') THEN 'Eligible'
	   WHEN VisitDate >= '2022-02-01' AND AgeAtEnrollment>17 AND EligibleTreatment='Yes' AND ISNULL(TreatmentStatus, '')<>'prescribed' AND ISNULL(DateOfDiagnosis, '')<>'' AND ISNULL(DataCollectionType, '')=('in-person') THEN 'Not eligible'
	   WHEN (ISNULL(AgeAtEnrollment, '')='' OR ISNULL(DateofDiagnosis, '')='' OR TreatmentName='Other DMT') AND VisitDate >= '2022-02-01' THEN 'Needs review'
	   WHEN TreatmentName='Pending' AND ISNULL(VisitCompletion, '')<>'Complete' AND VisitDate >= '2022-02-01' THEN 'Needs review'
	   WHEN ISNULL(AgeAtEnrollment, '') < 18 AND VisitDate >= '2022-02-01' THEN 'Not eligible'
	   WHEN ISNULL(TreatmentStatus,'')<>'prescribed' AND VisitDate >= '2022-02-01' THEN 'Not eligible'
	   WHEN ISNULL(DataCollectionType, '')='virtual' AND VisitDate >= '2022-02-01' THEN 'Not eligible'
	   WHEN TreatmentName IN ('No treatment') AND VisitCompletion='Complete' AND VisitDate >= '2022-02-01' THEN 'Not eligible'
	   WHEN EligibleTreatment='No' AND VisitDate >= '2022-02-01' THEN 'Not eligible'
	   ELSE ''
	   END AS RegistryEnrollmentStatus

INTO #EnrollDrugs
FROM
(
SELECT A.SiteID,
       A.SiteStatus,
	   A.SFSiteStatus,
       A.SubjectID,
	   A.PatientYOB,
	   A.AgeAtEnrollment,
	   A.ProviderID,
	   A.VisitDate,
	   A.eventId,
	   A.eventOccurrence,
	   A.DateofDiagnosis,
	   A.VisitCompletion,
	   A.TreatmentName,
	   A.OtherTreatment,
	   A.TreatmentStatus,
	   A.StartDate,
	   A.enteredStartDate,
	   A.FirstDoseReceivedToday,

	   CASE WHEN A.DataCollectionType='Virtually by phone or video call' THEN 'virtual'
	   WHEN A.DataCollectionType='In-person' THEN 'in-person'
	   ELSE A.DataCollectionType
	   END AS DataCollectionType,

	   CASE WHEN A.VisitDate < '2022-02-01' THEN 'Yes'
	   WHEN A.VisitDate >= '2022-02-01' AND A.TreatmentName=DrugRef.TreatmentName AND A.VisitDate >= DrugRef.StartDate AND A.VisitDate <= DrugRef.EndDate THEN 'Yes'
	   WHEN A.VisitDate >= '2022-02-01' AND A.TreatmentName IN ('No treatment', 'Pending') AND ISNULL(VisitCompletion, '')<>'Complete' THEN 'Needs review' 
	   WHEN A.VisitDate > '2023-03-08' AND A.TreatmentName='Other DMT' AND (UPPER(A.otherTreatment) LIKE '%TASCENSO%' OR  UPPER(A.otherTreatment) LIKE '%FINGOLIMOD%') THEN 'Yes'
	   WHEN A.VisitDate >= '2022-02-01' AND A.TreatmentName='Other DMT' THEN 'Needs review'
	   WHEN A.VisitDate >= '2022-02-01' AND (A.TreatmentName=DrugRef.TreatmentName AND A.VisitDate < DrugRef.StartDate) OR (A.VisitDate > DrugRef.EndDate) THEN 'No'
	   WHEN A.VisitDate >= '2022-02-01' AND ISNULL(A.TreatmentName, '')='' AND VisitCompletion='Complete' THEN 'No'
	   ELSE ''
	   END AS EligibleTreatment
FROM 
(
SELECT DISTINCT VL.SiteID,
       VL.SiteStatus,
	   VL.SFSiteStatus,
       VL.SubjectID,
	   S.birthdate AS PatientYOB,
	   (DATEPART(yy, AD.VisitDate)-S.birthdate) AS AgeAtEnrollment,
	   VL.ProviderID,
	   VL.VisitDate,
	   VL.eventId,
	   VL.DataCollectionType,
	   VL.eventOccurrence,
	   DD.[dx_ms_dt] AS DateofDiagnosis,
	   AD.VisitCompletion,
	   AD.TreatmentName,
	   AD.OtherTreatment,
	   AD.ChangesToday,
	   CASE WHEN AD.ChangesToday='No changes (current use)' THEN 'current'
	   WHEN AD.ChangesToday='Start' THEN 'prescribed'
	   WHEN AD.ChangesToday='Stop' THEN 'past use'
	   WHEN AD.ChangesToday='N/A - no longer in use' THEN 'past use'
	   WHEN AD.ChangesToday='Modify' THEN 'current'
	   WHEN AD.TreatmentName IN ('Pending', 'No treatment') THEN 'n/a'
	   ELSE ''
	   END AS TreatmentStatus,  
	   AD.StartDate,
	   AD.[enteredStartDate],
	   AD.FirstDoseReceivedToday

FROM [Reporting].[MS700].[v_op_VisitLog] VL
LEFT JOIN [RCC_MS700].[staging].[providerdiseasestatus] DD ON DD.subNum=VL.SubjectID AND DD.eventId=VL.eventId AND DD.eventOccurrence=VL.eventOccurrence
LEFT JOIN [Reporting].[MS700].[t_op_AllDrugs] AD ON AD.SubjectID=VL.SubjectID AND AD.eventId=VL.eventId
LEFT JOIN [RCC_MS700].[staging].[subjectdemography] S ON S.[subNum]=VL.SubjectID AND S.eventId=3042
WHERE VL.eventId=3042
) A
LEFT JOIN [Reporting].[MS700].[t_op_DrugReference] DrugRef ON DrugRef.TreatmentName=A.TreatmentName
) B

--SELECT * FROM #EnrollDrugs WHERE VisitDate >= '2022-02-01' AND TreatmentName='Aubagio (teriflunomide)' ORDER BY SiteID, SubjectID, VisitDate, EligibilityHierarchy
--SELECT MAX(LEN(SFSiteStatus)) FROM #EnrollDrugs

/*****Get DOI at Enrollment*****/

IF OBJECT_ID('tempdb.dbo.#EnrollDOI') IS NOT NULL BEGIN DROP TABLE #EnrollDOI END;

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, RESHierarchy, EligibilityHierarchy, TreatmentName) AS RowNum,
       SiteID,
	   SiteStatus,
	   SFSiteStatus,
	   SubjectID,
	   PatientYOB,
	   AgeAtEnrollment,
	   ProviderID,
	   VisitDate,
	   DateofDiagnosis,
	   VisitCompletion,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   EligibilityHierarchy,
	   StartDate,
	   enteredStartDate,
	   FirstDoseReceivedToday,
	   DataCollectionType,
	   RegistryEnrollmentStatus,
	   RESHierarchy,
	   Eligible, --'Yes' 'No' 'Under review (outcome TBD)'
	   ExceptionGranted,		--'Yes'  'No'
	   CASE WHEN Eligible='Under review (outcome TBD)' THEN 'Under review (outcome TBD)'
	   WHEN Eligible='Yes' THEN 'Eligible'
	   WHEN Eligible='No' AND ExceptionGranted='Yes' THEN 'Not eligible - Exception granted'
	   WHEN Eligible='No' AND ExceptionGranted='No' THEN 'Not eligible'
	   ELSE Eligible
	   END AS ReviewStatus

INTO #EnrollDOI
FROM 
(
SELECT DISTINCT ED.SiteID,
       ED.SiteStatus,
	   ED.SFSiteStatus,
       ED.SubjectID,
	   ED.PatientYOB,
	   ED.AgeAtEnrollment,
	   ED.ProviderID,
	   ED.VisitDate,
	   ED.DateofDiagnosis,
	   ED.VisitCompletion,
	   ED.TreatmentName,
	   ED.OtherTreatment,
	   CASE WHEN ISNULL(ED.OtherTreatment, '')='' THEN ED.TreatmentName
	   WHEN ED.TreatmentName='Other DMT' AND ISNULL(ED.OtherTreatment, '')<>'' THEN 'Other DMT: ' + otherTreatment
	   ELSE ED.TreatmentName
	   END AS TreatmentNameFull,
	   ED.EligibleTreatment,
	   ED.TreatmentStatus,
	   ED.EligibilityHierarchy,
	   ED.StartDate,
	   ED.enteredStartDate,
	   ED.FirstDoseReceivedToday,
	   ED.DataCollectionType,
	   ED.RegistryEnrollmentStatus,
	   CASE WHEN ED.RegistryEnrollmentStatus = 'Eligible' AND ED.TreatmentStatus='prescribed at visit' THEN 10
	   WHEN ED.RegistryEnrollmentStatus = 'Eligible' AND ED.TreatmentStatus='continued' THEN 15
	   WHEN ED.RegistryEnrollmentStatus = 'Needs review' AND ED.TreatmentStatus='prescribed at visit' THEN 30
	   WHEN ED.RegistryEnrollmentStatus = 'Needs review' AND ED.TreatmentStatus='continued' THEN 35
	   WHEN ED.RegistryEnrollmentStatus = 'Eligible' AND ED.TreatmentStatus='past use only' THEN 40
	   WHEN ED.RegistryEnrollmentStatus = 'Needs review' AND ED.TreatmentStatus='past use only' THEN 45
	   WHEN ED.RegistryEnrollmentStatus = 'Not eligible' THEN 50
	   ELSE ''
	   END AS RESHierarchy,
	   VR.pay_1_1000_dec AS Eligible, 
	   VR.pay_1_1003_dec AS ExceptionGranted

FROM #EnrollDrugs ED
LEFT JOIN [RCC_MS700].[staging].[visitreimbursement] VR ON VR.subNum=ED.SubjectID AND VR.eventId=ED.eventId AND VR.eventOccurrence=ED.eventOccurrence

) ED

--SELECT * FROM #EnrollDOI WHERE VisitDate >= '2022-02-01' ORDER BY SiteID, SubjectID, RowNum
--SELECT * FROM #EnrollDOI WHERE SiteID=1440  ORDER BY SubjectID
--WHERE VisitDate >= '2022-02-01' ORDER BY SiteID, SubjectID, RowNum


TRUNCATE TABLE [Reporting].[MS700].[t_op_E&E];

INSERT INTO [Reporting].[MS700].[t_op_E&E]
(
	   SiteID,
	   SiteStatus,
	   SFSiteStatus,
	   SubjectID,
	   ProviderID,
	   PatientYOB,
	   AgeAtEnrollment,
	   VisitDate,
	   DateofDiagnosis,
	   TreatmentName,
	   OtherTreatment,
	   TreatmentNameFull,
	   EligibleTreatment,
	   TreatmentStatus,
	   StartDate,
	   enteredStartDate,
	   DataCollectionType,
	   RegistryEnrollmentStatus,
	   EligibilityReview,
	   VisitCompletion
)


SELECT EDOI.SiteID,
       EDOI.SiteStatus,
	   CASE WHEN SiteID=1440 THEN 'Approved / Active'
	   ELSE EDOI.SFSiteStatus
	   END AS SFSiteStatus,
	   EDOI.SubjectID,
	   EDOI.ProviderID,
	   EDOI.PatientYOB,
	   EDOI.AgeAtEnrollment,
	   EDOI.VisitDate,
	   EDOI.DateofDiagnosis,
	   EDOI.TreatmentName,
	   EDOI.OtherTreatment,
	   EDOI.TreatmentNameFull,
	   EDOI.EligibleTreatment,
	   EDOI.TreatmentStatus,
	   CASE WHEN EDOI.FirstDoseReceivedToday = 'Yes' THEN EDOI.VisitDate
	   ELSE EDOI.StartDate
	   END AS StartDate,
	   CASE WHEN EDOI.FirstDoseReceivedToday = 'Yes' THEN FORMAT(VisitDate, 'dd-MMM-yyyy')
	   ELSE EDOI.enteredStartDate
	   END AS enteredStartDate,
	   EDOI.DataCollectionType,
	   CASE WHEN EDOI.RegistryEnrollmentStatus='Needs review' AND ISNULL(EDOI.ReviewStatus, '') IN ('Under review (outcome TBD)', '') THEN 'Needs review'
	   WHEN EDOI.RegistryEnrollmentStatus='Needs review' AND ISNULL(EDOI.ReviewStatus, '') IN ('Eligible', 'Not eligible - Exception granted') THEN 'Eligible - Review decision'
	   WHEN EDOI.RegistryEnrollmentStatus='Needs review' AND ISNULL(EDOI.ReviewStatus, '')='Not eligible' THEN 'Not eligible'
	   WHEN EDOI.RegistryEnrollmentStatus='Not eligible' AND ISNULL(EDOI.ReviewStatus, '') IN ('Not eligible') THEN 'Not eligible - Confirmed'
	   WHEN EDOI.RegistryEnrollmentStatus='Eligible' AND ISNULL(EDOI.ReviewStatus, '') IN ('Eligible', '') THEN 'Eligible'
	   ELSE RegistryEnrollmentStatus
	   END AS RegistryEnrollmentStatus,
	   ISNULL(EDOI.ReviewStatus, 'NULL') AS EligbilityReview,
	   EDOI.VisitCompletion

FROM #EnrollDOI EDOI
WHERE RowNum=1



--SELECT * FROM [Reporting].[MS700].[t_op_E&E] WHERE subjectID IN (70021030276, 70021630275) ORDER BY SiteID, SubjectID, TreatmentName



END

GO
