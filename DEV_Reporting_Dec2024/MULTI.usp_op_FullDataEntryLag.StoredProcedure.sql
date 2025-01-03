USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_FullDataEntryLag]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author: Kevin Soe
-- Create date: 02/12/2021
-- Description:	Create table of results for all DE Lag Reports
-- =============================================
			  --EXECUTE
CREATE PROCEDURE [MULTI].[usp_op_FullDataEntryLag] AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SELECT * FROM [MULTI].[t_op_FullDataEntryLag] where Registry = 'GPP-510'
DROP TABLE [MULTI].[t_op_FullDataEntryLag]

CREATE TABLE [MULTI].[t_op_FullDataEntryLag](
	[Registry] [varchar](15) NOT NULL,
	[FullRegName] [varchar](100) NOT NULL,
	[vID] [varchar](200) NULL,
	[SiteID] [int] NULL,
	[SubjectID] [varchar](15) NULL,
	[VisitDate] [date] NULL,
	[VisitType] [varchar](30) NULL,
	[FirstEntry] [date] NULL,
	[DifferenceInDays] [int] NULL
)

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT
		'PSO-500' AS [Registry],
		'Psoriasis (PSO-500)' AS [FullRegName],
		CAST([VisitID] AS varchar) AS [vID],
		[SiteNumber] AS [SiteID],
		[SubjectID] AS [SubjectID],
		[VisitDate],
		[VisitType],
		[CompletionDate] AS [FirstEntry],
		[DifferenceInDays] --SELECT *
	FROM [Reporting].[PSO500].[v_op_DataEntryLag]
	WHERE [SiteNumber] NOT LIKE '99%'


INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT
		'IBD-600' AS [Registry],
		'Inflammatory Bowel Disease (IBD-600)' AS [FullRegName],
		CAST([vID] AS varchar) AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT *
	FROM [Reporting].[IBD600].[t_DataEntryLag]

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT
		'PSA-400' AS [Registry],
		'Psoriatic Arthritis & Spondyloarthritis (PSA-400)' AS [FullRegName],
		CAST([vID] AS varchar) AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT *
	FROM [Reporting].[PSA400].[t_DataEntryLag]

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT
		'RA-100' AS [Registry],
		'Rheumatoid Arthritis (RA-100,02-021)' AS [FullRegName],
		CAST([VisitID] AS varchar) AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[CompletionDate] AS [FirstEntry],
		[DifferenceInDays] --SELECT *
FROM [Reporting].[RA100].[t_op_DataEntryLag]

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT
		'RA-102' AS [Registry],
		'Japan RA Registry (RA-102)' AS [FullRegName],
		CAST([vID] AS varchar) AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT *
 FROM [Reporting].[RA102].[t_op_109_DataEntryLag]

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT 
		'MS-700' AS [Registry],
		'Multiple Sclerosis (MS-700)' AS [FullRegName],
		[vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT *
	FROM [Reporting].[MS700].[t_DataEntryLag]

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT 
		'AD-550' AS [Registry],
		'Atopic Dermatitis (AD-550)' AS [FullRegName],
		CAST(vID AS varchar) AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT * 
	FROM [Reporting].[AD550].[t_DataEntryLag]
	WHERE [SiteID] <> '1440'

INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT 
		'NMO-750' AS [Registry],
		'Neuromyelitis Optica Spectrum Disorder (NMOSD-750)' AS [FullRegName],
		'' AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT TOP 100 * 
	FROM [Reporting].[NMO750].[t_DataEntryLag]
	WHERE [SiteID] <> '1440'


INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT 
		'AA-560' AS [Registry],
		'Alopecia Areata (AA-560)' AS [FullRegName],
		'' AS [vID],
		[SiteID],
		[SubjectID],
		[VisitDate],
		[VisitType],
		[FirstEntry],
		[DifferenceInDays] --SELECT * 
	FROM [regetlprod].[Reporting].[AA560].[t_op_DataEntryLag]
	WHERE [SiteID] NOT LIKE '99%'
	AND [SiteID] <> '1440'
-----------------------------------------------------
--Insert GPP below:
INSERT INTO [MULTI].[t_op_FullDataEntryLag]
SELECT 
		'GPP-510' AS [Registry],
		'Generalized Pustular Psoriasis (GPP-510)' AS [FullRegName],
		'' AS [vID],
		[SiteID],
		[SubjectID],
		DEcompletion as [VisitDate],
		[VisitType],
		VisitDate as [FirstEntry],
		[DifferenceInDays] --SELECT * 
	--FROM [Reporting].[GPP510].[v_op_DataEntryLag_NEW]
	FROM [Reporting].[GPP510].[v_op_DataEntryLag]
	WHERE [SiteID] NOT LIKE '99%'
	AND [SiteID] <> '1440'
	--Added below to remove FLARE visits from DataLag
	--AND visittype <> 'GPP Flare (Populated)'

-----------------------------------------------------
GO
