USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_DataEntryCompletion]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =======================================================
-- Author:		Kaye Mowrey
-- Create date: 7/26/2018
-- Description:	Procedure for Data Entry Completion Table
-- =======================================================

CREATE PROCEDURE [RA100].[usp_op_DataEntryCompletion] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/*
**********READ NOTES FROM OC*******************
see email string for incident 69322 from OC
OC Example:
To check if TrlObjectStateBitmask contains flag for signed:
(TrlObjectStateBitmask & 8) <> 0


To check if TrlObjectStateBitmask contains flag for signed or complete:
(TrlObjectStateBitmask & 12) <> 0
Or you can use “|” to create compound states (in this example, we are checking for either signed or complete states):
(TrlObjectStateBitmask & (8|4)) <> 0

To check if TrlObjectStateBitmask contains flag for signed or complete:
(TrlObjectStateBitmask & 12) <> 0
Or you can use “|” to create compound states (in this example, we are checking for either signed or complete states):
(TrlObjectStateBitmask & (8|4)) <> 0

TrlObjectStateId Caption                
---------------- -----------------------
1                No Data                
2                Incomplete             
4                Complete               
8                Signed                 
16               Partial Monitored      
32               Monitored              
64               Reviewed               
128              Locked                 
256              AddNotes               
512              QueryNew               
1024             QueryResponse          
2048             QueryReview            
4096             QueryClose             
8192             QueryReopen            
32768            Comments               
65536            Hidden                 
131072           Disabled               
262144           ReadOnly               
524288           BypassValidation       
1048576          SpecialLocked          
4194304          TemporaryObject        
8388608          ImportTemporaryObject  
16777216         DDEPass1Started        
33554432         DDEPass1Complete       
67108864         DDEPass2Started        
134217728        DDEPass2Complete       
536870912        DeletedItem            
1073741824       DeActive               
*/

/*

CREATE TABLE [RA100].[t_op_DataEntryCompletion]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitID] [bigint] NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NOT NULL,
	[CompletionInMinutes] [Dec] (20,2) NULL,
	[CompletionInHours] [dec] (20,2) NULL
);
*/


TRUNCATE TABLE [RA100].[t_op_DataEntryCompletion]


/************GET Site, Subject, and Visit Date************/
IF object_id('tempdb..#PROVIDERID') is not null BEGIN DROP TABLE #PROVIDERID END

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
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHEQ1]
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[PHF1_CPHIDF] AS ProviderID
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[PHFQ1]
UNION
SELECT VisitId
      ,[Site Object SiteNo] AS SiteID
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object ProCaption] AS VisitType
	  ,CAST([Visit Object VisitDate] AS date) AS VisitDate
	  ,[EXIT1_PHID] AS ProviderID
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[EXIT]

) PID


IF object_id('tempdb..#Subjects') is not null BEGIN DROP TABLE #Subjects END

SELECT CAST(st.SiteId AS bigint) AS AutoSiteID
	  ,CAST(st.[Site Number] AS int) AS SiteID
	  ,CAST(st.TrlObjectSiteId AS int) AS TrlObjectSiteId
	  ,CAST(st.TrlObjectId AS int) AS Site_TrlObjectId
	  ,CAST(s.PatientId AS bigint) AS PatientId
	  ,CAST(s.[Patient Number] AS bigint) AS SubjectID
	  ,CAST(s.TrlObjectPatientID AS bigint) AS TrlObjectPatientID
	  ,CAST(s.TrlObjectId AS bigint) as Subject_TrlObjectId
	  ,v.ProCaption AS VisitType
	  ,CAST(v.VisitDate AS date) AS VisitDate
	  ,CAST(PID.ProviderID AS int) AS VisitProviderID
	  ,CAST(v.VisitId AS int) AS VisitId
	  ,CAST(v.InstanceNo as int) AS VisitSequence
	  ,CAST(v.OrderNo AS int) as OrderNo
	  ,CAST(v.TrlObjectId AS bigint) AS TrlObjectId
	  ,CAST(v.LastChange AS datetime) as LastChangeDateTime
INTO #Subjects
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Patient Information] s
JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] st ON s.SiteId=st.SiteId 
JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[visits] v ON v.PatientId=s.PatientId 
LEFT JOIN #PROVIDERID PID ON v.VisitId=PID.VisitId
WHERE v.ProCaption IN ('Enrollment', 'Follow-up', 'Exit')
AND st.[Site Number] NOT IN (999, 998, 997)
AND ISNULL(v.VisitDate, '')<>''
AND ISNULL(v.[VisitDate], '')<>''
AND DATEDIFF(DD, v.[VisitDate], GetDate()) <= 730.0

---SELECT * FROM #Subjects

/******GET AUDIT DATE FOR Visit Page Creation (No Data for Enroll) or Incomplete/Complete Stage (FU)********************/
IF object_id('tempdb..#CreatedDate') IS NOT NULL BEGIN DROP TABLE #CreatedDate END

SELECT * 
INTO #CreatedDate
FROM  (
		SELECT [AuditId]
		      ,[CreateDate]
			  ,[TrlObjectFormId]
			  ,[TrlObjectTypeId]
			  ,[TrlObjectStateBitMask]
			  ,[TrlObjectVisitId]
			  ,ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[CreateDate] asc) as SignOrder
		FROM (
				SELECT a.[AuditId]
				      ,a.[StateChangeDateTime]	as [CreateDate]
					  ,a.[TrlObjectFormId]
					  ,a.[TrlObjectTypeId]
					  ,a.[TrlObjectStateBitMask]
					  ,a.[TrlObjectVisitId]
				FROM --		select top 100 * from
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
				WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId] =12   
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (1|2|4|8)) <> 0)

			) t1

	 ) t2 WHERE SignOrder = 1
	   AND DATEDIFF(DD, [CreateDate], GetDate()) < 730.0

	 ---SELECT * FROM #CreatedDate

/************GET AUDIT DATE FOR FIRST TIME Signature Form Completed or Signed************/
IF object_id('tempdb..#SignedDate') IS NOT NULL BEGIN DROP TABLE #SignedDate END

SELECT * 
INTO #SignedDate
FROM  (
		SELECT [AuditId]
		      ,[SignDate]
			  ,[TrlObjectFormId]
			  ,[TrlObjectTypeId]
			  ,[TrlObjectStateBitMask]
			  ,[TrlObjectVisitId]
			  ,ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[SignDate] asc) as CreateOrder
		FROM (
				SELECT a.[AuditId]
				      ,a.[StateChangeDateTime]	as [SignDate]
					  ,a.[TrlObjectFormId]
					  ,a.[TrlObjectTypeId]
					  ,a.[TrlObjectStateBitMask]
					  ,a.[TrlObjectVisitId]
				FROM ---  select top 100 * from
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
				WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId]=8 AND a.[DataValue]='Initial Signature'
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4)) <> 0)

			) t1

	 ) t2 WHERE CreateOrder = 1
	   AND DATEDIFF(DD, [SignDate], GetDate()) < 730
	---SELECT * from #SignedDate


/************GET ObjectTypes************/
if object_id('tempdb..#OB') is not null begin drop table #OB end

SELECT *
INTO #OB
FROM [172.16.81.24].[TMCORE_PRODUCTION].[dbo].[TrlObjectTypes] 


/************GET Created Date and Visit Info************/
IF object_id('tempdb..#Created') is not null BEGIN DROP TABLE #Created END

SELECT CAST(S.SiteID AS int) AS SiteID
       ,CAST(S.SubjectID AS bigint) AS SubjectID
	   ,CAST(S.VisitID AS bigint) AS VisitID
	   ,S.VisitType
	   ,CAST(S.VisitDate AS date) AS VisitDate
	   ,CAST(CD.CreateDate AS datetime) AS CreatedDate
INTO #Created   
FROM #CreatedDate CD
JOIN #OB OB ON OB.[TrlObjectTypeId] = CD.[TrlObjectTypeId]
JOIN #Subjects S ON S.TrlObjectId=CD.TrlObjectVisitId


/************GET Completion Date and Visit Info************/
IF object_id('tempdb..#Signed') is not null BEGIN DROP TABLE #Signed END

SELECT CAST(S.SiteID AS int) AS SiteID
       ,CAST(S.SubjectID AS bigint) AS SubjectID
	   ,CAST(S.VisitID AS bigint) AS VisitID
	   ,S.VisitType
	   ,CAST(S.VisitDate AS date) AS VisitDate
	   ,CAST(SD.SignDate AS datetime) AS CompletionDate
INTO #Signed   
FROM #SignedDate SD
JOIN #OB OB ON OB.[TrlObjectTypeId] = SD.[TrlObjectTypeId]
JOIN #Subjects S ON S.TrlObjectId=SD.TrlObjectVisitId

INSERT INTO [RA100].[t_op_DataEntryCompletion]
(
	[SiteID],
	[SubjectID],
    [VisitID],
	[VisitType],
	[VisitDate],
	[CreatedDate],
	[CompletionDate],
	[CompletionInMinutes],
	[CompletionInHours]
)


SELECT  CD.SiteID
       ,CD.SubjectID
	   ,CD.VisitID
	   ,CD.VisitType
	   ,CD.VisitDate
	   ,CD.CreatedDate
	   ,SD.CompletionDate
	   ,DATEDIFF(MI, CD.CreatedDate, SD.CompletionDate) AS CompletionInMinutes
	   ,DATEDIFF(HH, CD.CreatedDate, SD.CompletionDate) AS CompletionInHours  
FROM #Created CD
LEFT JOIN #Signed SD ON SD.[VisitID] = CD.VisitID AND SD.SubjectID=CD.SubjectID 
WHERE CD.CreatedDate IS NOT NULL
AND SD.CompletionDate IS NOT NULL

--SELECT * FROM [RA100].[t_op_DataEntryCompletion] ORDER BY SiteID, SubjectID, VisitDate


END

GO
