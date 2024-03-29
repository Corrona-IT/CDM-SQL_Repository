USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_VisitLog]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [GPP510].[v_op_VisitLog] as
	Select DISTINCT
	V.SITENUM as SiteID,
	V.SUBNUM as SubjectID,
	ISNULL(V.PROVID,'-') as VisitProviderID,
	V.VISNAME as [Visit Type],
	----
	V.VisitSEQ as EventOccurance,
	--ISNULL(V.VISDAT,'') as VisitDate,
	   CASE 
        WHEN VISDAT IS NULL THEN ''
        ELSE CONVERT(VARCHAR, VISDAT, 101) -- or any other format you prefer
    END AS VisitDate,
	--ISNULL(MONTH(V.VISDAT),'') as VisitMonth,
	--ISNULL(YEAR(V.VISDAT),'') as VisitYear,
	CASE 
        WHEN V.VISDAT IS NULL THEN ''
        ELSE CAST(MONTH(V.VISDAT) AS VARCHAR)
    END as VisitMonth,
    CASE 
        WHEN V.VISDAT IS NULL THEN ''
        ELSE CAST(YEAR(V.VISDAT) AS VARCHAR)
    END as VisitYear,
    ISNULL(VIR.VISASSESS_DEC, '-') AS DataCollectionType,
	-----------Hidden Columns-------------
	CASE
		WHEN V.VISNAME = 'Enrollment' THEN 0
		WHEN V.VISNAME = 'Follow-up' THEN ROW_NUMBER() OVER (PARTITION BY V.SUBNUM ORDER BY V.VISDAT)
		WHEN V.VISNAME = 'Exit' THEN 99
			ELSE '-' -- or some other default action if needed
			END AS VisitSequence,
	CASE 
		WHEN V.SITENUM IN (SELECT SP.SITENUM FROM Reporting.[GPP510].[v_op_SiteParameter]) THEN 'Active'
		ELSE 'Inactive'
			END AS SiteStatus,
	ISNULL(RS.CurrentStatus,'-') as SFSiteStatus,
	V.SUBID as PatientID,
	CASE 
		WHEN V.VISNAME IN ('Exit', 'Enrollment') THEN '-'
		WHEN ELG.PAY_3_1100 = 1 THEN 'Yes' -- Check if the visit has been paid
		WHEN PAYEXCP = 1 THEN 'Yes' -- Check for exception
		WHEN ELG.ELIG_EN = 1 THEN 'Yes' -- If eligible
		WHEN ELG.ELIG_EN = 2 THEN 'Yes' -- If visit is under review
		ELSE 'No' -- Default to 'No' if none of the above conditions are met
	END AS EligibleVisit,
	ISNULL(LEFT(PII.dob, 4), '-') AS YearofBirth,
	--ISNULL(SA.SEX_DEC,'-') as Gender,
	MAX(ISNULL(SA.SEX_DEC, '-')) OVER (PARTITION BY V.vID) AS Gender,
    SUBSTRING(
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
    ) AS Race,
	CASE
		WHEN SA.ETHNIC_DEC is NULL THEN 'Not Hispanic or Latino'
		ELSE SA.ETHNIC_DEC
	END AS Ethnicity
	----------------------------------------
	from [Zelta_GPP].[dbo].[VISIT] V
	LEFT JOIN [Zelta_GPP].[dbo].[SUB_A] SA on SA.SUBNUM = V.SUBNUM and SA.vID = V.vID
	--DAT TABLE IS WRONG
	--LEFT JOIN [Zelta_GPP].[dbo].[DAT_EC_SIG_TRAIL] DAT on DAT.SUBNUM = V.SUBNUM and DAT.ID = V.VID
	LEFT JOIN [Zelta_GPP].[dbo].[ADMIN] ADMN on ADMN.SUBNUM = V.SUBNUM and ADMN.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].MD_DX VIR on VIR.SUBNUM = V.SUBNUM and VIR.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].PII PII on PII.SUBNUM = V.SUBNUM and PII.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].ELG ELG on ELG.SUBNUM = V.SUBNUM and ELG.vID = V.vID
	LEFT JOIN [Zelta_GPP].[dbo].REIMB REIMB on REIMB.SUBNUM = V.SUBNUM and REIMB.vID = V.vID
	LEFT JOIN Reporting.[GPP510].[v_op_SiteParameter] SP ON SP.SITENUM = V.SITENUM
	--NO MATCHES YET IN SALESFORCE
	LEFT JOIN [Salesforce].[dbo].[registryStatus] RS 
		ON CAST(RS.siteNumber AS VARCHAR(50)) = CAST(V.SITENUM AS VARCHAR(50)) 
		AND RS.name = 'Generalized Pustular Psoriasis (GPP-510)'
GO
