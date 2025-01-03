USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SiteStatus_rcc]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [RA100].[v_op_SiteStatus_rcc] as 

SELECT DISTINCT VL.SiteID,
      RIGHT('0000' + VL.SiteID, 4) AS siteChar,
	   VL.SiteIDNotSubstring,
	   VL.SiteStatus,
 	   CASE WHEN VL.SiteID IN ('997', '998', '999', '1440') THEN 'Not participating'
		ELSE RS.[currentStatus] 
		END AS SFSiteStatus,
       CASE WHEN VL.SiteID IN ('997', '998', '999', '1440') THEN 'Rheumatoid Arthritis (RA-100,02-021)'
		ELSE RS.[name]
		END AS RegistryName

FROM
(
SELECT DISTINCT SUBSTRING(A.[name], 1, CHARINDEX('-',A.[name])-1) AS SiteID
,A.[name] AS SiteIDNotSubstring
,CASE WHEN A.[enabled]='true' THEN 'Active'
 ELSE 'Inactive'
 END AS SiteStatus
 
FROM [RCC_RA100].[api].[study_sites] A
) VL
LEFT JOIN [Salesforce].[dbo].[registryStatus] RS ON RS.siteNumber=RIGHT('0000' + VL.SiteID, 4) AND RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
--WHERE A.[name] NOT LIKE '1440%'



--SELECT * FROM [Salesforce].[dbo].[registryStatus] RS WHERE RS.[name]='Rheumatoid Arthritis (RA-100,02-021)'
GO
