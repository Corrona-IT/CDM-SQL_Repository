USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_subjectlog_TEST]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [GPP510].[v_op_subjectlog_TEST] AS 

Select vl.SiteID
	  ,CASE WHEN VL.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE VL.SFSiteStatus 
	   END AS SiteStatus
	  ,vl.SubjectID
	  ,cast(vl.visitDate as date) AS EnrollmentDate
	  ,(DATEPART(YEAR,vl.YearofBirth)) AS YearofBirth
	  ,CASE WHEN (ex.exit_date is null AND ex.exit_reason is null) THEN 'Active'
	  WHEN (ex.exit_date is not null AND ex.exit_reason is not null) THEN 'Exited'
	  WHEN (ex.exit_date is not null AND ex.exit_reason is null) THEN 'Exited - Incomplete Entry'
	  WHEN (ex.exit_date is null AND ex.exit_reason is not null) THEN 'Exited - Incomplete Entry'
	  END AS SubjectStatus
	  ,ex.exit_date 
	  ,ex.exit_reason_dec AS ExitReason
	  ,ex.exit_reason_specify AS ExitReasonDetails
	  
	  
From [Reporting].[GPP510].[v_op_VisitLog_TEST] vl 
left join [ZELTA_GPP_TEST].[staging].[exit] ex on vl.SubjectID = ex.Subnum and ex.PAGESEQ = 0
WHERE [VisitType] = 'Enrollment' --AND vl.SubjectID = 'GPP-9998-0010'
--ORDER BY SiteID

GO
