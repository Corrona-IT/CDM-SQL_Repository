USE [Reporting]
GO
/****** Object:  View [MULTI].[v_op_RCCSpecs]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =================================================
-- Author:		Kevin Soe
-- Create date: 7/28/2022
-- Description:	View of specifications for all variables for RCC registries
-- =================================================

		  --SELECT * FROM
CREATE VIEW [MULTI].[v_op_RCCSpecs] AS

SELECT
	 'AD-550' AS [registry]
	--,[versionName]
	,[questionText]
	,[variableName]
	,[crfName]
	,[edcDataType]
	,[responseSetLabel]
	,[responseSetOptions] --SELECT *
FROM [RCC_AD550].[meta].[specStaging]

UNION --ALL

SELECT
	 'MS-700' AS [registry]
	--,[versionName]
	,[questionText]
	,[variableName]
	,[crfName]
	,[edcDataType]
	,[responseSetLabel]
	,[responseSetOptions] --SELECT * 
FROM [RCC_MS700].[meta].[specStaging]

UNION --ALL

SELECT
	 'NMOSD-750' AS [registry]
	--,[versionName]
	,[questionText]
	,[variableName]
	,[crfName]
	,[edcDataType]
	,[responseSetLabel]
	,[responseSetOptions] --SELECT *
FROM [RCC_NMOSD750].[meta].[specStaging]
GO
