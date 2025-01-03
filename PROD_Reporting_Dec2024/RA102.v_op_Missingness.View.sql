USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_Missingness]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =================================================
-- Author:		Kevin Soe
-- Create date: 09/27/2022
-- Description:	Determine critical assesments are missing. 1=Missing 0=Not Missing
-- =================================================

		 --SELECT * FROM
CREATE VIEW [RA102].[v_op_Missingness] AS

SELECT
	 vis.[vID]
	,vis.[SITENUM] AS [SiteID]
	,vis.[SUBNUM] AS [SubjectID]
	,vis.[VISNAME] AS [VisitType]
	,CAST(vis.[VISITDATE] AS DATE) AS [VisitDate]
	,'' AS [VisitCode]
	,CASE 
		WHEN pr1.[TENDER_JTS_28] IS NULL THEN 1
		ELSE 0
	 END AS [TJS]
	,CASE 
		WHEN pr1.[SWOLLEN_JTS_28] IS NULL THEN 1
		ELSE 0
	 END AS [SJS]
	,CASE 
		WHEN pr1.[MD_GLOBAL_ASSESS] IS NULL THEN 1
		ELSE 0
	 END AS [MGA]
	,CASE 
		WHEN ISNULL(sb2.[DRESS_SELF],'')='' AND ISNULL(sb2.[SHAMPOO_HAIR],'')='' AND  ISNULL(sb2.[STAND_UP_CHAIR],'')='' AND ISNULL(sb2.[GET_IN_OUT_BED],'')='' AND ISNULL(sb2.[EAT_RICE],'')='' AND ISNULL(sb2.[LIFT_CUP_GLASS],'')='' AND ISNULL(sb2.[OPEN_CARTONS],'')='' AND ISNULL(sb2.[WALK_OUTDOORS],'')='' AND ISNULL(sb2.[CLIMB_5_STEPS],'')='' AND ISNULL(sb2.[WASH_DRY_BODY],'')='' AND ISNULL(sb2.[TAKE_TUB_BATH],'')='' AND ISNULL(sb2.[GET_ON_OFF_SEAT],'')='' AND ISNULL(sb2.[REACH_GET_DOWN],'')='' AND ISNULL(sb2.[BEND_DOWN],'')='' AND ISNULL(sb2.[OPEN_CAR_DOORS],'')='' AND ISNULL(sb2.[OPEN_JARS],'')='' AND ISNULL(sb2.[TURN_FAUCETS],'')='' AND ISNULL(sb2.[RUN_ERRANDS],'')='' AND ISNULL(sb2.[GET_IN_OUT_CAR],'')='' AND ISNULL(sb2.[VACUUMING],'')='' 
		THEN 1
		ELSE 0
	 END AS [HAQ]
	,CASE 
		WHEN sb3.[PT_GLOBAL_ASSESS] IS NULL THEN 1
		ELSE 0
	 END AS [PGA]
	,CASE 
		WHEN sb3.[HEALTH_STATUS_WALKING] IS NULL AND sb3.[HEALTH_STATUS_SELFCARE] IS NULL AND  sb3.[HEALTH_STATUS_ACTIVIES] IS NULL AND sb3.[HEALTH_STATUS_PAIN] IS NULL AND sb3.[HEALTH_STATUS_ANX_DEP] IS NULL AND sb4.[PT_HEALTH_STATE] IS NULL
		THEN 1
		ELSE 0
	 END AS [EQ5D] --SELECT *
  FROM [MERGE_RA_Japan].[staging].[VIS_DATE] vis
  LEFT JOIN --SELECT * FROM
  [MERGE_RA_Japan].[staging].[PRO_01] pr1 ON vis.vID=pr1.vID
  LEFT JOIN --SELECT * FROM
  [MERGE_RA_Japan].[staging].[SUB_02] sb2 ON vis.vID=sb2.vID
  LEFT JOIN --SELECT * FROM
  [MERGE_RA_Japan].[staging].[SUB_03] sb3 ON vis.vID=sb3.vID
  LEFT JOIN --SELECT * FROM
  [MERGE_RA_Japan].[staging].[SUB_04] sb4 ON vis.vID=sb4.vID
  WHERE ISNULL(vis.[VISITDATE],'')<>''
  AND vis.[SITENUM] NOT LIKE '99%'

GO
