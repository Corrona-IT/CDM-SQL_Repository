USE [Reporting]
GO
/****** Object:  View [RA102].[EnrollmentReport]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










/****** Enrollment Report  ******/

CREATE view [RA102].[EnrollmentReport] as 
--use [MERGE_RA_Japan]
--create schema [Jen]/****** Enrollment Report  ******/
/****** Enrollment Report  ******/
WITH DP AS
(
	SELECT DISTINCT
		DP.vID
		, DP.SITENUM
		, DP.SUBNUM
	FROM 
	[MERGE_RA_Japan].[staging].[DAT_PAGS] DP
	WHERE VISNAME = 'Enrollment'
)

SELECT 
	  DP.[vID]
	  ,ISNULL(DP.[SITENUM], '') AS [Site ID] 
	  ,ISNULL(DP.[SUBNUM], '') AS [Subject ID]
	  ,ISNULL(PRO01.PHYSICIAN_ID, '') AS [Provider ID]
	  ,CONVERT(DATE,VD.[VISITDATE]) AS [Enrollment Date]
	  --,CONVERT(DATE,PRO01.PAGELMDT) AS [PAGELMDT]
FROM 
  	  DP DP
  	  LEFT JOIN [MERGE_RA_Japan].[staging].[VIS_DATE] VD ON DP.vID = VD.vID
  	  LEFT JOIN [MERGE_RA_Japan].[staging].[PRO_01] PRO01 ON DP.vID = PRO01.vID





GO
