USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_infliximab_enroll]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [RA102].[v_op_infliximab_enroll] AS

with remicade as
(

SELECT CAST(PRO6.vID as dec(30,0)) AS vID
      ,CAST(PRO6.SITENUM as int) AS SITEID
	  ,CAST(PRO6.SUBNUM as dec(11,0)) AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,CAST(VIS.VISITDATE AS DATE) AS VISITDATE 
	  ,'Changes Made Today' AS PAGENAME
	,CASE
	     WHEN (PRO6.REMICADE_USETODAY='X') THEN 'INFLIXIMAB (REMICADE)'
	     ELSE ''
	  END AS DRUGNAME

	 ,SUBSTRING(PRO6.REMICADE_STATUSTODAY_DEC, 14, 34) AS DRUGSTATUS

FROM MERGE_RA_Japan.STAGING.PRO_06 PRO6
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO6.vID=VIS.VID
WHERE (PRO6.REMICADE_USETODAY='X')
AND PRO6.VISNAME='Enrollment'
AND (PRO6.REMICADE_STATUSTODAY NOT IN ('03', '3')) 


UNION

SELECT CAST(PRO6.vID as dec(30,0)) AS vID
      ,CAST(PRO6.SITENUM AS INT) AS SITEID
	  ,CAST(PRO6.SUBNUM AS dec(11,0)) AS SUBJECTID
	  ,PRO6.VISNAME AS VISITTYPE
	  ,CAST(VIS.VISITDATE AS DATE) AS VISITDATE 
	  ,'Changes Made Today' AS PAGENAME
	,CASE
	     WHEN (PRO6.REMICADE_BIOSIM_USETODAY='X') THEN 'INFLIXIMAB BS'
	     ELSE ''
	  END AS DRUGNAME

	 ,SUBSTRING(PRO6.REMICADE_BIOSIM_STATUSTODAY_DEC, 14, 34) AS DRUGSTATUS

FROM MERGE_RA_Japan.STAGING.PRO_06 PRO6
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS ON PRO6.vID=VIS.VID
WHERE (PRO6.REMICADE_BIOSIM_USETODAY='X')
AND PRO6.VISNAME='Enrollment'
AND (PRO6.REMICADE_BIOSIM_STATUSTODAY NOT IN ('03', '3'))

)


select Dash.Siteid AS SiteID
      ,Dash.ProviderID AS ProviderID
	  ,Dash.SubjectID AS SubjectID
	  ,CAST(Dash.VisitDate AS date) AS VisitDate
	  ,Dash.VisitType AS VisitType
	  ,Dash.AGE AS AGE
	  ,Dash.AtLeast18 AS AtLeast18
	  ,Dash.YR_ONSET_RA AS YR_ONSET_RA
	  ,Dash.Diagnosed AS Diagnosed
	  ,CASE WHEN Dash.Drug='REMICADE' THEN r.DRUGNAME
	   ELSE Dash.Drug
	   END AS Drug
	  ,Dash.EligibleDrug AS EligibleDrug
	  ,Dash.PrescAtVisit AS PrescAtVisit
	  ,Dash.PriorUse AS PriorUse
	  ,Dash.EligPresc_woPriorUse AS EligPresc_woPriorUse

from MERGE_RA_Japan.CDM.t_RA_Japan_Subj_Elig_Dashboard Dash
RIGHT JOIN remicade r on Dash.SiteID=r.SITEID and Dash.SubjectID=r.SUBJECTID
WHERE Dash.EligPresc_woPriorUse=1 AND Dash.PriorUse is NULL





GO
