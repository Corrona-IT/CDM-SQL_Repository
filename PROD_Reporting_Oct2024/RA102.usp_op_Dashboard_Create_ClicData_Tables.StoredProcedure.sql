USE [Reporting]
GO
/****** Object:  StoredProcedure [RA102].[usp_op_Dashboard_Create_ClicData_Tables]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [RA102].[usp_op_Dashboard_Create_ClicData_Tables] AS
	-- Add the parameters for the stored procedure here

/*

*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* DO NOT DROP AND RECREATE, USER "ClicData" HAS OBJECT LEVEL PERMISIONS
    -- Insert statements for procedure here
	IF OBJECT_ID('[CDM].[t_RA_Japan_Subj_Elig_Dashboard]', 'U') IS NOT NULL  DROP TABLE [CDM].[t_RA_Japan_Subj_Elig_Dashboard]; 

CREATE TABLE [RA102].[t_Subj_Elig_Dashboard](
	[SiteID] [int] NULL,
	[ProviderID] [int] NULL,
	[SubjectID] [bigint] NULL,
	[VisitDate] [date] NULL,
	[VisitType] [varchar](50) NOT NULL,
	[AGE] [int] NULL,
	[AtLeast18] [int] NULL,
	[YR_ONSET_RA] [int] NULL,
	[Diagnosed] [int] NULL,
	[Drug] [varchar](85) NULL,
	[EligibleDrug] [int] NULL,
	[PrescAtVisit] [int] NULL,
	[PriorUse] [int] NULL,
	[EligPresc_woPriorUse] [int] NULL
);


IF OBJECT_ID('[RA102].[t_Subj_Elig_Dashboard]', 'U') IS NOT NULL  DROP TABLE [RA102].[t_Subj_Elig_Dashboard]; 

CREATE TABLE [RA102].[t_op_VISITLOG_DASHBOARD](
	[Site ID] [bigint] NULL,
	[Subject ID] [nvarchar](50) NULL,
	[Visit Type] [nvarchar](100) NULL,
	[Visit Date] [date] NULL,
	[Month] [varchar](3) NOT NULL,
	[Year] [int] NULL
);

select count(*) from [RA102].[t_op_VISITLOG_DASHBOARD] -- 999
select count(*) from [RA102].[t_Subj_Elig_Dashboard] -- 680



*/




TRUNCATE TABLE [RA102].[t_Subj_Elig_Dashboard];
TRUNCATE TABLE [RA102].[t_op_VISITLOG_DASHBOARD];


WITH ELIGLIST AS
(
SELECT CASE 
       WHEN d.[Drug]='MTX' THEN 'ZZ_MTX'
	   ELSE d.[Drug]
	   END AS Drug_Order
      ,e1.[SiteID]
      ,e1.[ProviderID]
      ,e.[SubjectID]
      ,e.[VisitDate]
      ,dbl.[VisitType]
	  ,e.[AGE]
	  ,case when e.[Age] >= 18 then 1 else NULL end as [AtLeast18]
	  ,e.[Yr_Onset_RA]
	  ,CASE WHEN e.[Diagnosed]='RA' THEN 1 ELSE NULL END AS [Diagnosed]
      ,d.[Drug]
      ,d.[EligibleDrug]
      ,d.[PrescAtVisit]
      ,d.[PriorUse]
      ,d.[DrugReqSatisfied] as [EligPresc_woPriorUse]


  --		select *
  FROM [Reimbursement].[cdb_rajp].[v_EnrollmentEligibility] e
  join [Reimbursement].[cdb].[v_EnrollmentEligibility_wEFE] e1 on e.[SourceVisitID] = e1.[SourceVisitID]
  and e.[CorronaRegistryID] = e1.[CorronaRegistryID]

  join [CorronaDB_Load].[dbo].[edcvisittype] dbl on e.visittypeid=dbl.visittypeid

  join --		select * from
		[Reimbursement].[cdb_rajp].[v_Drugs_PrescAtVisit_PriorUse] d
  on e.[SourceVisitID] = d.[SourceVisitID] 
  and e.[CorronaRegistryID] = d.[CorronaRegistryID]

  WHERE e.[CorronaRegistryID] = 5
  AND d.[DrugReqSatisfied]=1
  AND e1.[SiteID] NOT LIKE '9%'

  ---ORDER BY SiteID, SubjectID, VisitDate
)

,ORDEREDLIST AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY [SubjectID], [VisitDate] ORDER BY [SubjectID], [VisitDate], [Drug_Order]) AS ROWNBR
	  ,EL.SiteID
      ,EL.ProviderID
	  ,EL.SubjectID
	  ,EL.VisitDate
	  ,EL.VisitType
	  ,EL.AGE
	  ,EL.AtLeast18
	  ,EL.YR_ONSET_RA
	  ,EL.Diagnosed
	  ,EL.Drug
	  ,EL.Drug_Order
	  ,EL.EligibleDrug
	  ,EL.PrescAtVisit
	  ,EL.PriorUse
	  ,EL.EligPresc_woPriorUse
FROM ELIGLIST EL
)

insert into [RA102].[t_Subj_Elig_Dashboard] (
	   [SiteID]
      ,[ProviderID]
      ,[SubjectID]
      ,[VisitDate]
      ,[VisitType]
      ,[AGE]
      ,[AtLeast18]
      ,[YR_ONSET_RA]
      ,[Diagnosed]
      ,[Drug]
      ,[EligibleDrug]
      ,[PrescAtVisit]
      ,[PriorUse]
      ,[EligPresc_woPriorUse]
	)
SELECT CAST(SiteID AS int) AS SiteID
      ,CAST(ProviderID AS int) AS ProviderID
	  ,CAST(SubjectID AS bigint) AS SubjectID
	  ,CAST(VisitDate AS DATE) AS VisitDate
	  ,VisitType
	  ,CAST(AGE AS int) AS AGE
	  ,CAST(AtLeast18 AS int) AS AtLeast18
	  ,CAST(YR_ONSET_RA AS int) AS YR_ONSET_RA
	  ,CAST(Diagnosed AS int) AS Diagnosed
	  ,Drug
	  ,CAST(EligibleDrug AS int) AS EligibleDrug
	  ,CAST(PrescAtVisit AS int) AS PrescAtVisit
	  ,PriorUse
	  ,CAST(EligPresc_woPriorUse AS int) AS EligPresc_woPriorUse
FROM ORDEREDLIST OL
WHERE ROWNBR=1 and SiteID NOT IN (9997, 9998, 9999);
---ORDER BY SiteID, SubjectID, VisitDate



insert into [RA102].[t_op_VISITLOG_DASHBOARD] (
	   [Site ID]
      ,[Subject ID]
      ,[Visit Type]
      ,[Visit Date]
      ,[Month]
      ,[Year]
  )

SELECT dp.SITENUM AS [Site ID]
     , dp.SUBNUM AS [Subject ID]
	 , dp.VISNAME AS [Visit Type]
	 , CAST(VIS.VISITDATE as date) AS [Visit Date]
	 , CASE
	   WHEN DATEPART(Month, VIS.VISITDATE)=1 THEN 'Jan'
	   WHEN DATEPART(Month, VIS.VISITDATE)=2 THEN 'Feb'
	   WHEN DATEPART(Month, VIS.VISITDATE)=3 THEN 'Mar'
	   WHEN DATEPART(Month, VIS.VISITDATE)=4 THEN 'Apr'
	   WHEN DATEPART(Month, VIS.VISITDATE)=5 THEN 'May'
	   WHEN DATEPART(Month, VIS.VISITDATE)=6 THEN 'Jun'
	   WHEN DATEPART(Month, VIS.VISITDATE)=7 THEN 'Jul'
	   WHEN DATEPART(Month, VIS.VISITDATE)=8 THEN 'Aug'
	   WHEN DATEPART(Month, VIS.VISITDATE)=9 THEN 'Sep'
	   WHEN DATEPART(Month, VIS.VISITDATE)=10 THEN 'Oct'
	   WHEN DATEPART(Month, VIS.VISITDATE)=11 then 'Nov'
	   WHEN DATEPART(Month, VIS.VISITDATE)=12 THEN 'Dec'
	   ELSE ''
	   END AS [Month]
	 , DATEPART(Year, VIS.VISITDATE) AS [Year]
FROM   --		select * from  
	[MERGE_RA_Japan].dbo.DAT_PAGS AS dp 
LEFT OUTER JOIN--		select * from  
         [MERGE_RA_Japan].dbo.VIS_DATE AS VIS 
ON VIS.SUBID = dp.SUBID AND VIS.VISITID = dp.VISITID AND VIS.VISITSEQ = dp.VISITSEQ
WHERE  (dp.PAGENAME = 'Date of visit') 
       AND ISNULL(VIS.VISITDATE, '')<>''
       AND dp.SUBNUM IN (SELECT SubjectID FROM [MERGE_RA_Japan].[CDM].[t_RA_Japan_Subj_Elig_Dashboard])
	   AND dp.SITENUM NOT IN (9997, 9998, 9999);

---ORDER BY dp.SITENUM, dp.SUBNUM, VIS.visitdate

/*
		select count(*) from [CDM].[t_RA_Japan_Subj_Elig_Dashboard]
		select count(*) from [MERGE_RA_Japan].[CDM].[t_RA_JAPAN_VISITLOG_DASHBOARD]
*/

END



GO
