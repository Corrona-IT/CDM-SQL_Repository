USE [Reporting]
GO
/****** Object:  View [PSA400].[v_op_IncompleteVisits_20180921pre]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [PSA400].[v_op_IncompleteVisits_20180921pre]  as 


SELECT
      evh.CorronaRegistryID,
      evh.SiteID,
      evh.[SubjectID],
      evh.[VisitDate],
      evh.[VisitSEQ],
      CASE WHEN evt.[VisitType]= 'FollowUp' THEN 'Follow Up'
	  ELSE evt.[VisitType]
	  END AS VisitType,
      CASE WHEN ers.[EDCResponseStatus]='InComplete' THEN 'Incomplete'
	  WHEN ers.[EDCResponseStatus]='NoData' THEN 'No data'
	  ELSE ers.[EDCResponseStatus]
	  END AS EDCResponseStatus
FROM [CorronaDB_Load].[dbo].[EDCVisitHeader] evh
JOIN [CorronaDB_Load].[dbo].[EDCResponseStatus] ers
on ers.EDCResponseStatusID = evh.EDCResponseStatusID
JOIN [CorronaDB_Load].[dbo].[EDCVisitType] evt
on evt.VisitTypeID = evh.VisitTypeID
where evt.[VisitTypeID] in (
              2 --Enrollment 
             ,3 --FollowUp 
             ,4 --TAE 
             ,5 --Pregnancy 
             ,7 --Exit 
       )            
AND ers.[EDCResponseStatusID] IN (
			  1 -- Signed
             ,2 -- NoData
             ,3 -- InComplete
             ,4 ) -- Monitored*
AND ISNULL(evh.[VisitDate], '')<>''
AND CorronaRegistryID=3  ---PSA is RegistryID 3
AND evh.SiteID NOT IN (99997, 99998, 99999)   

---ORDER BY SiteID, SubjectID
 

GO
