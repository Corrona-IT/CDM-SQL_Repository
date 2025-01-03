USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_VisitPlanningLineListingwExitRpt]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [RA102].[v_op_VisitPlanningLineListingwExitRpt] as 
/****** Visit Planning Line Listing Report including Exit Visits  ******/
WITH Enroll AS
(
	SELECT
		DP.[vID]
		, DP.[SITENUM]
		, DP.[SUBNUM]
		, DP.[SUBID]
		, DP.[REVISION]
		, VISDT.VISITDATE AS EnrollDate
		, PRO1.PHYSICIAN_ID AS EPID
		, row_number() over(partition by DP.[SITENUM], DP.[SUBNUM] order by DP.[DATALMDT] desc) AS ROWNUM
	FROM [MERGE_RA_Japan].[staging].[DAT_PAGS] DP
    LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VISDT ON DP.VID=VISDT.VID
	LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO1 ON DP.VID=PRO1.VID AND DP.VISITID=PRO1.VISITID
	WHERE DP.[VISNAME] = 'Enrollment' AND DP.[PAGEID] = 10 AND DP.STATUSID>0 and isnull(visdt.VISITDATE, '') <>'' -- Date of Visit

)



,SiteStatus AS
(
SELECT DISTINCT SITENUM AS [SiteID]
,CASE WHEN ACTIVE='t' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
FROM MERGE_RA_Japan.DBO.DAT_SITES 
---ORDER BY SITENUM
)


,VISDATE AS
(
SELECT VD.vID
      ,VD.SITENUM
	  ,VD.SUBNUM
	  ,VD.VISNAME
	  ,VD.STATUSID
	  ,VD.VISITID
	  ,VD.PAGEID
	  ,VD.VISITDATE AS VisitDate
	  ,PRO1.[PHYSICIAN_ID] AS ProviderID

FROM [MERGE_RA_Japan].[staging].[VIS_DATE] VD 
LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO1 ON VD.VID=PRO1.VID AND VD.VISITID=PRO1.VISITID


UNION

SELECT vID
      ,SITENUM
	  ,SUBNUM
	  ,VISNAME
	  ,STATUSID
	  ,VISITID
	  ,PAGEID
	  ,DISCONTINUE_DATE AS VisitDate
	  ,MD_COD AS ProviderID
   
FROM [MERGE_RA_Japan].[staging].[EXIT_01]
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
		, VD1.ProviderID
		, row_number() over(partition by DP.[SITENUM], DP.[SUBNUM] order by VD1.[VISITDATE] desc, DP.[VISNAME] asc) AS ROWNUM
	FROM 
	[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
	INNER JOIN VISDATE VD1 ON  DP.vID = VD1.vID AND DP.PAGEID = VD1.PAGEID
	WHERE DP.STATUSID>0 AND ((DP.[VISNAME] IN ('Followup') AND DP.[PAGEID] IN (2340))
	OR (DP.[VISNAME] IN ('Exit') AND DP.[PAGEID] IN (10))) -- Date of Visit
),

ASUB AS
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

,linelist as
(
SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,ISNULL(ASUB.[IDENT2], '') AS [Year of Birth]

	 ,((CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEDIFF(D, VD.[VISITDATE], GETDATE())
			WHEN V.[VISITDATE] IS NOT NULL THEN DATEDIFF(D, V.[VISITDATE], GETDATE())
		ELSE 0
		END)/30.00) AS [Months Since Last Visit] 

	  ,CONVERT(VARCHAR(10), CONVERT(DATE,(CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEADD(D, 180, VD.[VISITDATE])
		WHEN V.[VISITDATE] IS NOT NULL THEN DATEADD(D, 180, V.[VISITDATE])
		ELSE DATEADD(D, 180, GETDATE())
		END)), 101) AS [Target Date for Next Follow-Up Visit]

	  ,CONVERT(VARCHAR(10), CONVERT(DATE,(CASE WHEN (V.[VISITDATE] IS NULL AND VD.[VISITDATE] IS NOT NULL) OR V.[VISITDATE]< VD.[VISITDATE] THEN DATEADD(D, 150, VD.[VISITDATE])
		WHEN V.[VISITDATE] IS NOT NULL THEN DATEADD(D, 150, V.[VISITDATE])
		ELSE DATEADD(D, 150, GETDATE())
		END)), 101) AS [Earliest Eligible Date for Next Follow-Up Visit]

	  ,ISNULL(DP.EPID, '') AS [Enrollment Provider ID]
	  ,CONVERT(VARCHAR(10),CONVERT(DATE,DP.EnrollDate),101) AS [Enrollment Date]
	  ,CASE WHEN V.[VISNAME] IN ('Followup', 'Exit') THEN ISNULL(V.ProviderID, '')
	   ELSE DP.EPID END AS [Last Visit Provider ID]
	  ,CONVERT(VARCHAR(10), CONVERT(DATE,COALESCE( V.[VISITDATE],VD.[VISITDATE])),101) AS [Last Visit Date]
	  ,COALESCE(V.[VISNAME], 'Enrollment') AS [Last Visit Type]
FROM 
  	 Enroll DP
  	  LEFT JOIN VISDATE VD ON DP.[vID] = VD.[vID]
 	  LEFT JOIN ASUB ASUB ON ASUB.[SUBID] = DP.[SUBID]-- AND ASUB.[REVISION] = DP.[REVISION]
  	  LEFT JOIN Visits V ON  V.[ROWNUM]  = 1 AND V.[SUBID] = DP.[SUBID]
)

SELECT LL.[vID]
      ,LL.[Site ID]
	  ,SS.SiteStatus
	  ,LL.[Subject ID]
	  ,LL.[Year of Birth]
	  ,LL.[Months Since Last Visit]

	  ,CASE WHEN [Last Visit Type]='Exit' THEN 'Exited'
	   ELSE CONVERT(VARCHAR(10), [Target Date for Next Follow-up Visit])
	   END AS [Target Date for Next Followup Visit]

	  ,CAST([Target Date for Next Follow-up Visit] AS DATE) AS [Next Visit Target Date]

	  ,CASE WHEN [Last Visit Type]='Exit' THEN 'Exited'
	   ELSE CONVERT(VARCHAR(10), [Earliest Eligible Date for Next Follow-up Visit])
	   END AS [Earliest Eligible Date for Next Followup Visit]

	  ,CAST([Earliest Eligible Date for Next Follow-up Visit] AS DATE) AS [Next Visit Earliest Date]

	  ,[Enrollment Provider ID]
	  ,CAST([Enrollment Date] AS date) AS [Enrollment Date]
	  ,[Last Visit Provider ID]
	  ,CAST([Last Visit Date] AS date) AS [Last Visit Date]
	  ,[Last Visit Type]
FROM linelist LL
JOIN SiteStatus SS ON SS.SiteID=LL.[Site ID]
WHERE LL.[Site ID] NOT LIKE '9%'


---ORDER BY [Site ID], [Subject ID]






GO
