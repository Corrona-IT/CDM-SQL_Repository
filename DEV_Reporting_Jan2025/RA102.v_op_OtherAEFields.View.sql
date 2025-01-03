USE [Reporting]
GO
/****** Object:  View [RA102].[v_op_OtherAEFields]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [RA102].[v_op_OtherAEFields] AS

(

---GET OTHER FIELDS FROM Provider Follow Up Page 3 for Other Comorbidities
SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Other Comorbidity (1)' AS Event
	  ,PRO_CLI.COMOR_OTH_COND_SPECIFY_1 AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_OTH_COND_SPECIFY_1 IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Other Comorbidity (2)' AS Event
	  ,PRO_CLI.COMOR_OTH_COND_SPECIFY_2 AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_OTH_COND_SPECIFY_2 IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Other Comorbidity (3)' AS Event
	  ,PRO_CLI.COMOR_OTH_COND_SPECIFY_3 AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_OTH_COND_SPECIFY_3 IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Other Comorbidity (4)' AS Event
	  ,PRO_CLI.COMOR_OTH_COND_SPECIFY_4 AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_OTH_COND_SPECIFY_4 IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

---Get Comorbidities attributed to drug
SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Comorbidity (1)' AS Event
	  ,PRO_CLI.COMOR_DRUG_EVENT1_SPECIFY AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_DRUG_EVENT1_SPECIFY IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Comorbidity (2)' AS Event
	  ,PRO_CLI.COMOR_DRUG_EVENT2_SPECIFY AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_DRUG_EVENT2_SPECIFY IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Comorbidity (3)' AS Event
	  ,PRO_CLI.COMOR_DRUG_EVENT3_SPECIFY AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_DRUG_EVENT3_SPECIFY IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

SELECT PRO_CLI.vID
      ,PRO_CLI.SITENUM AS SiteID
	  ,PRO_CLI.SUBNUM AS SubjectID
	  ,PRO_CLI.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_CLI.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Comorbidity (4)' AS Event
	  ,PRO_CLI.COMOR_DRUG_EVENT4_SPECIFY AS OtherSpecify
	  
FROM MERGE_RA_Japan.staging.PRO_CLI
LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_CLI.VID
WHERE PRO_CLI.COMOR_DRUG_EVENT4_SPECIFY IS NOT NULL
AND PRO_CLI.VISNAME IN ('Followup', 'Enrollment')
---AND PRO_CLI.SITENUM NOT IN (9997, 9998, 9999)

UNION

---Get Other Infections from Provider Follow up Page 4
SELECT PRO_02A.vID
      ,PRO_02A.SITENUM AS SiteID
	  ,PRO_02A.SUBNUM AS SubjectID
	  ,PRO_02A.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_02A.PAGENAME AS PageName
	  ,'Other Infection' AS Event
	  ,PRO_02A.INF_OTHER_SPECIFY AS OtherSpecify
	  
 FROM MERGE_RA_Japan.staging.PRO_02A
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_02A.VID
 WHERE (PRO_02A.INF_OTHER_SPECIFY IS NOT NULL)  
 AND PRO_02A.VISNAME IN ('Followup', 'Enrollment')
 
 UNION
 
 ---Get Infections attributed to drug
 SELECT PRO_02A.vID
      ,PRO_02A.SITENUM AS SiteID
	  ,PRO_02A.SUBNUM AS SubjectID
	  ,PRO_02A.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_02A.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Infection (1)' AS Event
	  ,PRO_02A.INF_DRUG_EVENT1_SPECIFY AS OtherSpecify
	  
 FROM MERGE_RA_Japan.staging.PRO_02A
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_02A.VID
 WHERE (PRO_02A.INF_DRUG_EVENT1_SPECIFY IS NOT NULL)
 AND PRO_02A.VISNAME IN ('Followup', 'Enrollment')

UNION

SELECT PRO_02A.vID
      ,PRO_02A.SITENUM AS SiteID
	  ,PRO_02A.SUBNUM AS SubjectID
	  ,PRO_02A.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_02A.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Infection (2)' AS Event
	  ,PRO_02A.INF_DRUG_EVENT2_SPECIFY AS OtherSpecify
	  
 FROM MERGE_RA_Japan.staging.PRO_02A
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_02A.VID
 WHERE (PRO_02A.INF_DRUG_EVENT2_SPECIFY IS NOT NULL)
 AND PRO_02A.VISNAME IN ('Followup', 'Enrollment')

UNION

SELECT PRO_02A.vID
      ,PRO_02A.SITENUM AS SiteID
	  ,PRO_02A.SUBNUM AS SubjectID
	  ,PRO_02A.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_02A.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Infection (3)' AS Event
	  ,PRO_02A.INF_DRUG_EVENT3_SPECIFY AS OtherSpecify
	  
 FROM MERGE_RA_Japan.staging.PRO_02A
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_02A.VID
 WHERE (PRO_02A.INF_DRUG_EVENT3_SPECIFY IS NOT NULL)
 AND PRO_02A.VISNAME IN ('Followup', 'Enrollment')

UNION

SELECT PRO_02A.vID
      ,PRO_02A.SITENUM AS SiteID
	  ,PRO_02A.SUBNUM AS SubjectID
	  ,PRO_02A.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_02A.PAGENAME AS PageName
	  ,'Attributed Med - Specify Other Infection (4)' AS Event
	  ,PRO_02A.INF_DRUG_EVENT4_SPECIFY AS OtherSpecify
	  
 FROM MERGE_RA_Japan.staging.PRO_02A
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_02A.VID
 WHERE (PRO_02A.INF_DRUG_EVENT4_SPECIFY IS NOT NULL)
 AND PRO_02A.VISNAME IN ('Followup', 'Enrollment')

UNION

---Get Other Events from Provider Follow up Page 5 for events that meet SAE Criteria
SELECT PRO_03.vID
      ,PRO_03.SITENUM AS SiteID
	  ,PRO_03.SUBNUM AS SubjectID
	  ,PRO_03.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_03.PAGENAME AS PageName
	  ,'SAE Criteria (1)' AS Event
	  ,PRO_03.SAE_EVENT1_SPECIFY AS OtherSpecify

 FROM MERGE_RA_Japan.staging.PRO_03
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_03.VID
 WHERE (PRO_03.SAE_EVENT1_SPECIFY IS NOT NULL)
 AND PRO_03.VISNAME IN ('Followup', 'Enrollment')

 UNION

 SELECT PRO_03.vID
      ,PRO_03.SITENUM AS SiteID
	  ,PRO_03.SUBNUM AS SubjectID
	  ,PRO_03.VISNAME AS VisitName
	  ,VIS.VisitDate AS VisitDate
	  ,PRO_03.PAGENAME AS PageName
	  ,'SAE Criteria (2)' AS Event
	  ,PRO_03.SAE_EVENT2_SPECIFY AS OtherSpecify

 FROM MERGE_RA_Japan.staging.PRO_03
 LEFT JOIN MERGE_RA_Japan.staging.VIS_DATE VIS on VIS.VID=PRO_03.VID
 WHERE (PRO_03.SAE_EVENT2_SPECIFY IS NOT NULL)
 AND PRO_03.VISNAME IN ('Followup', 'Enrollment')
 )





GO
