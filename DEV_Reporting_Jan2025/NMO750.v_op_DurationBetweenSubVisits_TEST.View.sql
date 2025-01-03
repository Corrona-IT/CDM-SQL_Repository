USE [Reporting]
GO
/****** Object:  View [NMO750].[v_op_DurationBetweenSubVisits_TEST]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





		 --SELECT * FROM
CREATE VIEW [NMO750].[v_op_DurationBetweenSubVisits_TEST] AS
With DemoView As
(
SELECT ROW_NUMBER() OVER(PARTITION BY VL.SiteID, VL.SubjectID ORDER BY VL.VisitDate) AS [ROWNUM],
     VL.[SubjectID] AS [SubjectID],
	 VL.[SiteID] AS [SiteID],
	 VL.[SFSiteStatus] AS [SiteStatus],
	 VL.[VisitType] AS [VisitType],
	 VL.[VisitDate] AS [VisitDate],
	 (SELECT VisitDate FROM [Reporting].[NMO750].[t_op_VisitLog] TT
	 WHERE TT.VisitType='Enrollment' AND TT.EligibleVisit='Yes' AND TT.SubjectID = VL.SubjectID) AS [EnrollmentVisit]

FROM [Reporting].[NMO750].[t_op_VisitLog] VL 
WHERE ISNULL(VL.VisitDate, '')<>''
 AND VL.EligibleVisit='Yes'
 AND VL.VisitType IN ('Follow-up')
 AND VL.SubjectID IN (SELECT SubjectID FROM [Reporting].[NMO750].[t_op_VisitLog] WHERE VisitType='Enrollment' AND EligibleVisit='Yes')
)
,followupvis AS
(
 Select VLL.[SubjectID],
        'V' + CAST((VLL.[ROWNUM]) AS nvarchar) + ': ' + CAST(VLL.[VisitDate] AS nvarchar) AS [FollowUp],
		CASE 
		WHEN VLL.[ROWNUM] = 1 
		THEN 'EN/V' + CAST((VLL.[ROWNUM]) AS nvarchar) + ': ' + CAST(DATEDIFF(D, VLL.[EnrollmentVisit], VLL.[VisitDate]) AS nvarchar)
		WHEN VLL.[ROWNUM] > 1 
		THEN 'V' + CAST((VLL.[ROWNUM]-1) AS nvarchar) + '/V' + CAST((VLL.[ROWNUM]) AS nvarchar) + ': ' +
		CAST(DATEDIFF(D, 
		(Select DLL.[VisitDate] FROM DemoView DLL 
		WHERE DLL.[ROWNUM] = (VLL.ROWNUM-1) AND DLL.[SubjectID] = VLL.[SubjectID]), 
		VLL.[VisitDate]) AS nvarchar)
		WHEN VLL.[ROWNUM] = 0 THEN ' '
		END AS [DurationBet]
		FROM DemoView VLL
		WHERE VisitType IN ('Follow-up')
)
 SELECT 
 --[ROWNUM],
 [SiteID],
 [SubjectID],
 [SiteStatus],

-- [VisitType],
-- [VisitDate],
 [EnrollmentVisit],
 STUFF((
        SELECT DISTINCT '    ' + FollowUp
        FROM followupvis RS
        WHERE RS.subjectID=DemoView.SubjectID
        FOR XML PATH('')
        )
        ,1,1,'') AS [FollowupVisits],
 STUFF((
        SELECT DISTINCT '    ' + DurationBet
        FROM followupvis RS
        WHERE RS.subjectID=DemoView.SubjectID
        FOR XML PATH('')
        )
        ,1,1,'') AS [FollowupVisitDuration]

 FROM DemoView
 WHERE [ROWNUM] = 1
GO
