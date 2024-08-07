USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EarlyFU]    Script Date: 7/15/2024 12:41:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [GPP510].[v_op_EarlyFU] AS

WITH VisitsWithDetails AS (
    SELECT 
        V.SiteID,
        V.SubjectID,
        V.[VisitType],
        CAST(V.VisitDate as Date) as VisitDate,
        V.EventOccurance,
        REIMB.PAYEXCP,
        REIMB.PAYEXCPRSN,
        ELG.EARLYFU,
        REIMB.PERMINCOMPL_DEC,
        V.Vid,
        V.EligibleVisit,
        CASE 
            WHEN V.EligibleVisit = '' THEN 'No'
            WHEN REIMB.PAYEXCP = '1' THEN 'Not reviewed'
            WHEN ELG.EARLYFU = 'X' THEN 'Yes'
            ELSE 'Not reviewed'
        END as EarlyVisitRulesSatisfied,
        CASE
            WHEN REIMB.PERMINCOMPL_DEC = 'No' THEN 'No'
            WHEN REIMB.PERMINCOMPL_DEC = 'Yes' AND REIMB.PAYEXCP = 1 THEN 'Yes'
            ELSE V.EligibleVisit
        END AS FinalEligibleVisit,
	Case
		When ELG.OOWFU = 'X' THEN 'Yes'
		End as New_OOWFU
    FROM 
        Reporting.[GPP510].[V_op_VisitLog] V
    LEFT JOIN ZELTA_GPP.[dbo].[REIMB] REIMB ON V.Vid = REIMB.Vid
    LEFT JOIN ZELTA_GPP.[dbo].[ELG] ELG ON V.Vid = ELG.Vid
    WHERE 
        V.[VisitType] = 'Enrollment' OR V.[VisitType] LIKE '%Follow%'
),
VisitsWithEligibleDates AS (
    SELECT 
        *,
        LAG(VisitDate) OVER (PARTITION BY SubjectID, FinalEligibleVisit ORDER BY VisitDate) AS PreviousVisitDate,
        DATEDIFF(day, LAG(VisitDate) OVER (PARTITION BY SubjectID, FinalEligibleVisit ORDER BY VisitDate), VisitDate) AS DaysSinceLastVisit
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
    FinalEligibleVisit as Eligible,
    EarlyVisitRulesSatisfied
FROM 
    VisitsWithEligibleDates
WHERE
    DaysSinceLastVisit IS NOT NULL AND DaysSinceLastVisit < 150;
GO
