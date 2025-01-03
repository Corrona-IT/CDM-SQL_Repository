USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_SubjectVisits2]    Script Date: 11/13/2024 1:41:25 PM ******/
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

CREATE PROCEDURE [RA100].[usp_op_SubjectVisits2] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
  SET NOCOUNT ON;



/*
CREATE TABLE [Reporting].[RA100].[t_op_SubjectVisits2]
(
	[SiteID] [int] NOT NULL,
	[SiteStatus] [varchar] (30) NULL,
	[PatientId] [bigint] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[YOB] [int] NULL,
	[OnsetYear] [int] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[EnrollingProviderID] [int] NULL,
	[VisitProviderID] [int] NULL,
	[VisitID] [bigint] NULL,
	[VisitSequence] [int] NULL,
	[OrderNo] [int] NULL,
	[LastChangeDateTime] [datetime] NULL,
	[VisitSigned] [int] NULL
) ON [PRIMARY]
GO
*/




IF object_id('tempdb..#ENROLLINGPROVIDERID') is not null BEGIN DROP TABLE #ENROLLINGPROVIDERID END
---SELECT * FROM #PROVIDERID where VisitType='Enrollment', 'FU'

SELECT SiteID
	  ,SubjectID
	  ,EnrollingProviderID
INTO #ENROLLINGPROVIDERID 
FROM
(
SELECT [Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Patient Information_ENPHID] AS EnrollingProviderID
FROM [OMNICOMM_RA100].[dbo].[PAT]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
) EPID


IF OBJECT_ID('tempdb..#YOB') is not null BEGIN DROP TABLE #YOB END

SELECT [PEQ1].[Site Object SiteNo] AS SiteID
      ,[PEQ1].[Patient Object PatientNo] AS SubjectID
	  ,CASE WHEN [PEQ1].PEQ2_BRTHDAT='' THEN NULL
	   ELSE [PEQ1].PEQ2_BRTHDAT
	   END AS [YOB]
INTO #YOB
FROM [OMNICOMM_RA100].[dbo].[PEQ1] [PEQ1]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)

IF OBJECT_ID('tempdb..#ONSET') is not null BEGIN DROP TABLE #ONSET END

SELECT [SiteID] AS SiteID
      ,[PatientId] AS PatientID
      ,[Sys. PatientNo] AS SubjectID
	  ,CASE WHEN [RASTYR]='' THEN NULL
	   ELSE [RASTYR]
	   END AS OnsetYear
INTO #ONSET
FROM [OMNICOMM_RA100].[dbo].[G_PHE3]
WHERE [SiteID] NOT IN (997, 998, 999)

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
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[PHE2_CPHID] AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[PHEQ1]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[PHF1_CPHIDF] AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[PHFQ1]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[EXIT1_PHID] AS ProviderID
FROM [OMNICOMM_RA100].[dbo].[EXIT]
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)

) PID

IF OBJECT_ID('tempdb..#SubjectList') is not null BEGIN DROP TABLE #SubjectList END

SELECT CAST(st.[Site Object SiteNo] AS int) AS SiteID
	  ,CASE WHEN UPPER(st.[Site Information_Address 3])='X' THEN 'Inactive'
	   ELSE 'Active'
	   END AS SiteStatus
	  ,CAST(s.PatientId AS bigint) AS PatientId
	  ,s.[Patient Object PatientNo] AS SubjectID
	  ,YOB.[YOB]
	  ,ONSET.OnsetYear
	  ,v.[Visit Object ProCaption] AS VisitType
	  ,CAST(v.[Visit Object VisitDate] AS date) AS VisitDate
	  ,CAST(EPID.EnrollingProviderID AS int) as EnrollingProviderID
	  ,CAST(PID.ProviderID AS int) AS VisitProviderID
	  ,CAST(v.VisitId AS int) AS VisitId
	  ,CAST(v.InstanceNo as int) AS VisitSequence
	  ,CAST(v.[Visit Object OrderNo] AS int) as OrderNo
	  ,CAST(v.[Visit_LatestDataChange] AS datetime) as LastChangeDateTime
	  ,ISCRF.IS_ISATTEST AS VisitSigned
INTO #SubjectList
FROM [OMNICOMM_RA100].[dbo].[PAT] s
JOIN [OMNICOMM_RA100].[dbo].[SITE] st ON s.SiteId=st.SiteId 
JOIN [OMNICOMM_RA100].[dbo].[VISIT] v ON v.PatientId=s.PatientId 
LEFT JOIN [OMNICOMM_RA100].[dbo].[IS] ISCRF ON ISCRF.[VisitId]=v.VisitId
LEFT JOIN #PROVIDERID PID ON v.VisitId=PID.VisitId
LEFT JOIN #ENROLLINGPROVIDERID EPID ON EPID.SubjectID=s.[Patient Object PatientNo]
LEFT JOIN #YOB YOB ON YOB.SubjectID=s.[Patient Object PatientNo]
LEFT JOIN #ONSET ONSET ON ONSET.PatientID=s.PatientId

WHERE v.[Visit Object ProCaption] IN ('Enrollment', 'Follow-up', 'Exit')
AND st.[Site Object SiteNo] NOT IN (999, 998, 997)
AND ISNULL(v.[Visit Object VisitDate], '')<>''


TRUNCATE TABLE [Reporting].[RA100].[t_op_SubjectVisits2];

INSERT INTO [Reporting].[RA100].[t_op_SubjectVisits2]
(
	[SiteID],
	[SiteStatus],
	[PatientId],
	[SubjectID],
	[YOB],
	[OnsetYear],
	[VisitType],
	[VisitDate],
	[EnrollingProviderID],
	[VisitProviderID],
	[VisitID],
	[VisitSequence],
	[OrderNo],
	[LastChangeDateTime],
	[VisitSigned]
)

SELECT SiteID
	  ,SiteStatus
	  ,PatientId
	  ,CAST(SubjectID AS bigint) AS SubjectID
	  ,[YOB]
	  ,OnsetYear
	  ,VisitType
	  ,VisitDate
	  ,EnrollingProviderID
	  ,VisitProviderID
	  ,VisitId
	  ,VisitSequence
	  , OrderNo
	  ,LastChangeDateTime
	  ,VisitSigned

FROM #SubjectList







END

GO
