USE [Reporting]
GO
/****** Object:  StoredProcedure [dbo].[usp_op_HBCompareVisitLogs]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===================================================================================================
-- Author:		Kaye Mowrey
-- Update date: Updated to add MS Registry on 1/28/2020
-- Description:	Procedure to create table for SubjectLog for page 3 of new Patient FU Tracker SMR Report
-- ===================================================================================================

CREATE PROCEDURE [dbo].[usp_op_HBCompareVisitLogs] AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	/*****Update AD HB Visit Log Table*****/


TRUNCATE TABLE [Reporting].[AD550].[t_HBCompareVisitLog];


INSERT INTO [Reporting].[AD550].[t_HBCompareVisitLog]
   (
		    [SiteID]
           ,[SubjectID]
           ,[ProviderID]
           ,[VisitSequence]
           ,[VisitDate]
           ,[VisitMonth]
           ,[VisitYear]
           ,[VisitType]
	)

  SELECT [SiteID]
        ,[SubjectID]
        ,[ProviderID]
        ,[VisitSequence]
        ,[VisitDate]
        ,[VisitMonth]
	    ,[VisitYear]
        ,[VisitType]

FROM [Reporting].[AD550].[t_op_VisitLog]
WHERE SiteID<>1440



/*****Update IBD HB Visit Log Table*****/

TRUNCATE TABLE [Reporting].[IBD600].[t_HBCompareVisitLog];


INSERT INTO [Reporting].[IBD600].[t_HBCompareVisitLog]
   (
		    [SiteID]
           ,[SubjectID]
           ,[ProviderID]
           ,[VisitSequence]
           ,[VisitDate]
           ,[VisitMonth]
           ,[VisitYear]
           ,[VisitType]
	)

  SELECT [SiteID]
      ,[SubjectID]
      ,[ProviderID]
      ,[VisitSequence]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]

  FROM [Reporting].[IBD600].[v_op_VisitLog]
  WHERE ISNUMERIC(SubjectID)=1


  --SELECT COUNT(*) FROM [Reporting].[IBD600].[t_HBCompareVisitLog]
  --SELECT COUNT(*) FROM [Reporting].[IBD600].[v_op_VisitLog]



/*****Update MS HB Visit Log Table*****/


TRUNCATE TABLE [Reporting].[MS700].[t_HBCompareVisitLog];


INSERT INTO [Reporting].[MS700].[t_HBCompareVisitLog]
   (
		    [SiteID]
           ,[SubjectID]
           ,[VisitType]
           ,[VisitSequence]
           ,[VisitDate]
           ,[ProviderID]
	)

  SELECT [SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitSequence]
      ,[VisitDate]
      ,[ProviderID]

  FROM [Reporting].[MS700].[v_op_VisitLog]
  WHERE SiteID <> 1440


  --SELECT * FROM [Reporting].[MS700].[v_op_VisitLog] WHERE EligibleVisit IN ('Yes', '-')

/*****Update PSA HB Visit Log Table*****/

TRUNCATE TABLE [Reporting].[PSA400].[t_HBCompareVisitLog];

INSERT INTO [Reporting].[PSA400].[t_HBCompareVisitLog]
  (
            [SiteID]
           ,[SubjectID]
           ,[VisitType]
           ,[VisitSequence]
           ,[VisitDate]
           ,[ProviderID]
   )

  SELECT [SiteID]
      ,[SubjectID]
      ,[VisitType]
      ,[VisitSequence]
      ,[VisitDate]
      ,[ProviderID]

  FROM [Reporting].[PSA400].[v_op_VisitLog]

  --SELECT COUNT(*) FROM [Reporting].[PSA400].[t_HBCompareVisitLog]
  --SELECT COUNT(*) FROM [Reporting].[PSA400].[v_op_VisitLog]


/*****Update PSO HB Visit Log Table*****/


TRUNCATE TABLE [Reporting].[PSO500].[t_HBCompareVisitLog];


INSERT INTO [Reporting].[PSO500].[t_HBCompareVisitLog]
  (
		    [SiteID]
           ,[SubjectID]
           ,[VisitDate]
           ,[Month]
           ,[Year]
           ,[VisitType]
	)

  SELECT [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[Month]
      ,[Year]
      ,[VisitType]

  FROM [Reporting].[PSO500].[v_op_VisitLog]

  --SELECT COUNT(*) FROM [Reporting].[PSO500].[t_HBCompareVisitLog]
  --SELECT COUNT(*) FROM [Reporting].[PSO500].[v_op_VisitLog]



/*****Update RA100 HB Visit Log Table*****/

TRUNCATE TABLE [Reporting].[RA100].[t_HBCompareVisitLog];

INSERT INTO [Reporting].[RA100].[t_HBCompareVisitLog]
  (         [SiteID]
           ,[SubjectID]
           ,[VisitDate]
           ,[VisitType]
           ,[ProviderID]
           ,[VisitSequence]
   )

SELECT [SiteID]
      ,[SubjectID]
      ,[VisitDate]
      ,[VisitType]
      ,[ProviderID]
      ,[VisitSequence]
  FROM [Reporting].[RA100].[v_op_VisitLog]

  --SELECT COUNT(*) FROM [Reporting].[RA100].[t_HBCompareVisitLog]
  --SELECT COUNT(*) FROM [Reporting].[RA100].[v_op_VisitLog]


END

GO
