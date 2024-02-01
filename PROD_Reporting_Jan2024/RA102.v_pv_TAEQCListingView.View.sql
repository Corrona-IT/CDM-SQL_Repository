USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_TAEQCListingView]    Script Date: 1/31/2024 10:27:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [RA102].[v_pv_TAEQCListingView] AS
SELECT 
    UPPER(ISNULL((SELECT TOP 1 SQU.CLOSED 
                  FROM MERGE_RA_JAPAN.staging.DAT_SQU SQU
                  WHERE CAST(TAE.[Subject ID] AS NVARCHAR) = CAST(SQU.[SUBNUM] AS NVARCHAR)
                    AND [Last Page Updated – Name] = SQU.[PAGENAME]
                  ORDER BY SQU.REVISION DESC, SQU.LASTMDT DESC), '')) AS CLOSED,
    TAE.*
FROM Reporting.RA102.t_pv_TAEQC TAE;
GO
