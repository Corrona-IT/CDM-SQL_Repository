USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_RegistryManager]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [PSO500].[v_op_RegistryManager] AS



SELECT DISTINCT [pmLastName] + ', ' +[pmFirstName] AS RegistryManager

  FROM [Salesforce].[dbo].[registryStatus]
  WHERE 1=1
  AND [name]='Psoriasis (PSO-500)'
  AND currentStatus<>'Not participating'
  AND ISNULL(siteNumber, '')<>''


GO
