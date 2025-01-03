USE [Reporting]
GO
/****** Object:  StoredProcedure [PSO500].[usp_Create_PSO_ClicData_Tables]    Script Date: 1/3/2025 4:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****THIS PROCEDURE JUST COMPLETES [PSO500].[t_Elig] TABLE...[PSO500].[t_EligDashboard] TABLE AND [PSO500].[t_VisitLog] TABLE ARE NOW COMPLETED IN [PSO500].[usp_op_CAT] PROCEDURE*****/




-- ====================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 05/01/2019
-- Description:	Update to include new drugs as of Apr 22, 2019 of Cyltezo, Ixifi, Renflexis and Skyrizi
-- Updated to only complete Eligiblity report - ClicData tables are completed by PSO CAT procedure
-- =====================================================================================================

CREATE PROCEDURE [PSO500].[usp_Create_PSO_ClicData_Tables] AS
	-- Add the parameters for the stored procedure here


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* DO NOT DROP AND RECREATE, USER "ClicData" HAS OBJECT LEVEL PERMISIONS
    -- Insert statements for procedure here
	IF OBJECT_ID('[PSO500].[t_Elig]', 'U') IS NOT NULL  DROP TABLE [PSO500].[t_Elig]; 

CREATE TABLE [PSO500].[t_Elig]
(
	[SiteID] [int] NOT NULL,
	[SubjectID] [bigint] NULL,
	[ProviderID] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[Age and Diagnosis Criteria] [varchar](100) NULL,
	[Biologic Criteria] [varchar](250) NULL,
	[Non-biologic Criteria] [varchar](250) NULL,
	[Eligible Treatment] [nvarchar](1024) NULL,
	[YearofBirth] [nvarchar](1024) NULL,
	[AtLeast18] [varchar](3) NULL,
	[PsODiagnosis] [int] NULL,
	[PsADiagnosis] [int] NULL,
	[Clinical Diagnosis Form Status] [nvarchar](50) NULL,
	[Non-Bio Form Status] [nvarchar](50) NULL,
	[CRF Name - Current Non Biologic] [nvarchar](1024) NULL,
	[Start date - Current Non-Biologic] [date] NULL,
	[Current Non-Biologic] [nvarchar](1024) NULL,
	[Current Non-Biologic - Other] [nvarchar](1024) NULL,
	[Days Since Current Non-Biologic Start to Enrollment Date] [int] NULL,
	[Current Non-Biologic - First Ever Use] [nvarchar](1024) NULL,
	[CRF Name - Past Non-Biologic] [nvarchar](1024) NULL,
	[Stop date - Past Non-Biologic] [smalldatetime] NULL,
	[Days Since Past Non-Biologic Stop to Current Non-Biologic Start] [int] NULL,
	[Days Since Past NonBio Stop to NonBio Initiated] [int] NULL,
	[Past Non-Biologic] [nvarchar](1024) NULL,
	[Past Non-Biologic - Other] [nvarchar](1024) NULL,
	[Past Non-Biologic - First Ever Use] [nvarchar](1024) NULL,
	[Past Non-Biologic Same as Current Non-Biologic] [varchar](3) NULL,
	[Current NonBio Same as NonBio Start Today] [varchar](3) NULL,
	[Bio Form Status] [nvarchar](50) NULL,
	[CRF Name - Current Biologic] [nvarchar](1024) NULL,
	[Start date - Current Biologic] [date] NULL,
	[Days Since Current Biologic Start to Enrollment] [int] NULL,
	[Current Biologic] [nvarchar](1024) NULL,
	[Current Biologic - Other] [nvarchar](1024) NULL,
	[Current Biologic - First Ever Use] [nvarchar](1024) NULL,
	[CRF Name - Past Biologic] [nvarchar](1024) NULL,
	[Stop date - Past Biologic] [smalldatetime] NULL,
	[Past Biologic] [nvarchar](1024) NULL,
	[Past Biologic - Other] [nvarchar](1024) NULL,
	[Past Biologic - First Ever Use] [nvarchar](1024) NULL,
	[Current Bio Same as Past Bio] [varchar](3) NULL,
	[Days Since Past Bio Stop to Current Bio Start] [int] NULL,
	[Bio Prescribed Today Same as Past Bio] [varchar](3) NULL,
	[Days Since Past Bio Stop to Initiated Bio] [int] NULL,
	[Current Bio Stopped Today] [varchar](3) NULL,
	[Changes Today Form Status] [nvarchar](50) NULL,
	[TreatmentStartedAtENRVis] [varchar](3) NULL,
	[TreatmentStopped AtENRVis] [varchar](3) NULL,
	[PSO Treatment initiated at ENR visit1] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit1 - Other] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit2] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit2 - Other] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit3] [nvarchar](1024) NULL,
	[PSO Treatment initiated at ENR visit3 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit1] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit1 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit2] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit2 - Other] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit3] [nvarchar](1024) NULL,
	[PSO Treatment stopped at ENR visit3 - Other] [nvarchar](1024) NULL
);




select count(*) from [PSO500].[t_Elig] -- 999
select count(*) from [PSO500].[t_VisitLog]


*/



/*
SELECT * from #ELIG_CRITERIA_LIST where isnumeric(SiteNumber)=0
*/
if object_id('tempdb..#ELIG_CRITERIA_LIST') is not null begin drop table #ELIG_CRITERIA_LIST end


 SELECT DISTINCT
	ADSITE.[TrlSiteId],
	SIT.[Site Number] AS [SiteNumber],
	PAT.[Caption] AS SubjectID,
	VIS.VisitId,
	VIST.TrlObjectID AS TrlObjectVisitId,
	SUB.[pat_md_cod] AS ProviderID,
	CAST(VIS.[Visit Object VisitDate] AS date) AS EnrollmentDate,
	SUB.[birthdate_pat] AS YearofBirth,
	CASE WHEN SUB.[birthdate_pat] != '' AND YEAR(VIS.[Visit Object VisitDate]) - CAST(SUB.[birthdate_pat] AS INT) >= 18 THEN 'Yes' ELSE 'No' END AS [AtLeast18],
	PE.[Form Object Status] AS [Clinical Diagnosis Form Status],
	PE.[PE2_dx_ps] AS [PsODiagnosis],
	PE.[PE2_dx_pa] AS [PsADiagnosis],
	NB.[Form Object Status] AS [Non-Bio Form Status],
	PrevNonBio.crf_name AS [CRF Name - Current Non-Biologic],

	PrevNonBio.nb_date AS [Start date - Current Non-Biologic],
	DATEDIFF(D, PrevNonBio.nb_date, (VIS.[Visit Object VisitDate])) AS CurrNBDateDiff,

	PrevNonBio.nb_name AS [Current Non-Biologic],
	PrevNonBio.nb_other AS [Current Non-Biologic - Other],
	PrevNonbio.nb_f_use AS [Current Non-Biologic - First Ever Use],
	PastNonBio.crf_name AS [CRF Name - Past Non-Biologic],

	CONVERT(nvarchar(11), PastNonBio.nb_date, 113) AS [Stop date - Past Non-Biologic],

	PastNonBio.nb_name AS [Past Non-Biologic],
	PastNonBio.nb_other AS [Past Non-Biologic - Other],

	CASE WHEN PrevNonBio.nb_name + ISNULL(PrevNonBio.nb_other, '')=PastNonBio.nb_name + ISNULL(PastNonBio.nb_other, '')  THEN 'Yes'
	ELSE 'No'
	END AS CurrentNBEqualPastNB,

	CASE WHEN (PrevNonBio.nb_name + ISNULL(PrevNonBio.nb_other, '')=PastNonBio.nb_name + ISNULL(PastNonBio.nb_other, '')) 
	AND (PastNonBio.nb_date<>'' AND PrevNonBio.nb_date<>'') THEN
	DATEDIFF(D, CAST(PastNonBio.nb_date AS DATE), PrevNonBio.nb_date)
	ELSE NULL
	END AS PastNBCurrNBDateDiff,

	PastNonBio.nb_f_use AS [Past Non-Biologic - First Ever Use],
	BIO.[Form Object Status] AS [Bio Form Status],
	PrevBio.crf_name AS [CRF Name - Current Biologic],
	PrevBio.bio_date AS [Start date - Current Biologic],

	CASE WHEN ISNULL(PrevBio.bio_date, '')<>''
	THEN DATEDIFF(D, PrevBio.bio_date, (VIS.[Visit Object VisitDate])) 
	ELSE NULL END AS [Days Since Current Bio Start],

	PrevBio.bio_name AS [Current Biologic],
	PrevBio.bio_other AS [Current Biologic - Other],
	PrevBio.bio_f_use AS [Current Biologic - First Ever Use],
	PastBio.crf_name AS [CRF Name - Past Biologic],
	PastBio.bio_date AS [Stop date - Past Biologic],
	PastBio.bio_name AS [Past Biologic],
	PastBio.bio_other AS [Past Biologic - Other],
	PastBio.bio_f_use AS [Past Biologic - First Ever Use],

	CASE WHEN PrevBio.bio_name + ISNULL(PrevBio.bio_other, '') = PastBio.bio_name + ISNULL(PastBio.bio_other, '')
	     THEN 'Yes'
		 ELSE ''
	END AS [Current Bio Same as Past Bio],

	CT.[Form Object Status] AS [Changes Today Form Status],

	CASE WHEN EXISTS 
		(
			SELECT *
			FROM OMNICOMM_PSO.inbound.[CT] CT
			WHERE CT.[VisitId] = VIS.VisitId AND CT.[Visit Object ProCaption] = 'Enrollment' AND 
			(
				CT.[CT2_bionb_status] = 'Prescribed Today' 
				OR CT.[CT3_bionb_status2] = 'Prescribed Today' 
				OR CT.[CT4_bionb_status3] = 'Prescribed Today' ))
		THEN 'Yes'
		ELSE 'No'
	END AS [TreatmentStartedAtENRVis],

		CASE WHEN EXISTS 
		(
			SELECT *
			FROM OMNICOMM_PSO.inbound.[CT] CT
			WHERE CT.[VisitId] = VIS.VisitId AND CT.[Visit Object ProCaption] = 'Enrollment' AND 
			(
				CT.[CT2_bionb_status] = 'Stopped Today' 
				OR CT.[CT3_bionb_status2] = 'Stopped Today' 
				OR CT.[CT4_bionb_status3] = 'Stopped Today' ))
		THEN 'Yes'
		ELSE 'No'
	END AS [TreatmentStoppedAtENRVis],

	CASE WHEN PHE_BIO_START_TODAY.[CT2_bionb_status] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT2_bionb_name] ELSE '' END AS [PSO treatment initiated at ENR visit1],
	CASE WHEN PHE_BIO_START_TODAY.[CT2_bionb_status] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT2_bionb_other_specify] ELSE '' END AS [PSO treatment initiated at ENR visit1 - Other],
	CASE WHEN PHE_BIO_START_TODAY.[CT3_bionb_status2] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT3_bionb_name2] ELSE '' END AS [PSO treatment initiated at ENR visit2],
	CASE WHEN PHE_BIO_START_TODAY.[CT3_bionb_status2] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT3_bionb_other_specify2] ELSE '' END AS [PSO treatment initiated at ENR visit2 - Other],
	CASE WHEN PHE_BIO_START_TODAY.[CT4_bionb_status3] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT4_bionb_name3] ELSE '' END AS [PSO treatment initiated at ENR visit3],
	CASE WHEN PHE_BIO_START_TODAY.[CT4_bionb_status3] = 'Prescribed Today' THEN PHE_BIO_START_TODAY.[CT4_bionb_other_specify3] ELSE '' END AS [PSO treatment initiated at ENR visit3 - Other],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT2_bionb_status] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT2_bionb_name] ELSE '' END AS [PSO treatment stopped at ENR visit1],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT2_bionb_status] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT2_bionb_other_specify] ELSE '' END AS [PSO treatment stopped at ENR visit1 - Other],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT3_bionb_status2] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT3_bionb_name2] ELSE '' END AS [PSO treatment stopped at ENR visit2],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT3_bionb_status2] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT3_bionb_other_specify2] ELSE '' END AS [PSO treatment stopped at ENR visit2 - Other],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT4_bionb_status3] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT4_bionb_name3] ELSE '' END AS [PSO treatment stopped at ENR visit3],
	CASE WHEN PHE_BIO_STOP_TODAY.[CT4_bionb_status3] = 'Stopped Today' THEN PHE_BIO_STOP_TODAY.[CT4_bionb_other_specify3] ELSE '' END AS [PSO treatment stopped at ENR visit3 - Other]

INTO #ELIG_CRITERIA_LIST

FROM OMNICOMM_PSO.inbound.[Patients] PAT
INNER JOIN OMNICOMM_PSO.inbound.[G_Site Information] SIT ON SIT.SiteId = PAT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[AdHoc_Sites] ADSITE ON ADSITE.SiteId = SIT.SiteId
INNER JOIN OMNICOMM_PSO.inbound.[G_Subject Information] SUB ON SUB.PatientId = PAT.PatientId
INNER JOIN OMNICOMM_PSO.inbound.[VISIT] VIS ON VIS.PatientId = PAT.PatientId AND VIS.[Visit Object ProCaption] = 'Enrollment'
INNER JOIN --		select * from
	OMNICOMM_PSO.inbound.[Visits] VIST 
		ON VIST.Visitid = VIS.Visitid -- Added join to pull in TrlObjectVisitId. 1552 before and after this join.
INNER JOIN OMNICOMM_PSO.inbound.[PE] PE ON PE.PatientId = PAT.PatientId
INNER JOIN OMNICOMM_PSO.inbound.[NB] NB ON VIS.PatientId = NB.PatientId
INNER JOIN OMNICOMM_PSO.inbound.[BIO] BIO ON VIS.PatientId = BIO.PatientId
INNER JOIN OMNICOMM_PSO.inbound.[CT] CT ON VIS.PatientId = CT.PatientId
LEFT JOIN
	(
		SELECT crf_name, nb_date, nb_name, nb_other, nb_f_use, VisitId FROM
		(
			SELECT [Form Object Caption] AS crf_name, NB3_nbio_use2 AS nb_name, 
			CASE WHEN NB3_nonbio_st_dt2=UPPER('UNK/UNK/UNK') OR NB3_nonbio_st_dt2='//' THEN ''
			     WHEN NB3_nonbio_st_dt2 LIKE UPPER('%/UNK') AND NB3_nonbio_st_dt2<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB3_nonbio_st_dt2, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB3_nonbio_st_dt2, 2)='//' AND LEN(NB3_nonbio_st_dt2)=6 THEN LEFT(NB3_nonbio_st_dt2, 4) + '/01/01'
				 WHEN RIGHT(NB3_nonbio_st_dt2, 1)='/' AND LEN(NB3_nonbio_st_dt2)=8 THEN LEFT(NB3_nonbio_st_dt2, 7) + '/01'	
				 ELSE NB3_nonbio_st_dt2
				 END AS nb_date, 
			NB3_nonbio_other_use2 AS nb_other, NB3_nonbio_firstever2 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB3_nonbio_statushx2 <> 'Past'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB4_nbio_use3 AS nb_name, 
			CASE WHEN NB4_nonbio_st_dt3=UPPER('UNK/UNK/UNK') OR NB4_nonbio_st_dt3='//' THEN ''
			     WHEN NB4_nonbio_st_dt3 LIKE UPPER('%/UNK') AND NB4_nonbio_st_dt3<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB4_nonbio_st_dt3, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB4_nonbio_st_dt3, 2)='//' AND LEN(NB4_nonbio_st_dt3)=6 THEN LEFT(NB4_nonbio_st_dt3, 4) + '/01/01'
				 WHEN RIGHT(NB4_nonbio_st_dt3, 1)='/' AND LEN(NB4_nonbio_st_dt3)=8 THEN LEFT(NB4_nonbio_st_dt3, 7) + '/01'	
				 ELSE NB4_nonbio_st_dt3
				 END AS nb_date,
			NB4_nonbio_other_use3 AS nb_other, NB4_nonbio_firstever3 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB4_nonbio_statushx3 <> 'Past'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB5_nbio_use4 AS nb_name, 
			CASE WHEN NB5_nonbio_st_dt4=UPPER('UNK/UNK/UNK') OR NB5_nonbio_st_dt4='//' THEN ''
			     WHEN NB5_nonbio_st_dt4 LIKE UPPER('%/UNK') AND NB5_nonbio_st_dt4<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB5_nonbio_st_dt4, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB5_nonbio_st_dt4, 2)='//' AND LEN(NB5_nonbio_st_dt4)=6 THEN LEFT(NB5_nonbio_st_dt4, 4) + '/01/01'
				 WHEN RIGHT(NB5_nonbio_st_dt4, 1)='/' AND LEN(NB5_nonbio_st_dt4)=8 THEN LEFT(NB5_nonbio_st_dt4, 7) + '/01'	
				 ELSE NB5_nonbio_st_dt4
				 END AS nb_date,
			NB5_nonbio_other_use4 AS nb_other, NB5_nonbio_firstever4 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB5_nonbio_statushx4 <> 'Past'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB7_nbio_use5 AS nb_name, 
			CASE WHEN NB7_nonbio_st_dt5=UPPER('UNK/UNK/UNK') OR NB7_nonbio_st_dt5='//' THEN ''
			     WHEN NB7_nonbio_st_dt5 LIKE UPPER('%/UNK') AND NB7_nonbio_st_dt5<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB7_nonbio_st_dt5, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB5_nonbio_st_dt4, 2)='//' AND LEN(NB7_nonbio_st_dt5)=6 THEN LEFT(NB7_nonbio_st_dt5, 4) + '/01/01'
				 WHEN RIGHT(NB7_nonbio_st_dt5, 1)='/' AND LEN(NB7_nonbio_st_dt5)=8 THEN LEFT(NB7_nonbio_st_dt5, 7) + '/01'	
				 ELSE NB7_nonbio_st_dt5
				 END AS nb_date,	
			NB7_nonbio_other_use5 AS nb_other, NB7_nonbio_firstever5 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB7_nonbio_statushx5 <> 'Past'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB2_nbio_use AS nb_name, 
			CASE WHEN NB2_nonbio_st_dt=UPPER('UNK/UNK/UNK') OR NB2_nonbio_st_dt='//' THEN ''
			     WHEN NB2_nonbio_st_dt LIKE UPPER('%/UNK') AND NB2_nonbio_st_dt<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB2_nonbio_st_dt, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB2_nonbio_st_dt, 2)='//' AND LEN(NB2_nonbio_st_dt)=6 THEN LEFT(NB2_nonbio_st_dt, 4) + '/01/01'
				 WHEN RIGHT(NB2_nonbio_st_dt, 1)='/' AND LEN(NB2_nonbio_st_dt)=8 THEN LEFT(NB2_nonbio_st_dt, 7) + '/01'	
				 ELSE NB2_nonbio_st_dt
				 END AS nb_date,			
			NB2_nonbio_other_use AS nb_other, NB2_nonbio_firstever AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB_NB2
			WHERE NB_NB2.NB2_nonbio_statushx <> 'Past'
			) AS NOBIO
		WHERE nb_name <> '' AND nb_name in ('methotrexate', 'cyclosporine', 'apremilast {Otezla}', 'Other')
	) AS PrevNonBio ON PrevNonBio.VisitID = VIS.VisitId
LEFT JOIN
	(
		SELECT crf_name, nb_date, nb_name, nb_other, nb_f_use, VisitId FROM
		(
			SELECT [Form Object Caption] AS crf_name, NB3_nbio_use2 AS nb_name, 
			CASE WHEN NB3_nonbio_dt_stp2=UPPER('UNK/UNK/UNK') OR NB3_nonbio_dt_stp2='//' THEN ''
			     WHEN NB3_nonbio_dt_stp2 LIKE UPPER('%/UNK') AND NB3_nonbio_dt_stp2<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB3_nonbio_dt_stp2, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB3_nonbio_dt_stp2, 2)='//' AND LEN(NB3_nonbio_dt_stp2)=6 THEN LEFT(NB3_nonbio_dt_stp2, 4) + '/01/01'
				 WHEN RIGHT(NB3_nonbio_dt_stp2, 1)='/' AND LEN(NB3_nonbio_dt_stp2)=8 THEN LEFT(NB3_nonbio_dt_stp2, 7) + '/01'	
				 ELSE NB3_nonbio_dt_stp2
				 END AS nb_date,			
			NB3_nonbio_other_use2 AS nb_other, NB3_nonbio_firstever2 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB3_nonbio_statushx2 <> 'Current'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB4_nbio_use3 AS nb_name, 
			CASE WHEN NB4_nonbio_dt_stp3=UPPER('UNK/UNK/UNK') OR NB4_nonbio_dt_stp3='//' THEN ''
			     WHEN NB4_nonbio_dt_stp3 LIKE UPPER('%/UNK') AND NB4_nonbio_dt_stp3<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB4_nonbio_dt_stp3, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB4_nonbio_dt_stp3, 2)='//' AND LEN(NB4_nonbio_dt_stp3)=6 THEN LEFT(NB4_nonbio_dt_stp3, 4) + '/01/01'
				 WHEN RIGHT(NB4_nonbio_dt_stp3, 1)='/' AND LEN(NB4_nonbio_dt_stp3)=8 THEN LEFT(NB4_nonbio_dt_stp3, 7) + '/01'	
				 ELSE NB4_nonbio_dt_stp3
				 END AS nb_date,			
			NB4_nonbio_other_use3 AS nb_other, NB4_nonbio_firstever3 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB4_nonbio_statushx3 <> 'Current'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB5_nbio_use4 AS nb_name, 
			CASE WHEN NB5_nonbio_dt_stp4=UPPER('UNK/UNK/UNK') OR NB5_nonbio_dt_stp4='//' THEN ''
			     WHEN NB5_nonbio_dt_stp4 LIKE UPPER('%/UNK') AND NB5_nonbio_dt_stp4<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB5_nonbio_dt_stp4, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB5_nonbio_dt_stp4, 2)='//' AND LEN(NB5_nonbio_dt_stp4)=6 THEN LEFT(NB5_nonbio_dt_stp4, 4) + '/01/01'
				 WHEN RIGHT(NB5_nonbio_dt_stp4, 1)='/' AND LEN(NB5_nonbio_dt_stp4)=8 THEN LEFT(NB5_nonbio_dt_stp4, 7) + '/01'	
				 ELSE NB5_nonbio_dt_stp4
				 END AS nb_date,			
			NB5_nonbio_other_use4 AS nb_other, NB5_nonbio_firstever4 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB5_nonbio_statushx4 <> 'Current'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB7_nbio_use5 AS nb_name, 
			CASE WHEN NB7_nonbio_dt_stp5=UPPER('UNK/UNK/UNK') OR NB7_nonbio_dt_stp5='//' THEN ''
			     WHEN NB7_nonbio_dt_stp5 LIKE UPPER('%/UNK') AND NB7_nonbio_dt_stp5<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB7_nonbio_dt_stp5, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB7_nonbio_dt_stp5, 2)='//' AND LEN(NB7_nonbio_dt_stp5)=6 THEN LEFT(NB7_nonbio_dt_stp5, 4) + '/01/01'
				 WHEN RIGHT(NB7_nonbio_dt_stp5, 1)='/' AND LEN(NB7_nonbio_dt_stp5)=8 THEN LEFT(NB7_nonbio_dt_stp5, 7) + '/01'	
				 ELSE NB7_nonbio_dt_stp5
				 END AS nb_date,
			NB7_nonbio_other_use5 AS nb_other, NB7_nonbio_firstever5 AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB
			WHERE NB.NB7_nonbio_statushx5 <> 'Current'

			UNION
			SELECT [Form Object Caption] AS crf_name, NB2_nbio_use AS nb_name, 
			CASE WHEN NB2_nonbio_dt_stp=UPPER('UNK/UNK/UNK') OR NB2_nonbio_dt_stp='//' THEN ''
			     WHEN NB2_nonbio_dt_stp LIKE UPPER('%/UNK') AND NB2_nonbio_dt_stp<>UPPER('UNK/UNK/UNK') THEN REPLACE(NB2_nonbio_dt_stp, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(NB2_nonbio_dt_stp, 2)='//' AND LEN(NB2_nonbio_dt_stp)=6 THEN LEFT(NB2_nonbio_dt_stp, 4) + '/01/01'
				 WHEN RIGHT(NB2_nonbio_dt_stp, 1)='/' AND LEN(NB2_nonbio_dt_stp)=8 THEN LEFT(NB2_nonbio_dt_stp, 7) + '/01'	
				 ELSE NB2_nonbio_dt_stp
				 END AS nb_date,			
			NB2_nonbio_other_use AS nb_other, NB2_nonbio_firstever AS nb_f_use, VisitId FROM OMNICOMM_PSO.inbound.NB_NB2
			WHERE NB_NB2.NB2_nonbio_statushx <> 'Current'
			) AS NOBIO
		WHERE nb_name <> '' AND nb_name in ('methotrexate', 'cyclosporine', 'apremilast {Otezla}', 'Other')
	) AS PastNonBio ON PastNonBio.VisitID = VIS.VisitId
LEFT JOIN
(
	SELECT crf_name, bio_date, bio_name, bio_other, bio_f_use, VisitId FROM
	(
		SELECT [Form Object Caption] AS crf_name, BIO2_bio_use AS bio_name, 
		CASE WHEN BIO2_bio_st_dt=UPPER('UNK/UNK/UNK') OR BIO2_bio_st_dt='//' THEN ''
			     WHEN BIO2_bio_st_dt LIKE UPPER('%/UNK') AND BIO2_bio_st_dt<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO2_bio_st_dt, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(BIO2_bio_st_dt, 2)='//' AND LEN(BIO2_bio_st_dt)=6 THEN LEFT(BIO2_bio_st_dt, 4) + '/01/01'
				 WHEN RIGHT(BIO2_bio_st_dt, 1)='/' AND LEN(BIO2_bio_st_dt)=8 THEN LEFT(BIO2_bio_st_dt, 7) + '/01'	
				 ELSE BIO2_bio_st_dt
				 END AS bio_date,		
		BIO2_bio_oth_use AS bio_other, BIO2_bio_firstever AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO2_bio_statushx <> 'Past'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO3_bio_use2 AS bio_name, 
		CASE WHEN BIO3_bio_st_dt2=UPPER('UNK/UNK/UNK') OR BIO3_bio_st_dt2='//' THEN ''
			     WHEN BIO3_bio_st_dt2 LIKE UPPER('%/UNK') AND BIO3_bio_st_dt2<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO3_bio_st_dt2, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(BIO3_bio_st_dt2, 2)='//' AND LEN(BIO3_bio_st_dt2)=6 THEN LEFT(BIO3_bio_st_dt2, 4) + '/01/01'
				 WHEN RIGHT(BIO3_bio_st_dt2, 1)='/' AND LEN(BIO3_bio_st_dt2)=8 THEN LEFT(BIO3_bio_st_dt2, 7) + '/01'	
				 ELSE BIO3_bio_st_dt2
				 END AS bio_date,		
		BIO3_bio_oth_use2 AS bio_other, BIO3_bio_firstever2 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO3_bio_statushx2 <> 'Past'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO4_bio_use3 AS bio_name, 
		CASE WHEN BIO4_bio_st_dt3=UPPER('UNK/UNK/UNK') OR BIO4_bio_st_dt3='//' THEN ''
			     WHEN BIO4_bio_st_dt3 LIKE UPPER('%/UNK') AND BIO4_bio_st_dt3<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO4_bio_st_dt3, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(BIO4_bio_st_dt3, 2)='//' AND LEN(BIO4_bio_st_dt3)=6 THEN LEFT(BIO4_bio_st_dt3, 4) + '/01/01'
				 WHEN RIGHT(BIO4_bio_st_dt3, 1)='/' AND LEN(BIO4_bio_st_dt3)=8 THEN LEFT(BIO4_bio_st_dt3, 7) + '/01'	
				 ELSE BIO4_bio_st_dt3
				 END AS bio_date,		
		BIO4_bio_oth_use3 AS bio_other, BIO4_bio_firstever3 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO4_bio_statushx3 <> 'Past'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO5_bio_use4 AS bio_name, 
		CASE WHEN BIO5_bio_st_dt4=UPPER('UNK/UNK/UNK') OR BIO5_bio_st_dt4='//' THEN ''
			     WHEN BIO5_bio_st_dt4 LIKE UPPER('%/UNK') AND BIO5_bio_st_dt4<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO5_bio_st_dt4, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(BIO5_bio_st_dt4, 2)='//' AND LEN(BIO5_bio_st_dt4)=6 THEN LEFT(BIO5_bio_st_dt4, 4) + '/01/01'
				 WHEN RIGHT(BIO5_bio_st_dt4, 1)='/' AND LEN(BIO5_bio_st_dt4)=8 THEN LEFT(BIO5_bio_st_dt4, 7) + '/01'	
				 ELSE BIO5_bio_st_dt4
				 END AS bio_date,		
		BIO5_bio_oth_use4 AS bio_other, BIO5_bio_firstever4 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO5_bio_statushx4 <> 'Past'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO6_bio_use5 AS bio_name, 
		CASE WHEN BIO6_bio_st_dt5=UPPER('UNK/UNK/UNK') OR BIO6_bio_st_dt5='//' THEN ''
			     WHEN BIO6_bio_st_dt5 LIKE UPPER('%/UNK') AND BIO6_bio_st_dt5<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO6_bio_st_dt5, UPPER('/UNK'), '/01') 
			     WHEN RIGHT(BIO6_bio_st_dt5, 2)='//' AND LEN(BIO6_bio_st_dt5)=6 THEN LEFT(BIO6_bio_st_dt5, 4) + '/01/01'
				 WHEN RIGHT(BIO6_bio_st_dt5, 1)='/' AND LEN(BIO6_bio_st_dt5)=8 THEN LEFT(BIO6_bio_st_dt5, 7) + '/01'	
				 ELSE BIO6_bio_st_dt5
				 END AS bio_date,		
		BIO6_bio_oth_use5 AS bio_other, BIO6_bio_firstever5 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO6_bio_statushx5 <> 'Past'
		) AS NOBIO
	WHERE bio_name <> '' AND bio_name in ('adalimumab {Humira}', 'brodalumab {Siliq}', 'etanercept {Enbrel}', 'guselkumab {Tremfya}', 'infliximab {Remicade}', 'secukinumab {Cosentyx}', 'ustekinumab {Stelara}', 'ixekizumab {Taltz}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other')
    --and VisitId not in (34949)  --one of the visit ID has invalid date '2018//' so filtering that VisitID
) AS PrevBio ON PrevBio.VisitID = VIS.VisitId
LEFT JOIN
(
	SELECT crf_name, bio_date, bio_name, bio_other, bio_f_use, VisitId FROM
	(
		SELECT [Form Object Caption] AS crf_name, BIO2_bio_use AS bio_name, 
		CASE WHEN BIO2_bio_dt_stp=UPPER('UNK/UNK/UNK') OR BIO2_bio_dt_stp='//' THEN ''
			 WHEN BIO2_bio_dt_stp LIKE UPPER('%/UNK') AND BIO2_bio_dt_stp<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO2_bio_dt_stp, UPPER('/UNK'), '/01') 
			WHEN RIGHT(BIO2_bio_dt_stp, 2)='//' AND LEN(BIO2_bio_dt_stp)=6 THEN LEFT(BIO2_bio_dt_stp, 4) + '/01/01'
			WHEN RIGHT(BIO2_bio_dt_stp, 1)='/' AND LEN(BIO2_bio_dt_stp)=8 THEN LEFT(BIO2_bio_dt_stp, 7) + '/01'	
			ELSE BIO2_bio_dt_stp
			END AS bio_date,		
		BIO2_bio_oth_use AS bio_other, BIO2_bio_firstever AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO2_bio_statushx <> 'Current'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO3_bio_use2 AS bio_name, 
		CASE WHEN BIO3_bio_dt_stp2=UPPER('UNK/UNK/UNK') OR BIO3_bio_dt_stp2='//' THEN ''
			 WHEN BIO3_bio_dt_stp2 LIKE UPPER('%/UNK') AND BIO3_bio_dt_stp2<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO3_bio_dt_stp2, UPPER('/UNK'), '/01') 
			 WHEN RIGHT(BIO3_bio_dt_stp2, 2)='//' AND LEN(BIO3_bio_dt_stp2)=6 THEN LEFT(BIO3_bio_dt_stp2, 4) + '/01/01'
			 WHEN RIGHT(BIO3_bio_dt_stp2, 1)='/' AND LEN(BIO3_bio_dt_stp2)=8 THEN LEFT(BIO3_bio_dt_stp2, 7) + '/01'	
			ELSE BIO3_bio_dt_stp2
			END AS bio_date,		
		BIO3_bio_oth_use2 AS bio_other, BIO3_bio_firstever2 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO3_bio_statushx2 <> 'Current'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO4_bio_use3 AS bio_name,
		CASE WHEN BIO4_bio_dt_stp3=UPPER('UNK/UNK/UNK') OR BIO4_bio_dt_stp3='//' THEN ''
			 WHEN BIO4_bio_dt_stp3 LIKE UPPER('%/UNK') AND BIO4_bio_dt_stp3<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO4_bio_dt_stp3, UPPER('/UNK'), '/01') 
			WHEN RIGHT(BIO4_bio_dt_stp3, 2)='//' AND LEN(BIO4_bio_dt_stp3)=6 THEN LEFT(BIO4_bio_dt_stp3, 4) + '/01/01'
	        WHEN RIGHT(BIO4_bio_dt_stp3, 1)='/' AND LEN(BIO4_bio_dt_stp3)=8 THEN LEFT(BIO4_bio_dt_stp3, 7) + '/01'	
			ELSE BIO4_bio_dt_stp3
			END AS bio_date,		
		BIO4_bio_oth_use3 AS bio_other, BIO4_bio_firstever3 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO4_bio_statushx3 <> 'Current'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO5_bio_use4 AS bio_name, 
		CASE WHEN BIO5_bio_dt_stp4=UPPER('UNK/UNK/UNK') OR BIO5_bio_dt_stp4='//' THEN ''
			  WHEN BIO5_bio_dt_stp4 LIKE UPPER('%/UNK') AND BIO5_bio_dt_stp4<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO5_bio_dt_stp4, UPPER('/UNK'), '/01') 
			WHEN RIGHT(BIO5_bio_dt_stp4, 2)='//' AND LEN(BIO5_bio_dt_stp4)=6 THEN LEFT(BIO5_bio_dt_stp4, 4) + '/01/01'
			WHEN RIGHT(BIO5_bio_dt_stp4, 1)='/' AND LEN(BIO5_bio_dt_stp4)=8 THEN LEFT(BIO5_bio_dt_stp4, 7) + '/01'	
			ELSE BIO5_bio_dt_stp4
			END AS bio_date,		
		BIO5_bio_oth_use4 AS bio_other, BIO5_bio_firstever4 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO5_bio_statushx4 <> 'Current'

		UNION
		SELECT [Form Object Caption] AS crf_name, BIO6_bio_use5 AS bio_name, 
		CASE WHEN BIO6_bio_dt_stp5=UPPER('UNK/UNK/UNK') OR BIO6_bio_dt_stp5='//' THEN ''
			  WHEN BIO6_bio_dt_stp5 LIKE UPPER('%/UNK') AND BIO6_bio_dt_stp5<>UPPER('UNK/UNK/UNK') THEN REPLACE(BIO6_bio_dt_stp5, UPPER('/UNK'), '/01') 
			WHEN RIGHT(BIO6_bio_dt_stp5, 2)='//' AND LEN(BIO6_bio_dt_stp5)=6 THEN LEFT(BIO6_bio_dt_stp5, 4) + '/01/01'
			WHEN RIGHT(BIO6_bio_dt_stp5, 1)='/' AND LEN(BIO6_bio_dt_stp5)=8 THEN LEFT(BIO6_bio_dt_stp5, 7) + '/01'	
			ELSE BIO6_bio_dt_stp5
			END AS bio_date,		
		BIO6_bio_oth_use5 AS bio_other, BIO6_bio_firstever5 AS bio_f_use, VisitId FROM OMNICOMM_PSO.inbound.[BIO]
		WHERE BIO.BIO6_bio_statushx5 <> 'Current'
		) AS NOBIO
	WHERE bio_name <> '' AND bio_name in ('adalimumab {Humira}', 'brodalumab {Siliq}', 'etanercept {Enbrel}', 'guselkumab {Tremfya}', 'infliximab {Remicade}', 'secukinumab {Cosentyx}', 'ustekinumab {Stelara}', 'ixekizumab {Taltz}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other')
) AS PastBio ON PastBio.VisitID = VIS.VisitId
LEFT JOIN 
	(
		SELECT *
		FROM OMNICOMM_PSO.inbound.[CT]
		WHERE CT.[Visit Object ProCaption] = 'Enrollment' AND 
			(
				CT.[CT2_bionb_status] = 'Prescribed Today' 
				OR CT.[CT3_bionb_status2] = 'Prescribed Today' 
				OR CT.[CT4_bionb_status3] = 'Prescribed Today' )
	) AS PHE_BIO_START_TODAY ON PHE_BIO_START_TODAY.VisitId = vis.VisitId
LEFT JOIN 
	(
		SELECT *
		FROM OMNICOMM_PSO.inbound.CT
		WHERE CT.[Visit Object ProCaption] = 'Enrollment' AND 
			(
				CT.[CT2_bionb_status] = 'Stopped Today' 
				OR CT.[CT3_bionb_status2] = 'Stopped Today' 
				OR CT.[CT4_bionb_status3] = 'Stopped Today' )
	) AS PHE_BIO_STOP_TODAY ON PHE_BIO_STOP_TODAY.VisitId = vis.VisitId
WHERE ISNULL(PAT.[Caption], '')<>''
AND ISNUMERIC(PAT.[Caption])=1


		
if object_id('tempdb..#A1') is not null begin drop table #A1 end


SELECT  
        ECL.SiteNumber 
       ,ECL.SubjectID
	   ,ECL.EnrollmentDate
	   ,ECL.ProviderID
	   ,ECL.YearofBirth
	   ,ECL.AtLeast18
	   ,ECL.PsODiagnosis
	   ,ECL.PsADiagnosis
	   ,ECL.[Clinical Diagnosis Form Status]
	   ,ECL.[CRF Name - Current Non-Biologic]
	   ,ECL.[Non-Bio Form Status]
/* Start date for Current Non-biologic wasn't always converting, so here I check if it is a date, and if so, I convert it
   so it can be used later to get days since... */
	  ,CASE WHEN ISDATE(ECL.[Start date - Current Non-Biologic])=1
	   THEN CONVERT(smalldatetime, ECL.[Start date - Current Non-Biologic], 110) 
	   END AS [Start date - Current Non-Biologic]

	   ,ECL.[Current Non-Biologic]
	   ,ECL.[Current Non-Biologic - Other]
	   ,ECL.[CRF Name - Past Non-Biologic]
	   ,ECL.[Current Non-Biologic - First Ever Use]
	   ,ECL.[Past Non-Biologic]
	   ,ECL.[Past Non-Biologic - Other]
	   ,ECL.[Past Non-Biologic - First Ever Use]
	   ,ECL.[Bio Form Status]
	   ,ECL.[CRF Name - Current Biologic]
	   ,ECL.[Current Biologic]
	   ,ECL.[Current Biologic - Other]
	   ,ECL.[Current Biologic - First Ever Use]
/* Stop date for Past Non-biologic wasn't always converting, so here I check if it is a date, and if so, I convert it
   so it can be used later to get days since... */
	  ,CASE WHEN ISDATE(ECL.[Stop date - Past Non-Biologic])=1
	   THEN CONVERT(smalldatetime, ECL.[Stop date - Past Non-Biologic], 110) 
	   END AS [Stop date - Past Non-Biologic]

	   ,ECL.[CRF Name - Past Biologic]
	   ,ECL.[Past Biologic]
	   ,ECL.[Past Biologic - Other]
/* Stop date for Past Biologic wasn't always converting, so here I check if it is a date, and if so, I convert it
   so it can be used later to get days since... */
	  ,CASE WHEN ISDATE(ECL.[Stop date - Past Biologic])=1
	   THEN CONVERT(smalldatetime, ECL.[Stop date - Past Biologic], 110) 
	   END AS [Stop date - Past Biologic]

	   ,ECL.[Past Biologic - First Ever Use]
	   ,ECL.[Current Bio Same as Past Bio]
/* Start date for Current Biologic wasn't always converting, so here I check if it is a date, and if so, I convert it
   so it can be used later to get days since... */
	  ,CASE WHEN ISDATE(ECL.[Start date - Current Biologic])=1
	   THEN CONVERT(smalldatetime, ECL.[Start date - Current Biologic], 110) 
	   END AS [Start date - Current Biologic]

	   ,ECL.[Changes Today Form Status]
	   ,ECL.[TreatmentStartedAtENRVis]
	   ,ECL.[TreatmentStoppedAtENRVis]
	   ,ECL.[PSO treatment initiated at ENR visit1]
	   ,ECL.[PSO treatment initiated at ENR visit1 - Other]
	   ,ECL.[PSO treatment initiated at ENR visit2]
	   ,ECL.[PSO treatment initiated at ENR visit2 - Other]
	   ,ECL.[PSO treatment initiated at ENR visit3]
	   ,ECL.[PSO treatment initiated at ENR visit3 - Other] 
	   ,ECL.[PSO treatment stopped at ENR visit1]
	   ,ECL.[PSO treatment stopped at ENR visit1 - Other]
	   ,ECL.[PSO treatment stopped at ENR visit2]
	   ,ECL.[PSO treatment stopped at ENR visit2 - Other]
	   ,ECL.[PSO treatment stopped at ENR visit3]
	   ,ECL.[PSO treatment stopped at ENR visit3 - Other]
/* Get the days since the current non biologic in the record/row was started prior to enrollment date when enrollment is at or before 6/3/2016 */
	   ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	   AND ECL.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   AND ECL.[Current Non-Biologic] NOT IN (ISNULL(ECL.[PSO treatment stopped at ENR visit1], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit2], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit3], ''))
       AND ISDATE(ECL.[Start date - Current Non-Biologic])=1
	   THEN DATEDIFF(D, ECL.[Start date - Current Non-Biologic], ECL.EnrollmentDate)
	   ELSE NULL
	   END AS [Days Since Current Non-Biologic Start to Enrollment Date]
/* Check to see if the current non biologic in the record/row when enrollment is before or is 6/30/2016 is the same as a non-biologic started today (enrollment) */
	   ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	    AND ECL.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
 	    AND ECL.[Current Non-Biologic] IN (ECL.[PSO treatment initiated at ENR visit1], ECL.[PSO treatment initiated at ENR visit2], ECL.[PSO treatment initiated at ENR visit3])
	    THEN 'Yes'
		ELSE ''
		END AS [Current NonBio Same as NonBio Start Today]
/* Check to see if the current non biologic in the record/row when enrollment at or before 6/30/2016 is the same as as a past non biologic */
	   ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	    AND ECL.[Past Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
 	    AND ECL.[Past Non-Biologic] IN (ECL.[PSO treatment initiated at ENR visit1], ECL.[PSO treatment initiated at ENR visit2], ECL.[PSO treatment initiated at ENR visit3])
	    THEN 'Yes'
		ELSE ''
		END AS [Past NonBio Same as NonBio Start Today]
/* Get the days since the past non biologic in the record/row was stopped and then restarted when enrollment is at or before 6/30/2016 */
	   ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	    AND ECL.[Past Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	    AND ECL.[Past Non-Biologic] IN (ECL.[PSO treatment initiated at ENR visit1], ECL.[PSO treatment initiated at ENR visit2], ECL.[PSO treatment initiated at ENR visit3])
	    AND ISDATE(ECL.[Stop date - Past Non-Biologic])=1
		THEN DATEDIFF(D, CAST(ECL.[Stop date - Past Non-Biologic] AS date), ECL.EnrollmentDate)
        ELSE NULL
		END AS [Days Since Past NonBio Stop to NonBio Initiated]
/* Check if past non biologic is the same as current non biologic in the record/row when enrollment is at or before 6/30/2016 */
	  ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	   AND ECL.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   AND ECL.[Past Non-Biologic]=ECL.[Current Non-Biologic]
	   AND ECL.[Current Non-Biologic] NOT IN (ISNULL(ECL.[PSO treatment stopped at ENR visit1], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit2], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit3], ''))
	   THEN 'Yes'
	   END AS [Past Non-Biologic Same as Current Non-Biologic]
/* Same logic as checking if past non biologic and current biologic in the record/row are the same, and if so, get the days
   between past non biologic stop to to restart */
	  ,CASE WHEN ECL.EnrollmentDate <= convert(date,'2016-06-30')
	   AND ECL.[Past Non-Biologic]=ECL.[Current Non-Biologic]
	   AND  ECL.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   AND ECL.[Current Non-Biologic] NOT IN (ISNULL(ECL.[PSO treatment stopped at ENR visit1], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit2], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit3], ''))
       AND ISDATE(ECL.[Stop date - Past Non-Biologic])=1
	   AND ISDATE(ECL.[Start date - Current Non-Biologic])=1
	   THEN DATEDIFF(D, CAST(ECL.[Stop date - Past Non-Biologic] AS date), ECL.[Start date - Current Non-Biologic])
	   END AS [Days Since Past Non-Biologic Stop to Current Non-Biologic Start]

/* If current biologic is the same as past biologic and stop and start days are present, get the days between past biologic stop and the restart */
	   ,CASE WHEN (ECL.[Current Biologic] + ISNULL(ECL.[Current Biologic - Other], ''))=(ECL.[Past Biologic] + ISNULL(ECL.[Past Biologic - Other], '')) 
	    AND ISDATE(ECL.[Stop date - Past Biologic])=1
		AND ISDATE(ECL.[Start date - Current Biologic])=1
	    THEN DATEDIFF(D, [Stop date - Past Biologic], [Start date - Current Biologic]) 
		ELSE NULL
		END AS [Days Since Past Bio Stop to Current Bio Start]

/* If current biologic for record/row is not 'Other' and is not stopped at enrollment and a start date is available, get days from start to enrollment*/
		,CASE WHEN (ISNULL(ECL.[Current Biologic], '') NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', ISNULL(ECL.[PSO treatment stopped at ENR visit1], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit2], ''), ISNULL(ECL.[PSO treatment stopped at ENR visit3], '')))
		AND ISDATE(ECL.[Start date - Current Biologic])=1
		THEN DATEDIFF(d, cast(ECL.[Start date - Current Biologic] as date), ECL.EnrollmentDate) 
		ELSE NULL
		END AS [Days Since Current Biologic Start to Enrollment]

/* Determine if a biologic started at enrollment was used previously */
		,CASE WHEN ECL.[Past Biologic] IN (ECL.[PSO treatment initiated at ENR visit1], ECL.[PSO treatment initiated at ENR visit2], ECL.[PSO treatment initiated at ENR visit3]) 
	    THEN 'Yes'
		ELSE ''
		END AS [Bio Prescribed Today Same as Past Bio]

/* Using logic that determined if biologic started at enrollment was previously used, and dates are available, get the days between the past use stop and current enrollment date */
		,CASE WHEN ECL.[Past Biologic] + ISNULL(ECL.[Past Biologic - Other], '') IN (ECL.[PSO treatment initiated at ENR visit1] + ISNULL(ECL.[PSO treatment initiated at ENR visit1 - Other], ''), ECL.[PSO treatment initiated at ENR visit2] + ISNULL(ECL.[PSO treatment initiated at ENR visit2 - Other], ''), ECL.[PSO treatment initiated at ENR visit3] + ISNULL(ECL.[PSO treatment initiated at ENR visit3 - Other], ''))
 		 AND ISDATE(ECL.[Stop date - Past Biologic])=1
		 THEN DATEDIFF(D, CAST(ECL.[Stop date - Past Biologic] AS DATE), ECL.EnrollmentDate) 
		 ELSE NULL
		 END AS [Days Since Past Bio Stop to Initiated Bio]

/* Determine if the current biologic was stopped at enrollment */		 
	   ,CASE WHEN ECL.[Current Biologic] + ISNULL(ECL.[Current Biologic - Other], '') IN (ECL.[PSO treatment stopped at ENR visit1] + ISNULL(ECL.[PSO treatment stopped at ENR visit1 - Other], ''), ECL.[PSO treatment stopped at ENR visit2] + ISNULL(ECL.[PSO treatment stopped at ENR visit2 - Other], ''), ECL.[PSO treatment stopped at ENR visit3] + ISNULL(ECL.[PSO treatment stopped at ENR visit3 - Other], '')) 
	    THEN 'Yes'
		ELSE ''
		END AS [Current Bio Stopped Today]
into #A1
FROM #ELIG_CRITERIA_LIST AS ECL
WHERE isnull(ECL.SubjectID, '')<>''
AND isnumeric(ECL.SubjectID) = 1
---AND ECL.SiteNumber NOT IN (997, 998, 999)



	
if object_id('tempdb..#A2') is not null begin drop table #A2 end



SELECT  
        A1.SiteNumber 
       ,A1.SubjectID
	   ,A1.EnrollmentDate
	   ,A1.ProviderID
	   ,A1.YearofBirth
	   ,A1.AtLeast18
	   ,A1.PsODiagnosis
	   ,A1.PsADiagnosis
	   ,A1.[Clinical Diagnosis Form Status]

	   /******************AGE AND DIAGNOSIS********************/

		---Check Age and Diagnosis Criteria
	   ,CASE WHEN (A1.AtLeast18='Yes' AND A1.PsODiagnosis=1) THEN 'Eligible'

	    WHEN (A1.AtLeast18='' OR A1.PsODiagnosis IS NULL) AND A1.[Clinical Diagnosis Form Status] IN ('No Data', 'Incomplete') THEN 'Needs Review - not enough data to determine age and/or diagnosis' 

	    WHEN (A1.AtLeast18='No' OR A1.PsODiagnosis IS NULL) AND (A1.[Clinical Diagnosis Form Status] IN ('No Data Locked','Complete', 'Signed', 'Monitored', 'Partial Monitored', 'Complete Locked')) 
		THEN 'Ineligible'

	    ELSE '' END AS [Age and Diagnosis Criteria]

		/***********************BIOLOGICS************************/

---Determine eligibility of Cyltezo, Ixifi, Renflexis and Skyrizi with start dates 4/22/2019 or later with no past use
		,CASE WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}'))
		AND NOT EXISTS (SELECT B1.SubjectID FROM #A1 B1 where B1.SubjectID=A1.SubjectID AND (B1.[Past Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])
		OR B1.[Current Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])))
		THEN 'Eligible new biologic'

---Determine eligibility of Cimzia and Ilumya (use start dates 5/29/2018 and 10/10/2018 respectively) because there was no past use
		WHEN A1.EnrollmentDate >= convert(date,'2018-10-10') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3]IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')) 
		AND NOT EXISTS (SELECT B1.SubjectID FROM #A1 B1 where B1.SubjectID=A1.SubjectID AND (B1.[Past Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])
		OR B1.[Current Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])))
		THEN 'Eligible new biologic'

		WHEN A1.EnrollmentDate >= convert(date,'2018-05-29') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')) 
		AND NOT EXISTS (SELECT B1.SubjectID FROM #A1 B1 where B1.SubjectID=A1.SubjectID AND (B1.[Past Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])
		OR B1.[Current Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])))
		THEN 'Eligible new biologic'


---Determines biologic started at enrollment is eligible because there was no past use
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')) 
		AND NOT EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID AND (B1.[Past Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])
		OR B1.[Current Biologic] IN (A1.[PSO treatment initiated at ENR visit1], A1.[PSO treatment initiated at ENR visit2], A1.[PSO treatment initiated at ENR visit3])))
		THEN 'Eligible new biologic'

---Determines eligibility of Cyltezo, Ixifi, Renflexis and Skyrizi with start dates 4/22/2019 or later started at enrollment is eligible because restarted > 365 days from past use

		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		    (A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}'))
		AND EXISTS (SELECT B1.[Days Since Past Bio Stop to Initiated Bio] FROM #A1 B1 WHERE B1.[SubjectID]=A1.[SubjectID] AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], '')<>''
		AND B1.[Days Since Past Bio Stop to Initiated Bio]>365)
		THEN 'Eligible new biologic'

---Determines eligibility of Cimzia and Ilumya (use start dates 5/29/2018 and 10/10/2018 respectively) started at enrollment is eligible because restarted > 365 days from past use

		WHEN A1.EnrollmentDate >= convert(date,'2018-10-10') AND
		    (A1.[PSO treatment initiated at ENR visit1] IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}'))
		AND EXISTS (SELECT B1.[Days Since Past Bio Stop to Initiated Bio] FROM #A1 B1 WHERE B1.[SubjectID]=A1.[SubjectID] AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], '')<>''
		AND B1.[Days Since Past Bio Stop to Initiated Bio]>365)
		THEN 'Eligible new biologic'


		WHEN A1.EnrollmentDate >= convert(date,'2018-05-29') AND
		    (A1.[PSO treatment initiated at ENR visit1] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}'))
		AND EXISTS (SELECT B1.[Days Since Past Bio Stop to Initiated Bio] FROM #A1 B1 WHERE B1.[SubjectID]=A1.[SubjectID] AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], '')<>''
		AND B1.[Days Since Past Bio Stop to Initiated Bio]>365)
		THEN 'Eligible new biologic'


--Determines biologic started at enrollment is eligible because restarted > 365 days from past use
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')) 
		AND EXISTS (SELECT B1.[Days Since Past Bio Stop to Initiated Bio] FROM #A1 B1 WHERE B1.[SubjectID]=A1.[SubjectID] AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], '')<>''
		AND B1.[Days Since Past Bio Stop to Initiated Bio]>365)
		THEN 'Eligible new biologic'

---Determines current biologic is eligible because current biologic was not stopped and was started <= 365 prior to enrollment and > 365 days after previous use stop

		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND ISNULL(B1.[Days Since Past Bio Stop to Current Bio Start], '')<>'' AND B1.[Days Since Past Bio Stop to Current Bio Start]>365)
		 THEN 'Eligible current biologic'

	    WHEN A1.EnrollmentDate >= convert(date,'2018-10-10') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND ISNULL(B1.[Days Since Past Bio Stop to Current Bio Start], '')<>'' AND B1.[Days Since Past Bio Stop to Current Bio Start]>365)
		 THEN 'Eligible current biologic'

	   	WHEN A1.EnrollmentDate >= convert(date,'2018-05-29') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND ISNULL(B1.[Days Since Past Bio Stop to Current Bio Start], '')<>'' AND B1.[Days Since Past Bio Stop to Current Bio Start]>365)
		 THEN 'Eligible current biologic'

		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND ISNULL(B1.[Days Since Past Bio Stop to Current Bio Start], '')<>'' AND B1.[Days Since Past Bio Stop to Current Bio Start]>365)
		 THEN 'Eligible current biologic'

---Determines current biologic is eligible because current biologic was not stopped and was started <= 365 prior to enrollment where there was no previous use

		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND B1.[Current Biologic] NOT IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=B1.SubjectID))
		 THEN 'Eligible current biologic'


	    WHEN A1.EnrollmentDate >= convert(date,'2018-10-10') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('tildrakizumab {Ilumya}', 'certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND B1.[Current Biologic] NOT IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=B1.SubjectID))
		 THEN 'Eligible current biologic'

	   	WHEN A1.EnrollmentDate >= convert(date,'2018-05-29') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('certolizumab {Cimzia}', 'ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND B1.[Current Biologic] NOT IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=B1.SubjectID))
		 THEN 'Eligible current biologic'

		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '') IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND B1.[Current Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]<=365
		 AND B1.[Current Biologic] NOT IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=B1.SubjectID))
		 THEN 'Eligible current biologic'


---Determines ineligibility of Cimzia and Ilumya (use start dates 5/29/2018 and 10/10/2018 respectively) because enrollment prior to eligible drug date
				
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		  OR A1.[PSO treatment initiated at ENR visit2]IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		  OR A1.[PSO treatment initiated at ENR visit3]IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')) 
		THEN 'Ineligible - biologic started before approval date'

		WHEN A1.EnrollmentDate < convert(date,'2018-10-10') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')) 
		THEN 'Ineligible - biologic started before approval date'
		
		WHEN A1.EnrollmentDate < convert(date,'2019-04-22') AND
		(A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		  OR A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		  OR A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')) 
		THEN 'Ineligible - biologic started before approval date'

---Determines current biologic is ineligible because restart was <=365 days from past stop and CRF in complete status
		WHEN EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '')<>''
		AND B1.[Current Biologic] NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
	    AND ISNULL(B1.[Days Since Past Bio Stop to Current Bio Start], '')<>'' AND B1.[Days Since Past Bio Stop to Current Bio Start]<=365)
	    AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		THEN 'Ineligible - current biologic started <= 365 days since past use'

---Determines current biologic is ineligible because restart was <=365 days from past stop but CRF in incomplete status and should be reviewed
		WHEN A1.[Current Biologic]=A1.[Past Biologic]
		AND ISNULL(A1.[Days Since Past Bio Stop to Current Bio Start], '')<>''
		AND A1.[Days Since Past Bio Stop to Current Bio Start]<=365
		AND A1.[Bio Form Status] IN ('Incomplete', 'Incomplete Locked')
		THEN 'Needs Review - current biologic stopped <= 365 days after past use but CRF in incomplete status'

---Determines biologic initiated at enrollment is ineligible because it restarted <=365 days since previously stopped and CRF is complete
		WHEN EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID AND 
		B1.[Past Biologic] IN (B1.[PSO treatment initiated at ENR visit1], B1.[PSO treatment initiated at ENR visit2], B1.[PSO treatment initiated at ENR visit3])
		AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], 0)<=365
		AND B1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - new biologic started <= 365 from past discontinuance'

---Determines biologic initiated at enrollment is ineligible because it restarted <=365 days since previously stopped but needs review because CRF is incomplete
		WHEN EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID AND 
		B1.[Past Biologic] IN (B1.[PSO treatment initiated at ENR visit1], B1.[PSO treatment initiated at ENR visit2], B1.[PSO treatment initiated at ENR visit3])
		AND ISNULL(B1.[Days Since Past Bio Stop to Initiated Bio], 0)<=365
		AND B1.[Bio Form Status] IN ('No Data', 'Incomplete'))
		THEN 'Needs Review - new biologic started <= 365 from past discontinuance but CRF in incomplete status'

---Determines that there is no eligible biologic (current biologic stopped and no eligible biologic started at enrollment)
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   	AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - current biologic stopped and no eligible biologic initiated'

		WHEN A1.EnrollmentDate < convert(date,'2018-10-10') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   	AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - current biologic stopped and no eligible biologic initiated'

		WHEN A1.EnrollmentDate < convert(date,'2019-04-22') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   	AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - current biologic stopped and no eligible biologic initiated'
		
		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
	   	AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - current biologic stopped and no biologic initiated'
				
---Incomplete forms and not enough data
		WHEN (ISNULL(A1.[Current Biologic], '')='' 
		AND ISNULL(A1.[PSO treatment initiated at ENR visit1], '')=''
		AND ISNULL(A1.[PSO treatment initiated at ENR visit2], '')=''
		AND ISNULL(A1.[PSO treatment initiated at ENR visit3], '')='')
		AND (A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked')
		OR A1.[Changes Today Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - not enough data to determine eligibility'

---Determines current biologic ineligible since it was started >365 days prior to enrollment, not stopped, and no new biologics started
		WHEN EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '')<>''
		AND B1.[Current Biologic] NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND (ISNULL(B1.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B1.[Days Since Current Biologic Start to Enrollment]>365))
		 THEN 'Ineligible - current biologic started > 365 days prior to enrollment'

---Determines current biologic needs review because no start date was entered, current biologic not stopped, and no new biologics started
		WHEN EXISTS (SELECT B1.SubjectID FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID  AND 
		ISNULL(B1.[Current Biologic], '')<>''
		AND B1.[Current Biologic] NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND (ISNULL(B1.[Start date - Current Biologic], '')=''))
		 AND (A1.[PSO treatment initiated at ENR visit1] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}'))
		 THEN 'Needs review - no start date provided for current biologic'

---Determines needs review because no current or initiated eligible biologic but CRF incomplete
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND (A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - no eligible biologic but CRF in incomplete status'

		WHEN A1.EnrollmentDate < convert(date,'2018-10-10') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', 'tildrakizumab {Ilumya}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND (A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - no eligible biologic but CRF in incomplete status'

		WHEN A1.EnrollmentDate < convert(date,'2019-04-22') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}', '', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND (A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - no eligible biologic but CRF in incomplete status'

		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		A1.[Current Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
		AND A1.[PSO treatment initiated at ENR visit1] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND (A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - no eligible biologic but CRF in incomplete status'

---Determine ineligible because there is no eligible current biologic or intiated biologic and CRF is complete
		WHEN A1.EnrollmentDate < convert(date,'2018-05-29') AND
		ISNULL(A1.[Current Biologic], '') IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')
		AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}')
		AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}'))
		   AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		   AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - no eligible current biologic and no eligible biologic initiated'

		WHEN A1.EnrollmentDate < convert(date,'2018-10-10') AND
		ISNULL(A1.[Current Biologic], '') IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}')
		AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}')
		AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}'))
		   AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		   AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - no eligible current biologic and no eligible biologic initiated'

		WHEN A1.EnrollmentDate < convert(date,'2019-04-22') AND
		ISNULL(A1.[Current Biologic], '') IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}')
		AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}'))
		   AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		   AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - no eligible current biologic and no eligible biologic initiated'

		WHEN A1.EnrollmentDate >= convert(date,'2019-04-22') AND
		ISNULL(A1.[Current Biologic], '') IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', 'Other')
		AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}'))
		   AND (A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		   AND A1.[Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked'))
		THEN 'Ineligible - no eligible current biologic and no eligible biologic initiated'

---Determines Needs Review because no stop date for past use of biologic is available
		WHEN EXISTS (SELECT B1.[Current Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID AND B1.[Current Biologic]=B1.[Past Biologic] AND ISNULL(B1.[Stop date - Past Biologic], '')='')
		THEN 'Needs Review - No stop date for past use of biologic available'

---Determines no current or initiated biologic but the bio and non bio forms are incomplete or no data and requires review
		WHEN ISNULL(A1.[Current Biologic], '')<>''
		AND ISNULL([Start date - Current Biologic], '')=''
		THEN 'Needs Review - missing start date for current biologic' 
		
		WHEN ISNULL(A1.[Current Non-Biologic], '')=''
		AND ISNULL(A1.[Current Biologic], '')=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND (A1.[Changes Today Form Status] IN ('No Data', 'Incomplete')
		OR A1.[Non-Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked')
		OR A1.[Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked'))
		THEN 'Needs Review - No eligible treatment entered but CRF in incomplete status'
		ELSE '' END AS BioCriteria
		
		/*********************NON-BIOLOGICS**********************/

---Check current nonbiologic before 6/30/2016 was started <= 365 days prior and not stopped at enrollment on current record/row
		,CASE WHEN A1.EnrollmentDate <= convert(date,'2016-06-30')
		 AND A1.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		 AND A1.[Current Non-Biologic] NOT IN (ISNULL(A1.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(A1.[PSO treatment stopped at ENR visit2], ''), ISNULL(A1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(A1.[Days Since Current Non-Biologic Start to Enrollment Date], '')<>''
		 AND A1.[Days Since Current Non-Biologic Start to Enrollment Date]<=365
		 THEN 'Eligible current non-biologic'
---Check current nonbiologic before 6/30/2016 was started <= 365 days prior and not stopped at enrollment on any record/row
		 WHEN A1.EnrollmentDate <= convert(date,'2016-06-30')
		 AND EXISTS (SELECT B1.[Current Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID
		 AND B1.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		 AND B1.[Current Non-Biologic] NOT IN (ISNULL(B1.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B1.[PSO treatment stopped at ENR visit2], ''), ISNULL(B1.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B1.[Days Since Current Non-Biologic Start to Enrollment Date], '')<>''
		 AND B1.[Days Since Current Non-Biologic Start to Enrollment Date]<=365)
		 THEN 'Eligible current non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and previously prescribed but stopped >365 days prior to enrollment
---Initiated 1
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit1] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')<>'' AND B1.[Days Since Past NonBio Stop to NonBio Initiated]>365)
		THEN 'Eligible new non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and previously prescribed but stopped >365 days prior to enrollment
---Initiated 2
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')<>'' AND B1.[Days Since Past NonBio Stop to NonBio Initiated]>365)
		THEN 'Eligible new non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and previously prescribed but stopped >365 days prior to enrollment
---Initiated 3
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')<>'' AND B1.[Days Since Past NonBio Stop to NonBio Initiated]>365)
		THEN 'Eligible new non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and not previously prescribed
---Initiated 1
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit1] NOT IN (SELECT ISNULL(B1.[Past Non-Biologic], '') FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID)
		THEN 'Eligible new non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and not previously prescribed
---Initiated 2
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] NOT IN (SELECT ISNULL(B1.[Past Non-Biologic], '') FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID)
		THEN 'Eligible new non-biologic'

---Check new nonbiologic started at enrollment prior to 6/30/2016 and not previously prescribed
---Initiated 3
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] NOT IN (SELECT ISNULL(B1.[Past Non-Biologic], '') FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID)
		THEN 'Eligible new non-biologic'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 1
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit1] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')='')
		THEN 'Needs Review - no stop date for past non-biologic'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 2
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')='')
		THEN 'Needs Review - no stop date for past non-biologic'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 3
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND ISNULL(B1.[Days Since Past NonBio Stop to NonBio Initiated], '')='')
		THEN 'Needs Review - no stop date for past non-biologic'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 1
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit1] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND B1.[Days Since Past NonBio Stop to NonBio Initiated]<=365
		AND B1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked') 
		AND B1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked')) 
		THEN 'Ineligible new non-biologic - previously prescribed and stopped <= 365 days prior to enrollment'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 2
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit2] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND B1.[Days Since Past NonBio Stop to NonBio Initiated]<=365
		AND B1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked') 
		AND B1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked')) 
		THEN 'Ineligible new non-biologic - previously prescribed and stopped <= 365 days prior to enrollment'

---New nonbiologic started at enrollment prior to 6/30/2016 but previously prescribed and not stopped <=365 days prior to enrollment
---Initiated 3
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		AND A1.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A1.[PSO treatment initiated at ENR visit3] IN (SELECT B1.[Past Non-Biologic] FROM #A1 B1 WHERE B1.SubjectID=A1.SubjectID 
		AND B1.[Days Since Past NonBio Stop to NonBio Initiated]<=365
		AND B1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked') 
		AND B1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked')) 
		THEN 'Ineligible new non-biologic - previously prescribed and stopped <= 365 days prior to enrollment'

---Current nonbiologic enrollment prior to 6/30/2016 is stopped at enrollment and no new eligible PSO treatment started
        WHEN A1.EnrollmentDate <= convert(date,'2016-06-30') 
		     AND ISNULL(A1.[Current Non-Biologic], '')<>''
			 AND A1.[Current Non-Biologic] IN (A1.[PSO treatment stopped at ENR visit1], A1.[PSO treatment stopped at ENR visit2], A1.[PSO treatment stopped at ENR visit3])
			 AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
			 AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
			 AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}'))
			 AND (A1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked')) 
		THEN 'Ineligible - no current or initiated eligible non-biologic'

---Current nonbiologic was started prior to 6/30/2016 with completed form started >365 days prior, and no new eligible treatment was started at enrollment
	    WHEN (A1.EnrollmentDate <= convert(date,'2016-06-30'))
		     AND A1.[Days Since Current Non-Biologic Start to Enrollment Date]>365
			 AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}') 
			 AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}') 
			 AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')) 
			 AND (A1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked')) 
		THEN 'Ineligible - current non-biologic started > 365 days prior to enrollment'


---Current nonbiologic was started prior to 6/30/2016 with incomplete form; was started >365 days prior
        WHEN (A1.EnrollmentDate <= convert(date,'2016-06-30'))
		     AND A1.[Days Since Current Non-Biologic Start to Enrollment Date]>365
			 AND (A1.[PSO treatment initiated at ENR visit1] NOT IN ('methotrexate', 'apremilast {Otezla}', 'cyclosporine')
			 AND A1.[PSO treatment initiated at ENR visit2] NOT IN ('methotrexate', 'apremilast {Otezla}', 'cyclosporine')
			 AND A1.[PSO treatment initiated at ENR visit3] NOT IN ('methotrexate', 'apremilast {Otezla}', 'cyclosporine'))  
			 AND (A1.[Non-Bio Form Status] IN ('No Data', 'Incomplete')) 
		THEN 'Needs Review - current non-biologic started > 365 days prior to enrollment but CRF in incomplete status'

---No current non-biologic or biologic and no PSO Treatment started
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30')
		AND ISNULL(A1.[Current Non-Biologic], '')=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[Changes Today Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		AND A1.[Non-Bio Form Status] IN ('Complete', 'Monitored', 'Partial Monitored', 'Complete Locked', 'Signed', 'Signed Locked', 'No Data Locked')
		THEN 'Ineligible - no current non-biologic or eligible treatment initiated'

---No current non-biologic or biologic and no PSO Treatment started
		WHEN A1.EnrollmentDate <= convert(date,'2016-06-30')
		AND ISNULL(A1.[Current Non-Biologic], '')=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[PSO treatment initiated at ENR visit1]=''
		AND A1.[Changes Today Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked')
		AND A1.[Non-Bio Form Status] IN ('No Data', 'Incomplete', 'No Data Locked', 'Incomplete Locked')
		THEN 'Needs Review - not enough data to determine eligiblity and CRF in incomplete status'
    	ELSE '' END AS NonBioCriteria

	   ,CASE WHEN ISNULL(A1.[Current Biologic], '')<>'' AND A1.[Current Biologic] NOT IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=A1.SubjectID) THEN 'No'
	    WHEN ISNULL(A1.[Current Biologic], '')<>'' AND A1.[Current Biologic] IN (SELECT ISNULL(C1.[Past Biologic], '') FROM #A1 C1 WHERE C1.SubjectID=A1.SubjectID) THEN 'Yes'
		ELSE ''
		END AS CurrentBiologicPastUse
	   ,A1.[CRF Name - Current Non-Biologic]
	   ,A1.[Non-Bio Form Status]
	   ,A1.[Start date - Current Non-Biologic]
	   ,A1.[Current Non-Biologic]
	   ,A1.[Current Non-Biologic - Other]
	   ,A1.[Days Since Current Non-Biologic Start to Enrollment Date]
	   ,A1.[CRF Name - Past Non-Biologic]
	   ,A1.[Current Non-Biologic - First Ever Use]
	   ,A1.[Current NonBio Same as NonBio Start Today]
	   ,A1.[Past NonBio Same as NonBio Start Today]
	   ,A1.[Days Since Past NonBio Stop to NonBio Initiated]
	   ,A1.[Past Non-Biologic Same as Current Non-Biologic]
	   ,A1.[Days Since Past Non-Biologic Stop to Current Non-Biologic Start]
	   ,A1.[Past Non-Biologic]
	   ,A1.[Past Non-Biologic - Other]
	   ,A1.[Stop date - Past Non-Biologic]
	   ,A1.[Past Non-Biologic - First Ever Use]
	   ,A1.[Bio Form Status]
	   ,A1.[CRF Name - Current Biologic]
	   ,A1.[Current Biologic]
	   ,A1.[Current Biologic - Other]
	   ,A1.[Start date - Current Biologic]
	   ,A1.[Days Since Current Biologic Start to Enrollment]
	   ,A1.[Current Biologic - First Ever Use]
	   ,A1.[CRF Name - Past Biologic]
	   ,A1.[Past Biologic]
	   ,A1.[Past Biologic - Other]
	   ,A1.[Stop date - Past Biologic]
	   ,A1.[Past Biologic - First Ever Use]
	   ,A1.[Current Bio Same as Past Bio]
	   ,A1.[Days Since Past Bio Stop to Current Bio Start]
	   ,A1.[Bio Prescribed Today Same as Past Bio]
	   ,A1.[Days Since Past Bio Stop to Initiated Bio]
	   ,A1.[Current Bio Stopped Today]
	   ,A1.[Changes Today Form Status]
	   ,A1.[TreatmentStartedAtENRVis]
	   ,A1.[TreatmentStoppedAtENRVis]
	   ,A1.[PSO treatment initiated at ENR visit1]
	   ,A1.[PSO treatment initiated at ENR visit1 - Other]
	   ,A1.[PSO treatment initiated at ENR visit2]
	   ,A1.[PSO treatment initiated at ENR visit2 - Other]
	   ,A1.[PSO treatment initiated at ENR visit3]
	   ,A1.[PSO treatment initiated at ENR visit3 - Other] 
	   ,A1.[PSO treatment stopped at ENR visit1]
	   ,A1.[PSO treatment stopped at ENR visit1 - Other]
	   ,A1.[PSO treatment stopped at ENR visit2]
	   ,A1.[PSO treatment stopped at ENR visit2 - Other]
	   ,A1.[PSO treatment stopped at ENR visit3]
	   ,A1.[PSO treatment stopped at ENR visit3 - Other]
into #A2
FROM #A1 A1
 
	--SELECT * FROM #A2 WHERE SubjectID IN (45021060092, 45171380053, 49990020003)
	
if object_id('tempdb..#C1') is not null begin drop table #C1 end


/***Check Eligible Drugs***/

SELECT  
        A2.SiteNumber 
       ,A2.SubjectID
	   ,A2.EnrollmentDate
	   ,A2.ProviderID
	   ,A2.YearofBirth
	   ,A2.AtLeast18
	   ,A2.PsODiagnosis
	   ,A2.PsADiagnosis
	   ,A2.[Age and Diagnosis Criteria]
	   ,A2.[BioCriteria] AS [Biologic Criteria]
	   ,A2.[NonBioCriteria] AS [Non-Biologic Criteria]

	   /**********ELIGIBLE TREATMENT LISTING**********/

	   /*************Biologics*******************/
	   ,CASE WHEN A2.[PSO treatment initiated at ENR visit1] NOT IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit1] NOT IN (SELECT ISNULL(B2.[Current Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit1] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}')
		THEN A2.[PSO treatment initiated at ENR visit1]

		WHEN (A2.[PSO treatment initiated at ENR visit1] IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID AND B2.[Days Since Past Bio Stop to Initiated Bio]>365)) 
		AND A2.[PSO treatment initiated at ENR visit1] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		THEN A2.[PSO treatment initiated at ENR visit1]

		WHEN A2.[PSO treatment initiated at ENR visit2] NOT IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit2] NOT IN (SELECT ISNULL(B2.[Current Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit2] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		THEN A2.[PSO treatment initiated at ENR visit2]

		WHEN (A2.[PSO treatment initiated at ENR visit2] IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID AND B2.[Days Since Past Bio Stop to Initiated Bio]>365)) 
		AND A2.[PSO treatment initiated at ENR visit2] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		THEN A2.[PSO treatment initiated at ENR visit2]

		WHEN A2.[PSO treatment initiated at ENR visit3] NOT IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit3] NOT IN (SELECT ISNULL(B2.[Current Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		AND A2.[PSO treatment initiated at ENR visit3] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		THEN A2.[PSO treatment initiated at ENR visit3]

		WHEN (A2.[PSO treatment initiated at ENR visit3] IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID AND B2.[Days Since Past Bio Stop to Initiated Bio]>365)) 
		AND A2.[PSO treatment initiated at ENR visit3] IN ('ustekinumab {Stelara}', 'secukinumab {Cosentyx}', 'adalimumab {Humira}', 'etanercept {Enbrel}', 'ixekizumab {Taltz}', 'infliximab {Remicade}', 'guselkumab {Tremfya}', 'brodalumab {Siliq}', 'adalimumab-atto {Amjevita}', 'etanercept-szzs {Erelzi}', 'infliximab-dyyb {Inflectra}', 'certolizumab {Cimzia}', 'tildrakizumab {Ilumya}', 'adalimumab-adbm {Cyltezo}', 'infliximab-qbtx {Ixifi}', 'infliximab-abda {Renflexis}', 'risankizumab {Skyrizi}') 
		THEN A2.[PSO treatment initiated at ENR visit3]

		 WHEN (ISNULL(A2.[Current Biologic], '')<>''
		 AND EXISTS( SELECT B2.[Current Biologic] FROM #A2 B2 WHERE A2.[SubjectID]=B2.[SubjectID] AND
		 B2.[Current Biologic] NOT IN (SELECT ISNULL(C2.[Past Biologic], '') FROM #A2 C2 WHERE B2.SubjectID=C2.SubjectID)))
		 THEN (SELECT TOP 1 B2.[Current Biologic] FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID 
		 AND B2.[Current Biologic] NOT IN (SELECT ISNULL(C2.[Past Biologic], '') FROM #A2 C2 WHERE C2.SubjectID=B2.SubjectID)
		 AND ISNULL(B2.[Days Since Current Biologic Start to Enrollment],'')<>'' 
	     AND B2.[Days Since Current Biologic Start to Enrollment]<=365 
	     AND B2.[Current Biologic] NOT IN ('Other BIOLOGIC', 'Other BIOSIMILAR', ISNULL(B2.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B2.[PSO treatment stopped at ENR visit2], ''), ISNULL(B2.[PSO treatment stopped at ENR visit3], '')))
		 
		WHEN (ISNULL(A2.[Current Biologic], '')<>''
		AND A2.[Current Biologic] IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID))
		THEN (SELECT TOP 1 B2.[Current Biologic] FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID  
		AND B2.[Current Biologic] IN (SELECT ISNULL(C2.[Past Biologic], '') FROM #A2 C2 WHERE C2.SubjectID=A2.SubjectID)
		AND B2.[Current Biologic] NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', ISNULL(B2.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B2.[PSO treatment stopped at ENR visit2], ''), ISNULL(B2.[PSO treatment stopped at ENR visit3], ''))
		 AND (ISNULL(B2.[Days Since Current Biologic Start to Enrollment], '')<>'' AND B2.[Days Since Current Biologic Start to Enrollment]<=365)
		 AND (ISNULL(B2.[Days Since Past Bio Stop to Current Bio Start],'')<>'' AND B2.[Days Since Past Bio Stop to Current Bio Start]>365))

		WHEN (ISNULL(A2.[Current Biologic], '')<>''
		AND A2.[Current Biologic] IN (SELECT ISNULL(B2.[Past Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID))
		THEN (SELECT TOP 1 B2.[Current Biologic] FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID  
		AND B2.[Current Biologic] IN (SELECT ISNULL(C2.[Past Biologic], '') FROM #A2 C2 WHERE C2.SubjectID=B2.SubjectID)
		AND B2.[Current Biologic] NOT IN ('', 'Other BIOLOGIC', 'Other BIOSIMILAR', ISNULL(B2.[PSO treatment stopped at ENR visit1], ''), 
		      ISNULL(B2.[PSO treatment stopped at ENR visit2], ''), ISNULL(B2.[PSO treatment stopped at ENR visit3], ''))
		 AND ISNULL(B2.[Days Since Current Biologic Start to Enrollment], '')='')	

		 ELSE NULL END AS [Eligible Biologic]


       /**************Non-biologics*****************/
	    ,CASE WHEN ISNULL(A2.[Current Non-Biologic], '')<>''
		AND A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit1] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit2] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit3] NOT IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		---AND A2.[Days Since Current Non-Biologic Start to Enrollment Date]<=365
		THEN (SELECT TOP 1 B2.[Current Non-Biologic] FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID
		AND B2.[Current Non-Biologic] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND ISNULL(B2.[Days Since Current Non-Biologic Start to Enrollment Date], '')<>''
		AND B2.[Days Since Current Non-Biologic Start to Enrollment Date]<=365)

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND ISNULL(A2.[Past Non-Biologic], '')='' 
		THEN A2.[PSO treatment initiated at ENR visit1]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND ISNULL(A2.[Past Non-Biologic], '')='' 
		THEN A2.[PSO treatment initiated at ENR visit2]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND ISNULL(A2.[Past Non-Biologic], '')='' 
		THEN A2.[PSO treatment initiated at ENR visit3]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit1] NOT IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		THEN A2.[PSO treatment initiated at ENR visit1]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit2] NOT IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		THEN A2.[PSO treatment initiated at ENR visit2]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit3] NOT IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID)
		THEN A2.[PSO treatment initiated at ENR visit3]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit1] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit1] IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID
		AND B2.[Days Since Past NonBio Stop to NonBio Initiated] > 365)
		THEN A2.[PSO treatment initiated at ENR visit1]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit2] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit2] IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID
		AND B2.[Days Since Past NonBio Stop to NonBio Initiated] > 365)
		THEN A2.[PSO treatment initiated at ENR visit2]

		WHEN A2.EnrollmentDate <= convert(date,'2016-06-30')
		AND A2.[PSO treatment initiated at ENR visit3] IN ('methotrexate', 'cyclosporine', 'apremilast {Otezla}')
		AND A2.[PSO treatment initiated at ENR visit3] IN (SELECT ISNULL(B2.[Past Non-Biologic], '') FROM #A2 B2 WHERE B2.SubjectID=A2.SubjectID
		AND B2.[Days Since Past NonBio Stop to NonBio Initiated] > 365)
		THEN A2.[PSO treatment initiated at ENR visit3]

		ELSE NULL END AS [Eligible NonBiologic]

	   ,A2.[Clinical Diagnosis Form Status]
	   ,A2.[CRF Name - Current Non-Biologic]
	   ,A2.[Non-Bio Form Status]
	   ,A2.[Start date - Current Non-Biologic]
	   ,A2.[Current Non-Biologic]
	   ,A2.[Current Non-Biologic - Other]
	   ,A2.[Days Since Current Non-Biologic Start to Enrollment Date]
	   ,A2.[CRF Name - Past Non-Biologic]
	   ,A2.[Current Non-Biologic - First Ever Use]
	   ,A2.[Current NonBio Same as NonBio Start Today]
	   ,A2.[Past NonBio Same as NonBio Start Today]
	   ,A2.[Days Since Past Non-Biologic Stop to Current Non-Biologic Start]
	   ,A2.[Days Since Past NonBio Stop to NonBio Initiated]
	   ,A2.[Past Non-Biologic Same as Current Non-Biologic]
	   ,A2.[Past Non-Biologic]
	   ,A2.[Past Non-Biologic - Other]
	   ,A2.[Stop date - Past Non-Biologic]
	   ,A2.[Past Non-Biologic - First Ever Use]
	   ,A2.[Bio Form Status]
	   ,A2.[CRF Name - Current Biologic]
	   ,A2.[Current Biologic]
	   ,A2.[Current Biologic - Other]
	   ,A2.[Start date - Current Biologic]
	   ,A2.[Days Since Current Biologic Start to Enrollment]
	   ,A2.[Current Biologic - First Ever Use]
	   ,A2.[CRF Name - Past Biologic]
	   ,A2.[Past Biologic]
	   ,A2.[Past Biologic - Other]
	   ,A2.[Stop date - Past Biologic]
	   ,A2.[Past Biologic - First Ever Use]
	   ,A2.[Current Bio Same as Past Bio]
	   ,A2.[Days Since Past Bio Stop to Current Bio Start]
	   ,A2.[Bio Prescribed Today Same as Past Bio]
	   ,A2.[Days Since Past Bio Stop to Initiated Bio]
	   ,A2.[Current Bio Stopped Today]
	   ,A2.[Changes Today Form Status]
	   ,A2.[TreatmentStartedAtENRVis]
	   ,A2.[TreatmentStoppedAtENRVis]
	   ,A2.[PSO treatment initiated at ENR visit1]
	   ,A2.[PSO treatment initiated at ENR visit1 - Other]
	   ,A2.[PSO treatment initiated at ENR visit2]
	   ,A2.[PSO treatment initiated at ENR visit2 - Other]
	   ,A2.[PSO treatment initiated at ENR visit3]
	   ,A2.[PSO treatment initiated at ENR visit3 - Other] 
	   ,A2.[PSO treatment stopped at ENR visit1]
	   ,A2.[PSO treatment stopped at ENR visit1 - Other]
	   ,A2.[PSO treatment stopped at ENR visit2]
	   ,A2.[PSO treatment stopped at ENR visit2 - Other]
	   ,A2.[PSO treatment stopped at ENR visit3]
	   ,A2.[PSO treatment stopped at ENR visit3 - Other]
into #C1
FROM #A2 A2

--SELECT * FROM #C1 WHERE SubjectID IN (45021040302)
--SELECT * FROM #A2 WHERE SubjectID IN (45021060092, 45171380053, 49990020003) 
--SELECT * FROM #C1 WHERE [Biologic Criteria]='Eligible current biologic'  AND [Eligible Biologic] IS NULL ORDER BY SiteNumber, SubjectID

if object_id('tempdb..#C2') is not null begin drop table #C2 end

SELECT  
        C1.SiteNumber 
       ,C1.SubjectID
	   ,C1.EnrollmentDate
	   ,C1.ProviderID
	   ,C1.YearofBirth
	   ,C1.AtLeast18
	   ,C1.PsODiagnosis
	   ,C1.PsADiagnosis
	   ,C1.[Age and Diagnosis Criteria]
	   ,C1.[Biologic Criteria]
	   ,C1.[Non-Biologic Criteria]
	   ,COALESCE([Eligible Biologic], [Eligible NonBiologic]) AS [Eligible Treatment]
	   ,C1.[Clinical Diagnosis Form Status]
	   ,C1.[CRF Name - Current Non-Biologic]
	   ,C1.[Non-Bio Form Status]
	   ,C1.[Start date - Current Non-Biologic]
	   ,C1.[Current Non-Biologic]
	   ,C1.[Current Non-Biologic - Other]
	   ,C1.[Days Since Current Non-Biologic Start to Enrollment Date]
	   ,C1.[CRF Name - Past Non-Biologic]
	   ,C1.[Current Non-Biologic - First Ever Use]
	   ,C1.[Current NonBio Same as NonBio Start Today]
	   ,C1.[Past NonBio Same as NonBio Start Today]
	   ,C1.[Days Since Past Non-Biologic Stop to Current Non-Biologic Start]
	   ,C1.[Days Since Past NonBio Stop to NonBio Initiated]
	   ,C1.[Past Non-Biologic Same as Current Non-Biologic]
	   ,C1.[Past Non-Biologic]
	   ,C1.[Past Non-Biologic - Other]
	   ,C1.[Stop date - Past Non-Biologic]
	   ,C1.[Past Non-Biologic - First Ever Use]
	   ,C1.[Bio Form Status]
	   ,C1.[CRF Name - Current Biologic]
	   ,C1.[Current Biologic]
	   ,C1.[Current Biologic - Other]
	   ,C1.[Start date - Current Biologic]
	   ,C1.[Days Since Current Biologic Start to Enrollment]
	   ,C1.[Current Biologic - First Ever Use]
	   ,C1.[CRF Name - Past Biologic]
	   ,C1.[Past Biologic]
	   ,C1.[Past Biologic - Other]
	   ,C1.[Stop date - Past Biologic]
	   ,C1.[Past Biologic - First Ever Use]
	   ,C1.[Current Bio Same as Past Bio]
	   ,C1.[Days Since Past Bio Stop to Current Bio Start]
	   ,C1.[Bio Prescribed Today Same as Past Bio]
	   ,C1.[Days Since Past Bio Stop to Initiated Bio]
	   ,C1.[Current Bio Stopped Today]
	   ,C1.[Changes Today Form Status]
	   ,C1.[TreatmentStartedAtENRVis]
	   ,C1.[TreatmentStoppedAtENRVis]
	   ,C1.[PSO treatment initiated at ENR visit1]
	   ,C1.[PSO treatment initiated at ENR visit1 - Other]
	   ,C1.[PSO treatment initiated at ENR visit2]
	   ,C1.[PSO treatment initiated at ENR visit2 - Other]
	   ,C1.[PSO treatment initiated at ENR visit3]
	   ,C1.[PSO treatment initiated at ENR visit3 - Other] 
	   ,C1.[PSO treatment stopped at ENR visit1]
	   ,C1.[PSO treatment stopped at ENR visit1 - Other]
	   ,C1.[PSO treatment stopped at ENR visit2]
	   ,C1.[PSO treatment stopped at ENR visit2 - Other]
	   ,C1.[PSO treatment stopped at ENR visit3]
	   ,C1.[PSO treatment stopped at ENR visit3 - Other]
into #C2
FROM #C1 C1


TRUNCATE TABLE [Reporting].[PSO500].[t_Elig];


insert into [Reporting].[PSO500].[t_Elig] 
(
	[SiteID],
	[SubjectID],
	[ProviderID],
	[EnrollmentDate],
	[Age and Diagnosis Criteria],
	[Biologic Criteria],
	[Non-biologic Criteria],
	[Eligible Treatment],
	[YearofBirth],
	[AtLeast18],
	[PsODiagnosis],
	[PsADiagnosis],
	[Clinical Diagnosis Form Status],
	[Non-Bio Form Status],
	[CRF Name - Current Non Biologic],
	[Start date - Current Non-Biologic],
	[Current Non-Biologic],
	[Current Non-Biologic - Other],
	[Days Since Current Non-Biologic Start to Enrollment Date],
	[Current Non-Biologic - First Ever Use],
	[CRF Name - Past Non-Biologic],
	[Stop date - Past Non-Biologic],
	[Days Since Past Non-Biologic Stop to Current Non-Biologic Start],
	[Days Since Past NonBio Stop to NonBio Initiated],
	[Past Non-Biologic],
	[Past Non-Biologic - Other],
	[Past Non-Biologic - First Ever Use],
	[Past Non-Biologic Same as Current Non-Biologic],
	[Current NonBio Same as NonBio Start Today],
	[Bio Form Status],
	[CRF Name - Current Biologic],
	[Start date - Current Biologic],
	[Days Since Current Biologic Start to Enrollment],
	[Current Biologic],
	[Current Biologic - Other],
	[Current Biologic - First Ever Use],
	[CRF Name - Past Biologic],
	[Stop date - Past Biologic],
	[Past Biologic],
	[Past Biologic - Other],
	[Past Biologic - First Ever Use],
	[Current Bio Same as Past Bio],
	[Days Since Past Bio Stop to Current Bio Start],
	[Bio Prescribed Today Same as Past Bio],
	[Days Since Past Bio Stop to Initiated Bio],
	[Current Bio Stopped Today],
	[Changes Today Form Status],
	[TreatmentStartedAtENRVis],
	[TreatmentStopped AtENRVis],
	[PSO Treatment initiated at ENR visit1],
	[PSO Treatment initiated at ENR visit1 - Other],
	[PSO Treatment initiated at ENR visit2],
	[PSO Treatment initiated at ENR visit2 - Other],
	[PSO Treatment initiated at ENR visit3],
	[PSO Treatment initiated at ENR visit3 - Other],
	[PSO Treatment stopped at ENR visit1],
	[PSO Treatment stopped at ENR visit1 - Other],
	[PSO Treatment stopped at ENR visit2],
	[PSO Treatment stopped at ENR visit2 - Other],
	[PSO Treatment stopped at ENR visit3],
	[PSO Treatment stopped at ENR visit3 - Other] 
)

SELECT 
       CAST(C2.SiteNumber AS INT) AS SiteID
	  ,CAST(C2.SubjectID AS bigint) AS SubjectID
	  ,CAST(C2.ProviderID AS int) AS ProviderID
	  ,CAST(C2.EnrollmentDate AS date) AS EnrollmentDate
      ,C2.[Age and Diagnosis Criteria]
      ,C2.[Biologic Criteria]
      ,C2.[Non-biologic Criteria]
	  ,C2.[Eligible Treatment]
	  ,C2.YearofBirth
	  ,C2.AtLeast18
	  ,C2.PsODiagnosis
	  ,C2.PsADiagnosis
	  ,C2.[Clinical Diagnosis Form Status]
	  ,C2.[Non-Bio Form Status]
	  ,C2.[CRF Name - Current Non-Biologic]
	  ,CAST(C2.[Start date - Current Non-Biologic] AS date) AS [Start date - Current Non-Biologic]
	  ,C2.[Current Non-Biologic]
	  ,C2.[Current Non-Biologic - Other]
	  ,C2.[Days Since Current Non-Biologic Start to Enrollment Date]
	  ,C2.[Current Non-Biologic - First Ever Use]
	  ,C2.[CRF Name - Past Non-Biologic]
	  ,CAST(C2.[Stop date - Past Non-Biologic] AS smalldatetime) AS [Stop date - Past Non-Biologic]
	  ,C2.[Days Since Past Non-Biologic Stop to Current Non-Biologic Start]
	  ,C2.[Days Since Past NonBio Stop to NonBio Initiated]
	  ,C2.[Past Non-Biologic]
	  ,C2.[Past Non-Biologic - Other]
	  ,C2.[Past Non-Biologic - First Ever Use] 
	  ,C2.[Past Non-Biologic Same as Current Non-Biologic]
	  ,C2.[Current NonBio Same as NonBio Start Today]
	  ,C2.[Bio Form Status]
	  ,C2.[CRF Name - Current Biologic]
	  ,CAST(C2.[Start date - Current Biologic] AS DATE) AS [Start date - Current Biologic]
	  ,C2.[Days Since Current Biologic Start to Enrollment]
	  ,C2.[Current Biologic]
	  ,C2.[Current Biologic - Other]
	  ,C2.[Current Biologic - First Ever Use]
	  ,C2.[CRF Name - Past Biologic]
	  ,CAST(C2.[Stop date - Past Biologic] AS smalldatetime) AS [Stop date - Past Biologic]
	  ,C2.[Past Biologic]
	  ,C2.[Past Biologic - Other]
	  ,C2.[Past Biologic - First Ever Use]
	  ,C2.[Current Bio Same as Past Bio]
	  ,C2.[Days Since Past Bio Stop to Current Bio Start]
	  ,C2.[Bio Prescribed Today Same as Past Bio]
	  ,C2.[Days Since Past Bio Stop to Initiated Bio]
	  ,C2.[Current Bio Stopped Today]
	  ,C2.[Changes Today Form Status]
	  ,C2.[TreatmentStartedAtENRVis]
	  ,C2.[TreatmentStoppedAtENRVis]
	  ,C2.[PSO treatment initiated at ENR visit1]
	  ,C2.[PSO treatment initiated at ENR visit1 - Other]
	  ,C2.[PSO treatment initiated at ENR visit2]
	  ,C2.[PSO treatment initiated at ENR visit2 - Other]
	  ,C2.[PSO treatment initiated at ENR visit3]
	  ,C2.[PSO treatment initiated at ENR visit3 - Other] 
	  ,C2.[PSO treatment stopped at ENR visit1]
	  ,C2.[PSO treatment stopped at ENR visit1 - Other]
	  ,C2.[PSO treatment stopped at ENR visit2]
	  ,C2.[PSO treatment stopped at ENR visit2 - Other]
	  ,C2.[PSO treatment stopped at ENR visit3]
	  ,C2.[PSO treatment stopped at ENR visit3 - Other]

FROM #C2 C2
WHERE SiteNumber not in (997, 998, 999)

 


 /*
 select top 10 * from [Reporting].[PSO500].[t_Elig] 
 select top 10 * from [Reporting].[PSO500].[t_VisitLog] 
*/


END


GO
