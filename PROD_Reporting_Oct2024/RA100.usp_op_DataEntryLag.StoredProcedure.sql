USE [Reporting]
GO
/****** Object:  StoredProcedure [RA100].[usp_op_DataEntryLag]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =================================================
-- Author:		Kaye Mowrey
-- Create date: 7/12/2018
-- Description:	Procedure for Data Entry Lag Table
-- =================================================

CREATE PROCEDURE [RA100].[usp_op_DataEntryLag] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
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
CREATE TABLE [Reporting].[RA100].[t_op_DataEntryLag]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NOT NULL,
	[VisitType] [varchar](250) NULL,
	[VisitDate] [date] NULL,
	[CompletionDate] [date] NULL,
	[DifferenceInDays] [int] NULL,
	[VisitID] [bigint] NULL,
	[AuditID] [bigint] NULL,
	[AuditDate] [datetime] NULL,
	[SignedState] [int] NULL,
	[CompleteState] [int] NULL,
	[InCompleteState] [int] NULL,
	[TrlObjectStateBitMask] [bigint] NULL,
	[LastRefreshDate] [date] NULL
) ON [PRIMARY]
GO
*/


TRUNCATE TABLE [Reporting].[RA100].[t_op_DataEntryLag]

/************GET Site, Subject and Visit Info************/
if object_id('tempdb..#Subjects') is not null begin drop table #Subjects end

SELECT st.SiteId
	  ,st.[Site Number]
	  ,st.TrlObjectSiteId
	  ,st.TrlObjectId AS Site_TrlObjectId
	  ,s.PatientId
	  ,s.[Patient Number] AS SubjectID
	  ,s.TrlObjectPatientID
	  ,s.TrlObjectId AS Subject_TrlObjectId
	  ,v.ProCaption AS VisitType
	  ,v.VisitDate
	  ,v.VisitId
	  ,v.OrderNo
	  ,v.TrlObjectId
	  ,v.LastChange AS LastChangeDateTime
INTO #Subjects

FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Patient Information] s
JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Site Information] st ON s.SiteId=st.SiteId 
JOIN [172.16.81.24].[DataModel_TMCORe_production].[dbo].[visits] v ON v.PatientId=s.PatientId 

WHERE v.ProCaption IN ('Enrollment', 'Follow-up')
AND st.[Site Number] NOT IN (999, 998, 997)
AND ISNULL(v.VisitDate, '')<>''
AND DATEDIFF(DD, v.VisitDate, GetDate()) <= 730.0



/************GET AUDIT DATE FOR FIRST TIME ICRF SIGNED************/
if object_id('tempdb..#RowOrder') is not null begin drop table #RowOrder end

SELECT * 
INTO #RowOrder
FROM  (
		SELECT *
			  ,ROW_NUMBER() OVER(PARTITION BY t1.TrlObjectFormId ORDER BY t1.[AuditDate] asc) as SignOrder
		FROM (
				SELECT a.AuditId
				      ,a.[StateChangeDateTime]	as [AuditDate]
					  ,a.[TrlObjectFormId]
					  ,a.[TrlObjectTypeId]
					  ,a.[TrlObjectStateBitMask]
					  ,a.[TrlObjectVisitId]
				FROM --		select top 100 * from
						[172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
				WHERE a.[TrlObjectFormId] is not null
					AND a.[TrlObjectTypeId] =12   
					AND ((ISNULL(a.[TrlObjectStateBitmask], 0) & (8|4|2)) <> 0)
					AND DATEDIFF(DD, a.[StateChangeDateTime], GetDate()) <= 730.0
			) t1

	 ) t2 WHERE SignOrder = 1

	---select * from #RowOrder



/************GET AUDIT DATE FOR FIRST TIME ICRF SIGNED************/
if object_id('tempdb..#OB') is not null begin drop table #OB end

SELECT *
INTO #OB
FROM [172.16.81.24].[TMCORE_PRODUCTION].[dbo].[TrlObjectTypes] 




INSERT INTO [Reporting].[RA100].[t_op_DataEntryLag]
(
	[SiteID],
	[SubjectID],
	[VisitType],
	[VisitDate],
	[CompletionDate],
	[DifferenceInDays],
	[VisitID],
	[AuditID],
	[AuditDate],
	[SignedState],
	[CompleteState],
	[InCompleteState],
	[TrlObjectStateBitMask],
	[LastRefreshDate]
)


SELECT CAST(S.[Site Number] AS int) AS SiteID
     , CAST(S.[SubjectId] AS bigint) AS SubjectID
 	 , S.[VisitType] as [VisitType]
	 , CAST(S.[VisitDate] AS DATE) AS VisitDate
	 , CAST(a.[AuditDate] AS date) AS CompletionDate
	 , DATEDIFF(DD, S.[VisitDate], a.[AuditDate])  AS DifferenceInDays
	 , CAST(S.[VisitId] AS bigint) AS VisitID
	 , CAST(a.[AuditId] AS bigint) AS AuditID
     , a.[AuditDate]
	/**** SignedState will be 8 if Audit Date was Signed; CompleteState will be 4 if Audit Date was Complete], IncompleteState will be 2 if Audit Date was Incomplete ****/
  	 , ISNULL(a.[TrlObjectStateBitmask], 0) & (8) AS [SignedState]
 	 , ISNULL(a.[TrlObjectStateBitmask], 0) & (4) AS [CompleteState]
	 , ISNULL(a.[TrlObjectStateBitmask], 0) & (2) AS [InCompleteState]
	 , a.[TrlObjectStateBitMask]
	 , CAST(GETDATE() AS date) AS LastRefreshDate

FROM #RowOrder a
JOIN #OB ob ON ob.[TrlObjectTypeId] = a.[TrlObjectTypeId]
JOIN #Subjects S ON S.TrlObjectId=a.TrlObjectVisitId

WHERE DATEDIFF(DD, a.AuditDate, GetDate()) <= 730.0
---ORDER BY [Site Number], [SubjectId], [VisitDate]

END

GO
