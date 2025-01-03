USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_VisitLog_V3]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [RA100].[v_op_VisitLog_V3]  as




SELECT SiteID
      ,SubjectID
	  ,VisitDate
	  ,CASE WHEN VisitType LIKE 'Follow%' THEN 'Follow-Up'
	   ELSE VisitType
	   END AS VisitType
	  ,VisitProviderID AS ProviderID
	  ,VisitSequence
	  ,'RA-100' AS Registry
FROM Reporting.RA100.t_op_SubjectVisits





GO
