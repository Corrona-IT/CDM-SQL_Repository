USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_Exits]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [RA100].[v_op_Exits]  AS



 SELECT SiteID,
        SubjectID,
		PatientId,
		MAX(VisitDate) AS ExitDate, 
		VisitType
 FROM [Reporting].[RA100].[t_op_SubjectVisits] sv
 WHERE sv.VisitType='Exit' 
 AND ISNULL(sv.VisitDate, '')<>''
 AND sv.VisitDate >= (SELECT MAX(VisitDate) FROM [Reporting].[RA100].[t_op_SubjectVisits] sv2 WHERE sv2.VisitType IN ('Enrollment', 'Follow-Up') AND sv2.PatientId=sv.PatientId)
 GROUP BY SiteID, SubjectID, PatientId, VisitType


GO
