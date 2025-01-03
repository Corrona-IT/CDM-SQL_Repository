USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_op_OtherDrugsENRFU]    Script Date: 11/13/2024 12:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- ==================================================================================
-- Author:		Kaye Mowrey
-- Create date: 8/23/2018
-- Description:	Procedure to create table for Other Drugs at Enrollment and Follow-up
-- ==================================================================================

CREATE PROCEDURE [PSO500].[usp_op_OtherDrugsENRFU] AS


/*
*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* DO NOT DROP AND RECREATE, USER "ClicData" HAS OBJECT LEVEL PERMISIONS
    -- Insert statements for procedure here
	IF OBJECT_ID('[PSO500].[t_Elig]', 'U') IS NOT NULL  DROP TABLE [PSO500].[t_Elig]; 

CREATE TABLE [PSO500].[t_op_OtherDrugsENRFU]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar] (30) NOT NULL,
	[VisitId] [bigint] NULL,
	[TrlObjectVisitId] [bigint] NULL,
	[VisitName] [nvarchar] (100) NULL,
	[EnrollingProviderID] [int] NULL,
	[VisitDate] [date] NULL,
	[CRFName] [nvarchar] (250) NULL,
	[DrugName] [nvarchar] (150) NULL,
	[OtherSpecify] [nvarchar] (300) NULL

);
SELECT * FROM [PSO500].[t_op_OtherDrugsENRFU]
*/


TRUNCATE TABLE [Reporting].[PSO500].[t_op_OtherDrugsENRFU];


if object_id('tempdb.dbo.#OthDrugs') is not null begin drop table #OthDrugs end

--select * from #othDrugs

 SELECT DISTINCT
	CAST(SIT.[Site Number] AS int) AS [SiteID],
	PAT.[Caption] AS [SubjectID],
	--PAT.[Caption] AS [SubjectID],
	CAST(VIS.VisitId AS bigint) AS VisitId,
	CAST(VIST.TrlObjectID AS bigint) AS TrlObjectVisitId,
	VIS.[Visit Object ProCaption] AS [VisitName],
	CAST(SUB.[pat_md_cod] AS int) AS [EnrollingProviderID],
	CAST(VIS.[Visit Object VisitDate] AS date) AS [VisitDate],
	AllNbBio.[crf_name] AS [CRFName],
	AllNbBio.[nbbio_name] AS [DrugName],
	AllNbBio.[nbbio_other] AS [OtherSpecify]

into #OthDrugs

FROM [OMNICOMM_PSO].[inbound].[Patients] PAT
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN [OMNICOMM_PSO].[inbound].[AdHoc_Sites] ADSITE ON ADSITE.SiteId = SIT.SiteId
INNER JOIN [OMNICOMM_PSO].[inbound].[G_Subject Information] SUB ON SUB.PatientId = PAT.PatientId
INNER JOIN [OMNICOMM_PSO].[inbound].[VISIT] VIS ON VIS.PatientId = PAT.PatientId 
INNER JOIN --		select * from
	[OMNICOMM_PSO].[inbound].[Visits] VIST 
		ON VIST.Visitid = VIS.Visitid -- Added join to pull in TrlObjectVisitId. 1552 before and after this join.
INNER JOIN [OMNICOMM_PSO].[inbound].[PE] PE ON PE.PatientId = PAT.PatientId
LEFT JOIN
	(
		SELECT crf_name, nbbio_name, nbbio_other, VisitId FROM
		(
			SELECT [Form Object Caption] AS crf_name, NB2_nbio_use AS nbbio_name, NB2_nonbio_other_use AS nbbio_other, VisitId 
			FROM [OMNICOMM_PSO].[inbound].NB_NB2
			UNION
			SELECT [Form Object Caption] AS crf_name, NB3_nbio_use2 AS nbbio_name, NB3_nonbio_other_use2 AS nbbio_other, VisitId 
			FROM [OMNICOMM_PSO].[inbound].NB
			UNION
			SELECT [Form Object Caption] AS crf_name, NB4_nbio_use3 AS nbbio_name, NB4_nonbio_other_use3 AS nbbio_other, VisitId 
			FROM [OMNICOMM_PSO].[inbound].NB
			UNION
			SELECT [Form Object Caption] AS crf_name, NB5_nbio_use4 AS nbbio_name, NB5_nonbio_other_use4 AS nbbio_other, VisitId 
			FROM [OMNICOMM_PSO].[inbound].NB
			UNION
			SELECT [Form Object Caption] AS crf_name, NB7_nbio_use5 AS nbbio_name, NB7_nonbio_other_use5 AS nbbio_other, VisitId 
			FROM [OMNICOMM_PSO].[inbound].NB
			UNION
			SELECT [Form Object Caption] AS crf_name, NBF2_nbio_use_fu AS nb_name, NBF2_oth_nbio_use_fu AS nbbio_other, VisitId  
			FROM [OMNICOMM_PSO].[inbound].NBF
			UNION
			SELECT [Form Object Caption] AS crf_name, NBF3_nbio_use_fu2 AS nb_name, NBF3_oth_nbio_use_fu2 AS nbbio_other, VisitId  
			FROM [OMNICOMM_PSO].[inbound].NBF
			UNION
			SELECT [Form Object Caption] AS crf_name, NBF4_nbio_use_fu3 AS nb_name, NBF4_oth_nbio_use_fu3 AS nbbio_other, VisitId  
			FROM [OMNICOMM_PSO].[inbound].NBF
			UNION
			SELECT [Form Object Caption] AS crf_name, NBF5_nbio_use_fu4 AS nb_name, NBF5_oth_nbio_use_fu4 AS nbbio_other, VisitId  
			FROM [OMNICOMM_PSO].[inbound].NBF
			UNION
			SELECT [Form Object Caption] AS crf_name, NBF6_nbio_use_fu5 AS nb_name, NBF6_oth_nbio_use_fu5 AS nbbio_other, VisitId  
			FROM [OMNICOMM_PSO].[inbound].NBF
			UNION
			SELECT [Form Object Caption] AS crf_name, BIO2_bio_use AS nbbio_name,
				CASE WHEN BIO2_bio_use = 'Other' THEN BIO2_bio_oth_use
					 WHEN BIO2_bio_use = 'Other BIOLOGIC' THEN BIO2_bio_oth_use 
					 WHEN BIO2_bio_use = 'Other BIOSIMILAR' THEN BIO2_biosim_oth_name
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIO]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIO3_bio_use2 AS nbbio_name,
				CASE WHEN BIO3_bio_use2 = 'Other' THEN BIO3_bio_oth_use2 
					 WHEN BIO3_bio_use2 = 'Other BIOLOGIC' THEN BIO3_bio_oth_use2 
					 WHEN BIO3_bio_use2 = 'Other BIOSIMILAR' THEN BIO3_biosim_oth_name2
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIO]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIO4_bio_use3 AS nbbio_name,
				CASE WHEN BIO4_bio_use3 = 'Other' THEN BIO4_bio_oth_use3 
					 WHEN BIO4_bio_use3 = 'Other BIOLOGIC' THEN BIO4_bio_oth_use3 
					 WHEN BIO4_bio_use3 = 'Other BIOSIMILAR' THEN BIO4_biosim_oth_name3
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIO]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIO5_bio_use4 AS nbbio_name,
				CASE WHEN BIO5_bio_use4 = 'Other' THEN BIO5_bio_oth_use4 
					 WHEN BIO5_bio_use4 = 'Other BIOLOGIC' THEN BIO5_bio_oth_use4 
					 WHEN BIO5_bio_use4 = 'Other BIOSIMILAR' THEN BIO5_biosim_oth_name4
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIO]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIO6_bio_use5 AS nbbio_name,
				CASE WHEN BIO6_bio_use5 = 'Other' THEN BIO6_bio_oth_use5
					 WHEN BIO6_bio_use5 = 'Other BIOLOGIC' THEN BIO6_bio_oth_use5 
					 WHEN BIO6_bio_use5 = 'Other BIOSIMILAR' THEN BIO6_biosim_oth_name5
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIO]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIOF2_bio_name_fu AS nbbio_name,
				CASE WHEN BIOF2_bio_name_fu = 'Other' THEN BIOF2_oth_bio_use_fu 
					 WHEN BIOF2_bio_name_fu = 'Other BIOLOGIC' THEN BIOF2_oth_bio_use_fu 
					 WHEN BIOF2_bio_name_fu = 'Other BIOSIMILAR' THEN BIOF2_biosim_oth_name
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIOF]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIOF3_bio_name_fu2 AS nbbio_name,
				CASE WHEN BIOF3_bio_name_fu2 = 'Other' THEN BIOF3_oth_bio_use_fu2 
					 WHEN BIOF3_bio_name_fu2 = 'Other BIOLOGIC' THEN BIOF3_oth_bio_use_fu2 
					 WHEN BIOF3_bio_name_fu2 = 'Other BIOSIMILAR' THEN BIOF3_biosim_oth_name2
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIOF]
			UNION
			SELECT [Form Object Caption] AS crf_name, BIOF4_bio_name_fu3 AS nbbio_name,
				CASE WHEN BIOF4_bio_name_fu3 = 'Other' THEN BIOF4_oth_bio_use_fu3
					 WHEN BIOF4_bio_name_fu3 = 'Other BIOLOGIC' THEN BIOF4_oth_bio_use_fu3 
					 WHEN BIOF4_bio_name_fu3 = 'Other BIOSIMILAR' THEN BIOF4_biosim_oth_name3
					 END AS nbbio_other, VisitId FROM [OMNICOMM_PSO].[inbound].[BIOF]
			UNION
			SELECT [Form Object Caption] AS crf_name, CT2_bionb_name AS nbbio_name, 
				CASE WHEN CT2_bionb_name = 'Other' THEN CT2_bionb_other_specify
					 WHEN CT2_bionb_name = 'Other BIOLOGIC' THEN CT2_bionb_other_specify 
					 WHEN CT2_bionb_name = 'Other BIOSIMILAR' THEN CT2_biosim_oth_name
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CT]
			UNION
			SELECT [Form Object Caption] AS crf_name, CT3_bionb_name2 AS nbbio_name, 
				CASE WHEN CT3_bionb_name2 = 'Other' THEN CT3_bionb_other_specify2
					 WHEN CT3_bionb_name2 = 'Other BIOLOGIC' THEN CT3_bionb_other_specify2 
					 WHEN CT3_bionb_name2 = 'Other BIOSIMILAR' THEN CT3_biosim_oth_name2
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CT]
			UNION
			SELECT [Form Object Caption] AS crf_name, CT4_bionb_name3 AS nbbio_name, 
				CASE WHEN CT4_bionb_name3 = 'Other' THEN CT4_bionb_other_specify3
					 WHEN CT4_bionb_name3 = 'Other BIOLOGIC' THEN CT4_bionb_other_specify3 
					 WHEN CT4_bionb_name3 = 'Other BIOSIMILAR' THEN CT4_biosim_oth_name3
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CT]
			UNION
			SELECT [Form Object Caption] AS crf_name, CTF2_bionb_name_fu AS nbbio_name, 
				CASE WHEN CTF2_bionb_name_fu = 'Other' THEN CTF2_other_bionb_specify_fu
					 WHEN CTF2_bionb_name_fu = 'Other BIOLOGIC' THEN CTF2_other_bionb_specify_fu 
					 WHEN CTF2_bionb_name_fu = 'Other BIOSIMILAR' THEN CTF2_biosim_oth_name
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CTF]
			UNION
			SELECT [Form Object Caption] AS crf_name, CTF3_bionb_name_fu2 AS nbbio_name, 
				CASE WHEN CTF3_bionb_name_fu2 = 'Other' THEN CTF3_other_bionb_specify_fu2
					 WHEN CTF3_bionb_name_fu2 = 'Other BIOLOGIC' THEN CTF3_other_bionb_specify_fu2 
					 WHEN CTF3_bionb_name_fu2 = 'Other BIOSIMILAR' THEN CTF3_biosim_oth_name2
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CTF]
			UNION
			SELECT [Form Object Caption] AS crf_name, CTF4_bionb_name_fu3 AS nbbio_name, 
				CASE WHEN CTF4_bionb_name_fu3 = 'Other' THEN CTF4_other_bionb_specify_fu3
					 WHEN CTF4_bionb_name_fu3 = 'Other BIOLOGIC' THEN CTF4_other_bionb_specify_fu3 
					 WHEN CTF4_bionb_name_fu3 = 'Other BIOSIMILAR' THEN CTF4_biosim_oth_name3
					 END AS nbbio_other, VisitId  FROM [OMNICOMM_PSO].[inbound].[CTF]
			) AS NBBIO
		WHERE nbbio_name <> '' AND nbbio_name in ('Other', 'Other BIOLOGIC', 'OTHER BIOSIMILAR')
	) AS AllNbBio ON AllNbBio.VisitID = VIS.VisitId
	WHERE nbbio_name <> '' AND nbbio_name in ('Other', 'Other BIOLOGIC', 'OTHER BIOSIMILAR')
	AND SIT.[Site Number] NOT IN (998, 999)

		 



insert into [Reporting].[PSO500].[t_op_OtherDrugsENRFU]
(
	[SiteID],
	[SubjectID],
	[VisitId],
	[TrlObjectVisitId],
	[VisitName],
	[EnrollingProviderID],
	[VisitDate],
	[CRFName],
	[DrugName],
	[OtherSpecify]

)

SELECT 	[SiteID],
       	[SubjectID],
		[VisitId],
		[TrlObjectVisitId],
		[VisitName],
		[EnrollingProviderID],
		[VisitDate],
		[CRFName],
		[DrugName],
		[OtherSpecify]
FROM #OthDrugs 


END




GO
