USE [Reporting]
GO
/****** Object:  View [RA102].[v_pv_TAEQCListingView]    Script Date: 11/13/2024 12:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [RA102].[v_pv_TAEQCListingView] AS
SELECT DISTINCT *
FROM Reporting.RA102.t_pv_TAEQC TAE
LEFT JOIN (
    SELECT
        AQU.vID AS AQU_vID,
        AQU.REVISION AS AQU_REVISION,
        AQU.CLOSED AS AQU_CLOSED
        -- Include other columns from AQU that you need
    FROM MERGE_RA_JAPAN.staging.DAT_AQU AQU
    JOIN (
        SELECT
            vID,
            MAX(REVISION) AS max_revision
        FROM MERGE_RA_JAPAN.staging.DAT_AQU
        GROUP BY vID
    ) MaxAQU ON AQU.vID = MaxAQU.vID AND AQU.REVISION = MaxAQU.max_revision
) AQU ON TAE.vID = AQU.AQU_vID
;
GO
