USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_RAExceptionsList_old_donotuse]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 
CREATE view [RA100].[v_op_RAExceptionsList_old_donotuse] as

select * from OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0','Data Source="C:\SharePoint_OneDrive_Sync\Corrona LLC\IT - Infrastructure and Development - Files_for_SQL_OneDrive_Sync\RA_Exceptions_List.xlsx"; Extended Properties="Excel 12.0;IMEX=1;HDR=Yes"')...[RA_Exceptions_List$]
WHERE SiteID IS NOT NULL
GO
