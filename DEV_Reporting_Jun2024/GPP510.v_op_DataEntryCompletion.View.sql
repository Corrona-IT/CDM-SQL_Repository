USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_DataEntryCompletion]    Script Date: 7/15/2024 11:18:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [GPP510].[v_op_DataEntryCompletion] as

SELECT DISTINCT COMP.SITENUM as SiteID,
		COMP.SUBNUM as SubjectID,
	  CASE WHEN COMP.SITENUM IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	   ELSE vis.SFSiteStatus 
	   END AS SiteStatus,
		COMP.VISNAME as VisitOrEventType,
		COMP.VisitSeq as EventOccurrence,

--VIS.VISDAT as VisitAndOnsetDate,
--COALESCE(ANA.DATALMDT, AFLD.DATALMDT,TAE.DATALMDT, VIS.VISDAT) AS VisitAndOnsetDate,

CAST(COMP.DATALMDT as DATE) AS VisitDate,

--COMP.STATUSID_DEC as CompletionStatus

'Incomplete' as CompletionStatus 

FROM [ZELTA_GPP].[dbo].[VISIT_COMP] COMP
LEFT JOIN [GPP510].[v_op_VisitLog] VIS on VIS.vID = COMP.vID
WHERE COMP.STATUSID_DEC != 'Complete'

--LEFT JOIN Reporting.GPP510.v_op_VisitLog VIS on VIS.vID = COMP.vID
--LEFT JOIN [dbo].[VISIT] VIS on VIS.vID = COMP.vID and VIS.VISITSEQ = COMP.VISITSEQ
--LEFT JOIN [dbo].[TAE] TAE on COMP.vID = TAE.vID 
--LEFT JOIN [dbo].[TAE_AFLD] AFLD on COMP.vID = AFLD.vID 
--LEFT JOIN [dbo].[TAE_ANA] ANA on COMP.vID = ANA.vID 
--LEFT JOIN [dbo].[PEQ] PEQ on COMP.vID = PEQ.vID 

GO
