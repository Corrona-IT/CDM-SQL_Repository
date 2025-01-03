USE [Reporting]
GO
/****** Object:  View [AD550].[v_op_PatientDemographics]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [AD550].[v_op_PatientDemographics] AS


With PatDemoView As
(
Select vl.SiteID
	  ,vl.SubjectID
	  ,vl.SiteStatus
	  ,vd.eventName As VisitType
	  ,sf.VISIT_MD_COD AS ProviderId
	  ,sf.visit_dt AS EnrollmentDate
	  ,CASE WHEN vd.SEX = 1 THEN 'Female'
	   WHEN vd.SEX = 0 THEN 'Male'
	   END AS Gender 
	  ,vd.BIRTHDATE As BirthYear
	  ,CASE WHEN ISNUMERIC(vd.BIRTHDATE) = 1 THEN (DATEPART(YEAR, sf.visit_dt) - CAST(vd.BIRTHDATE AS int)) 
	  WHEN ISNUMERIC(vd.BIRTHDATE) = 0 THEN CAST(NULL AS INT)
	  END AS AgeEnrollment 
	  ,CASE WHEN vd.ethnicity_hispanic = 1 THEN 'Hispanic or Latino'
	   WHEN vd.ethnicity_hispanic = 0 THEN 'Not Hispanic or Latino'
	   END AS Ethnicity
	  ,sf.ageonset AS AgeOnset
	  --,CASE WHEN sf.DX_IBD_DEC = 'Other indeterminate colitis' THEN sf.DX_IBD_SP 
	  --ELSE sf.DX_IBD_DEC END AS Diagnosis
	  --,sf.YR_DX_IBD AS diagnosisYear
	  

From [Reporting].AD550.v_op_subjects vl 
left join [RCC_AD550].staging.subject vd on vl.SubjectID = vd.SUBNUM and vd.eventName = 'Enrollment Visit' 
left join [RCC_AD550].staging.provider sf on vl.SubjectID = sf.SUBNUM and sf.eventName = 'Enrollment Visit'
--left join [RCC_AA560].staging.providerform pf on vl.subjectId = pf.subNum and vl.eventId = pf.eventId
Where vd.eventName= 'Enrollment Visit'
and vl.[status]='Enrolled'
)
,race AS
(
Select subNum
,CASE WHEN RACE_NATIVE_AM = 1 THEN 'Native American'
ELSE ''
END AS Race
From [RCC_AD550].staging.subject
Where RACE_NATIVE_AM = 1
Union

Select subNum
,CASE WHEN RACE_ASIAN = 1 THEN 'Asian'
ELSE ''
END AS Race
From [RCC_AD550].staging.subject
Where RACE_ASIAN = 1
Union

Select subNum
,CASE WHEN RACE_BLACK = 1 THEN 'Black'
ELSE ''
END AS Race
From [RCC_AD550].staging.subject
Where RACE_BLACK = 1
Union

Select subNum
,CASE WHEN RACE_PACIFIC = 1 THEN 'Pacific'
ELSE ''
END AS Race
From [RCC_AD550].staging.subject
Where RACE_PACIFIC = 1
Union

Select subNum
,CASE WHEN RACE_WHITE = 1 THEN 'White'
ELSE ''
END AS Race
From [RCC_AD550].staging.subject
Where RACE_WHITE = 1
Union

Select subNum
, RACE_OTH_TXT AS Race
From [RCC_AD550].staging.subject
Where RACE_OTHER = 1

)

Select 
	   SiteID
	  ,SubjectID
	  ,SiteStatus
	  ,VisitType
	  ,ProviderId
	  ,EnrollmentDate
	  ,Gender
	  ,BirthYear
	  ,AgeEnrollment 
	  ,Ethnicity
	  ,AgeOnset
	  ,STUFF((
        SELECT DISTINCT ', ' + race
        FROM race RS
        WHERE RS.subNum=PatDemoView.SubjectID
        FOR XML PATH('')
        )
        ,1,1,'') AS Race
From PatDemoView
--Order by SiteID, SubjectID
--Order commands are commented out when running the entire code to make the view




GO
