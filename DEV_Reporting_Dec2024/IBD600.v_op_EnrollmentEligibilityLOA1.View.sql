USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_EnrollmentEligibilityLOA1]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





---THIS VIEW IS NOW EnrollmentEligiblityLOA1 IN PRODUCTION





CREATE VIEW [IBD600].[v_op_EnrollmentEligibilityLOA1] AS

WITH ENR AS
(
SELECT VS.vID
      ,VS.SITENUM AS SiteID
	  ,CASE WHEN S.ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
	  ,VS.SUBNUM AS SubjectID
	  ,CAST(VS.VISITDATE AS date) AS EnrollmentDate
	  ,VS.VISNAME AS VisitType
	  ,VS.AGE AS AgeAtVisit
	  ,DEM.BIRTHDATE AS YOB
	  ,DX.MD_COD AS ProviderID
	  ,DX.DX_IBD_DEC AS Diagnosis
	  ,REIMB.INELIGIBLE_DEC AS SubjectEligibilityMonitorReview
	  ,ISNULL(REIMB.INELIGIBLE_RSN_DEC, '') + ISNULL(';  ' + REIMB.INELIGIBLE_RSN_OTH , '') AS IneligibleReasonMonitorReview
	  ,REIMB.INELIGIBLE_EXCEPTION_DEC AS ExceptionGrantedforEligibility
	  ,REIMB.INELIGIBLE_EXCEPTION_RSN AS EligibilityExceptionReason
	  ,REIMB.VISIT_PAID AS VisitPaid
	  ,REIMB.PII_HB AS PIIRequirementMet
	  ,REIMB.INELIGIBLE
	  ,REIMB.INELIGIBLE_EXCEPTION
	   
FROM [MERGE_IBD].[staging].[VISIT] VS
LEFT JOIN [MERGE_IBD].[dbo].[DAT_SITES] S ON S.SITENUM=VS.SITENUM
LEFT JOIN [MERGE_IBD].[staging].[MD_DX] DX ON VS.VID=DX.VID AND VS.SUBNUM=DX.SUBNUM
LEFT JOIN [MERGE_IBD].[staging].[REIMB] REIMB ON VS.VID=REIMB.VID AND VS.SUBNUM=REIMB.SUBNUM
LEFT JOIN [MERGE_IBD].[staging].[PT_DEMOG] DEM ON DEM.VID=VS.VID AND DEM.SUBNUM=VS.SUBNUM
WHERE VS.VISNAME='Enrollment'
--AND VS.SUBNUM IN (60011030009, 60121440144, 60151490103, 60642630016)
)

,MODSTARTSDT AS
(
SELECT D.vID
      ,D.SiteID
	  ,D.SiteStatus
	  ,D.SubjectID
      ,D.VisitID
	  ,D.VisitType
	  ,D.EnrollmentDate
	  ,D.EligibilityVersion
	  ,D.StartDateString
	  ,D.StartYear
	  ,D.DRUG_CLASS123_USE_EN
  	  ,D.DrugClass
	  ,D.PastUse
	  ,D.CurrentUse
	  ,D.ChangesToday
	  ,D.NoPriorUse
	  ,D.BiologicName
	  ,D.DrugName
	  ,D.EligibleDrug
	  ,D.StartDate
	  ,D.FirstDoseAdminTodayVisit
	  ,CASE WHEN D.StartDate='UNK-UNK-UNK' THEN NULL
	   WHEN D.ChangesToday='Start' AND D.FirstDoseAdminTodayVisit='Yes' THEN D.EnrollmentDate
	   ELSE (D.StartYear+'-'+D.StartMonth+'-'+D.StartDay) 
	   END AS ModPriorCurrStartDate
	  ,CASE WHEN D.VISIT_COMPLETE='X' THEN 'Complete'
	   WHEN ISNULL(D.VISIT_COMPLETE, '')='' THEN 'Incomplete'
	   ELSE 'Incomplete'
	   END AS VisitCompletionStatus
	  ,CASE WHEN D.ChangesToday='Start' AND D.EligibleDrug='Yes' THEN 1
	   WHEN D.ChangesToday='Modify' AND D.EligibleDrug='Yes' THEN 2
	   WHEN D.ChangesToday='Current Use' AND D.EligibleDrug='Yes' THEN 3
	   ELSE 99
	   END AS UseStatusOrder

FROM (
SELECT V.vID
      ,V.SITENUM AS SiteID
	  ,CASE WHEN S.ACTIVE='t' THEN 'Active'
       ELSE 'Inactive'
       END AS SiteStatus
	  ,V.SUBNUM AS SubjectID
      ,V.VISITID AS VisitID
	  ,V.VISNAME AS VisitType
	  ,V.VISITDATE AS EnrollmentDate
	  ,CASE WHEN V.VISITDATE<'2019-01-01' THEN 0
	   WHEN V.VISITDATE>='2019-01-01' THEN 1
	   ELSE ''
	   END AS EligibilityVersion
	  ,DRUG.GX__ST_DT AS StartDateString
	  ,MDS.DRUG_CLASS123_USE_EN
  	  ,DRUG.NOT_DRUG_CLASS123_DEC AS DrugClass
	  ,DRUG.P__G__10_USE_DEC AS BiologicName
	  ,COALESCE(P__G__10_USE_DEC, P__G__20_USE_DEC, P__G__30_USE_DEC) AS DrugName
	  ,DRUG.GX__USE_NONE AS NoPriorUse
	  ,DRUG.GX__USE_PAST AS PastUse
	  ,DRUG.GX__USE_CUR AS CurrentUse
	  ,CASE WHEN GX__RX_TDY_DEC='N/A - no longer in use' THEN 'Past Use'
	   WHEN GX__RX_TDY_DEC='No changes (current use)' THEN 'Current Use'
	   ELSE GX__RX_TDY_DEC
	   END AS ChangesToday
	  ,DRUG.GX__DOSE_RCVD_TDY_DEC AS FirstDoseAdminTodayVisit
	  ,DRUG.GX__ST_DT AS StartDate
	  ,CASE WHEN ISNULL(P__G__10_USE, '') NOT IN ('', 'oth_bio', 'inv_agent') 
	   AND GX__RX_TDY_DEC IN ('No changes (current use)', 'Start')
	   THEN 'Yes'
	   WHEN ISNULL(P__G__10_USE, '') NOT IN ('', 'oth_bio', 'inv_agent') 
	   AND GX__RX_TDY_DEC='Modify'
	   THEN 'Yes'
	   ELSE 'No'
	   END AS EligibleDrug
	  ,CASE WHEN LEFT(RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)),	
	   CHARINDEX('-', RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)))-1)='UNK' THEN '06'
	   ELSE LEFT(RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)), 
	   CHARINDEX('-', RIGHT(DRUG.GX__ST_DT, LEN(DRUG.GX__ST_DT)-CHARINDEX('-', DRUG.GX__ST_DT)))-1)
	   END AS StartMonth
	  ,RIGHT(DRUG.GX__ST_DT, 2) AS DayofMo2
	  ,CASE	WHEN ISNUMERIC(RIGHT(DRUG.GX__ST_DT, 1))=1 THEN RIGHT(DRUG.GX__ST_DT, 2)
	   WHEN ISNULL(DRUG.GX__ST_DT, '')='' THEN NULL
	   WHEN RIGHT(DRUG.GX__ST_DT, 3)='UNK' AND DATEPART(D, V.VISITDATE)<10 THEN REPLICATE('0',1)+CAST(DATEPART(D, V.VISITDATE) AS nvarchar)
	   WHEN RIGHT(DRUG.GX__ST_DT, 3)='UNK' AND DATEPART(D, V.VISITDATE)>28 THEN '28'
	   ELSE CAST(DATEPART(D, V.VISITDATE) AS nvarchar) 
	   END AS StartDay
	  ,SUBSTRING(DRUG.GX__ST_DT, 1, 4) AS StartYear
	  ,VC.VISIT_COMPLETE

FROM [MERGE_IBD].[staging].[VISIT] V
LEFT JOIN [MERGE_IBD].[dbo].[DAT_SITES] S ON S.SITENUM=V.SITENUM
LEFT JOIN MERGE_IBD.staging.DRUG DRUG ON V.vID=DRUG.vID
LEFT JOIN [MERGE_IBD].[staging].[VISIT_COMP] VC ON VC.vID=V.vID 
LEFT JOIN [MERGE_IBD].[staging].[MD_SUMMARY] MDS ON MDS.vID=V.vID
WHERE V.VISNAME='Enrollment' 

) D

) 

,ELIG AS
(
SELECT  ROW_NUMBER() OVER (PARTITION BY MSD.vID, MSD.SiteID, MSD.SubjectID ORDER BY MSD.vID, MSD.SiteID, MSD.SubjectID, ENR.EnrollmentDate, UseStatusOrder, DrugClass, BiologicName, DrugName, ModPriorCurrStartDate) AS ROWNUM
      ,MSD.vID
      ,MSD.VISITID as VisitID
	  ,MSD.VisitType
      ,MSD.SiteID
	  ,ENR.SiteStatus
	  ,MSD.SubjectID
	  ,ENR.ProviderID
	  ,CAST(ENR.EnrollmentDate AS date) AS EnrollmentDate
	  ,MSD.EligibilityVersion
	  ,CASE WHEN MSD.EligibilityVersion=1 AND MSD.DRUG_CLASS123_USE_EN IS NULL THEN 'Needs review'
	   WHEN MSD.EligibilityVersion=1 AND MSD.DRUG_CLASS123_USE_EN=0 AND EligibleDrug='No' THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=0 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '')<>'' THEN 'Eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday='Start' AND NoPriorUse='X' THEN 'Eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday='Start' AND PastUse='X' THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday='Start' AND CurrentUse='X' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))<=13 THEN 'Eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday='Start' AND CurrentUse='X' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))>13 THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday='Start' AND ISNULL(PastUse, '')='' and  ISNULL(NoPriorUse, '')='' AND ISNULL(CurrentUse, '')='' THEN 'Not Eligible'
	   WHEN MSD.EligibilityVersion=1 and ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')=''AND (ISNULL(MSD.StartDate, '')='' OR MSD.StartDate='UNK-UNK-UNK') THEN ''
	   WHEN MSD.EligibilityVersion=1 and ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')='' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))<=13 THEN 'Eligible'
	  WHEN MSD.EligibilityVersion=1 and ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') 
			AND ISNULL(PastUse, '')='' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))>13 THEN 'Not eligible'
	  WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ChangesToday IN ('Current Use', 'Modify') AND ISNULL(PastUse, '')='X' THEN 'Not eligible'
	  WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND EligibleDrug='Yes' AND ISNULL(ChangesToday, '') IN ('', 'Past Use') THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=1 AND ENR.AgeAtVisit>=18 AND ISNULL(ENR.Diagnosis, '') NOT IN ('','Indeterminate colitis')
	        AND MSD.DrugClass<>'Biologic/biosimilar or small molecule' THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=1 AND EligibleDrug='No' OR ENR.AgeAtVisit<18 OR ISNULL(ENR.Diagnosis, '') IN ('','Indeterminate colitis') THEN 'Not eligible'
	   WHEN MSD.EligibilityVersion=0 AND ENR.AgeAtVisit<18 OR ISNULL(ENR.Diagnosis, '')='' THEN 'Not eligible'
	   ELSE ''
	   END AS EligibilityStatus
	  ,ENR.YOB
	  ,ENR.AgeAtVisit
	  ,ENR.Diagnosis
	  ,CASE WHEN MSD.ChangesToday IN ('Current Use', 'Modify') AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND (ISNULL(MSD.StartDate, '')<>'' AND  MSD.StartDate<>'UNK-UNK-UNK') THEN 'Prevalent User'
	   WHEN MSD.ChangesToday IN ('Current Use', 'Modify') AND  MSD.DrugClass='Biologic/biosimilar or small molecule' AND (ISNULL(MSD.StartDate, '')='' OR MSD.StartDate='UNK-UNK-UNK') THEN 'Error'
	   WHEN MSD.ChangesToday='Start' AND MSD.DrugClass='Biologic/biosimilar or small molecule' AND MSD.CurrentUse IS NULL THEN 'Incident User'
	   WHEN MSD.DrugClass='Biologic/biosimilar or small molecule' AND MSD.ChangesToday='Start' AND MSD.CurrentUse='X' THEN 'Error'
	   WHEN MSD.DRUG_CLASS123_USE_EN IS NULL THEN ''
	   ELSE 'n/a'
	   END AS BiologicStatus
  	  ,MSD.DRUG_CLASS123_USE_EN
	  ,MSD.DrugClass
  	  ,CASE WHEN MSD.ChangesToday IN ('Current Use', 'Modify', 'Start') AND MSD.DrugClass='Biologic/biosimilar or small molecule' THEN MSD.BiologicName
	   ELSE ''
	   END AS BiologicName
	  ,DrugName
	  ,MSD.EligibleDrug
	  ,MSD.PastUse
	  ,MSD.CurrentUse
	  ,MSD.ChangesToday
	  ,NoPriorUse
	  ,MSD.FirstDoseAdminTodayVisit
	  ,MSD.StartDate
	  ,CASE WHEN ISNULL(BiologicName, '')<>'' AND ChangesToday='Start' AND MSD.FirstDoseAdminTodayVisit='Yes' THEN ENR.EnrollmentDate
	   ELSE (CONVERT(datetime, MSD.ModPriorCurrStartDate,101)) 
	   END AS ModPriorCurrStartDate
	  ,CASE WHEN ISNULL(BiologicName, '')<>'' AND ChangesToday='Start' AND MSD.FirstDoseAdminTodayVisit='Yes' THEN 0
	   ELSE DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date)) 
	   END AS MonthsSinceDrugStart
	  ,CASE WHEN ISNULL(BiologicName, '')<>'' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))<=13 THEN 'Yes'
	   WHEN ISNULL(BiologicName, '')<>'' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date))>13 THEN 'No'
	   WHEN ISNULL(BiologicName, '')<>'' AND ChangesToday='Start' AND DATEDIFF(M, CAST(MSD.ModPriorCurrStartDate AS date), CAST(ENR.EnrollmentDate AS date)) IS NULL THEN 'Yes'
	   ELSE ''
	   END AS BiologicInitiatedWithin12MoEnroll
	  ,VisitCompletionStatus
	  ,UseStatusOrder
	  ,ENR.SubjectEligibilityMonitorReview
	  ,ENR.IneligibleReasonMonitorReview
	  ,ENR.ExceptionGrantedforEligibility
	  ,ENR.INELIGIBLE
	  ,ENR.INELIGIBLE_EXCEPTION
	   
FROM MODSTARTSDT MSD
LEFT JOIN ENR ON ENR.VID=MSD.VID
WHERE MSD.VisitType='Enrollment'
)


,E1 AS (
SELECT ROWNUM
      ,vID
	  ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitType
	  ,DrugClass
	  ,DrugName
	  ,ChangesToday
	  ,EligibleDrug
	  ,PastUse
	  ,CurrentUse
	  ,NoPriorUse
	  ,FirstDoseAdminTodayVisit
	  ,ModPriorCurrStartDate AS StartDate
	  ,MonthsSinceDrugStart
	  
FROM ELIG
WHERE ROWNUM<>1
AND (ChangesToday='Past Use' OR PastUse='X')
--ORDER BY SiteID, SubjectID, ROWNUM

)

SELECT *
FROM
(
SELECT E2.ROWNUM
      ,E2.vID
      ,E2.VisitID
	  ,E2.VisitType
	  ,E2.AgeAtVisit
	  ,E2.DRUG_CLASS123_USE_EN
	  ,E2.INELIGIBLE
	  ,E2.INELIGIBLE_EXCEPTION
	  ,E2.DrugClass
	  ,E2.DrugName
	  ,E2.ChangesToday
	  ,E2.EligibleDrug
	  ,E2.PastUse
	  ,E2.CurrentUse
	  ,E2.NoPriorUse
	  ,E2.FirstDoseAdminTodayVisit
	  ,E2.StartDate AS StringStartDate
	  ,E2.ModPriorCurrStartDate AS StartDate
	  ,E2.MonthsSinceDrugStart
	  ,E2.SiteID
	  ,E2.SiteStatus
	  ,E2.SubjectID
	  ,E2.ProviderID
	  ,E2.EnrollmentDate
	  ,E2.EligibilityVersion

	  ,CASE WHEN E2.EligibilityStatus='Not Eligible' AND E2.SubjectEligibilityMonitorReview='Yes' THEN 'Eligible - by Override'
	   WHEN E2.EligibilityStatus='Not Eligible' AND E2.SubjectEligibilityMonitorReview='No' AND E2.ExceptionGrantedforEligibility='Yes' THEN 'Eligible - by Override'
	   WHEN E2.EligibilityStatus='Not Eligible' AND E2.SubjectEligibilityMonitorReview='No' AND ISNULL(E2.ExceptionGrantedforEligibility, '') IN ('','No') THEN 'Not eligible - Confirmed'
	   ELSE E2.EligibilityStatus
	   END AS EligibilityStatus
	  ,CASE WHEN E2.SubjectEligibilityMonitorReview<>'No' AND E2.SubjectEligibilityMonitorReview='Yes' THEN 'Eligible'
	   WHEN E2.SubjectEligibilityMonitorReview='Under review (outcome TBD)' THEN E2.SubjectEligibilityMonitorReview
	   WHEN E2.SubjectEligibilityMonitorReview='No' AND E2.ExceptionGrantedforEligibility='Yes' THEN 'Not eligible - Exception granted'
	   WHEN E2.EligibilityStatus='Not Eligible' AND E2.SubjectEligibilityMonitorReview='No' AND E2.ExceptionGrantedforEligibility='No' THEN 'Not eligible' 
	   WHEN E2.SubjectEligibilityMonitorReview='No' AND ISNULL(E2.ExceptionGrantedforEligibility, '') IN ('', 'No') THEN 'Not eligible'
	   ELSE ''
	   END AS ReviewOutcome
      ,E2.YOB
	  ,E2.Diagnosis
	  ,E2.BiologicStatus
	  ,CASE WHEN EXISTS (SELECT E1.DrugName FROM E1 WHERE E1.vID=E2.vID AND E1.DrugName=E2.BiologicName) THEN 'Review Needed'
	   WHEN EXISTS (SELECT E1.DrugName FROM E1 WHERE E1.vID=E2.vID AND E1.DrugName LIKE '%adalimumab%' AND E2.BiologicName LIKE '%adalimumab%') THEN 'Review Needed'
	   WHEN EXISTS (SELECT E1.DrugName FROM E1 WHERE E1.vID=E2.vID AND E1.DrugName LIKE '%infliximab%' AND E2.BiologicName LIKE '%infliximab%') THEN 'Review Needed'
	   ELSE ''
	   END AS PastUseReview
	  ,E2.BiologicName
	  ,CASE WHEN E2.BiologicStatus IN ('Error', 'n/a') THEN ''
	   ELSE E2.BiologicInitiatedWithin12MoEnroll
	   END AS BiologicInitiatedWithin12MoEnroll
	  ,CASE WHEN E2.ChangesToday IN ('Current Use', 'Modify') AND E2.PastUse IS NULL AND E2.BiologicStatus IN ('Prevalent User') THEN 'Yes'
       WHEN E2.ChangesToday='Start' AND E2.NoPriorUse='X' AND E2.BiologicStatus IN ('Incident User') THEN 'Yes'
	   WHEN E2.BiologicStatus IN ('Error', 'n/a') THEN ''
	   ELSE 'No'
	   END AS FirstTimeUseCurrentBiologic
	   ,E2.VisitCompletionStatus

FROM ELIG E2
WHERE E2.ROWNUM=1 
) A



--SELECT * FROM [MERGE_IBD].[staging].[REIMB] WHERE SUBNUM IN (60362030040, 60793210018, 60362030041, 60021040097, 60773150004)

GO
