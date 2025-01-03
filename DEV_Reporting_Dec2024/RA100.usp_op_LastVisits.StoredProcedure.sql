USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_LastVisits]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author: Kevin Soe
-- Create date: 28-JUL-2021
-- Description: Procedure to determine the most enrollment and follow-up visits
-- =============================================
		 --SELECT * FROM
			   --EXECUTE
CREATE PROCEDURE [RA100].[usp_op_LastVisits] AS

/*
CREATE TABLE [RA100].[t_op_LastVisits]
(
	   [ROWNUM] [int] NOT NULL
      ,[SiteID] [int] NOT NULL
      ,[SubjectID] [bigint] NOT NULL
      ,[VisitType] [nvarchar] (25) NOT NULL
      ,[LastVisitDate] [date] NOT NULL
);
*/

TRUNCATE TABLE [Reporting].[RA100].[t_op_LastVisits];

IF OBJECT_ID('tempdb.dbo.#LastVisits') IS NOT NULL BEGIN DROP TABLE #LastVisits END

SELECT 
	 ROW_NUMBER() OVER(PARTITION BY  SiteID, SubjectID ORDER BY VisitDate DESC) as ROWNUM
	,[SiteID]
	,[SubjectID]
	,[VisitType]
	,[VisitDate]

INTO #LastVisits
FROM [Reporting].[RA100].[v_op_VisitLog]
WHERE [VisitType] <> 'Exit'

INSERT INTO [Reporting].[RA100].[t_op_LastVisits]
(
	 [ROWNUM]
	,[SiteID]
	,[SubjectID]
	,[VisitType]
	,[LastVisitDate]
)

SELECT 
	 [ROWNUM]
	,[SiteID]
	,[SubjectID]
	,[VisitType]
	,[VisitDate] AS [LastVisitDate]
FROM #LastVisits
WHERE ROWNUM = 1
GO
