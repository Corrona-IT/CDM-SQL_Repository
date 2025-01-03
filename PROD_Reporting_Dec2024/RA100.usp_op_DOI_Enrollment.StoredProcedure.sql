USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_DOI_Enrollment]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- ===========================================================================
-- Author:		Kaye Mowrey
-- Updated date: 3/24/2021 with updated Registry Enrollment Status
-- Description:	Procedure for Drugs at Enrollment with Hierarchy for DOI
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================


CREATE PROCEDURE [RA100].[usp_op_DOI_Enrollment] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*


CREATE TABLE [Reporting].[RA100].[t_op_DOI_Enrollment]
(
ROWNUM int NOT NULL,
VisitId nvarchar(20) NOT NULL,
[PatientId] nvarchar(20) NOT NULL,
SiteID int NOT NULL,
SiteStatus varchar(10) NULL,
SubjectID bigint NOT NULL,
VisitType nvarchar(30) NULL,
ProviderID varchar(10) NULL,
YearofBirth int NULL,
Age int NULL,
VisitDate date NULL,
OnsetYear int NULL,
JuvenileRA nvarchar(25) NULL,
YearsSinceOnset int NULL,
EligibilityVersion int NULL,
PageDescription nvarchar(100) NULL,
Page4FormStatus nvarchar(30) NULL,
Page5FormStatus nvarchar(30) NULL,
NoTreatment int NULL,
TreatmentName nvarchar(300) NULL,
ChangesToday nvarchar(50) NULL,
FirstUseDate nvarchar(20) NULL,
StartDate nvarchar(10) NULL,
MonthsSinceStartToVisit int NULL,
CurrentDose nvarchar(100) NULL,
CurrentFrequency nvarchar(150) NULL,
MostRecentDoseNotCurrentDose nvarchar(100) NULL,
MostRecentPastUseDate nvarchar(20) NULL,
DrugOfInterest nvarchar(300) NULL,
DrugHierarchy int NULL,
DOIInitiationStatus varchar(150) NULL, 
AdditionalDOI varchar(300) NULL,
SubscriberDOI varchar(10) NULL, 
TwelveMonthInitiationRule varchar(25) NULL, 
PriorJAKiUse varchar(10) NULL,
FirstTimeUse varchar(30) NULL,
RegistryEnrollmentStatus varchar(300) NULL

) ON [PRIMARY]
GO
*/



IF OBJECT_ID('tempdb..#B') IS NOT NULL BEGIN DROP TABLE #B END;

/**************Enrollment visits in the database that have an Enrollment date**********************/

SELECT E.VisitID
      ,E.SiteID
	  ,E.SiteStatus
	  ,E.PatientId
      ,E.SubjectID
	  ,E.VisitType
	  ,E.VisitProviderID AS ProviderID
	  ,E.[YOB] AS YearofBirth
	  ,DATEPART(YY, E.VisitDate) - E.[YOB] AS Age
	  ,E.VisitDate
	  ,E.OnsetYear
	  ,DATEPART(YY, E.VisitDate) - E.OnsetYear as YearsSinceOnset
	  ,(SELECT MIN(VisitDate) FROM [RA100].[t_op_SubjectVisits_wNoDates] E2 WHERE E2.VisitType='Follow-up' AND E2.SubjectID=E.SubjectID AND ISNULL(E2.VisitDate, '')<>'') AS FirstFUDate
	  ,CASE WHEN E.VisitDate <= '2013-02-25' THEN 99
	   WHEN E.VisitDate > '2013-02-25' AND E.VisitDate <= '2019-05-31' THEN 0
	   WHEN E.VisitDate >= '2019-06-01' THEN 1
	   WHEN ISNULL(E.VisitDate, '')='' THEN 99
	   ELSE NULL
	   END AS EligibilityVersion  

INTO #B
FROM [RA100].[t_op_SubjectVisits] E
WHERE E.VisitType='Enrollment'
--select * from #B where visitdate is null


/***Treatments listed at Enrollment***/

IF OBJECT_ID('tempdb..#G') IS NOT NULL BEGIN DROP TABLE #G END;

SELECT F.VisitId
	  ,F.[PatientId]
	  ,F.SiteID
	  ,A.SiteStatus
	  ,F.SubjectID
	  ,F.VisitType
	  ,F.VisitDate
	  ,F.PageDescription
	  ,F.Page4FormStatus
	  ,F.Page5FormStatus
	  ,F.NoTreatment
	  ,F.TreatmentName
	  ,F.ChangesToday
	  ,F.FirstUseDate
	  ,F.CalcStartDate
	  ,DATEDIFF(M, CalcStartDate, F.VisitDate) AS MonthsSinceStartToVisit 
	  ,F.CurrentDose
	  ,F.CurrentFrequency
	  ,F.MostRecentDoseNotCurrentDose
	  ,F.MostRecentPastUseDate

	  ,CASE WHEN F.Page4FormStatus LIKE 'No Data%' AND F.Page5FormStatus LIKE 'No Data%' THEN 'no data'
	   WHEN ISNULL(TreatmentName, '')='' AND ISNULL(F.NoTreatment, '')='' AND (Page4FormStatus LIKE '%Locked%' OR Page4FormStatus LIKE '%Complete%') AND (Page5FormStatus LIKE '%Locked%' OR Page5FormStatus LIKE '%Complete%') THEN 'no data'
	   WHEN ISNULL(F.TreatmentName, '')='' AND F.Page4FormStatus='No Data' AND F.Page5FormStatus<>'No Data' THEN 'pending'
	   WHEN ISNULL(F.TreatmentName, '')='' AND F.Page5FormStatus='No Data' AND F.Page4FormStatus<>'No Data' THEN 'pending'
	   WHEN F.Page4FormStatus<>'No Data' AND F.NoTreatment=1 AND F.TreatmentName='' THEN 'no treatment'
	   WHEN F.Page4FormStatus='Incomplete' AND ISNULL(F.NoTreatment, '')='' AND ISNULL(F.TreatmentName, '')='' THEN 'pending'
	   WHEN F.Page5FormStatus='Incomplete' AND ISNULL(F.NoTreatment, '')='' AND ISNULL(F.TreatmentName, '')='' THEN 'pending'
	   WHEN F.VisitDate >= '2022-01-01' AND F.VisitDate < '2022-03-18' AND F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND (ISNULL(F.CurrentDose, '')<>'' OR  F.ChangesToday='Start drug') AND F.TreatmentName<>'prednisone' THEN 'CDMARD'
	   WHEN F.VisitDate >= '2022-01-01' AND F.VisitDate < '2022-03-18' AND F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND (ISNULL(F.CurrentDose, '')<>'' OR  F.ChangesToday='Start drug') AND F.TreatmentName='prednisone' THEN F.TreatmentName
	   WHEN F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND (ISNULL(F.CurrentDose, '')<>'' OR  F.ChangesToday='Start drug') THEN 'cDMARD or steroids only'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND ISNULL(F.CurrentDose, '')='' AND F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Start drug' THEN 'no treatment'
	   WHEN ISNULL(F.ChangesToday, '')='Stop drug' AND ISNULL(F.CurrentDose,'')='' AND TreatmentName='rituximab (Rituxan)' AND (ISNULL(F.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F.MostRecentPastUseDate, '')<>'') THEN 'past biologic or JAKi use'
	   WHEN ISNULL(F.ChangesToday, '') IN ('Stop drug', '') AND ISNULL(F.CurrentDose,'')=''  AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND (ISNULL(F.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F.MostRecentPastUseDate, '')<>'') THEN 'past biologic or JAKi use'
	   WHEN F.ChangesToday='Stop drug' AND TreatmentName='Investigational Agent' THEN 'past Investigational agent use'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.FirstUseDate, '')<>'' AND  ISNULL(F.ChangesToday, '')='' AND ISNULL(F.CurrentDose,'')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.MostRecentPastUseDate, '')='' THEN F.TreatmentName
	   WHEN F.ChangesToday<>'Stop drug' AND TreatmentName='Investigational Agent' THEN F.TreatmentName
	   WHEN ISNULL(F.ChangesToday, '') IN ('Stop drug') AND ISNULL(F.CurrentDose,'')<>''  AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' THEN 'past biologic or JAKi use'
	   WHEN ISNULL(F.ChangesToday, '') IN ('Stop drug') AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 'past biologic or JAKi use'
	   WHEN ISNULL(F.TreatmentName, '')<>'' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.FirstUseDate, '')='' AND  ISNULL(F.ChangesToday, '')='' AND ISNULL(F.CurrentDose,'')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.MostRecentPastUseDate, '')='' THEN 'past use assumed'
	   ELSE F.TreatmentName 
	   END AS DrugOfInterest

	 ,CASE WHEN F.ChangesToday='Start drug' AND F.TreatmentName='baricitinib (Olumiant)' THEN 10
	  WHEN F.TreatmentName='Investigational agent' AND F.ChangesToday IN ('Start drug', 'Change dose') THEN 9
	  WHEN F.TreatmentName='Investigational agent' AND ISNULL(F.ChangesToday, '')='' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.MostRecentPastUseDate, '')='' THEN 9
	  WHEN F.TreatmentName='Investigational agent' AND ISNULL(F.ChangesToday, '')='' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.MostRecentPastUseDate, '')<>'' THEN 70
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday='Start drug' AND ISNULL(F.TreatmentName, '') NOT IN ('', 'baricitinib (Olumiant)') THEN 20
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday='Change dose' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.CurrentDose, '')<>'' THEN 30
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND F.TreatmentName<>'rituximab (Rituxan)' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.CurrentDose, '')<>'' THEN 40
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND F.TreatmentName='rituximab (Rituxan)' AND (ISNULL(F.FirstUseDate, '')<>'' OR ISNULL(F.MostRecentDoseNotCurrentDose, '')<>'') THEN 40
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND ISNULL(F.MostRecentPastUseDate, '')='' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.CurrentDose, '')<>'' THEN 50
	  WHEN ISNULL(F.TreatmentName, '')<>'' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.CurrentDose,'')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.MostRecentPastUseDate, '')='' AND F.Page4FormStatus='Incomplete' THEN 55
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND F.TreatmentName<>'rituximab (Rituxan)' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.CurrentDose, '')='' THEN 50
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.ChangesToday<>'Stop drug' AND ISNULL(F.FirstUseDate, '')<>'' AND ISNULL(F.MostRecentPastUseDate, '')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.CurrentDose, '')='' THEN 50
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.TreatmentName<>'rituximab (Rituxan)' AND F.ChangesToday<>'Stop drug' AND ISNULL(F.FirstUseDate, '')='' AND ISNULL(F.CurrentDose, '')<>'' THEN 60
	  WHEN ISNULL(F.ChangesToday, '')='Stop drug' AND ISNULL(F.CurrentDose,'')='' AND TreatmentName='rituximab (Rituxan)' AND (ISNULL(F.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F.MostRecentPastUseDate, '')<>'') THEN 80
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.ChangesToday, '') IN ('Stop drug', '') AND ISNULL(F.CurrentDose,'')=''  AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND (ISNULL(F.MostRecentDoseNotCurrentDose, '')<>'' OR ISNULL(F.MostRecentPastUseDate, '')<>'') THEN 80
	  WHEN ISNULL(F.ChangesToday, '') IN ('Stop drug') AND ISNULL(F.CurrentDose,'')<>''  AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' THEN 80
	  WHEN ISNULL(F.ChangesToday, '') IN ('Stop drug') AND TreatmentName<>'rituximab (Rituxan)' AND F.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 80
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(F.TreatmentName, '')<>'' AND ISNULL(F.ChangesToday, '')='' AND ISNULL(F.CurrentDose,'')='' AND ISNULL(F.MostRecentDoseNotCurrentDose, '')='' AND ISNULL(F.MostRecentPastUseDate, '')='' THEN 90
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.Page4FormStatus='Incomplete' AND ISNULL(F.NoTreatment, '')='' AND ISNULL(F.TreatmentName, '')=''  THEN 95
	  WHEN F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND ISNULL(F.TreatmentName, '')<>'prednisone' AND F.VisitDate >='2022-01-01' and F.VisitDate < '2022-03-18' AND (ISNULL(F.CurrentDose, '')<>'' OR F.ChangesToday='Start drug') AND F.ChangesToday<>'Stop drug' THEN 100
	  WHEN F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND ISNULL(F.TreatmentName, '')<>'prednisone' AND F.VisitDate >='2022-01-01' and F.VisitDate < '2022-03-18' AND F.ChangesToday='Stop drug' THEN 800
	  WHEN F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND F.Page5FormStatus<>'No Data' AND ISNULL(F.TreatmentName, '')<>'' AND ISNULL(F.TreatmentName, '')='prednisone' AND (ISNULL(F.CurrentDose, '')<>'' OR F.ChangesToday='Start drug') THEN 898
	  WHEN F.PageDescription='(Page 5)Provider Enrollment Questionnaire' AND ISNULL(F.TreatmentName, '')<>'' THEN 997
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND NoTreatment=1 THEN 998
	  ELSE 999
	  END AS DrugHierarchy
	 
	 ,CASE WHEN ChangesToday='Start drug' THEN 10
	  WHEN ChangesToday='Change dose' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 20
	  WHEN ISNULL(ChangesToday, '')='' AND ISNULL(FirstUseDate, '')<>'' THEN 20
	  WHEN ISNULL(ChangesToday, '')<>'Stop drug' AND ISNULL(CurrentDose, '')<>'' AND PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 20
	  WHEN ISNULL(ChangesToday, '')<>'Stop drug' AND TreatmentName='rituximab (Rituxan)' AND (ISNULL(FirstUseDate, '')<>'' OR ISNULL(MostRecentDoseNotCurrentDose, '')<>'') THEN 30
	  ELSE 50
	  END AS DrugInitiationHierarchy

	 ,CASE WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND F.TreatmentName='rituximab (Rituxan)' THEN 'ZZ_rituximab (Rituxan)'
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND UPPER(F.TreatmentName) LIKE '%TRUX%' THEN 'ZZ_Rituximab'
	  WHEN F.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND UPPER(F.TreatmentName) LIKE '%RUXI%%' THEN 'ZZ_Rituximab'
	  WHEN ISNULL(F.TreatmentName, '')='' THEN 'ZZ_no treatment'
	  ELSE F.TreatmentName
	  END AS TreatmentNameOrder

INTO #G
FROM [Reporting].[RA100].[t_op_Enrollment_Drugs] F 
LEFT JOIN [Reporting].[RA100].[v_op_SiteStatus] A ON A.SiteID=F.SiteID

--SELECT distinct visittype FROM #G WHERE VisitID IS NULL OR PatientId IS NULL OR SiteID IS NULL OR SubjectID IS NULL ORDER BY SiteID, SubjectID


/**Determine months since start (12 Month Rule) and prior JAKi use**/

IF OBJECT_ID('tempdb..#G2') IS NOT NULL BEGIN DROP TABLE #G2 END;

SELECT ROW_NUMBER() OVER(PARTITION BY SiteID, SubjectID ORDER BY SiteID, SubjectID, DrugHierarchy, DrugInitiationHierarchy, CalcStartDate DESC, TreatmentNameOrder) AS ROWNUM
      ,G.VisitId
	  ,G.[PatientId]
	  ,G.SiteID
	  ,G.SiteStatus
	  ,G.SubjectID
	  ,G.VisitType
	  ,G.VisitDate
	  ,G.PageDescription
	  ,G.Page4FormStatus
	  ,G.Page5FormStatus
	  ,G.NoTreatment
	  ,G.TreatmentName
	  ,G.ChangesToday
	  ,G.FirstUseDate
	  ,G.CalcStartDate

	  ,CASE WHEN G.DrugOfInterest='Investigational Agent' THEN NULL
	   WHEN  G.ChangesToday='Start drug' AND ISNULL(G.CalcStartDate, '')<>'' THEN FORMAT(G.CalcStartDate, 'MMM-yyyy')
	   WHEN G.ChangesToday='Start drug' AND ISNULL(G.CalcStartDate, '')='' THEN '-' --FORMAT(G.VisitDate, 'MMM-yyyy')
	   WHEN G.DrugOfInterest='CDMARD' AND ISNULL(G.FirstUseDate, '')<>'' THEN '-'
	   WHEN G.DrugHierarchy IN (80, 90, 888, 999) THEN '-'
	   WHEN G.DrugOfInterest='cDMARD or steroids only' THEN '-'
	   WHEN G.DrugOfInterest='Incomplete' THEN '-'
	    WHEN G.DrugOfInterest='no data' THEN '-'
	   WHEN G.DrugHierarchy=40 AND G.FirstUseDate='' THEN 'missing'
	   WHEN G.DrugHierarchy=40 AND G.FirstUseDate='1900/01' THEN 'missing'
	   WHEN ISNULL(G.FirstUseDate, '')<>'' THEN FORMAT(G.CalcStartDate, 'MMM-yyyy')
	   END AS StartDate

	  ,CASE WHEN G.ChangesToday='Start drug' AND ISNULL(G.CalcStartDate, '')<>'' THEN DATEDIFF(M, G.CalcStartDate, G.VisitDate)
	   WHEN G.ChangesToday='Start drug' AND ISNULL(G.CalcStartDate, '')='' THEN 0
	   ELSE G.MonthsSinceStartToVisit
	   END AS MonthsSinceStartToVisit

	  ,G.CurrentDose
	  ,G.CurrentFrequency
	  ,G.MostRecentDoseNotCurrentDose
	  ,G.MostRecentPastUseDate
	  ,G.DrugOfInterest
	  ,G.DrugHierarchy

	  ,CASE WHEN G.DrugOfInterest IN ('cDMARD or steroids only', 'past biologic or JAKi use', 'no treatment', 'no data', 'Incomplete') THEN '-'
	   WHEN G.DrugOfInterest='Investigational Agent' THEN ''
	   WHEN G.ChangesToday='Start drug' AND G.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 'prescribed at visit'
	   WHEN G.ChangesToday='Change dose' AND G.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 'continued'
	   WHEN DrugOfInterest=TreatmentName AND ISNULL(ChangesToday, '')='' AND ISNULL(FirstUseDate, '')<>'' THEN 'continued'
	   WHEN ISNULL(G.ChangesToday, '')<>'Stop drug' AND ISNULL(CurrentDose, '')<>'' AND G.PageDescription='(Page 4)Provider Enrollment Questionnaire' THEN 'continued'
	   WHEN ISNULL(G.ChangesToday, '')<>'Stop drug' AND TreatmentName='rituximab (Rituxan)' AND (ISNULL(G.FirstUseDate, '')<>'' OR ISNULL(G.MostRecentDoseNotCurrentDose, '')<>'') THEN 'continued'
	   WHEN DrugHierarchy IN (80, 90) THEN '-'
	   ELSE '-'
	   END AS DOIInitiationStatus

	  ,CASE WHEN G.DrugOfInterest='baricitinib (Olumiant)' THEN 'yes'
	   WHEN G.DrugOfInterest='Investigational Agent' THEN ''
	   WHEN ISNULL(G.DrugOfInterest, '')<>'baricitinib (Olumiant)' AND G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.DrugOfInterest=G.TreatmentName THEN 'no'
	   ELSE '-'
	   END AS SubscriberDOI

	  ,CASE WHEN G.DrugOfInterest IN ('cDMARD or steroids only', 'past biologic or JAKi use', 'past use assumed', 'no treatment', 'no data', 'Incomplete') THEN '-'
	   WHEN G.DrugOfInterest='Investigational Agent' THEN ''
	   WHEN G.ChangesToday='Start drug' THEN '-'
	   WHEN  G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND ISNULL(G.FirstUseDate, '')<>'' AND G.MonthsSinceStartToVisit<=13 THEN 'met'
	   WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.ChangesToday='Change dose' AND DrugOfInterest<>'no treatment' AND ISNULL(G.FirstUseDate, '')<>'' AND G.MonthsSinceStartToVisit>13 THEN 'not met' 
	   WHEN G.PageDescription='(Page 4)Provider Enrollment Questionnaire' AND G.ChangesToday='Change dose' AND G.DrugOfInterest<>'no treatment' AND ISNULL(G.FirstUseDate, '')='' THEN 'not met'
	   WHEN G.DrugHierarchy IN (30, 40, 50, 60) AND G.MonthsSinceStartToVisit<=13 THEN 'met'
	   WHEN G.DrugHierarchy IN (30, 40, 50, 60) AND G.MonthsSinceStartToVisit>13 THEN 'not met'
	   WHEN G.DrugHierarchy IN (30, 40, 50, 60) AND ISNULL(G.MonthsSinceStartToVisit, '')='' THEN 'not met'
	   WHEN G.DrugHierarchy IN (10, 19, 20, 80, 90, 100, 800, 888, 999) THEN '-'
	   ELSE ''
	   END AS TwelveMonthInitiationRule

	  ,CASE WHEN G.DrugOfInterest<>'baricitinib (Olumiant)' AND G.DrugOfInterest<>'Investigational Agent' THEN '-'
	   WHEN G.DrugOfInterest='Investigational Agent' THEN ''
	   WHEN G.DrugOfInterest='baricitinib (Olumiant)' AND EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND (G1.TreatmentName LIKE '%Xeljanz%' OR G1.TreatmentName LIKE '%baricitinib%' OR G1.TreatmentName LIKE '%upadacitinib%') AND G1.DrugOfInterest='past biologic or JAKi use') THEN 'yes'
	   WHEN G.DrugOfInterest='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%Xeljanz%' AND G1.DrugOfInterest='past biologic or JAKi use') THEN 'no'
	   WHEN G.DrugOfInterest='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%baricitinib (Olumiant)%' AND G1.DrugOfInterest='past biologic or JAKi use') THEN 'no'
	   WHEN G.DrugOfInterest='baricitinib (Olumiant)' AND NOT EXISTS(SELECT TreatmentName FROM #G G1 WHERE G1.VisitId=G.VisitId AND G1.TreatmentName LIKE '%upadacitinib%' AND G1.DrugOfInterest='past biologic or JAKi use') THEN 'no'
	   ELSE '-'
	   END AS PriorXeljanzUse

INTO #G2
FROM #G G 

--SELECT * FROM #G2 WHERE ROWNUM IS NULL ORDER BY SiteID, SubjectID, ROWNUM


/**Get subjects that had prior biologic or Jaki use**/

IF OBJECT_ID('tempdb..#PriorBioJakiUse') IS NOT NULL BEGIN DROP TABLE #PriorBioJakiUse END;

SELECT SubjectID,
VisitDate,
TreatmentName,
DrugOfInterest
INTO #PriorBioJakiUse
FROM #G
WHERE DrugOfInterest='past biologic or JAKi use'

--SELECT * FROM #PriorBioJakiUse



IF OBJECT_ID('tempdb..#G3') IS NOT NULL BEGIN DROP TABLE #G3 END;

/**Determine Juvenile RA, formatted start date**/

SELECT DISTINCT 
       G2.ROWNUM
      ,B.VisitId
	  ,B.[PatientId]
	  ,B.SiteID
	  ,G2.SiteStatus
	  ,B.SubjectID
	  ,B.VisitType
	  ,B.ProviderID
	  ,B.YearofBirth
	  ,B.Age
	  ,G2.VisitDate
	  ,B.OnsetYear
	  ,CASE WHEN ISNULL(B.YearofBirth, '')<>'' AND ISNULL(B.OnsetYear, '')<>'' AND B.OnsetYear-B.YearofBirth<18 THEN 'yes'
	   WHEN ISNULL(B.YearofBirth, '')<>'' AND ISNULL(B.OnsetYear, '')<>'' AND B.OnsetYear-B.YearofBirth>=18 THEN 'no'
	   WHEN ISNULL(B.YearofBirth, '')='' OR ISNULL(B.OnsetYear, '')='' THEN 'not calculable'
	   ELSE ''
	   END AS JuvenileRA
	  ,B.YearsSinceOnset
	  ,B.EligibilityVersion
	  ,G2.PageDescription
	  ,G2.Page4FormStatus
	  ,G2.Page5FormStatus
	  ,G2.NoTreatment
	  ,G2.TreatmentName
	  ,G2.ChangesToday
	  ,G2.FirstUseDate
	  ,G2.StartDate
	  ,G2.MonthsSinceStartToVisit
	  ,G2.CurrentDose
	  ,G2.CurrentFrequency
	  ,G2.MostRecentDoseNotCurrentDose
	  ,G2.MostRecentPastUseDate
	  ,G2.DrugOfInterest
	  ,G2.DrugHierarchy
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,TwelveMonthInitiationRule
	  ,PriorXeljanzUse

INTO #G3
FROM #B B 
LEFT JOIN #G2 G2 ON G2.VisitId=B.VisitID

--SELECT * FROM #G3 WHERE ROWNUM is null AND PageDescription='(Page 5)Provider Enrollment Questionnaire' ORDER BY VisitDate DESC, SubjectID


TRUNCATE TABLE [Reporting].[RA100].[t_op_DOI_Enrollment];

INSERT INTO [Reporting].[RA100].[t_op_DOI_Enrollment]
(
	ROWNUM,
	VisitId,
	PatientId,
	SiteID,
	SiteStatus,
	SubjectID,
	VisitType,
	ProviderID,
	YearofBirth,
	Age,
	VisitDate,
	OnsetYear,
	JuvenileRA,
	YearsSinceOnset,
	EligibilityVersion,
	PageDescription,
	Page4FormStatus,
	Page5FormStatus,
	NoTreatment,
	TreatmentName,
	ChangesToday,
	FirstUseDate,
	StartDate,
	MonthsSinceStartToVisit,
	CurrentDose,
	CurrentFrequency,
	MostRecentDoseNotCurrentDose,
	MostRecentPastUseDate,
	DrugOfInterest,
	DrugHierarchy,
	DOIInitiationStatus, 
	SubscriberDOI, 
	AdditionalDOI,
	TwelveMonthInitiationRule, 
	PriorJAKiUse,
	FirstTimeUse,
	RegistryEnrollmentStatus
)

/**Put all current treatments not listed under Eligible Medication into additional column, determine first time use, and determine eligibility status**/

SELECT DISTINCT 
       ROWNUM
      ,VisitId
	  ,[PatientId]
	  ,SiteID
	  ,SiteStatus
	  ,G3.SubjectID
	  ,VisitType
	  ,ProviderID
	  ,YearofBirth
	  ,Age
	  ,G3.VisitDate
	  ,OnsetYear
	  ,JuvenileRA
	  ,YearsSinceOnset
	  ,EligibilityVersion
	  ,PageDescription
	  ,Page4FormStatus
	  ,Page5FormStatus
	  ,NoTreatment
	  ,TreatmentName
	  ,ChangesToday
	  ,FirstUseDate
	  ,StartDate
	  ,MonthsSinceStartToVisit
	  ,CurrentDose
	  ,CurrentFrequency
	  ,MostRecentDoseNotCurrentDose
	  ,MostRecentPastUseDate
	  ,DrugOfInterest
	  ,DrugHierarchy
	  ,DOIInitiationStatus
	  ,SubscriberDOI
	  ,STUFF((
        SELECT ', '+ TreatmentName 
        FROM #G3 E
		WHERE E.VisitId=G3.VisitId
		AND DrugHierarchy IN (10, 20, 30, 40)
		AND ROWNUM<>1
        FOR XML PATH('')
        )
        ,1,1,'') AS AdditionalDOI
	  ,TwelveMonthInitiationRule
	  ,PriorXeljanzUse AS PriorJAKiUse
	 ,CASE WHEN G3.DrugOfInterest='Investigational agent' THEN ''
	  WHEN DrugOfInterest LIKE 'Other%' THEN 'undefined'
	  WHEN DrugOfInterest<>TreatmentName THEN '-'
	  WHEN (SELECT COUNT(TreatmentName) FROM #G3 G1 WHERE G1.VisitId=G3.VisitId AND G3.ROWNUM=1 AND G1.TreatmentName=G3.DrugOfInterest) > 1 THEN 'No'
	  WHEN (SELECT COUNT(TreatmentName) FROM #G3 G1 WHERE G1.VisitId=G3.VisitId AND G3.ROWNUM=1 AND G1.TreatmentName=G3.DrugOfInterest) = 1 THEN 'yes'
	  ELSE ''
	  END AS FirstTimeUse

	 ,CASE WHEN EligibilityVersion=99 THEN 'Eligible'
      WHEN EligibilityVersion=0 THEN 'Eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND G3.Age<18 THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND JuvenileRA='yes' THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest='no data' THEN 'Needs review'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest='incomplete' THEN 'Needs review'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('cDMARD or steroids only', 'past biologic or JAKi use', 'no treatment') AND YearsSinceOnset<=1 AND VisitDate < '2021-06-01' THEN 'Eligible - Disease activity'
	  WHEN EligibilityVersion NOT IN (99, 0) AND TreatmentName='prednisone' AND VisitDate >= '2022-01-01' THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('cDMARD') AND VisitDate >= '2022-01-01' AND VisitDate < '2022-03-18' AND ChangesToday<>'Stop drug' AND SubjectID NOT IN (SELECT SubjectID FROM #PriorBioJakiUse) THEN 'Eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('cDMARD') AND VisitDate >= '2022-01-01' AND VisitDate < '2022-03-18' AND SubjectID IN (SELECT SubjectID FROM #PriorBioJakiUse) THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('cDMARD') AND VisitDate >= '2022-01-01' AND VisitDate < '2022-03-18' AND ChangesToday='Stop drug' THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('past biologic or JAKi use', 'no treatment') AND VisitDate >= '2022-01-01' THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0)  AND DrugofInterest IN ('cDMARD or steroids only', 'past biologic or JAKi use', 'no treatment') AND YearsSinceOnset<=1 AND (VisitDate >= '2021-06-01' AND VisitDate < '2022-01-01') THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest='cDMARD or steroids only' AND YearsSinceOnset>1 THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest='no treatment' AND YearsSinceOnset>1 THEN 'Not Eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND TwelveMonthInitiationRule='not met' AND YearsSinceOnset>1 THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest LIKE 'Other%' THEN 'Needs review'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest=TreatmentName AND PageDescription='(Page 4)Provider Enrollment Questionnaire' AND Page4FormStatus='Incomplete' THEN 'Needs review'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest=TreatmentName AND (TwelveMonthInitiationRule='met' OR (StartDate='-' AND G3.DOIInitiationStatus='prescribed at visit')) THEN 'Eligible'
	  WHEN G3.EligibilityVersion NOT IN (99, 0) AND DrugOfInterest=TreatmentName AND TwelveMonthInitiationRule='not met' THEN 'Not eligible'
	  WHEN G3.EligibilityVersion NOT IN (99, 0) AND DrugOfInterest=TreatmentName AND (StartDate='-' AND DOIInitiationStatus<>'prescribed at visit') THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest=G3.TreatmentName AND (DATEPART(YY, VisitDate)-OnsetYear<=1) AND TwelveMonthInitiationRule<>'not met' THEN 'Eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND (DrugOfInterest=G3.TreatmentName AND DrugofInterest NOT IN ('cDMARD or steroids only', 'past biologic or JAKi use')) THEN 'Eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugofInterest IN ('cDMARD or steroids only', 'past biologic or JAKi use') THEN 'Not eligible'
	  WHEN EligibilityVersion NOT IN (99, 0) AND DrugOfInterest='Investigational Agent' AND ISNULL(CurrentDose, '')='' AND ISNULL(MostRecentDoseNotCurrentDose, '')='' THEN 'Needs review'
	  WHEN EligibilityVersion NOT IN (99, 0) AND (DrugOfInterest='incomplete' OR ISNULL(OnsetYear, '')='' OR ISNULL(StartDate, '')='') THEN 'Needs review'
	  ELSE '-'
	  END AS RegistryEnrollmentStatus

FROM #G3 G3


--SELECT * FROM [Reporting].[RA100].[t_op_DOI_Enrollment] WHERE ROWNUM=1 AND SubjectID=195010122 ORDER BY SiteID, SubjectID



END

GO
