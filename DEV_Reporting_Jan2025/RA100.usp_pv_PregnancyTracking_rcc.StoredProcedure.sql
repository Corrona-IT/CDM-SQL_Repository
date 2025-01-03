USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_pv_PregnancyTracking_rcc]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =================================================
-- Author:		Kevin Soe
-- Create date: 10/16/2023
-- Description:	Procedure for Pregnancy Tracking in RCC
-- =================================================


			   --EXECUTE
CREATE PROCEDURE [RA100].[usp_pv_PregnancyTracking_rcc] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*	   DROP
CREATE TABLE [RA100].[t_pv_PregnancyTracking_rcc]
(
	[SiteID] [int] NOT NULL,
	[subjectId] [bigint] NOT NULL,
	[subNum] [nvarchar](25) NULL,
	[EventName] [nvarchar](350) NULL,
	[eventId] [bigint] NULL,
	[eventOccurrence] [bigint] NULL,
	[VisitDate] [datetime] NULL,
	[crfOccurrence] [bigint] NULL,
	[hasData] [nvarchar](10) NULL,
	[gender] [nvarchar](10) NULL,
	[eventCrfId] [bigint] NULL,
	[auditId] [bigint] NULL,
	[questionText] [nvarchar](500) NULL,
	[oldValue] [nvarchar](1000) NULL,
	[newValue] [nvarchar](1000) NULL,
	[VisitTreatments] [nvarchar](1000) NULL,
	[OtherVisitTreatments] [nvarchar](1000) NULL,
	[LastModifiedDate] [datetime] NULL,
	[current] [int] NULL,
	[columnOrder] [int] NULL
) ON [PRIMARY]
GO
*/

TRUNCATE TABLE [Reporting].[RA100].t_pv_PregnancyTracking_rcc;

INSERT INTO [Reporting].[RA100].[t_pv_PregnancyTracking_rcc]
(
	 [SiteID] 
	,[subjectId] 
	,[subNum] 
	,[EventName] 
	,[eventId] 
	,[eventOccurrence] 
	,[VisitDate]
	,[crfOccurrence] 
	,[hasData] 
	,[gender] 
	,[eventCrfId] 
	,[auditId] 
	,[questionText] 
	,[oldValue] 
	,[newValue] 
	,[VisitTreatments] 
	,[OtherVisitTreatments] 
	,[LastModifiedDate]
	,[current]
	,[columnOrder]
	)

	SELECT *
	FROM [RA100].v_pv_PregnancyTracking_rcc
	WHERE subjectId IS NOT NULL

	--SELECT * FROM [RA100].t_pv_PregnancyTracking_rcc

	END 
GO
