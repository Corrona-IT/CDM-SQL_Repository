USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_VisitLog]    Script Date: 9/3/2024 3:31:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [GPP510].[v_op_VisitLog] AS

WITH AggregatedDemographics AS (
    SELECT distinct
        SUBNUM,
        vID,
        MAX(NATAMERUS) AS NATAMERUS,
        MAX(ASIAN) AS ASIAN,
        MAX(BLCKUS) AS BLCKUS,
        MAX(PACIFIC) AS PACIFIC,
        MAX(WHITEUS) AS WHITEUS,
        MAX(RACEOTHUS) AS RACEOTHUS,
        MAX(NATAMERCA) AS NATAMERCA,
        MAX(ARAB) AS ARAB,
        MAX(BLCKCA) AS BLCKCA,
        MAX(CHINA) AS CHINA,
        MAX(FILIP) AS FILIP,
        MAX(JAPAN) AS JAPAN,
        MAX(KOREA) AS KOREA,
        MAX(LATIN) AS LATIN,
        MAX(SASIA) AS SASIA,
        MAX(SEASIA) AS SEASIA,
        MAX(WASIA) AS WASIA,
        MAX(WHITECA) AS WHITECA,
        MAX(RACEOTHCA) AS RACEOTHCA,
        MAX(SEX_DEC) AS SEX_DEC,
        MAX(ETHNIC_DEC) AS Ethnicity
    FROM
        [Zelta_GPP].[dbo].[SUB_A]
    GROUP BY
        SUBNUM,
        vID
),
AggregatedPatientInfo AS (
    SELECT distinct
        SUBNUM,
        MAX(ISNULL(SEX_DEC, ' ')) OVER (PARTITION BY SUBNUM) AS Gender,
        MAX(ISNULL(Ethnicity, ' ')) OVER (PARTITION BY SUBNUM) AS Ethnicity,
        MAX(SUBSTRING(
            CONCAT(
                CASE WHEN NATAMERUS = 'X' THEN ' / American Indian or Alaskan Native' ELSE '' END,
                CASE WHEN ASIAN = 'X' THEN ' / Asian' ELSE '' END,
                CASE WHEN BLCKUS = 'X' THEN ' / Black' ELSE '' END,
                CASE WHEN PACIFIC = 'X' THEN ' / Native Hawaiian or Other Pacific Islander' ELSE '' END,
                CASE WHEN WHITEUS = 'X' THEN ' / White' ELSE '' END,
                CASE WHEN RACEOTHUS = 'X' THEN ' / Aboriginal person' ELSE '' END,
                CASE WHEN NATAMERCA = 'X' THEN ' / American Indian' ELSE '' END,
                CASE WHEN ARAB = 'X' THEN ' / Arab' ELSE '' END,
                CASE WHEN BLCKCA = 'X' THEN ' / Black' ELSE '' END,
                CASE WHEN CHINA = 'X' THEN ' / Chinese' ELSE '' END,
                CASE WHEN FILIP = 'X' THEN ' / Filipino' ELSE '' END,
                CASE WHEN JAPAN = 'X' THEN ' / Japanese' ELSE '' END,
                CASE WHEN KOREA = 'X' THEN ' / Korean' ELSE '' END,
                CASE WHEN LATIN = 'X' THEN ' / Latin American' ELSE '' END,
                CASE WHEN SASIA = 'X' THEN ' / South Asian' ELSE '' END,
                CASE WHEN SEASIA = 'X' THEN ' / Southeast Asian' ELSE '' END,
                CASE WHEN WASIA = 'X' THEN ' / West Asian' ELSE '' END,
                CASE WHEN WHITECA = 'X' THEN ' / White' ELSE '' END,
                CASE WHEN RACEOTHCA = 'X' THEN ' / Alien' ELSE '' END
            ),
            4, 1000
        )) OVER (PARTITION BY SUBNUM) AS Race
    FROM
        AggregatedDemographics
),
-------------------------------------------------
CombinedVisitAndTAE AS (
-----------------------------
SELECT
    SITENUM,
    SUBNUM,
    SUBID,
    PROVID,
    VISNAME,
    VisitSEQ,
    VISDAT,
    VID
FROM (
    SELECT 
        VIS.SITENUM,
        VIS.SUBNUM,
        VIS.SUBID,
        VIS.PROVID,
        VIS.VISNAME,
        VIS.VisitSEQ,
        VIS.VISDAT,
        VIS.VID,
        ROW_NUMBER() OVER (PARTITION BY VIS.SITENUM, VIS.SUBNUM, VIS.VISNAME, VIS.VID ORDER BY VIS.VISDAT DESC) AS rn
    FROM 
        [Zelta_GPP].[dbo].[VISIT] VIS
    WHERE 
        VIS.VISDAT IS NOT NULL
        --AND EXISTS (
        --    SELECT 1
        --    FROM [Zelta_GPP].[dbo].[VISIT] V2
        --    WHERE V2.SUBNUM = VIS.SUBNUM AND V2.VISNAME = 'Enrollment'
        --)
) AS VIS
WHERE VIS.rn = 1

UNION 

SELECT
    SITENUM,
    SUBNUM,
    SUBID,
    PROVID,
    VISNAME,
    VisitSEQ,
    VISDAT,
    VID
FROM (
    SELECT 
        TAE.SITENUM,
        TAE.SUBNUM,
        TAE.SUBID,
        TAE.PROVID,
        TAE.VISNAME,
        TAE.VisitSEQ,
        CASE
            WHEN TAE.VISNAME LIKE '%pregnancy%' THEN COALESCE(PEQ.LASTPERIODDAT, TAE.STDAT)
            WHEN TAE.VISNAME LIKE '%flare%' AND ISDATE(FLR.FLRSTDAT) = 1 THEN FLR.FLRSTDAT
            ELSE TAE.STDAT
        END AS VISDAT,
        TAE.VID,
        ROW_NUMBER() OVER (PARTITION BY TAE.SITENUM, TAE.SUBNUM, TAE.VISNAME, TAE.VID ORDER BY 
            CASE 
                WHEN TAE.VISNAME LIKE '%pregnancy%' THEN COALESCE(PEQ.LASTPERIODDAT, TAE.STDAT) 
                WHEN TAE.VISNAME LIKE '%flare%' AND ISDATE(FLR.FLRSTDAT) = 1 THEN FLR.FLRSTDAT 
                ELSE TAE.STDAT 
            END DESC) AS rn
    FROM 
        [Zelta_GPP].[dbo].[TAE] TAE
    LEFT JOIN 
        [Zelta_GPP].[dbo].[PEQ] PEQ ON PEQ.SUBNUM = TAE.SUBNUM AND PEQ.VID = TAE.VID AND PEQ.VISNAME = TAE.VISNAME
    LEFT JOIN 
        [ZELTA_GPP].[dbo].[FLR] FLR ON FLR.SUBNUM = TAE.SUBNUM AND FLR.VID = TAE.VID AND FLR.VISNAME = TAE.VISNAME
    WHERE 
        TAE.PAGENAME = 'Confirmation Status'
        AND EXISTS (
            SELECT 1
            FROM [Zelta_GPP].[dbo].[VISIT] V2
            WHERE V2.SUBNUM = TAE.SUBNUM AND V2.VISNAME = 'Enrollment'
        )
) AS TAE
WHERE TAE.rn = 1
-----------------------------
    UNION

    SELECT
        SITENUM,
        SUBNUM,
        SUBID,
        PROVID,
        VISNAME,
        VisitSEQ,
        VISDAT,
        VID
    FROM (
        SELECT 
            EXT.SITENUM,
            EXT.SUBNUM,
            EXT.SUBID,
            EXT.PROVID,
            EXT.VISNAME,
            EXT.VisitSEQ,
            EXT.EXITDAT AS VISDAT,
            EXT.VID,
            ROW_NUMBER() OVER (PARTITION BY EXT.SITENUM, EXT.SUBNUM, EXT.VISNAME, EXT.VID ORDER BY EXT.EXITDAT DESC) AS rn
        FROM 
            [Zelta_GPP].[dbo].[EXIT] EXT
        WHERE 
            EXT.EXITDAT IS NOT NULL
			--Causing all Exits to be removed. Remove line and test if this fixes it
            --AND EXT.PAGENAME = 'Confirmation Status'
    ) AS EXT
    WHERE EXT.rn = 1

)
---------------------------------------------------------
, VisitSequence1 AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
		    --PARTITION BY SUBNUM, VISNAME, VID
            PARTITION BY SUBNUM, VISNAME 
            ORDER BY VISDAT
        ) AS SeqNum
    FROM CombinedVisitandTAE
)
------------------------------------------------------------
	Select DISTINCT
	V.SITENUM as SiteID,
	V.SUBNUM as SubjectID,
	ISNULL(V.PROVID,' ') as VisitProviderID,
	V.VISNAME as [VisitType],
	V.VisitSEQ as EventOccurance,
    V.VISDAT AS VisitDate, -- or any other format you prefer

	CAST(DAY(V.VISDAT) AS VARCHAR) as VisitDay,
	SUBSTRING(DATENAME(MONTH, V.VISDAT), 1, 3) AS VisitMonth,
	DATEPART(YEAR,V.VISDAT) AS VisitYear,

	 CAST(V.VISDAT as DATE) AS SortableVisitDate,
	 ISNULL(FIRST_VALUE(VIR.VISASSESS_DEC) OVER (PARTITION BY V.SUBNUM, V.vID ORDER BY CASE WHEN VIR.VISASSESS_DEC IS NULL OR VIR.VISASSESS_DEC = '' THEN 1 ELSE 0 END, VIR.VISASSESS_DEC DESC), '') AS DataCollectionType,

-----------Hidden Columns--------------------------------------
   CASE 
        WHEN V.VISNAME = 'Enrollment' THEN 0
        WHEN V.VISNAME = 'Subject Exit' THEN 99
        ELSE V.SeqNum
    END AS VisitSequence,
------------------------------------------

	CASE WHEN S.ACTIVE='t' THEN 'Active'
	ELSE 'Inactive'
	END AS SiteStatus,

	CASE WHEN V.SITENUM IN (1440, 9900, 9997, 9998, 9999) THEN 'Approved / Active'
	ELSE ISNULL(RS.CurrentStatus,'') 
	END AS SFSiteStatus,
	'GPP-510' AS Registry,
	'Generalized Pustular Psoriasis (GPP510)' AS RegistryName,

	V.SUBID as PatientID,
	CASE 
		WHEN V.VISNAME NOT IN ('Enrollment', 'Follow-Up (Non-flaring)') THEN ''
		WHEN V.VISNAME = 'Enrollment' and isnull (ELIG_EN,'') in ('',1,2)  THEN 'Yes'
		When  V.VISNAME = 'Enrollment' and ELIG_EN = 0  and ELIGEXC_EN = 1 THEN 'Yes'
		When V.VISNAME = 'Enrollment' and ELIG_EN = 0  and ELIGEXC_EN = 0 THEN 'No'
		WHEN V.VISNAME = 'Follow-Up (Non-flaring)' and isnull (ELIG_FU,'') in ('',1,2)  THEN 'Yes'
		When  V.VISNAME = 'Follow-Up (Non-flaring)' and ELIG_FU = 0  and ELIGEXC_FU = 1 THEN 'Yes'
		When V.VISNAME = 'Follow-Up (Non-flaring)' and ELIG_FU = 0  and ELIGEXC_FU = 0 THEN 'No'
		ELSE '' 
	END AS EligibleVisit,
	------------------------------------------
	(SELECT TOP 1 CASE 
              WHEN DSUB.IDENT2 = '1900-01-01' THEN '' 
              ELSE DSUB.IDENT2 
				END 
		FROM [Zelta_GPP].[dbo].DAT_SUB DSUB
		WHERE DSUB.SUBID = V.SUBID 
		ORDER BY CASE WHEN DSUB.IDENT2 IS NULL OR DSUB.IDENT2 = '' OR DSUB.IDENT2 = '1900-01-01' THEN 1 ELSE 0 END, CAST(DSUB.IDENT2 AS DATE) DESC) 
		AS YearofBirth,
    --select IDENT2,* from  [Zelta_GPP].[dbo].DAT_SUB
	---------------------------------------------
    ISNULL(AP.Gender, ' ') as Gender,
    ISNULL(AP.Ethnicity, ' ') as Ethnicity,
    ISNULL(AP.Race, ' ') as Race,
	V.VID as Vid
	----------------------------------------
	--FROM CombinedVisitAndTAE V

	FROM VisitSequence1 V
	LEFT JOIN AggregatedDemographics SA ON SA.SUBNUM = V.SUBNUM AND SA.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].[ADMIN] ADMN on ADMN.SUBNUM = V.SUBNUM and ADMN.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].MD_DX VIR on VIR.SUBNUM = V.SUBNUM and VIR.vID = V.vID
	--PII NOT SHOWING IN PROD > REMOVE IT
	--LEFT JOIN [Zelta_GPP].[dbo].PII PII on  PII.SUBNUM = V.SUBNUM and PII.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].ELG ELG on ELG.SUBNUM = V.SUBNUM and ELG.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].REIMB REIMB on REIMB.SUBNUM = V.SUBNUM and REIMB.vID = V.vID
	LEFT JOIN AggregatedPatientInfo AP ON AP.SUBNUM = V.SUBNUM
	LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
		ON CAST(RS.siteNumber AS VARCHAR(50)) = CAST(V.SITENUM AS VARCHAR(50)) 
		AND RS.name = 'Generalized Pustular Psoriasis (GPP-510)'
	LEFT JOIN [Zelta_GPP].[dbo].[PEQ] PEQ on PEQ.SUBNUM = V.SUBNUM AND PEQ.vID = V.vID
	LEFT JOIN [ZELTA_GPP].[dbo].[DAT_SITES] S ON S.SITENUM=V.SITENUM


GO
