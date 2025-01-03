USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_Exits]    Script Date: 12/9/2024 2:46:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- ================================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 05/10/2019
-- Description:	Procedure to create table for Page 3 Subject Log of new Patient FU Tracker SMR Report
-- ================================================================================================================

CREATE PROCEDURE [RA100].[usp_op_Exits] AS


/*
*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
CREATE TABLE [RA100].[t_op_Exits]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[ExitDate] [date] NOT NULL,
	[ExitReason] [nvarchar] (500) NULL,
	[ExitReasonDetails] [nvarchar] (1500) NULL

);
*/


TRUNCATE TABLE [Reporting].[RA100].[t_op_Exits];

INSERT INTO [RA100].[t_op_Exits](
	[SiteID],
	[SubjectID],
	[ExitDate],
	[ExitReason],
	[ExitReasonDetails]
) 



SELECT DISTINCT [Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,CONVERT(DATE, [Visit Object VisitDate]) AS ExitDate
	  ,[EXIT2_EXITRSN] AS ExitReason
	  ,[EXIT2_EXOTH1] AS ExitReasonDetails

FROM [OMNICOMM_RA100].[dbo].[EXIT]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
---AND [Patient Object PatientNo] IN ('1060062', '1060068', '105560658', '994278016')




END

GO
