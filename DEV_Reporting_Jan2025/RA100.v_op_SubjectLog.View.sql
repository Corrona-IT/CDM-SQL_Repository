USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_SubjectLog]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ===================================================================================================
-- V1.1 Author: Kevin Soe
-- V1.1 Create Date: 10/1/2020
-- ===================================================================================================


CREATE VIEW [RA100].[v_op_SubjectLog] AS

WITH EXITSWDUPS AS 
(
SELECT  
       ROW_NUMBER() OVER(PARTITION BY [Site Object SiteNo], [Patient Object PatientNo] ORDER BY [Site Object SiteNo], [Patient Object PatientNo], [Visit Object VisitDate] DESC, [EXIT2_EXITRSN] DESC) AS ROWNUM
	  ,CAST([Site Object SiteNo] AS int) AS SiteID
      ,CAST([Patient Object PatientNo] AS bigint) AS SubjectID
	  ,MAX(CONVERT(DATE, [Visit Object VisitDate])) AS ExitDate
	  ,[EXIT2_EXITRSN] AS ExitReason
	  ,[EXIT2_EXOTH1] AS ExitReasonDetails
FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[EXIT] E
WHERE [Site Object SiteNo] NOT IN (997, 998, 999)
AND NOT EXISTS (SELECT SubjectID FROM [RA100].[t_op_SubjectVisits] V WHERE V.SubjectID=CAST(E.[Patient Object PatientNo] AS bigint) AND V.VisitDate>E.[Visit Object VisitDate])
AND [Visit Object VisitDate] IS NOT NULL
GROUP BY [Site Object SiteNo], [Patient Object PatientNo], [Visit Object VisitDate], [EXIT2_EXITRSN], [EXIT2_EXOTH1]

)


,EXITS AS
(
SELECT DISTINCT ROWNUM
      ,SiteID
	  ,SubjectID
	  --V1 ExitDate
	  --,ExitDate
	  --V1.1 ExitDate
	  ,CASE
		WHEN ExitDate = '' THEN NULL
		ELSE ExitDate
		END AS ExitDate
	  ,CASE WHEN ISNULL(ExitDate, '')<>'' AND ISNULL(ExitReason, '')='' THEN 'Unknown Exit Reason'
	   ELSE ExitReason
	   END AS ExitReason
	  ,ExitReasonDetails
from EXITSWDUPS
WHERE ROWNUM=1
AND ExitDate IS NOT NULL OR ExitReason IS NOT NULL

)


,Visits AS
(
SELECT DISTINCT 
      ROW_NUMBER() OVER(PARTITION BY SV.SiteID, SV.SubjectID ORDER BY SV.SiteID, SV.SubjectID, SV.VisitDate, VisitType) AS ROWNUM   
      ,SV.SiteID
      ,SV.SiteStatus
	  ,CAST(SV.SubjectID AS bigint) AS SubjectID
	  ,SV.VisitDate AS VisitDate
	  ,SV.VisitType
	  ,SV.[YOB]

FROM [RA100].[t_op_SubjectVisits] SV
WHERE SV.VisitType IN ('Enrollment', 'Follow-up')
AND SV.SiteID NOT IN (997, 998, 999)
)

,MinVisit AS
(
SELECT ROWNUM
      ,SiteID
	  ,SiteStatus
	  ,SubjectID
	  ,VisitDate
	  ,VisitType
	  ,[YOB] 
FROM Visits 
WHERE ROWNUM=1 
)

SELECT DISTINCT 
       V.ROWNUM
	  ,V.SiteID
	  ,V.SiteStatus
	  ,V.SubjectID
	  ,V.VisitDate
	  ,V.VisitType
	  ,V.[YOB] 
	  ,E.ExitDate
	  ,E.ExitReason
	  ,E.ExitReasonDetails
FROM MinVisit V
LEFT JOIN EXITS E ON E.SubjectID=V.SubjectID


--ORDER BY SiteID, SubjectID, ROWNUM






GO
