USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_EER]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















-- ===========================================================================
-- Author:		Kaye Mowrey
-- Updated date: 2/8/2023
-- Description:	Procedure for Drugs at Enrollment with Hierarchy for DOI
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================


CREATE PROCEDURE [RA100].[usp_op_EER] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*
CREATE TABLE [RA100].[t_op_EER](
	[SiteID] [int] NOT NULL,
	[SiteStatus] [nvarchar](10) NULL,
	[SFSiteStatus] [nvarchar](60) NULL,
	[SubjectID] [bigint] NOT NULL,
	[ProviderID] [bigint] NULL,
	[YearofBirth] [int] NULL,
	[Age] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[OnsetYear] [int] NULL,
	[JuvenileRA] [nvarchar] (20) NULL,
	[EligibilityVersion] [int] NULL,
	[TreatmentName] [nvarchar](500) NULL,
	[EligibleMedication] [nvarchar](500) NULL,
	[TreatmentStatus] [nvarchar] (200) NULL,
	[StartDate] [nvarchar] (10) NULL,
	[AdditionalMedications] [nvarchar](750) NULL,
	[TwelveMonthInitiationRule] [nvarchar](50) NULL,
	[PriorJAKiUse] [nvarchar](20) NULL,
	[FirstTimeUse] [nvarchar](30) NULL,
	[RegistryEnrollmentStatus] [nvarchar](50) NULL
) ON [PRIMARY]
GO

*/

IF OBJECT_ID('tempdb..#ENROLL') IS NOT NULL BEGIN DROP TABLE #ENROLL END;

/**Enrollment visits in the database that have an Enrollment date**/

SELECT E.VisitID
      ,E.SiteID
	  ,CASE WHEN SiteID LIKE '99%' THEN 'Active'
	   ELSE E.SiteStatus
	   END AS SiteStatus
	  ,E.PatientId
      ,E.SubjectID
	  ,E.VisitProviderID AS ProviderID
	  ,E.[YOB] AS YearofBirth
	  ,DATEPART(YY, E.VisitDate) - E.[YOB] AS Age
	  ,E.VisitDate AS EnrollmentDate
	  ,E.OnsetYear
	  ,DATEPART(YY, E.VisitDate) - E.OnsetYear as YearsSinceOnset
	  ,CASE WHEN E.OnsetYear-E.[YOB]<16 THEN 'yes'
	   WHEN E.OnsetYear-E.[YOB]>=16 THEN 'no'
	   ELSE 'not calculable'
	   END AS JuvenileRA
	  ,(SELECT MIN(VisitDate) FROM [RA100].[t_op_SubjectVisits_wNoDates] E2 WHERE E2.VisitType='Follow-up' AND E2.SubjectID=E.SubjectID AND ISNULL(E2.VisitDate, '')<>'') AS FirstFUDate
	  ,CASE WHEN E.VisitDate <= '2013-02-25' THEN 99
	   WHEN E.VisitDate BETWEEN '2013-02-25' AND '2019-05-31' THEN 0
	   WHEN E.VisitDate >= '2019-06-01' THEN 1
	   ELSE NULL
	   END AS EligibilityVersion  

INTO #ENROLL
FROM [RA100].[t_op_SubjectVisits] E
WHERE E.VisitType='Enrollment'
AND VisitDate IS NOT NULL

--SELECT * FROM #ENROLL ORDER BY SiteID, SubjectID


IF OBJECT_ID('tempdb..#BiologicNaive') IS NOT NULL BEGIN DROP TABLE #BiologicNaive END;
/**Biologic Naive at Enrollment**/

SELECT VisitID, SiteID, SubjectID, NoTreatment, TreatmentName 
INTO #BiologicNaive
FROM [RA100].[t_op_Enrollment_Drugs] ED
WHERE PageDescription='(Page 4)Provider Enrollment Questionnaire'
AND ISNULL(NoTreatment, '')=1


--SELECT * FROM #BiologicNaive WHERE SubjectID=178130789

/***Treatments listed at Enrollment***/

IF OBJECT_ID('tempdb..#G') IS NOT NULL BEGIN DROP TABLE #G END;

SELECT E2.VisitId
	  ,E2.[PatientId]
	  ,E2.SiteID
	  ,E2.SiteStatus
	  ,E2.SubjectID
	  ,E2.ProviderID
	  ,E2.EnrollmentDate
	  ,E2.YearofBirth
	  ,E2.Age
	  ,E2.OnsetYear
	  ,E2.YearsSinceOnset
	  ,E2.JuvenileRA
	  ,E2.EligibilityVersion
	  ,E2.PageDescription
	  ,E2.Page4FormStatus
	  ,E2.Page5FormStatus
	  ,E2.NoTreatment
	  ,E2.TreatmentName
	  ,E2.Treatment
	  ,E2.EligibleTreatment
	  ,E2.ChangesToday
	  ,E2.TreatmentStatus
	  ,E2.FirstUseDate
	  ,E2.CalcStartDate
	  ,E2.MonthsSinceStartToVisit 
	  ,E2.CurrentDose
	  ,E2.CurrentFrequency
	  ,E2.MostRecentDoseNotCurrentDose
	  ,E2.MostRecentPastUseDate
	  ,E2.EligibleMedication       
	   ,TreatmentNameOrder
INTO #G
FROM
(
SELECT E1.VisitId
	  ,E1.[PatientId]
	  ,E1.SiteID
	  ,E1.SiteStatus
	  ,E1.SubjectID
	  ,E1.ProviderID
	  ,E1.EnrollmentDate
	  ,E1.YearofBirth
	  ,E1.Age
	  ,E1.OnsetYear
	  ,E1.YearsSinceOnset
	  ,E1.JuvenileRA
	  ,E1.EligibilityVersion
	  ,E1.PageDescription
	  ,E1.Page4FormStatus
	  ,E1.Page5FormStatus
	  ,E1.NoTreatment
	  ,E1.TreatmentName
	  ,E1.Treatment
	  ,CASE WHEN E1.EnrollmentDate < '2019-06-01' THEN 'Eligible'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND E1.TreatmentStatus='past use only' THEN 'Not eligible'
	   WHEN E1.EnrollmentDate > '2020-03-01' AND E1.TreatmentName LIKE '%infliximab biosimilar (other)%' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2020-03-01' AND E1.TreatmentName LIKE '%infliximab biosimilar (other)%' AND TreatmentStatus='continued' AND MonthsSinceStartToVisit<13 THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2020-03-01' AND E1.TreatmentName LIKE '%infliximab biosimilar (other)%' AND ISNULL(TreatmentStatus, '') IN ('past use only', 'stopped at visit') THEN 'Not eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RITUXI%' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RITUXI%' AND TreatmentStatus='continued' AND MonthsSinceStartToVisit<13 THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RITUXI%' AND ISNULL(TreatmentStatus, '') IN ('past use only', 'stopped at visit') THEN 'Not eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RUXIENCE%' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RUXIENCE%' AND TreatmentStatus='continued' AND MonthsSinceStartToVisit<13 THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: RUXIENCE%' AND ISNULL(TreatmentStatus, '') IN ('past use only', 'stopped at visit') THEN 'Not eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUXIMA%' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUXIMA%' AND TreatmentStatus='continued' AND MonthsSinceStartToVisit<13 THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUXIMA%' AND ISNULL(TreatmentStatus, '') IN ('past use only', 'stopped at visit') THEN 'Not eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUZIMA%' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUZIMA%' AND TreatmentStatus='continued' AND MonthsSinceStartToVisit<13 THEN 'Eligible'
	   WHEN E1.EnrollmentDate > '2022-03-17' AND UPPER(E1.TreatmentName) LIKE '%OTHER: TRUZIMA%' AND ISNULL(TreatmentStatus, '') IN ('past use only', 'stopped at visit') THEN 'Not eligible'
       WHEN E1.EnrollmentDate >= '2019-06-01' AND ISNULL(E1.TreatmentName, '')='' AND E1.NoTreatment IS NULL THEN 'Needs review'
	   WHEN E1.EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND E1.TreatmentName IN ('hydroxychloroquinine (Plaquenil)', 'leflunomide (Arava)', 'methotrexate (MTX)', 'sulfasalazine (Azulfadine)') AND E1.SubjectID IN (SELECT SubjectID FROM #BiologicNaive) THEN 'Eligible'
	   WHEN E1.EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND E1.TreatmentName IN ('hydroxychloroquinine (Plaquenil)', 'leflunomide (Arava)', 'methotrexate (MTX)', 'sulfasalazine (Azulfadine)') AND E1.SubjectID NOT IN (SELECT SubjectID FROM #BiologicNaive) THEN 'Not eligible'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND EXISTS (SELECT TreatmentName FROM [RA100].[t_op_DrugReference] DR WHERE DR.TreatmentName=E1.Treatment AND E1.EnrollmentDate BETWEEN DR.StartDate AND DR.EndDate AND DR.NeedsReview='No') THEN 'Eligible'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND UPPER(E1.TreatmentName) LIKE 'OTHER%' THEN 'Needs review'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND TreatmentName LIKE '%(other)%' THEN 'Needs review'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND EXISTS (SELECT TreatmentName FROM [RA100].[t_op_DrugReference] DR WHERE DR.TreatmentName=E1.Treatment AND E1.EnrollmentDate BETWEEN DR.StartDate AND DR.EndDate AND DR.NeedsReview='Yes') THEN 'Needs review'
	   WHEN E1.EnrollmentDate >= '2019-06-01' AND NOT EXISTS (SELECT TreatmentName FROM [RA100].[t_op_DrugReference] DR WHERE DR.TreatmentName=E1.Treatment AND E1.EnrollmentDate BETWEEN DR.StartDate AND DR.EndDate) THEN 'Not eligible' 
	   END AS EligibleTreatment

	  ,E1.ChangesToday
	  ,E1.TreatmentStatus
	  ,E1.FirstUseDate
	  ,E1.CalcStartDate
	  ,E1.MonthsSinceStartToVisit 
	  ,E1.CurrentDose
	  ,E1.CurrentFrequency
	  ,E1.MostRecentDoseNotCurrentDose
	  ,E1.MostRecentPastUseDate

	  ,CASE WHEN PageDescription='(Page 4)Provider Enrollment Questionnaire'AND E1.Page4FormStatus='No Data' AND E1.NoTreatment IS NULL THEN 'no data'
	   WHEN PageDescription='(Page 5)Provider Enrollment Questionnaire' AND E1.Page5FormStatus='No Data' AND E1.NoTreatment IS NULL THEN 'no data'
	   WHEN ISNULL(E1.TreatmentName, '')='' AND ISNULL(E1.NoTreatment, '')='' AND (Page4FormStatus LIKE '%Locked%' OR Page4FormStatus LIKE '%Complete%') AND (Page5FormStatus LIKE '%Locked%' OR Page5FormStatus LIKE '%Complete%') THEN 'no treatment'
	   WHEN ISNULL(E1.TreatmentName, '')='' AND PageDescription='(Page 5)Provider Enrollment Questionnaire' AND Page5FormStatus='Incomplete' AND ISNULL(E1.NoTreatment, '')='' THEN 'pending'
	   WHEN ISNULL(E1.TreatmentName, '')='' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND E1.Page4FormStatus='Incomplete' AND ISNULL(E1.NoTreatment, '')='' THEN 'pending'
	   WHEN E1.NoTreatment=1 AND E1.TreatmentName='' THEN 'no treatment'
	   WHEN E1.EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND E1.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND ISNULL(E1.TreatmentName, '')<>'' AND E1.TreatmentStatus IN ('prescribed at visit', 'continued') AND E1.TreatmentName<>'prednisone' THEN 'CDMARD'
	   WHEN E1.EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND E1.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND E1.TreatmentName='prednisone' THEN E1.TreatmentName
	   WHEN E1.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND ISNULL(E1.TreatmentName, '')<>'' THEN 'cDMARD or steroids only'
	   WHEN TreatmentStatus='stopped at visit' AND ISNULL(E1.CurrentDose,'')='' AND E1.TreatmentName='rituximab (Rituxan)' AND (ISNULL(E1.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(E1.MostRecentPastUseDate, '')<>'') THEN 'past biologic or JAKi use'
	   WHEN ISNULL(E1.ChangesToday, '') IN ('Stop drug', '') AND ISNULL(E1.CurrentDose,'')='' AND E1.TreatmentName<>'rituximab (Rituxan)' AND E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND (ISNULL(E1.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(E1.MostRecentPastUseDate, '')<>'') THEN 'past biologic or JAKi use'
	   WHEN TreatmentStatus='stopped at visit' AND E1.TreatmentName='Investigational Agent' THEN 'past Investigational agent use'
	   WHEN ISNULL(E1.TreatmentName, '')<>'' AND E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(E1.FirstUseDate, '')<>'' AND  ISNULL(E1.ChangesToday, '')='' AND ISNULL(E1.CurrentDose,'')='' AND ISNULL(E1.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(E1.MostRecentPastUseDate, '')='' THEN E1.TreatmentName
	   WHEN E1.ChangesToday<>'Stop drug' AND E1.TreatmentName='Investigational Agent' THEN E1.TreatmentName
	   WHEN TreatmentStatus='stopped at visit' AND ISNULL(E1.CurrentDose,'')<>''  AND E1.TreatmentName<>'rituximab (Rituxan)' AND E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(E1.MostRecentDoseNotCurrentDose, '')='' THEN 'past biologic or JAKi use'
	   WHEN ISNULL(E1.ChangesToday, '') IN ('Stop drug') AND E1.TreatmentName<>'rituximab (Rituxan)' AND E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 'past biologic or JAKi use'
	   WHEN ISNULL(E1.TreatmentName, '')<>'' AND E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(E1.FirstUseDate, '')='' AND  ISNULL(E1.ChangesToday, '')='' AND ISNULL(E1.CurrentDose,'')='' AND ISNULL(E1.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(E1.MostRecentPastUseDate, '')='' THEN E1.TreatmentName
	   WHEN PageDescription='(Page 4)Provider Enrollment Questionnaire' AND NoTreatment IS NULL AND Page4FormStatus='No Data' THEN 'no data'
	   WHEN PageDescription='(Page 5)Provider Enrollment Questionnaire' AND NoTreatment IS NULL AND Page5FormStatus='No Data' THEN 'no data'
	   ELSE E1.TreatmentName 
	   END AS EligibleMedication

	 ,CASE WHEN E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND E1.TreatmentName='rituximab (Rituxan)' THEN 'ZZ_rituximab (Rituxan)'
	  WHEN E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND UPPER(E1.TreatmentName) LIKE '%TRUX%' THEN 'ZZ_Rituximab'
	  WHEN E1.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND UPPER(E1.TreatmentName) LIKE '%RUXI%%' THEN 'ZZ_Rituximab'
	  WHEN ISNULL(E1.TreatmentName, '')='' THEN 'ZZ_no treatment'
	  ELSE E1.TreatmentName
	  END AS TreatmentNameOrder

FROM
(
SELECT E.VisitId
	  ,E.[PatientId]
	  ,E.SiteID
	  ,A.SiteStatus
	  ,E.SubjectID
	  ,E.ProviderID
	  ,E.EnrollmentDate
	  ,E.YearofBirth
	  ,E.Age
	  ,E.OnsetYear
	  ,E.YearsSinceOnset
	  ,E.JuvenileRA
	  ,E.EligibilityVersion
	  ,F.PageDescription
	  ,F.Page4FormStatus
	  ,F.Page5FormStatus
	  ,F.NoTreatment
	  ,F.TreatmentName
	  ,F.Treatment
	  ,F.ChangesToday

	  ,CASE WHEN F.ChangesToday='Start drug' THEN 'prescribed at visit'
	   WHEN ISNULL(F.ChangesToday, '')='' AND F.CalcStartDate=E.EnrollmentDate THEN 'prescribed at visit'
	   WHEN F.ChangesToday='Stop drug' THEN 'stopped at visit'
	   WHEN F.ChangesToday='Change dose' THEN 'continued'
	   WHEN ISNULL(F.ChangesToday, '')='' AND (ISNULL(F.CurrentDose, '')<>'' AND ISNULL(MostRecentDoseNotCurrentDose, '')='') THEN 'continued'
	   WHEN ISNULL(F.ChangesToday, '')='' AND (ISNULL(F.MostRecentPastUseDate, '')<>'' OR ISNULL(MostRecentDoseNotCurrentDose, '')<>'') AND F.TreatmentName<>'rituximab (Rituxan)' THEN 'past use only'
	   WHEN ISNULL(F.ChangesToday, '')='' AND ISNULL(F.MostRecentPastUseDate, '')<>'' AND F.TreatmentName='rituximab (Rituxan)' THEN 'continued'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND MostRecentPastUseDate<>'' THEN 'past use only'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND MostRecentPastUseDate='' THEN 'continued'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.FirstUseDate, '')='' AND  ISNULL(F.ChangesToday, '')='' AND ISNULL(F.CurrentDose,'')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.MostRecentPastUseDate, '')='' THEN 'past use assumed'
	   WHEN ISNULL(TreatmentName, '')='' THEN '-'
	   ELSE ''
	   END AS TreatmentStatus

	  ,F.FirstUseDate
	  ,F.CalcStartDate
	  ,DATEDIFF(M, CalcStartDate, F.VisitDate) AS MonthsSinceStartToVisit 
	  ,F.CurrentDose
	  ,F.CurrentFrequency
	  ,F.MostRecentDoseNotCurrentDose
	  ,F.MostRecentPastUseDate

FROM #ENROLL E
LEFT JOIN [Reporting].[RA100].[t_op_Enrollment_Drugs] F ON F.VisitId=E.VisitID and F.SiteID=E.SiteID AND F.VisitDate=E.EnrollmentDate
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] A ON A.SiteID=F.SiteID


) E1
) E2  

--SELECT * FROM #G1 WHERE SubjectID=100497083




IF OBJECT_ID('tempdb..#G1') IS NOT NULL BEGIN DROP TABLE #G1 END;

SELECT G.VisitId
	  ,G.[PatientId]
	  ,G.SiteID
	  ,G.SiteStatus
	  ,G.SubjectID
	  ,G.ProviderID
	  ,G.EnrollmentDate
	  ,G.YearofBirth
	  ,G.Age
	  ,G.OnsetYear
	  ,G.YearsSinceOnset
	  ,G.JuvenileRA
	  ,G.EligibilityVersion
	  ,G.PageDescription
	  ,G.Page4FormStatus
	  ,G.Page5FormStatus
	  ,G.NoTreatment
	  ,G.TreatmentName
	  ,G.Treatment
	  ,G.EligibleTreatment
	  ,G.ChangesToday
	  ,G.TreatmentStatus
	  ,G.FirstUseDate
	  ,G.CalcStartDate
	  ,G.MonthsSinceStartToVisit 
	  ,G.CurrentDose
	  ,G.CurrentFrequency
	  ,G.MostRecentDoseNotCurrentDose
	  ,G.MostRecentPastUseDate
	  ,G.EligibleMedication 
	  ,G.TreatmentNameOrder

	  ,CASE WHEN G.TreatmentName='baricitinib (Olumiant)' AND G.TreatmentStatus IN ('prescribed at visit', 'continued') THEN 10
	  WHEN G.NoTreatment=1 THEN 85
	  WHEN G.EligibleTreatment='Not eligible' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND TreatmentStatus IN ('prescribed at visit', 'continued') THEN 76
	  WHEN G.EligibleTreatment='Not eligible' AND PageDescription='(Page 5)Provider Enrollment Questionnaire' AND TreatmentStatus IN ('prescribed at visit', 'continued') THEN 77
	  WHEN G.EligibleTreatment='Not eligible' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND TreatmentStatus IN ('past use only') THEN 78
	  WHEN G.EligibleTreatment='Not eligible' AND PageDescription='(Page 5)Provider Enrollment Questionnaire' AND TreatmentStatus IN ('past use only') THEN 79
	  WHEN G.TreatmentName='Investigational agent' THEN 70
	  WHEN TreatmentStatus='stopped at visit' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 78
	  WHEN TreatmentStatus='stopped at visit' AND PageDescription='(Page 5)Provider Enrollment Questionnaire' THEN 79
	  WHEN EligibleMedication='past biologic or JAKi use' THEN 80
	  WHEN G.TreatmentName='' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(G.Treatment, '')='' AND Page4FormStatus='Incomplete' THEN 68
	  WHEN G.TreatmentName='' AND PageDescription='(Page 5)Provider Enrollment Questionnaire' AND Page5FormStatus='Incomplete' THEN 69
	  WHEN G.TreatmentName='rituximab (Rituxan)' AND G.EligibleTreatment='Eligible' AND (ISNULL(G.FirstUseDate, '')<>'' OR ISNULL(G.MostRecentDoseNotCurrentDose, '')<>'') THEN 30
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus='prescribed at visit' AND G.ChangesToday='Start drug' THEN 20
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus='prescribed at visit' AND ISNULL(ChangesToday, '')='' AND ISNULL(G.CurrentDose, '')<>'' AND ISNULL(G.MostRecentDoseNotCurrentDose, '')='' THEN 21
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus='prescribed at visit' AND ISNULL(ChangesToday, '')='' AND ISNULL(G.CurrentDose, '')='' AND ISNULL(G.MostRecentDoseNotCurrentDose, '')='' THEN 22
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus='prescribed at visit' AND ISNULL(ChangesToday, '')='' AND ISNULL(G.CurrentDose, '')='' AND ISNULL(G.MostRecentDoseNotCurrentDose, '')<>'' THEN 62
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus='continued' THEN 30
	  WHEN G.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND G.EligibleTreatment='Eligible' AND G.TreatmentStatus IN ('prescribed at visit', 'continued') THEN 36
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(G.Treatment , '')<>'' AND G.EligibleTreatment='Needs review' THEN 35
	  when G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(G.Treatment , '')='' AND G.Page4FormStatus<>'Incomplete' AND G.EligibleTreatment='Needs review' THEN 85
	  WHEN G.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND ISNULL(G.Treatment, '')='' AND Page5FormStatus<>'Incomplete' THEN 90
	  WHEN G.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND ISNULL(G.Treatment, '')<>'' AND
	  G.EligibleTreatment='Needs review' THEN 55
	  WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND TreatmentStatus='stopped at visit' THEN 60
	  WHEN G.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND TreatmentStatus='stopped at visit' THEN 62
	  ELSE 90
	  END AS DrugHierarchy

     ,CASE WHEN G.TreatmentStatus='prescribed at visit' AND G.ChangesToday='Start drug' AND G.EligibleTreatment='Eligible' THEN 10
	 WHEN G.TreatmentStatus='prescribed at visit' AND G.EligibleTreatment='Eligible' THEN 15
	  WHEN G.TreatmentStatus='continued' AND G.EligibleTreatment='Eligible' THEN 20
	  WHEN G.TreatmentStatus='prescribed at visit' AND G.EligibleTreatment='Needs review' THEN 30 
	  WHEN G.TreatmentStatus='continued' AND G.EligibleTreatment='Needs review' THEN 40 
	  WHEN G.TreatmentStatus='Needs review' THEN 45
	  WHEN G.TreatmentStatus='stopped at visit' THEN 50
	  WHEN G.EligibleMedication='past use assumed' THEN 60
	  WHEN G.TreatmentStatus='-' AND G.EligibleMedication<>G.TreatmentName AND EligibleMedication<>'no treatment' THEN 60
	  WHEN G.EligibleMedication='Investigational Agent' THEN 70
	  ELSE 80
	  END AS DrugInitiationHierarchy

INTO #G1
FROM #G G

--SELECT * FROM #G1 WHERE SubjectID=100497083
 



/**Determine months since start (12 Month Rule) and prior JAKi use**/

IF OBJECT_ID('tempdb..#G2') IS NOT NULL BEGIN DROP TABLE #G2 END;

SELECT ROW_NUMBER() OVER(PARTITION BY VisitId, SiteID, SubjectID ORDER BY SiteID, SubjectID, DrugHierarchy, DrugInitiationHierarchy, CalcStartDate DESC, TreatmentNameOrder) AS ROWNUM
      ,G.VisitId
	  ,G.[PatientId]
	  ,G.SiteID
	  ,G.SiteStatus
	  ,G.SubjectID
	  ,G.ProviderID
	  ,G.EnrollmentDate
	  ,G.EligibilityVersion
	  ,G.YearofBirth
	  ,G.Age
	  ,G.OnsetYear
	  ,G.YearsSinceOnset
	  ,G.JuvenileRA
	  ,G.PageDescription
	  ,G.Page4FormStatus
	  ,G.Page5FormStatus
	  ,G.NoTreatment
	  ,CASE WHEN EligibleMedication='no treatment' THEN 'no treatment'  
	   WHEN ISNULL(TreatmentName, '')='' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND Page4FormStatus<>'Incomplete' AND NoTreatment IS NULL THEN 'no treatment'
	   ELSE G.TreatmentName
	   END AS TreatmentName
	  ,G.Treatment
	  ,G.EligibleTreatment
	  ,G.ChangesToday
	  ,G.TreatmentStatus
	  ,G.FirstUseDate
	  ,G.CalcStartDate

	  ,CASE WHEN G.EligibleMedication='Investigational Agent' THEN NULL
	   WHEN G.TreatmentStatus='prescribed at visit' AND ISNULL(G.CalcStartDate, '')<>'' THEN FORMAT(G.CalcStartDate, 'MMM-yyyy')
	   WHEN G.TreatmentStatus='prescribed at visit' AND ISNULL(G.CalcStartDate, '')='' THEN '-' --FORMAT(G.VisitDate, 'MMM-yyyy')
	   WHEN G.EligibleMedication='CDMARD' AND ISNULL(G.FirstUseDate, '')<>'' THEN '-'
	   WHEN G.DrugHierarchy IN (80, 90, 888, 999) THEN '-'
	   WHEN G.EligibleMedication='cDMARD or steroids only' THEN '-'
	   WHEN G.EligibleMedication='Incomplete' THEN '-'
	    WHEN G.EligibleMedication='no data' THEN '-'
	   WHEN G.TreatmentStatus='continued' AND G.FirstUseDate='' THEN 'missing'
	   WHEN G.TreatmentStatus='continued' AND G.FirstUseDate='1900/01' THEN 'missing'
	   WHEN ISNULL(G.FirstUseDate, '')<>'' THEN FORMAT(G.CalcStartDate, 'MMM-yyyy')
	   END AS StartDate
	  ,DATEDIFF(M, CalcStartDate, G.EnrollmentDate) AS MonthsSinceStartToVisit
	  ,G.CurrentDose
	  ,G.CurrentFrequency
	  ,G.MostRecentDoseNotCurrentDose
	  ,G.MostRecentPastUseDate
	  ,G.EligibleMedication
	  ,G.DrugHierarchy
	  ,G.DrugInitiationHierarchy
	  ,CASE WHEN G.EligibleMedication='baricitinib (Olumiant)' THEN 'yes'
	   WHEN G.EligibleMedication='Investigational Agent' THEN ''
	   WHEN ISNULL(G.EligibleMedication, '')<>'baricitinib (Olumiant)' AND G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.EligibleMedication=G.TreatmentName THEN 'no'
	   ELSE '-'
	   END AS SubscriberDOI
	  ,CASE WHEN G.EligibleTreatment='Eligible' AND G.EligibleMedication='cDMARD or steroids only' AND G.TreatmentStatus='continued' AND G.MonthsSinceStartToVisit<=13 THEN 'met'
	   WHEN G.EligibleMedication IN ('cDMARD or steroids only', 'past biologic or JAKi use', 'past use assumed', 'no treatment', 'no data', 'Incomplete') AND EligibleTreatment='Not eligible' THEN '-'
	   WHEN G.EligibleMedication='Investigational Agent' THEN '-'
	   WHEN G.TreatmentStatus='prescribed at visit' THEN '-'
	   WHEN G.TreatmentStatus='continued' AND G.MonthsSinceStartToVisit<=13 THEN 'met'
	   WHEN G.TreatmentStatus='continued' AND G.MonthsSinceStartToVisit>13 THEN 'not met' 
	   WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.ChangesToday='' AND G.FirstUseDate='' THEN 'not met'
	   WHEN G.EligibleMedication<>'no treatment' AND ISNULL(G.FirstUseDate, '')='' AND CurrentDose<>'' THEN 'not met'
	   ELSE ''
	   END AS TwelveMonthInitiationRule

	  ,CASE WHEN G.EligibleMedication NOT IN ('baricitinib (Olumiant)','Investigational Agent') THEN '-'
	   WHEN G.EligibleMedication='Investigational Agent' THEN ''
	   WHEN G.EligibleMedication='baricitinib (Olumiant)' AND EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND (G1.TreatmentName LIKE '%Xeljanz%' OR G1.TreatmentName LIKE '%baricitinib%' OR G1.TreatmentName LIKE '%upadacitinib%') AND G1.EligibleMedication='past biologic or JAKi use') THEN 'yes'
	   WHEN G.EligibleMedication='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%Xeljanz%' AND G1.EligibleMedication='past biologic or JAKi use') THEN 'no'
	   WHEN G.EligibleMedication='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%baricitinib (Olumiant)%' AND G1.EligibleMedication='past biologic or JAKi use') THEN 'no'
	   WHEN G.EligibleMedication='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%upadacitinib%' AND G1.EligibleMedication='past biologic or JAKi use') THEN 'no'
	   ELSE '-'
	   END AS PriorXeljanzUse

INTO #G2
FROM #G1 G 

--SELECT * FROM #G2 WHERE SubjectID IN (100497083) ORDER BY SubjectID, ROWNUM


/**Get subjects that had prior biologic or Jaki use**/

IF OBJECT_ID('tempdb..#PriorBioJakiUse') IS NOT NULL BEGIN DROP TABLE #PriorBioJakiUse END;

SELECT SubjectID,
EnrollmentDate,
TreatmentName,
EligibleMedication,
TreatmentStatus
INTO #PriorBioJakiUse
FROM #G
WHERE TreatmentStatus IN ('stopped at visit', 'past use only') AND PageDescription='(Page 4)Provider Enrollment Questionnaire'


--SELECT * FROM #PriorBioJakiUse 


/**Put all current treatments not listed under Eligible Medication into additional column, determine first time use, and determine eligibility status**/

IF OBJECT_ID('tempdb..#EERTreatment') IS NOT NULL BEGIN DROP TABLE #EERTreatment END;

SELECT DISTINCT 
       ROWNUM
      ,VisitId
	  ,PatientId
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,ProviderID
	  ,YearofBirth
	  ,Age
	  ,EnrollmentDate
	  ,OnsetYear
	  ,JuvenileRA
	  ,YearsSinceOnset
	  ,EligibilityVersion
	  ,PageDescription
	  ,Page4FormStatus
	  ,Page5FormStatus
	  ,NoTreatment
	  ,Treatment
	  ,TreatmentName
	  ,EligibleTreatment
	  ,ChangesToday
	  ,TreatmentStatus
	  ,FirstUseDate
	  ,StartDate
	  ,MonthsSinceStartToVisit
	  ,CurrentDose
	  ,CurrentFrequency
	  ,MostRecentDoseNotCurrentDose
	  ,MostRecentPastUseDate
	  ,EligibleMedication
	  ,DrugHierarchy
	  ,SubscriberDOI
	  ,STUFF((
        SELECT ', '+ TreatmentName 
        FROM #G2 E
		WHERE E.VisitId=G2.VisitId
		AND EligibleMedication IN ('prescribed at visit', 'continued')
		AND ROWNUM<>1
        FOR XML PATH('')
        )
        ,1,1,'') AS AdditionalDOI

	  ,TwelveMonthInitiationRule
	  ,PriorXeljanzUse AS PriorJAKiUse
	 ,CASE WHEN G2.EligibleMedication='Investigational agent' THEN ''
	  WHEN EligibleMedication LIKE 'Other%' THEN 'undefined'
	  WHEN EligibleMedication<>TreatmentName THEN '-'
	  WHEN (SELECT COUNT(TreatmentName) FROM #G2 G1 WHERE G1.VisitId=G2.VisitId AND G2.ROWNUM=1 AND G1.TreatmentName=G2.EligibleMedication) > 1 THEN 'No'
	  WHEN (SELECT COUNT(TreatmentName) FROM #G2 G1 WHERE G1.VisitId=G2.VisitId AND G2.ROWNUM=1 AND G1.TreatmentName=G2.EligibleMedication) = 1 THEN 'yes'
	  ELSE ''
	  END AS FirstTimeUse

	 ,CASE WHEN EligibilityVersion IN (99, 0) THEN 'Eligible'
	  WHEN EnrollmentDate < '2019-06-01' THEN 'Eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND (Age<18 OR JuvenileRA='yes') THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleMedication IN ('no data', 'incomplete', 'Needs review') THEN 'Needs review'
	  WHEN EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND EligibleMedication IN ('CDMARD') AND EligibleTreatment='Eligible' THEN 'Eligible'
	  WHEN EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND EligibleMedication IN ('CDMARD') AND EligibleTreatment='Eligible' THEN 'Needs review'
	  WHEN EnrollmentDate BETWEEN '2022-01-01' AND '2022-03-17' AND EligibleMedication IN ('CDMARD') AND EligibleTreatment='Eligible' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleMedication IN ('CDMARD') AND SubjectID IN (SELECT SubjectID FROM #BiologicNaive) THEN 'Not eligible'
	 WHEN EnrollmentDate BETWEEN '2019-06-01'AND '2021-05-31' AND (EligibleMedication IN ('cDMARD or steroids only', 'no treatment', 'past biologic or JAKi use') OR PageDescription='(Page 5)Provider Enrollment Questionnaire') AND YearsSinceOnset<=1 THEN 'Eligible - Disease activity'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Eligible' AND TreatmentStatus='prescribed at visit' THEN 'Eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND UPPER(TreatmentName) LIKE 'OTHER%' AND TreatmentStatus='prescribed at visit' THEN 'Needs review'
	  WHEN EnrollmentDate >= '2019-06-01' AND UPPER(TreatmentName) LIKE 'OTHER%' AND TreatmentStatus='continued' AND TwelveMonthInitiationRule='met' THEN 'Needs review'
	  WHEN EnrollmentDate >= '2019-06-01' AND UPPER(TreatmentName) LIKE 'OTHER%' AND TreatmentStatus='continued' AND TwelveMonthInitiationRule='not met' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' and EligibleMedication='cDMARD or steroids only' AND EligibleTreatment='Eligible' THEN 'Eligible'
	  WHEN EnrollmentDate >= '2019-06-01' and EligibleMedication='cDMARD or steroids only' AND EligibleTreatment='Not eligible' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Eligible' AND TreatmentStatus='continued' AND TwelveMonthInitiationRule='not met' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Eligible' AND TreatmentStatus='continued' AND TwelveMonthInitiationRule='met' THEN 'Eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Not eligible' AND Page4FormStatus='Incomplete' THEN 'Needs review'
	  WHEN EnrollmentDate >= '2019-06-01' AND (EligibleMedication='incomplete' OR ISNULL(Age, '')='' OR ISNULL(OnsetYear, '')='') THEN 'Needs review'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Not eligible' AND Page4FormStatus<>'Incomplete' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleMedication='no treatment' THEN 'Not eligible'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleTreatment='Needs review' THEN 'Needs review'
	  WHEN EnrollmentDate >= '2019-06-01' AND EligibleMedication IN ('cDMARD or steroids only', 'past biologic or JAKi use') THEN 'Not eligible'
	  ELSE '-'
	  END AS RegistryEnrollmentStatus

INTO #EERTreatment
FROM #G2 G2
WHERE ROWNUM=1

--SELECT * FROM #EERTreatment WHERE EligibleMedication='cDMARD or steroids only' AND EnrollmentDate BETWEEN '2022-12-01' AND '2023-02-12'

--SELECT * FROM [Reporting].[RA100].[t_op_EER] WHERE SubjectID = 100497083

TRUNCATE TABLE [Reporting].[RA100].[t_op_EER];

INSERT INTO [Reporting].[RA100].[t_op_EER]
(
EER.SiteID,
EER.SiteStatus,
SFSiteStatus,
SubjectID,
ProviderID,
YearofBirth,
Age,
EnrollmentDate,
OnsetYear,
JuvenileRA,
EligibilityVersion,
TreatmentName,
EligibleMedication,
TreatmentStatus, 
StartDate,
AdditionalMedications,
TwelveMonthInitiationRule, 
PriorJAKiUse,
FirstTimeUse,
RegistryEnrollmentStatus
)


SELECT DISTINCT
EER.SiteID,
EER.SiteStatus,
CASE WHEN EER.SiteID LIKE '99%' THEN 'Approved / Active'
ELSE RS.[currentStatus] 
END AS SFSiteStatus,
EER.SubjectID,
ProviderID,
YearofBirth,
Age,
EER.EnrollmentDate,
OnsetYear,
JuvenileRA,
EligibilityVersion,
TreatmentName,
EligibleMedication,
TreatmentStatus,
StartDate,
AdditionalDOI AS AdditionalMedications,
TwelveMonthInitiationRule, 
PriorJAKiUse,
FirstTimeUse,
RegistryEnrollmentStatus

FROM #EERTreatment EER
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.SiteNumber=EER.SiteID AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'



END

GO
