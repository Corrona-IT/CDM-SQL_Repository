USE [Reporting]
GO
/****** Object:  View [IBD600].[v_op_PatientDemographics]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [IBD600].[v_op_PatientDemographics] AS
--Select * From [RCC_AA560].staging.providerform
With PatDemoView As
(
Select vl.SiteID
	  ,vl.SubjectID
	  ,vl.SiteStatus
	  ,vl.visitType As VisitType
	  ,sf.MD_COD AS ProviderId
	  ,vl.visitDate AS EnrollmentDate
	  ,vd.SEX_DEC AS Gender 
	  ,vd.BIRTHDATE As BirthYear
	  ,CASE WHEN ISNUMERIC(vd.BIRTHDATE) = 1 THEN (DATEPART(YEAR, vl.VISITDATE) - CAST(vd.BIRTHDATE AS int)) 
	  WHEN ISNUMERIC(vd.BIRTHDATE) = 0 THEN CAST(NULL AS INT)
	  END AS AgeEnrollment 
	  ,vd.RACE_HISPANIC_DEC AS Ethnicity
	  --,sf.DX_IBD_DEC AS Diagnosis
	  ,CASE WHEN sf.DX_IBD_DEC = 'Other indeterminate colitis' THEN sf.DX_IBD_SP 
	  ELSE sf.DX_IBD_DEC END AS Diagnosis
	  ,sf.YR_DX_IBD AS diagnosisYear
	  

From [Reporting].IBD600.v_op_VisitLog vl 
left join [MERGE_IBD].staging.PT_DEMOG vd on vl.SubjectID = vd.SUBNUM and vl.VisitType = vd.VISNAME 
left join [MERGE_IBD].staging.MD_DX sf on vl.SubjectID = sf.SUBNUM and vl.VisitType = sf.VISNAME
--left join [RCC_AA560].staging.providerform pf on vl.subjectId = pf.subNum and vl.eventId = pf.eventId
Where vl.VisitType = 'Enrollment'
)
,race AS
(
Select subNum
,CASE WHEN RACE_NATIVE_AM = 'X' THEN 'Native American'
ELSE ''
END AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_NATIVE_AM = 'X'
Union

Select subNum
,CASE WHEN RACE_ASIAN = 'X' THEN 'Asian'
ELSE ''
END AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_ASIAN = 'X'
Union

Select subNum
,CASE WHEN RACE_BLACK = 'X' THEN 'Black'
ELSE ''
END AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_BLACK = 'X'
Union

Select subNum
,CASE WHEN RACE_PACIFIC = 'X' THEN 'Pacific'
ELSE ''
END AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_PACIFIC = 'X'
Union

Select subNum
,CASE WHEN RACE_WHITE = 'X' THEN 'White'
ELSE ''
END AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_WHITE = 'X'
Union

Select subNum
, RACE_OTH_TXT AS Race
From [MERGE_IBD].staging.PT_DEMOG
Where RACE_OTHER = 'X'

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
	  ,Diagnosis
	  ,diagnosisYear
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
