USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_ModifiedIDs_OLD]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =================================================
-- Author:		Kevin Soe
-- Create date: 4/12/2022
-- Description:	View to obtain list of all IDs that have been modified in the TrialMaster EDC for the RA Registry. 
-- Will list full history of the ID changes that have occurred.
-- =================================================

		 --SELECT * FROM
CREATE VIEW [RA100].[v_op_ModifiedIDs_OLD] AS

/*Use AllImmutableIDs to obtain list of all Unique Immutable IDs [TrlObjectPatientId] and their associated display IDs [SubjectIDs] throughout history in TM and RAMP using the Audit trail. By using the Audit data, the list will include deleted subjects. */

WITH AllImmutableIDs AS 
(
SELECT 
      'TM' AS [Source]
	  --,P.[AuditId]
      ,P.[TrlObjectSiteId]
	  ,S.[Site Object SiteNo] AS [SiteID]
      ,P.[TrlObjectPatientId]
	  ,P.[DataValue] AS [SubjectID]
	  ,MIN(P.[zResponseDate]) AS [ModifiedDate]
	  --,P.[RoleName] AS [EDCRoleOfEditor] -- SELECT *
  FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits]  P 
  --[10.0.3.123].[OMNICOMM_RA100].[logs].[Patient] P
  LEFT JOIN [OMNICOMM_RA100].[dbo].[SITE] S ON P.[TrlObjectSiteId] = S.[TrlSiteId]
  WHERE S.[Site Object SiteNo] NOT LIKE '99%'
  AND P.[TrlObjectTypeId] IN (6)
  AND P.[DataValue] <> 'New Patient' 
  GROUP BY P.[TrlObjectSiteId], [Site Object SiteNo], [TrlObjectPatientId], [DataValue]

UNION

SELECT 
       'RAMP' AS [Source]
      --,NULL AS [AuditId]
      ,[SITEID] AS [TrlObjectSiteId]
      ,[STNO] AS [SiteID]
      ,[PATIENTID] AS [TrlObjectPatientId]
      ,[zRespVal] AS [DataValue]
      ,MIN([zRespDat]) AS [ModifiedDate]
	  --,[zRoleNam] AS [EDCRoleOfEditor]--SELECT *
      FROM [RA100].[t_op_RAMP_PatInfo_Audit]
      WHERE [QuestTxt] = 'Subject Number'
      AND [PATIENTID] <> '6150046'  --Specifically excluded because PT moved to Site 100 from Site 86 after RAMP and thus was creating a false positive
	  GROUP BY [SITEID], [STNO], [PATIENTID], [zRespVal]
)
,
/*Use AllNonDeletedSubjects to get a list of all subjects that have not been deleted in the live EDC. This list will be used to compare against the list of AllImmutableIDs so deleted subjects can be identified. */

AllNonDeletedSubjects AS
(
SELECT TrlobjectPatientID FROM [172.16.81.24].[DataModel_TMCORe_production].[dbo].[G_Patient Information_14]
)
,

/*Use DistinctIDCombos to create a list of distinct immutable IDs + Subject IDs from AllImmutableIDs so total times an Immutable ID + Subject ID combo appears on AllImmutableIDs can be determined.*/

  DistinctIDCombos AS 
  (
  SELECT DISTINCT
   [TrlObjectPatientId]
  ,[SubjectID]
  FROM AllImmutableIDs
  )
  ,

/*Use IDCount to determine how many times an immutable ID appears on DistinctIDCombos*/

  IDCount AS
  (
  SELECT 
  [TrlObjectPatientId]
  ,COUNT([TrlObjectPatientId]) AS [SubjectIDCount]
  FROM DistinctIDCombos
  GROUP BY [TrlObjectPatientId]
  )
  --,

/*Determine full list of subjects that have ever had their SubjectID modified by filtering out Immutable IDs that have only had 1 Subject ID associated with it*/

  SELECT 
	 K.[Source]
	,K.[TrlObjectSiteId]
	,K.[SiteID]
	,K.[TrlObjectPatientID]
	,I.[SubjectIDCount]
	,K.[SubjectID]
	,K.[ModifiedDate]
	,CASE
		WHEN K.[Source] = 'RAMP' THEN 'Hard Deleted'
		WHEN M.[TrlObjectPatientId] IS NULL THEN 'Soft Deleted'
		ELSE ''
	 END AS [DeletionStatus]
	--,K.[EDCRoleOfEditor]
  FROM AllImmutableIDs K
  LEFT JOIN IDCount I ON K.TrlObjectPatientId = I.TrlObjectPatientId
  LEFT JOIN AllNonDeletedSubjects M ON K.TrlObjectPatientId = M.TrlObjectPatientId -- Used to identify deleted subjects
  WHERE 
			I.[SubjectIDCount] > 1

GO
