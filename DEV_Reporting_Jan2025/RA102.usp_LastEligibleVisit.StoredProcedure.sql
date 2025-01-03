USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_LastEligibleVisit]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================
-- Author:		Garth	
-- Create date: 2018-06-19
-- Description:	truncate and reload table from csv on server
-- ======================================================

CREATE PROCEDURE [RA102].[usp_LastEligibleVisit] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*

drop TABLE [RA102].[t_LastEligibleVisit]

CREATE TABLE [RA102].[t_LastEligibleVisit](
	[SiteID] [int] NOT NULL,
	[SubjectID] [varchar](50) NOT NULL,
	[LaVisitDate] [date] NULL,
	[LastEligibleVisitDate] [date] NULL
)

*/


truncate table [RA102].[t_LastEligibleVisit]

BULK
INSERT [RA102].[t_LastEligibleVisit]
FROM 'D:\CDMShare\RA102_LastEligibleVisit.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
FIRSTROW = 2
)


END







GO
