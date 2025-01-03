USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_DataEntryCompletion]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [GPP510].[v_op_DataEntryCompletion] AS

WITH DEC1 AS
(
SELECT DISTINCT VIS.SiteID as SiteID,
		VIS.SubjectID as SubjectID,
	  CASE WHEN VIS.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE vis.SFSiteStatus 
	   END AS SiteStatus,
		VIS.[VisitType] as VisitOrEventType,
		VIS.EventOccurance as EventOccurrence,
        VIS.VisitDate as VisitDate,
        'Incomplete' as CompletionStatus 

 FROM [GPP510].[v_op_VisitLog] VIS
--Where VIS.[Visit Type] NOT IN ('Subject Exit','Follow-Up (Non-flaring)','Enrollment')
LEFT JOIN [ZELTA_GPP].[dbo].[VISIT_COMP] COMP on VIS.vID = COMP.vID
LEFT JOIN [ZELTA_GPP].[dbo].[REIMB] REI on VIS.vID = REI.vID
LEFT JOIN [ZELTA_GPP].[dbo].[EVNTSTAT] EV on VIS.vID = EV.vID
WHERE -- Enrollment, Follow-up, Exit,  in the EDC with no data entry completion form
(VIS.[VisitType] IN ('Subject Exit','Follow-Up (Non-flaring)','Enrollment') AND COMP.STATUSID_DEC IS NULL) 
OR  -- Enrollment, Follow-up, Exit,  in the EDC with a data entry completion page and a status of incomplete for visits
(COMP.VISNAME IN ('Subject Exit','Follow-Up (Non-flaring)','Enrollment') AND COMP.STATUSID_DEC != 'Complete')
OR -- TAE or pregnancy with  a confirmation status of 'confirmed event'  that is incomplete and not paid.
(VIS.[VisitType] NOT IN ('Subject Exit','Follow-Up (Non-flaring)','Enrollment') 
AND ISNULL(EV.EVNTSTAT_DEC, '') IN ('Confirmed event', '') 
AND (COMP.STATUSID_DEC != 'Complete' OR COMP.STATUSID_DEC IS NULL)
AND (REI.VISIT_PAID != 'X' OR REI.VISIT_PAID IS NULL)
)
)
--above is the code to bring in all incomplete visits, below is to make a line for any sites that have no incomplete visits saying all are completed
,NoRecords AS (
	SELECT SITE1.SITENUM as SiteID,
		'' as SubjectID,
	  CASE WHEN SITE1.SITENUM IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE RS.currentStatus
	   END AS SiteStatus,
		'' as VisitOrEventType,
		'' as EventOccurrence,
        '' as VisitDate,
        'All records completed' as CompletionStatus 
		FROM [GPP510].[v_op_SiteParameter] Site1
		LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
		ON CAST(RS.siteNumber AS VARCHAR(50)) = CAST(SITE1.SITENUM AS VARCHAR(50)) 
		AND RS.name = 'Generalized Pustular Psoriasis (GPP-510)'
        --LEFT JOIN [GPP510].[v_op_VisitLog] VIS1 ON VIS1.SiteID = Site1.SITENUM
        WHERE Site1.SITENUM NOT IN (SELECT DISTINCT SiteID FROM DEC1)
)
SELECT  SiteID,
		SubjectID,
	    SiteStatus,
		VisitOrEventType,
		EventOccurrence,
        VisitDate,
        CompletionStatus 
FROM DEC1

UNION

SELECT  SiteID,
		SubjectID,
	    SiteStatus,
		VisitOrEventType,
		EventOccurrence,
        VisitDate,
        CompletionStatus 
FROM NoRecords
GO
