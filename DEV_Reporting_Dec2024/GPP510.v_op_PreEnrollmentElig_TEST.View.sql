USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_PreEnrollmentElig_TEST]    Script Date: 12/5/2024 12:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [GPP510].[v_op_PreEnrollmentElig_TEST] as 

SELECT 
 A.Sitenum AS SiteID,
 'Approved / Active' AS SiteStatus,
 --SS.currentStatus AS SiteStatus,
 A.Subnum AS SubjectID,
 --DATEPART(YEAR,P.phidob) AS SubjectYearOfBirth,
 DS.IDENT2 AS SubjectYearOfBirth,
 A.subject_eligible_dec AS SubjectEligibility,
 A.elg_0_9999 AS ScreeningNotes,
 A.subject_consent_dec AS SubjectConsentSought,
 A.enr_dt_exp AS ExpectedEnrollmentDate,
 A.subject_no_consent_reason AS SubjectConsentNonApproachReason

FROM [ZELTA_GPP_TEST].[staging].[ADMIN] A
--JOIN [Salesforce].[dbo].[registryStatus] SS ON A.Sitenum = SS.Sitenumber AND SS.[name] = 'Generalized Pustular Psoriasis (GPP-510)'
LEFT JOIN [ZELTA_GPP_TEST].[staging].[PII] P ON A.Vid = P.Vid
left join [Zelta_GPP_TEST].[dbo].DAT_SUB DS on A.Subnum = DS.Subnum

Where 1=1
and A.PAGEID = 10 AND A.PAGENAME != 'Consent Status' AND (P.PAGEID != 20 OR P.PAGEID IS NULL) 
--AND SS.[name] = 'Generalized Pustular Psoriasis (GPP-510)' 
--AND SS.[currentStatus] IN ('Approved / Active', 'Pending closeout', 'Closed / Completed')


GO
