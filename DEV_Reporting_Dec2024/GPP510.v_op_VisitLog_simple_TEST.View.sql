USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_VisitLog_simple_TEST]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create VIEW [GPP510].[v_op_VisitLog_simple_TEST] as

SELECT *
FROM
(
    SELECT DISTINCT SITENUM,
        SUBNUM,
		SUBID,
        CASE WHEN VISNAME='Follow-Up (Non-flaring)' THEN 'Follow-up'
		ELSE VISNAME
		END AS VISNAME,
        VisitSEQ,
        VISDAT 
    FROM
        [Zelta_GPP_TEST].[dbo].[VISIT] VIS
		WHERE ISNULL(VIS.VISDAT, '')<>''
		AND PAGENAME='Visit Information'

UNION

SELECT DISTINCT [SITENUM]
      ,[SUBNUM]
      ,[SUBID]
      ,'Exit' AS [VISNAME]
      ,99 AS[VISITSEQ]
      ,[EXITDAT] AS VISDAT
  FROM [Zelta_GPP_TEST].[dbo].[EXIT] EX
  WHERE ISNULL(EXITDAT, '') <> ''
  ) A
GO
