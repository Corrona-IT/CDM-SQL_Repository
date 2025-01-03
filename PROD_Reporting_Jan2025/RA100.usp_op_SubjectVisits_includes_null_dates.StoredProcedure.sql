USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_SubjectVisits_includes_null_dates]    Script Date: 1/3/2025 4:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- ===========================================================================
-- Author:		Kaye Mowrey
-- Create date: 7/12/2018
-- Description:	Procedure for Subject Visits (Enrollment, Follow-Up, and Exit)
--              Does not include Test Sites 997, 998, 999
-- ===========================================================================

CREATE PROCEDURE [RA100].[usp_op_SubjectVisits_includes_null_dates] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*
CREATE TABLE [Reporting].[RA100].[t_op_SubjectVisits_wNoDates]
(

	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar] (30) NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[OnsetYear] [int] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[ProviderID] [int] NULL,
	[VisitID] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[OrderNo] [int] NULL,
	[LastChangeDateTime] [datetime] NULL,
	[VisitSigned] [int] NULL
) ON [PRIMARY]
GO
*/



TRUNCATE TABLE [Reporting].[RA100].[t_op_SubjectVisits_wNoDates];


IF OBJECT_ID('tempdb..#YOB') is not null BEGIN DROP TABLE #YOB END

SELECT [PEQ1].[Site Object SiteNo] AS SiteID
      ,[PEQ1].[Patient Object PatientNo] AS SubjectID
	  ,CASE WHEN [PEQ1].PEQ2_BRTHDAT='' THEN NULL
	   ELSE [PEQ1].PEQ2_BRTHDAT
	   END AS [YOB]

INTO #YOB
FROM [OMNICOMM_RA100].[dbo].[PEQ1]

--SELECT * FROM #YOB WHERE ISNULL(YOB, '')=''

IF OBJECT_ID('tempdb..#ONSET') is not null BEGIN DROP TABLE #ONSET END

SELECT [SiteID] AS SiteID
      ,[PatientId] AS PatientID
      ,[Sys. PatientNo] AS SubjectID
	  ,CASE WHEN [RASTYR]='' THEN NULL
	   ELSE [RASTYR]
	   END AS OnsetYear
INTO #ONSET
FROM [OMNICOMM_RA100].[dbo].[G_PHE3]

--SELECT * FROM #ONSET


IF object_id('tempdb..#PROVIDERID') is not null BEGIN DROP TABLE #PROVIDERID END
---SELECT * FROM #PROVIDERID where VisitType='Enrollment', 'FU'

SELECT VisitID
      ,SiteID
	  ,SubjectID
	  ,VisitType
	  ,VisitDate
	  ,ProviderID
INTO #PROVIDERID 
FROM
(
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CASE WHEN ISNULL([Visit Object VisitDate],'')='' THEN NULL
	   ELSE CAST([Visit Object VisitDate] AS date) 
	   END AS VisitDate
	  ,CASE WHEN ISNULL([PHE2_CPHID], '')='' THEN NULL
	   ELSE CAST([PHE2_CPHID] AS int)
	   END AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[PHEQ1]
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CASE WHEN ISNULL([Visit Object VisitDate],'')='' THEN NULL
	   ELSE CAST([Visit Object VisitDate] AS date) 
	   END AS VisitDate
	  ,CASE WHEN ISNULL([PHF1_CPHIDF], '')='' THEN NULL
	   ELSE CAST([PHF1_CPHIDF] AS int)
	   END AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[PHFQ1]
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CASE WHEN ISNULL([Visit Object VisitDate],'')='' THEN NULL
	   ELSE CAST([Visit Object VisitDate] AS date) 
	   END AS VisitDate
	  ,CASE WHEN ISNULL([EXIT1_PHID], '')='' THEN NULL
	   ELSE CAST([EXIT1_PHID] AS int)
	   END AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[EXIT]

) PID



---SELECT * FROM #PROVIDERID

INSERT INTO [Reporting].[RA100].[t_op_SubjectVisits_wNoDates]
(

	[SiteID],
	[SiteStatus],
	[PatientId],
	[SubjectID],
	[YOB],
	[OnsetYear],
	[VisitType],
	[VisitDate],
	[ProviderID],
	[VisitID],
	[VisitSequence],
	[OrderNo],
	[LastChangeDateTime],
	[VisitSigned]
)

SELECT CAST(st.[Site Information_Site Number] AS int) AS SiteID
	  ,CASE WHEN UPPER(st.[Site Information_Address 3])='X' THEN 'Inactive'
	   ELSE 'Active'
	   END AS SiteStatus
	  ,CAST(s.PatientId AS bigint) AS PatientId
	  ,CAST(s.[Patient Information_Patient Number] AS bigint) AS SubjectID
	  ,CAST(YOB.[YOB] AS int) AS [YOB]
	  ,CAST(ONSET.OnsetYear AS int) AS OnsetYear
	  ,v.[Visit Object ProCaption] AS VisitType
	  ,CASE WHEN ISNULL(v.[Visit Object VisitDate], '')='' THEN NULL
	   ELSE v.[Visit Object VisitDate] 
	   END AS VisitDate
	  ,CAST(PID.ProviderID AS int) AS ProviderID
	  ,CAST(v.VisitId AS int) AS VisitId
	  ,CAST(v.InstanceNo as int) AS VisitSequences
	  ,v.[Visit Object OrderNo] AS OrderNo
	  ,CAST(v.[Visit Object LastChange] AS datetime) as LastChangeDateTime
	  ,ISCRF.IS_ISATTEST AS VisitSigned

FROM OMNICOMM_RA100.[dbo].[VISIT] v
LEFT JOIN OMNICOMM_RA100.[dbo].[PAT] s ON s.PatientId=v.PatientId
LEFT JOIN OMNICOMM_RA100.[dbo].[SITE] st ON s.SiteId=st.SiteId 
LEFT JOIN OMNICOMM_RA100.[dbo].[IS] ISCRF ON ISCRF.[VisitId]=v.VisitId
LEFT JOIN #PROVIDERID PID ON v.VisitId=PID.VisitId
LEFT JOIN #YOB YOB ON YOB.SubjectID=s.[Patient Information_Patient Number]
LEFT JOIN #ONSET ONSET ON ONSET.PatientID=s.PatientId

WHERE v.[Visit Object ProCaption] IN ('Enrollment', 'Follow-up', 'Exit')
AND st.[Site Information_Site Number] NOT IN (999, 998, 997)
AND ISNUMERIC(s.[Patient Information_Patient Number])=1


---ORDER BY st.[Site Number], s.[Patient Number], v.VisitDate




END

GO
