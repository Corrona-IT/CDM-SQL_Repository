USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_subjectlog]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







Create VIEW [GPP510].[v_op_subjectlog] AS 

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
	  
	  
From [Reporting].[GPP510].[v_op_VisitLog] vl 
left join [ZELTA_GPP].[staging].[exit] ex on vl.SubjectID = ex.Subnum and ex.PAGESEQ = 0
WHERE vl.[VisitType] = 'Enrollment' --AND vl.SubjectID = 'GPP-9998-0010'
--ORDER BY SiteID

GO
