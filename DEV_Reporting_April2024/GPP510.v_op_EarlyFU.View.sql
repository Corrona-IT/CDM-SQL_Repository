USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_EarlyFU]    Script Date: 5/1/2024 1:26:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [GPP510].[v_op_EarlyFU] AS

WITH Visits AS (
    SELECT 
        V.SiteID,
        V.SubjectID,
        V.[Visit Type],
        CAST(V.VisitDate as Date) as VisitDate,  
        V.EligibleVisit,
        V.EventOccurance,
        -- Calculate the difference in days between the current visit and the previous visit for the same subject-----
        DATEDIFF(day, 
                 LAG(CAST(V.VisitDate as Date)) OVER (PARTITION BY V.SubjectID ORDER BY CAST(V.VisitDate as Date)), 
                 CAST(V.VisitDate as Date)) AS DaysSinceLastVisit,
	   ------------------------------------------------------------------------------------
       CASE 
		WHEN REIMB.PAYEXCP = 1 THEN 'yes'
		WHEN REIMB.PAYEXCP = 0 THEN 'no'
			ELSE 'No'
		END AS ExceptionGranted,
        -- EarlyVisitRuleSatisfied > Not Reviewed, Under Review (outcome TBD), Yes, No ------------------------
        CASE 
			WHEN V.EligibleVisit = '' THEN 'No'
			WHEN REIMB.PAYEXCP = '1' THEN 'Not Reviewed'
			WHEN ELG.EARLYFU = 'X' THEN 'Yes'
            ELSE 'Not Reviewed'
        END as EarlyVisitRulesSatisfied, 
		-------------------------------------------------------------------------------------------------------
        ISNULL(REIMB.PAYEXCPRSN, '') as ExceptionReason,
		Case 
			when ELG.OOWFU = 'x' THEN 'Yes'
			else 'No'
			End as OutOfWindow,
        V.Vid
    FROM 
        Reporting.[GPP510].[V_op_VisitLog] V
    LEFT JOIN ZELTA_GPP_TEST.[dbo].[REIMB] REIMB ON V.Vid = REIMB.Vid
	LEFT JOIN ZELTA_GPP_TEST.[dbo].[ELG] ELG on V.Vid = ELG.Vid
    WHERE 
        V.[Visit Type] = 'Enrollment' OR V.[Visit Type] LIKE '%Follow%'
)
SELECT 
    *
FROM 
    Visits
WHERE
    ISNULL(DaysSinceLastVisit, 0) < 150
    --AND ExceptionGranted <> 'Yes'
GO
