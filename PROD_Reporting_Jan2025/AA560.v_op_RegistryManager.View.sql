USE [Reporting]
GO
/****** Object:  View [AA560].[v_op_RegistryManager]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [AA560].[v_op_RegistryManager] AS 

SELECT DISTINCT RS.[pmLastName] + ', ' + RS.[pmFirstName] AS RegistryManager

FROM [Salesforce].[dbo].[registryStatus] RS 
WHERE RS.[name]='Alopecia Areata (AA-560)'
AND pmLastName IS NOT NULL
AND currentStatus IN ('Approved / Active', 'Pending closeout')


GO
