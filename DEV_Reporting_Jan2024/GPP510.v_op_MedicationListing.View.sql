USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_MedicationListing]    Script Date: 1/31/2024 10:11:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GPP510].[v_op_MedicationListing] as
select 
SITENUM as SiteID,
SUBNUM as SubjectID,
SUBID as PatientID ,
ATTESTDAT as AttestationDate,
DRUG as Treatment,
DRUGOTH as OtherTreatment,
--as TreatmentStatus, > 'Past Use' , 'Ongoing'  ,'Stopped' and 'InitiationReason'
CASE 
    WHEN DG.ONGO = 'X' THEN 'Ongoing'
    WHEN DG.FENDAT IS NOT NULL THEN 'Stopped'
    -- WHEN ISNULL(drug_hx_end, '')='' AND ISNULL(drug_hx_start, '')<>'' THEN 'Ongoing'
    WHEN ISNULL(DG.FENDAT, '') <> '' THEN 'Past use'
    ELSE COALESCE(NULLIF(DG.INITIATION_DEC, ''), 'Unknown')
		END AS TreatmentStatus,
DG.RXDAT as PrescribedDate,
DG.FSTDAT as StartDate,
--ImputedStartDateHistory,  (CALC?)
DG.FENDAT as StopDate,
--ImputedStopDateHistory (CALC?)
DG.ONGO as Ongoing,
DOSE as Dose,
DOSU_DEC as DoseUnits,
DOSFRQ_DEC as Frequency,
DOSFRQ as FrequencyNumber,
DOSFRQOTH as FrequencyOther,
DG.ROUTE_DEC as Route,
--Indication (no COLUMN_NAME LIKE '%vitiligo%') > GPPFLR, GPPPREV, PSO, PSA, INDOTH
--bodyRegion (NONE?)
DG.INITIATION_DEC AS InitaiationReason, -- DRUGNTSTRSN or INITIATION_DEC
DG.DRUGRSNSP as StopReason,
DG.NOTSTRSN as notStartedReason,
DG.RSNSP as OtherReasonStoppedOrNotStarted
from ZELTA_GPP.dbo.DRUG DG
GO
