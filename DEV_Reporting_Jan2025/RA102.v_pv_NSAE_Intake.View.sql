USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_NSAE_Intake]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [RA102].[v_pv_NSAE_Intake]

AS

SELECT 
	sub.SITENUM AS [Site ID],
	sub.SUBNUM [Subject ID],
	sub.VISNAME AS [Visit Name],
	VIS.VISITDATE AS [Visit Date],
	CASE WHEN sub.GENDER = '0' THEN 'Male'
		 WHEN sub.GENDER = '1' THEN 'Female'
		 ELSE '' END AS [Gender],
	sub.BIRTHDATE AS [Year of Birth],
	P.YR_ONSET_RA AS [RA Onset]

FROM  [MERGE_RA_Japan].dbo.SUB_01 AS sub 
LEFT OUTER JOIN [MERGE_RA_Japan].dbo.VIS_DATE AS VIS ON VIS.SUBID = sub.SUBID AND VIS.VISITID = sub.VISITID AND VIS.VISITSEQ = sub.VISITSEQ 
LEFT OUTER JOIN [MERGE_RA_Japan].dbo.PRO_01 AS P ON VIS.SUBID = P.SUBID AND VIS.VISITID = P.VISITID AND VIS.VISITSEQ = P.VISITSEQ
		WHERE sub.VISNAME = 'Enrollment'
GO
