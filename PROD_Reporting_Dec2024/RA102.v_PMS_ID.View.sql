USE [Reporting]
GO
/****** Object:  View [RA102].[v_PMS_ID]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [RA102].[v_PMS_ID] as

SELECT PRO1.vID
      ,PRO1.SITENUM
	  ,PRO1.SUBNUM
	  ,PRO1.VISNAME
	  ,VIS.VISITDATE
	  ,PRO1.VISITSEQ
	  ,PRO1.PHYSICIAN_ID
	  ,PRO1.PMS_STUDY
	  ,PRO1.PMS_ID_XELJANZ
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] PRO1
LEFT JOIN [MERGE_RA_Japan].[STAGING].VIS_DATE VIS ON VIS.VID=PRO1.VID AND VIS.VISITSEQ=PRO1.VISITSEQ
WHERE (PRO1.VISNAME='Enrollment' AND PMS_STUDY=1)
OR (PRO1.VISNAME='Followup' AND PMS_STUDY=1)
OR (PRO1.VISNAME='Enrollment' AND PMS_STUDY=0 AND EXISTS(SELECT vID
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] A
WHERE A.SITENUM=PRO1.SITENUM AND A.SUBNUM=PRO1.SUBNUM AND A.VISNAME='Followup' AND A.PMS_STUDY=1))
OR (PRO1.VISNAME='Followup' AND PMS_STUDY=0 AND EXISTS(SELECT vID
FROM [MERGE_RA_Japan].[STAGING].[PRO_01] A
WHERE A.SITENUM=PRO1.SITENUM AND A.SUBNUM=PRO1.SUBNUM AND A.VISNAME='Enrollment' AND A.PMS_STUDY=1))
AND PRO1.SITENUM NOT IN ('9997', '9999')
AND PMS_ID_REMICADE_BIOSIM IS NULL

---ORDER BY [PRO1].SITENUM, [PRO1].SUBNUM, [VIS].VISITDATE






GO
