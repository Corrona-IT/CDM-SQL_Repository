USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EarlyFU_TEST]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GPP510].[v_op_EarlyFU_TEST] AS
WITH VisitsWithDetails AS (
    SELECT 
        V.SiteID,
        V.SubjectID,
        V.VisitType,
        CAST(V.VisitDate AS DATE) AS VisitDate,  -- Ensuring date format
        V.EventOccurance,
        REIMB.PAYEXCP,  
        REIMB.PAYEXCPRSN,
        ELG.EARLYFU,
        REIMB.PERMINCOMPL_DEC,
        V.Vid,
        ELG.ELIG_FU_DEC as EligibleVisit,
        CASE 
            WHEN ELG.ELIG_FU = '1' THEN 'Reviewed'
            WHEN ELG.ELIG_FU = '0' THEN 'Not reviewed'
            WHEN ELG.ELIG_FU = '2' THEN 'Under review (outcome TBD)'
            ELSE 'Not reviewed'
        END as VisitReview,  
        CASE
            WHEN ELG.OOWFU = 'X' THEN 'Yes'
            ELSE 'No'
        END as New_OOWFU
    FROM Reporting.[GPP510].[V_op_VisitLog_TEST] V
        LEFT JOIN ZELTA_GPP_TEST.[dbo].[REIMB] REIMB ON V.Vid = REIMB.Vid
        LEFT JOIN ZELTA_GPP_TEST.[dbo].[ELG] ELG ON V.Vid = ELG.Vid
),
FilteredVisits AS (
    SELECT *
    FROM VisitsWithDetails
    WHERE VisitType IN ('Enrollment', 'Follow-Up (Non-flaring)')
),
VisitsWithEligibleDates AS (
    SELECT 
        F.*,
        LAG(F.VisitDate) OVER (PARTITION BY F.SubjectID ORDER BY F.VisitDate) AS PreviousVisitDate,
        DATEDIFF(day, LAG(F.VisitDate) OVER (PARTITION BY F.SubjectID ORDER BY F.VisitDate), F.VisitDate) AS DaysSinceLastVisit
    FROM 
        FilteredVisits F
)
SELECT 
    V.SiteID,
    V.SubjectID,
    V.VisitType,
    V.VisitDate,
    V.PreviousVisitDate,  -- Added for clarity in debugging
    V.DaysSinceLastVisit,
    V.EventOccurance,
    V.PAYEXCP,
    V.PAYEXCPRSN,
    V.EARLYFU,
    V.PERMINCOMPL_DEC,
    V.New_OOWFU,
    V.Vid,
    V.EligibleVisit,
    V.VisitReview
FROM 
    VisitsWithEligibleDates V
WHERE
    V.VisitType = 'Follow-Up (Non-flaring)'
    AND V.DaysSinceLastVisit IS NOT NULL 
    AND V.DaysSinceLastVisit <> 0 
    AND V.DaysSinceLastVisit < 150;
GO
