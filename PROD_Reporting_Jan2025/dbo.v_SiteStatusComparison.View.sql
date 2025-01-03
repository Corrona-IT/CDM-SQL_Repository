USE [Reporting]
GO
/****** Object:  View [dbo].[v_SiteStatusComparison]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_SiteStatusComparison] AS 
WITH EDCSiteStatus AS
(
SELECT SiteID,
       SiteStatus AS EDCSiteStatus,
	   Registry
FROM
(
SELECT DISTINCT SiteID,
       SiteStatus,
	   'AD-550' AS Registry
FROM [Reporting].[AD550].[v_SiteStatus]

UNION
---
SELECT DISTINCT SiteID,
       SiteStatus,
	   'AA-560' AS Registry
FROM [Reporting].[AA560].[v_SiteStatus]

UNION
--
---
SELECT DISTINCT SiteID,
       SiteStatus,
	   --'NMO-750' AS Registry
	   'NMOSD-750' AS Registry
FROM [Reporting].NMO750.v_SiteStatus

UNION
--
SELECT DISTINCT SiteID,
       SiteStatus,
	   'IBD-600' AS Registry
FROM [Reporting].[IBD600].[v_SiteStatus]

UNION

SELECT DISTINCT SiteID,
       SiteStatus,
	   'MS-700' AS Registry
FROM [Reporting].[MS700].[v_SiteStatus]

UNION

SELECT DISTINCT SiteID,
       SiteStatus,
	   'PSA-400' AS Registry
FROM [Reporting].[PSA400].[v_op_SiteStatus]
     
UNION

SELECT DISTINCT [Site Number] AS SiteID,
       site_status AS SiteStatus,
	   'PSO-500' AS Registry
FROM [OMNICOMM_PSO].[inbound].[G_Site Information] SIT 
WHERE [Site Number] NOT IN (997, 998, 999)

UNION

SELECT DISTINCT SiteID,
       SiteStatus,
	   'RA-100' AS Registry
FROM [Reporting].[RA100].[v_op_SiteStatus]

UNION

SELECT DISTINCT SiteID,
       SiteStatus,
	   'RA-102' AS Registry
FROM [Reporting].[RA102].[v_op_SiteStatus]
) A
)

,SFSiteStatus AS
(
SELECT Registry,
       SiteID,
	   SFSiteStatus
FROM
(
SELECT CASE WHEN [name] = 'Atopic Dermatitis (AD-550)' THEN 'AD-550'
	---
	   WHEN [name] = 'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)' THEN 'NMOSD-750'
	   WHEN [name] = 'Alopecia Areata (AA-560)' THEN 'AA-560'
       WHEN [name] = 'Corrona ePlatform Pilot' THEN ''
	   WHEN [name] = 'Inflammatory Bowel Disease (IBD-600)' THEN 'IBD-600'
	   WHEN [name] = 'Japan RA Registry (RA-102)' THEN 'RA-102'
	   WHEN [name] = 'Multiple Sclerosis (MS-700)' THEN 'MS-700'
	   WHEN [name] = 'Patient Outcomes: Real World Evidence in Rheumatoid Arthritis' THEN ''
	   WHEN [name] = 'Psoriasis (PSO-500)' THEN 'PSO-500'
	   WHEN [name] = 'Psoriatic Arthritis & Spondyloarthritis (PSA-400)' THEN 'PSA-400'
	   WHEN [name] = 'Rheumatoid Arthritis (RA-100,02-021)' THEN 'RA-100'
	   ELSE ''
       END AS Registry,
       siteNumber AS SiteID,
       CASE WHEN currentStatus='Approved / Active' THEN 'Active'
	   WHEN currentStatus LIKE '%active%' THEN 'Active'
	   WHEN currentStatus IN ('Closed / Completed', 'Not participating') THEN 'Inactive'
	   ELSE currentStatus
	   END AS SFSiteStatus
FROM [Salesforce].[dbo].[registryStatus]
) A
WHERE ISNULL(SiteID, '')<>'' 
AND ISNULL(Registry, '')<>''
)

SELECT EDC.SiteID,
       EDC.EDCSiteStatus,
	   SF.SFSiteStatus,
	   EDC.Registry
FROM EDCSiteStatus EDC
LEFT JOIN SFSiteStatus SF ON SF.Registry=EDC.Registry AND SF.SiteID=EDC.SiteID 
WHERE EDC.EDCSiteStatus<>SF.SFSiteStatus
--ORDER BY Registry, SiteID

GO
