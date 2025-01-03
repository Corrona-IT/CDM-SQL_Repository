USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_VisitPlanningLineListingReport]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [RA102].[v_op_VisitPlanningLineListingReport] as 

/****** Visit Planning Line Listing Report  ******/

WITH Enroll AS
(
	SELECT
		DP.[vID]
		, DP.[SITENUM]
		, DP.[SUBNUM]
		, DP.[SUBID]
		, DP.[REVISION]
		, row_number() over(partition by DP.[SITENUM], DP.[SUBNUM] order by DP.[DATALMDT] desc) AS ROWNUM
	FROM 
	[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
	WHERE DP.[VISNAME] = 'Enrollment' AND DP.[PAGEID] = 10 -- Date of Visit

)

,SiteStatus AS
(
SELECT DISTINCT SITENUM AS [SiteID]
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM MERGE_RA_Japan.DBO.DAT_SITES 
WHERE SITENUM NOT LIKE '9%'
---ORDER BY SITENUM
)

,Visits AS
(
	SELECT
		DP.[vID]
		, DP.[VISNAME]
		, DP.[SITENUM]
		, DP.[SUBNUM]
		, DP.[SUBID]
		, VD1.[STATUSID]
		, VD1.[VISITDATE]
		, PRO01.[PHYSICIAN_ID]
		, row_number() over(partition by DP.[SITENUM], DP.[SUBNUM] order by VD1.[VISITDATE] desc) AS ROWNUM
	FROM 
	[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
	INNER JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD1 ON  DP.vID = VD1.vID AND DP.PAGEID = VD1.PAGEID
	LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO01 ON DP.vID = PRO01.vID
	WHERE DP.[VISNAME] IN ('Followup') AND DP.[PAGEID] IN (2340) -- Date of Visit
)

,ASUB AS
(
	SELECT SITENUM, REVNUM, SUBID, SUBNUM, IDENT2, IDENT3, STATUSID, REVISION, DELETED, REASON, LASTMBY, LASTMDT
	FROM
		(SELECT
			SITENUM, REVNUM, SUBID, SUBNUM, IDENT2, IDENT3, STATUSID, REVISION, DELETED, REASON, LASTMBY, LASTMDT
			, row_number() over(partition by [SUBID] order by [LASTMDT] desc) AS ROWNUM
		FROM 
			[MERGE_RA_Japan].[dbo].[DAT_ASUB]
		) T
	WHERE ROWNUM = 1
)

SELECT 
	   DP.[vID]
	  ,SS.SiteStatus
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,ISNULL(ASUB.[IDENT2], '') AS [Year of Birth]
	 ,((CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEDIFF(D, VD.[VISITDATE], GETDATE())
			WHEN V.[VISITDATE] IS NOT NULL THEN DATEDIFF(D, V.[VISITDATE], GETDATE())
		ELSE 0
		END)/30.00) AS [Months Since Last Visit] 
	  ,CONVERT(VARCHAR(8), CONVERT(DATE,(CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEADD(D, 180, VD.[VISITDATE])
		WHEN V.[VISITDATE] IS NOT NULL THEN DATEADD(D, 180, V.[VISITDATE])
		ELSE DATEADD(D, 180, GETDATE())
		END)), 1) AS [Target Date for Next Follow-Up Visit]
	  ,CONVERT(VARCHAR(8), CONVERT(DATE,(CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEADD(D, 150, VD.[VISITDATE])
		WHEN V.[VISITDATE] IS NOT NULL THEN DATEADD(D, 150, V.[VISITDATE])
		ELSE DATEADD(D, 150, GETDATE())
		END)), 1) AS [Earliest Eligible Date for Next Follow-Up Visit]
	  ,ISNULL(PRO01.[PHYSICIAN_ID], '') AS [Provider ID]
	  ,CONVERT(VARCHAR(8),CONVERT(DATE,VD.[VISITDATE]),1) AS [Enrollment Date]
	  ,COALESCE(V.[PHYSICIAN_ID], '') AS [Last Follow-Up Provider ID]
	  ,CONVERT(VARCHAR(8), CONVERT(DATE,COALESCE( V.[VISITDATE],VD.[VISITDATE])),1) AS [Last Visit Date]
	  ,COALESCE(V.[VISNAME], 'Enrollment') AS [Last Visit - Visit Type]
FROM 
  	 Enroll DP
	  JOIN SiteStatus SS ON SS.SiteID=DP.[SITENUM]
	  LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.[vID] = VD.[vID]
  	  LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO01 ON DP.[vID] = PRO01.[vID]
  	  LEFT JOIN ASUB ASUB ON ASUB.[SUBID] = DP.[SUBID]-- AND ASUB.[REVISION] = DP.[REVISION]
  	  LEFT JOIN Visits V ON  V.[ROWNUM]  = 1 AND V.[SUBID] = DP.[SUBID]

WHERE DP.[SUBNUM] NOT IN (SELECT SUBNUM FROM [MERGE_RA_Japan].reports.v_Exit_Report)
AND DP.SITENUM NOT LIKE '9%'





GO
