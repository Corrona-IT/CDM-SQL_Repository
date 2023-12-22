USE [Reporting]
GO
/****** Object:  View [IBD600].[v_uat_pv_119_SAEDetectionPregnancy]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [IBD600].[v_uat_pv_119_SAEDetectionPregnancy] AS


SELECT DISTINCT
       CAST(DEMOG.SITENUM AS int) AS SiteID
      ,CAST(DEMOG.SUBNUM AS bigint) AS SubjectID
	  ,CAST(VIS.VISITDATE AS date) AS VisitDate
	  ,DEMOG.VISNAME AS VisitType
	  ,DEMOG.PREGNANT_SINCE_DEC AS PregnantSince
	  ,DEMOG.PREGNANT_CURRENT_DEC AS CurrentlyPregnant
	  ,CAST(DEMOG.PAGELMDT AS date) AS PageLastModificationDate
	  ,DEMOG.PAGELMBY AS PageLastModifiedBy
FROM MERGE_IBD_UAT.staging.PT_DEMOG DEMOG
LEFT JOIN MERGE_IBD_UAT.staging.VISIT VIS ON DEMOG.VID=VIS.VID
WHERE (DEMOG.PREGNANT_SINCE=1 OR DEMOG.PREGNANT_CURRENT=1)



GO
