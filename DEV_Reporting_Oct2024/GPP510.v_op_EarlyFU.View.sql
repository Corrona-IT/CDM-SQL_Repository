USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EarlyFU]    Script Date: 11/13/2024 12:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [GPP510].[v_op_EarlyFU] AS

WITH VisitsWithDetails AS (
    SELECT 
        V.SiteID,
        V.SubjectID,
        --V.[Visit Type],
		V.[VisitType],
        CAST(V.VisitDate as Date) as VisitDate,
        V.EventOccurance,
        REIMB.PAYEXCP,  
        REIMB.PAYEXCPRSN,
        ELG.EARLYFU,
        REIMB.PERMINCOMPL_DEC,
        V.Vid,
        V.EligibleVisit, 
		------------------------------------------
		/*This whole case statement below can be determined by ELIG_FU.
		When blank then not reviewed, when Yes (1) then reviewed, when No (0) then not reviewed, 
		when Under review (outcome TBD) (2) then Under review (outcome TBD).*/
		------------------------------------------
        CASE 
			WHEN ELG.ELIG_FU = '1' THEN 'Reviewed'
			WHEN ELG.ELIG_FU = '0' THEN 'Not reviewed'
			WHEN ELG.ELIG_FU = '2' THEN 'Under review (outcome TBD)'
			ELSE 'Not reviewed'
        END as VisitReview,  
        ------------------------------------------
		Case
			When ELG.OOWFU = 'X' THEN 'Yes'
			End as New_OOWFU
		--FROM Reporting.[GPP510].[V_op_VisitLog] V
		FROM Reporting.[GPP510].[V_op_VisitLog] V
		LEFT JOIN ZELTA_GPP.[dbo].[REIMB] REIMB ON V.Vid = REIMB.Vid
		LEFT JOIN ZELTA_GPP.[dbo].[ELG] ELG ON V.Vid = ELG.Vid
		WHERE 
			--V.[Visit Type] IN ('Follow-Up (Non-flaring)', 'GPP Flare (Populated)') 
			V.[VisitType] = 'Follow-Up (Non-flaring)'
),
VisitsWithEligibleDates AS (
    SELECT 
        *,
        LAG(VisitDate) OVER (PARTITION BY SubjectID, EligibleVisit ORDER BY VisitDate) AS PreviousVisitDate,
        DATEDIFF(day, LAG(VisitDate) OVER (PARTITION BY SubjectID, EligibleVisit ORDER BY VisitDate), VisitDate) AS DaysSinceLastVisit
    FROM 
        VisitsWithDetails
)
SELECT 
    SiteID,
    SubjectID,
    [VisitType],
    VisitDate,
    DaysSinceLastVisit,
    EventOccurance,
    PAYEXCP,
    PAYEXCPRSN,
    EARLYFU,
    PERMINCOMPL_DEC,
    New_OOWFU,
    Vid,
	EligibleVisit,
    VisitReview
FROM 
    VisitsWithEligibleDates
WHERE
    DaysSinceLastVisit IS NOT NULL 
    AND DaysSinceLastVisit <> 0 
    AND DaysSinceLastVisit < 150;
GO
