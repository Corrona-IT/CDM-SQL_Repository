USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_DataEntryCompletion_TEST]    Script Date: 6/6/2024 8:58:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [GPP510].[v_op_DataEntryCompletion_TEST] as

SELECT distinct
		VIS.SiteID as SiteID,
		VIS.SubjectID as SubjectID,
	  CASE WHEN VIS.SiteID IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE vis.SFSiteStatus 
	   END AS SiteStatus,
		VIS.[Visit Type] as VisitOrEventType,
		VIS.EventOccurance as EventOccurrence,
      --CAST(COMP.DATALMDT as DATE) AS VisitDate,
	   CAST(VIS.VisitDate AS DATE) AS VisitDate, --went back to visitlog visit date since a lot of the results dont have event completion pages, and thus null dates
'Incomplete' as CompletionStatus 
FROM Reporting.GPP510.v_op_VisitLog_TEST VIS
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT_COMP] COMP on VIS.vID = COMP.vID
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT] VISI on VIS.vID = VISI.vID and VIS.VISITSEQUENCE = VISI.VISITSEQ
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[EVNTSTAT] EV on COMP.vID = EV.vID 
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[REIMB] REI on COMP.vID = REI.vID
WHERE (COMP.VISNAME != 'Enrollment' AND COMP.VISNAME != 'Subject Exit' AND COMP.VISNAME != 'Follow-Up (Non-flaring)' --AND COMP.VISNAME != 'GPP Flare (Populated)' AND COMP.VISNAME != 'GPP Flare (Manual)'  
AND REI.VISIT_PAID IS NULL AND EV.EVNTSTAT_DEC = 'Confirmed event'  AND COMP.STATUSID_DEC != 'Complete') 
--Gives TAEs and pregnancies that are confirmed events, incomplete, and not paid
OR (VISI.VISNAME = 'Enrollment' OR VISI.VISNAME = 'Subject Exit' OR VISI.VISNAME = 'Follow-Up (Non-flaring)' 
 AND COMP.STATUSID_DEC IS NULL) --no data entry completion form
OR (VISI.VISNAME = 'Enrollment' OR VISI.VISNAME = 'Subject Exit' OR VISI.VISNAME = 'Follow-Up (Non-flaring)'
 AND COMP.STATUSID_DEC IS NOT NULL AND VISI.STATUSID_DEC != 'Complete')
-- a data entry completion page and a status of incomplete for visit
--LEFT JOIN Reporting.GPP510.v_op_VisitLog VIS on VIS.vID = COMP.vID
--LEFT JOIN [dbo].[VISIT] VIS on VIS.vID = COMP.vID and VIS.VISITSEQ = COMP.VISITSEQ
--LEFT JOIN [dbo].[TAE] TAE on COMP.vID = TAE.vID 
--LEFT JOIN [dbo].[TAE_AFLD] AFLD on COMP.vID = AFLD.vID 
--LEFT JOIN [dbo].[TAE_ANA] ANA on COMP.vID = ANA.vID 
--LEFT JOIN [dbo].[PEQ] PEQ on COMP.vID = PEQ.vID 
GO
