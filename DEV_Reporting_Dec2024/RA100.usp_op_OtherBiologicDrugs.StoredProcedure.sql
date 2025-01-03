USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_OtherBiologicDrugs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: 12/15/2019
-- Description:	Procedure for Other Biologic Drugs
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================




CREATE PROCEDURE [RA100].[usp_op_OtherBiologicDrugs] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;


/*

CREATE TABLE [Reporting].[RA100].[t_op_OtherDrugs]
(

VisitId bigint,
SiteID int,
SubjectID bigint,
VisitType nvarchar(30),
VisitDate date,
TreatmentName nvarchar(300),
SpecifyOther nvarchar(300),
ChangesToday nvarchar(50),
FirstUseDate nvarchar(20),

) ON [PRIMARY]
GO
*/

IF OBJECT_ID('tempdb.dbo.#Enroll') IS NOT NULL BEGIN DROP TABLE #Enroll END;

/************Other Biologics at Enrollment************/

SELECT PHEQ4_PHE9B.VisitId
	  ,CAST(PHEQ4_PHE9B.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(PHEQ4_PHE9B.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,PHEQ4_PHE9B.[Visit Object ProCaption] AS VisitType
	  ,CAST(PHEQ4_PHE9B.[Visit Object VisitDate] AS date) AS VisitDate

	  ,PHEQ4_PHE9B.PHE9B_CMTRT5 AS TreatmentName
	  
	  ,PHEQ4_PHE9B.PHE9B_CMOTH1 AS SpecifyOther

	  ,PHEQ4_PHE9B.[PHE9B_CMCH5] AS  ChangesToday
	  ,PHEQ4_PHE9B.[PHE9B_CMFDAT5] AS FirstUseDate

INTO #Enroll
FROM [OMNICOMM_RA100].[dbo].[PHEQ4_PHE9B] PHEQ4_PHE9B
JOIN [OMNICOMM_RA100].[dbo].[PHEQ4] PHEQ4 ON PHEQ4.VisitId=PHEQ4_PHE9B.VisitId
WHERE PHEQ4_PHE9B.[Site Object SiteNo] NOT IN (997, 998, 999)
AND ISNULL(PHEQ4_PHE9B.PHE9B_CMOTH1, '')<>''
AND CAST(PHEQ4_PHE9B.[Visit Object VisitDate] AS date) > '2019-07-31'
--SELECT * FROM #Enroll ORDER BY SiteID, SubjectID, TreatmentName


IF OBJECT_ID('tempdb.dbo.#FU') IS NOT NULL BEGIN DROP TABLE #FU END;


/************Other Biologics at Follow-up************/

SELECT PHF8B.VisitId
	  ,CAST(PHF8B.[Site Object SiteNo] AS int) AS SiteID
      ,CAST(PHF8B.[Patient Object PatientNo] AS bigint) AS SubjectID
	  ,PHF8B.[Visit Object ProCaption] AS VisitType
	  ,CAST(PHF8B.[Visit Object VisitDate] AS date) AS VisitDate

	  ,PHF8B.[PHF8B_CMTRT5] AS TreatmentName
	  ,PHF8B.[PHF8B_CMOTH1] AS SpecifyOther

	  ,PHF8B.[PHF8B_CMCH5] AS  ChangesToday
	  ,PHF8B.PHF8B_CMSTDT5 AS FirstUseDate

INTO #FU
FROM [OMNICOMM_RA100].[dbo].[PHFQ4_PHF8B] PHF8B
LEFT JOIN [OMNICOMM_RA100].[dbo].[PHFQ1] Q1 ON Q1.VisitId=PHF8B.VisitId
WHERE PHF8B.[Site Object SiteNo] NOT IN (997, 998, 999)
AND ISNULL(PHF8B.[PHF8B_CMOTH1], '')<>''
--AND CAST(PHF8B.[Visit Object VisitDate] AS date) > '2019-07-31'  /*email from Deirdre 1/2/20 updated to all dates with date parameter in report*/

--SELECT * FROM #FU ORDER BY VisitDate DESC, SiteID, SubjectID, TreatmentName


/************Combine Enrollment and FU Other Biologics************/

TRUNCATE TABLE [Reporting].[RA100].[t_op_OtherDrugs];

INSERT INTO [Reporting].[RA100].[t_op_OtherDrugs]

SELECT * FROM #Enroll
UNION
SELECT * FROM #FU

--SELECT * FROM [Reporting].[RA100].[t_op_OtherDrugs] ORDER BY SiteID, SubjectID, VisitDate, TreatmentName


END

GO
