USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_MedicationListing]    Script Date: 12/9/2024 2:46:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create VIEW [GPP510].[v_op_MedicationListing] as
WITH EnrollmentDate AS (
    SELECT 
        DG.SUBNUM as SubjectID,
        MIN(CASE WHEN V.VISNAME = 'Enrollment' THEN V.VISDAT ELSE NULL END) AS EnrollmentDate
		--CASE WHEN V.VISNAME = 'Enrollment' THEN V.VISDAT ELSE NULL END AS EnrollmentDate
    FROM 
        ZELTA_GPP.dbo.DRUG DG
        LEFT JOIN ZELTA_GPP.dbo.VISIT V ON DG.SITENUM = V.SITENUM AND DG.SUBNUM = V.SUBNUM 
    GROUP BY 
        DG.SUBNUM
)
select distinct
DG.SITENUM as SiteID,
DG.SUBNUM as SubjectID,
--DG.SUBID as PatientID ,
DG.VISNAME as VisitName,
DG.PAGENAME as PageName,
DRUG_DEC as Treatment,
DRUGOTH as OtherTreatment,
--"Calculated: Prescribed Started Not started Ongoing Stopped Past use"
--CASE 
--    WHEN DG.DRUG_DEC IS NULL  THEN ''
--    WHEN DG.ONGO = 'X' THEN 'Ongoing'
--    WHEN DG.FENDAT IS NOT NULL THEN 'Stopped'
--    WHEN ISNULL(DG.FENDAT, '') <> '' THEN 'Past use'
--    ELSE 'Unknown'
--		END AS TreatmentStatus,

DG.VISITSEQ as VisitSequence,
DG.PAGESEQ as PageSequence,
ED.EnrollmentDate as EnrollmentDate,
DG.RXDAT as PrescribedDate,
--DG.FSTDAT as StartDate,
--DG.FENDAT as StopDate,
--------------------------
CASE
    WHEN DG.PSTDAT = 'UNK-UNK-UNK' THEN ''  -- Return blank if the date is completely unknown
    WHEN DG.PSTDAT LIKE 'UNK-%' THEN COALESCE(DG.FSTDAT, '')  -- If UNK year in PSTDAT, defer to FSTDAT or blank
    WHEN DG.FSTDAT IS NOT NULL THEN DG.FSTDAT  -- Prefer FSTDAT when available
    ELSE  
        CASE 
            WHEN DG.PSTDAT LIKE '%-UNK' THEN REPLACE(DG.PSTDAT, 'UNK', '01')
            WHEN DG.PSTDAT LIKE '%-UNK-%' THEN REPLACE(DG.PSTDAT, 'UNK', '01')
            ELSE DG.PSTDAT
        END
END AS StartDate,
CASE
    WHEN DG.PENDAT = 'UNK-UNK-UNK' THEN ''  -- Return blank if the date is completely unknown
    WHEN DG.PENDAT LIKE 'UNK-%' THEN COALESCE(DG.FENDAT, '')  -- If UNK year in PENDAT, defer to FENDAT or blank
    WHEN DG.FENDAT IS NOT NULL THEN DG.FENDAT  -- Prefer FENDAT when available
    ELSE  
        CASE 
            WHEN DG.PENDAT LIKE '%-UNK' THEN REPLACE(DG.PENDAT, 'UNK', '01')
            WHEN DG.PENDAT LIKE '%-UNK-%' THEN REPLACE(DG.PENDAT, 'UNK', '01')
            ELSE DG.PENDAT
        END
END AS StopDate,
--------------------------
CASE 
    WHEN DG.DRUG_DEC IS NULL THEN 'Unknown'
    WHEN DG.ONGO = 'X' THEN 'Ongoing'
    WHEN 
        (
            CASE 
                WHEN DG.PENDAT = 'UNK-UNK-UNK' THEN NULL -- Assuming blank means it shouldn't be considered for 'Stopped'
                WHEN DG.PENDAT LIKE 'UNK-%' THEN COALESCE(DG.FENDAT, NULL)
                WHEN DG.FENDAT IS NOT NULL THEN DG.FENDAT
                ELSE
                    CASE 
                        WHEN DG.PENDAT LIKE '%-UNK' THEN REPLACE(DG.PENDAT, 'UNK', '01')
                        WHEN DG.PENDAT LIKE '%-UNK-%' THEN REPLACE(DG.PENDAT, 'UNK', '01')
                        ELSE DG.PENDAT
                    END
            END
        ) < ED.EnrollmentDate THEN 'Past Use'
    WHEN 
        (
            CASE 
                WHEN DG.PENDAT = 'UNK-UNK-UNK' THEN NULL
                WHEN DG.PENDAT LIKE 'UNK-%' THEN COALESCE(DG.FENDAT, NULL)
                WHEN DG.FENDAT IS NOT NULL THEN DG.FENDAT
                ELSE
                    CASE 
                        WHEN DG.PENDAT LIKE '%-UNK' THEN REPLACE(DG.PENDAT, 'UNK', '01')
                        WHEN DG.PENDAT LIKE '%-UNK-%' THEN REPLACE(DG.PENDAT, 'UNK', '01')
                        ELSE DG.PENDAT
                    END
            END
        ) IS NOT NULL THEN 'Stopped'
    ELSE 'Unknown'
END AS TreatmentStatus,

---------------------------
  CASE
    WHEN DG.ONGO = 'X' THEN 'Yes'
    ELSE ''
  END AS Ongoing,
DOSE as Dose,
DOSU_DEC as DoseUnits,
DOSFRQ_DEC as Frequency,
DOSFRQ as FrequencyNumber,
DOSFRQOTH as FrequencyOther,
DG.ROUTE_DEC as Route,
--Indication (no COLUMN_NAME LIKE '%vitiligo%') > GPPFLR, GPPPREV, PSO, PSA, INDOTH
CASE
	when DG.GPPFLR = 'X' then 'GPP Acute Flare'
	when DG.GPPPREV = 'X' then 'GPP Flare Prevention'
	when DG.PSO = 'X' then 'Psoriasis'
	when DG.PSA = 'X' then 'Psoriatic arthritis'
	when DG.INDOTH = 'X' then 'Other Autoimmune Indication'
	else ' '
END AS Indication,
DG.INITIATION_DEC AS InitiationReason, -- DRUGNTSTRSN or INITIATION_DEC
--DG.DRUGRSNSP as StopReason,
CASE
  WHEN DG.DRUGRSNSP = 'BF' THEN 'Breastfeeding'
  WHEN DG.DRUGRSNSP = 'DF' THEN 'Dose / frequency increase'
  WHEN DG.DRUGRSNSP = 'FR' THEN 'Failure to maintain initial'
  WHEN DG.DRUGRSNSP = 'FE' THEN 'Fear of future side effect'
  WHEN DG.DRUGRSNSP = 'IR' THEN 'Inadequate initial response'
  WHEN DG.DRUGRSNSP = 'IP' THEN 'Interchangeable substitution by pharmacy'
  WHEN DG.DRUGRSNSP = 'ME' THEN 'Minor side effect'
  WHEN DG.DRUGRSNSP = 'DW' THEN 'Subject doing well'
  WHEN DG.DRUGRSNSP = 'PP' THEN 'Subject preference'
  WHEN DG.DRUGRSNSP = 'PG' THEN 'Pregnancy'
  WHEN DG.DRUGRSNSP = 'SE' THEN 'Serious side effect'
  WHEN DG.DRUGRSNSP = 'TI' THEN 'Temporary interruption'
  WHEN DG.DRUGRSNSP = 'IC' THEN 'To improve compliance'
  WHEN DG.DRUGRSNSP = 'IT' THEN 'To improve tolerability'
  WHEN DG.DRUGRSNSP = 'OT' THEN 'Other (specify)'
  WHEN DG.DRUGRSNSP = 'DI' THEN 'Denied by Insurance'
  ELSE DG.DRUGRSNSP
END AS StopReason,
CASE
  WHEN DG.NOTSTRSN = 'BF' THEN 'Breastfeeding'
  WHEN DG.NOTSTRSN = 'DF' THEN 'Dose / frequency increase'
  WHEN DG.NOTSTRSN = 'FR' THEN 'Failure to maintain initial'
  WHEN DG.NOTSTRSN = 'FE' THEN 'Fear of future side effect'
  WHEN DG.NOTSTRSN = 'IR' THEN 'Inadequate initial response'
  WHEN DG.NOTSTRSN = 'IP' THEN 'Interchangeable substitution by pharmacy'
  WHEN DG.NOTSTRSN = 'ME' THEN 'Minor side effect'
  WHEN DG.NOTSTRSN = 'DW' THEN 'Subject doing well'
  WHEN DG.NOTSTRSN = 'PP' THEN 'Subject preference'
  WHEN DG.NOTSTRSN = 'PG' THEN 'Pregnancy'
  WHEN DG.NOTSTRSN = 'SE' THEN 'Serious side effect'
  WHEN DG.NOTSTRSN = 'TI' THEN 'Temporary interruption'
  WHEN DG.NOTSTRSN = 'IC' THEN 'To improve compliance'
  WHEN DG.NOTSTRSN = 'IT' THEN 'To improve tolerability'
  WHEN DG.NOTSTRSN = 'OT' THEN 'Other (specify)'
  WHEN DG.NOTSTRSN = 'DI' THEN 'Denied By Insurance'
  else DG.NOTSTRSN
END AS notStartedReason,
DG.RSNSP as OtherReasonStoppedOrNotStarted
--DG.vid as vID
from ZELTA_GPP.dbo.DRUG DG
LEFT JOIN EnrollmentDate ED ON DG.SUBNUM = ED.SubjectID 
Where DG.DRUG_DEC is not NULL


GO
