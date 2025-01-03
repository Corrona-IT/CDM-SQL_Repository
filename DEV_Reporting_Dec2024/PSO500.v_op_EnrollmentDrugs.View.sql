USE [Reporting]
GO
/****** Object:  View [PSO500].[v_op_EnrollmentDrugs]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















/****PLEASE NOTE: This view feeds the PSO all drugs table*****/


CREATE VIEW [PSO500].[v_op_EnrollmentDrugs] AS	


SELECT VisitID,
	SiteID,
	PatientId,
	SubjectID,
	VisitType,
	VisitDate,
	REPLACE(crfName, '_Page 1', '') AS crfName,
	crfStatus,
	Treatment, 
	otherTreatment, 
 	TreatmentStatus,
	FirstDoseToday, 
	firstUse,
	startDate AS enteredStartDate,
	CASE WHEN UPPER(startDate)='UNK/UNK/UNK' OR startDate='//' THEN ''
	     WHEN UPPER(startDate)='UNK//' THEN ''
		 WHEN UPPER(startDate)='//UNK' THEN ''
	     WHEN startDate LIKE UPPER('%/UNK') AND startDate<>UPPER('UNK/UNK/UNK') THEN REPLACE(startDate, UPPER('/UNK'), '/01')
	     WHEN RIGHT(startDate, 2)='//' AND LEN(startDate)=6 THEN LEFT(startDate, 4) + '/01/01' 
	     WHEN RIGHT(startDate, 1)='/' AND LEN(startDate)=8 THEN LEFT(startDate, 7) + '/01'
		 WHEN UPPER(startDate) LIKE '%UNK%' THEN ''
	     ELSE startDate
	END AS startDate,

	StartReasons,
	changeDate,
	changeReasons,
	Dose,
	Frequency,
	CASE WHEN stopDate=UPPER('UNK/UNK/UNK') OR stopDate='//' THEN ''
	     WHEN stopDate LIKE UPPER('%/UNK') AND stopDate<>UPPER('UNK/UNK/UNK') THEN REPLACE(stopDate, UPPER('/UNK'), '/01')
	     WHEN RIGHT(stopDate, 2)='//' AND LEN(stopDate)=6 THEN LEFT(stopDate, 4) + '/01/01' 
	     WHEN RIGHT(stopDate, 1)='/' AND LEN(stopDate)=8 THEN LEFT(stopDate, 7) + '/01'
	     ELSE stopDate
	END AS stopDate,
	StopReasons

	FROM
	(
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		NB3_nbio_use2 AS Treatment, 
		NB3_nonbio_other_use2 AS otherTreatment, 
		NB3_nonbio_statushx2 AS TreatmentStatus,
		'' AS FirstDoseToday,	 
		NB3_nonbio_firstever2 AS firstUse, 
		NB3_nonbio_st_dt2 AS startDate,
		STUFF(COALESCE(', '+NULLIF(NB3_nonbio_rsnstart4__C, ''), '')
			+ COALESCE(', '+NULLIF(NB3_nonbio_rsnstart5__C, ''), '')
			+ COALESCE(', '+NULLIF(NB3_nonbio_rsnstart6__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NB3_nonbio_currdose2]='Other' THEN [NB3_nonbio_other_currdose2] + ' ' + [NB3_nonbio_unit2]
	    ELSE [NB3_nonbio_currdose2] + ' ' + [NB3_nonbio_unit2]
	    END AS Dose,
		CASE WHEN [NB3_nonbio_currfreq_weeks2]<>'' THEN [NB3_nonbio_currfreq_weeks2] + [NB3_nonbio_currfreq2]
		ELSE [NB3_nonbio_currfreq2]
		END AS Frequency,
		[NB3_nonbio_dt_stp2] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(NB3_nonbio_rsnstop4__C, ''), '')
			+ COALESCE(', '+NULLIF(NB3_nonbio_rsnstop5__C, ''), '')
			+ COALESCE(', '+NULLIF(NB3_nonbio_rsnstop6__C, ''), '')
			, 1, 1, '') AS StopReasons
		FROM OMNICOMM_PSO.inbound.NB

		UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		NB4_nbio_use3 AS Treatment, 
		NB4_nonbio_other_use3 AS otherTreatment,	
		NB.NB4_nonbio_statushx3 AS TreatmentStatus,
		'' AS FirstDoseToday,
		NB4_nonbio_firstever3 AS firstUse, 	
		NB4_nonbio_st_dt3 AS startDate,
		STUFF(COALESCE(', '+NULLIF(NB4_nonbio_rsnstart7__C, ''), '')
			+ COALESCE(', '+NULLIF(NB4_nonbio_rsnstart8__C, ''), '')
			+ COALESCE(', '+NULLIF(NB4_nonbio_rsnstart9__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NB4_nonbio_currdose3]='Other' THEN [NB4_nonbio_other_currdose3] + ' ' + [NB4_nonbio_unit3]
	    ELSE [NB4_nonbio_currdose3] + ' ' + [NB4_nonbio_unit3]
	    END AS Dose,
		CASE WHEN [NB4_nonbio_currfreq_weeks3]<>'' THEN [NB4_nonbio_currfreq_weeks3] + [NB4_nonbio_currfreq3]
		ELSE [NB4_nonbio_currfreq3]
		END AS Frequency,
		[NB4_nonbio_dt_stp3] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(NB4_nonbio_rsnstop7__C, ''), '')
			+ COALESCE(', '+NULLIF(NB4_nonbio_rsnstop8__C, ''), '')
			+ COALESCE(', '+NULLIF(NB4_nonbio_rsnstop9__C, ''), '')
			, 1, 1, '') AS StopReasons
		FROM OMNICOMM_PSO.inbound.NB

		UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		NB5_nbio_use4 AS Treatment, 
		NB5_nonbio_other_use4 AS otherTreatment,
		NB.NB5_nonbio_statushx4 AS TreatmentStatus,
		'' AS FirstDoseToday,
		NB5_nonbio_firstever4 AS firstUse,
		NB5_nonbio_st_dt4 AS startDate,
		STUFF(COALESCE(', '+NULLIF(NB5_nonbio_rsnstart10__C, ''), '')
			+ COALESCE(', '+NULLIF(NB5_nonbio_rsnstart11__C, ''), '')
			+ COALESCE(', '+NULLIF(NB5_nonbio_rsnstart12__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NB5_nonbio_currdose4]='Other' THEN [NB5_nonbio_other_currdose4] + ' ' + [NB5_nonbio_unit4]
	    ELSE [NB5_nonbio_currdose4] + ' ' + [NB5_nonbio_unit4]
	    END AS Dose,
		CASE WHEN [NB5_nonbio_currfreq_weeks4]<>'' THEN [NB5_nonbio_currfreq_weeks4] + [NB5_nonbio_currfreq4]
		ELSE [NB5_nonbio_currfreq4]
		END AS Frequency,
		[NB5_nonbio_dt_stp4] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(NB5_nonbio_rsnstop10__C, ''), '')
			+ COALESCE(', '+NULLIF(NB5_nonbio_rsnstop11__C, ''), '')
			+ COALESCE(', '+NULLIF(NB5_nonbio_rsnstop12__C, ''), '')
			, 1, 1, '') AS StopReasons
		FROM OMNICOMM_PSO.inbound.NB

		UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		NB7_nbio_use5 AS Treatment, 
		NB7_nonbio_other_use5 AS otherTreatment,
		NB7_nonbio_statushx5 AS TreatmentStatus,
		'' AS FirstDoseToday,
		NB7_nonbio_firstever5 AS firstUse,
		NB7_nonbio_st_dt5 AS startDate,
		STUFF(COALESCE(', '+NULLIF(NB7_nonbio_rsnstart13__C, ''), '')
			+ COALESCE(', '+NULLIF(NB7_nonbio_rsnstart14__C, ''), '')
			+ COALESCE(', '+NULLIF(NB7_nonbio_rsnstart15__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NB7_nonbio_currdose5]='Other' THEN [NB7_nonbio_other_currdose5] + ' ' + [NB7_nonbio_unit5]
	    ELSE [NB7_nonbio_currdose5] + ' ' + [NB7_nonbio_unit5]
	    END AS Dose,
		CASE WHEN [NB7_nonbio_currfreq_weeks5]<>'' THEN [NB7_nonbio_currfreq_weeks5] + [NB7_nonbio_currfreq5]
		ELSE [NB7_nonbio_currfreq5]
		END AS Frequency, 
		[NB7_nonbio_dt_stp5] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(NB7_nonbio_rsnstop13__C, ''), '')
			+ COALESCE(', '+NULLIF(NB7_nonbio_rsnstop14__C, ''), '')
			+ COALESCE(', '+NULLIF(NB7_nonbio_rsnstop15__C, ''), '')
			, 1, 1, '') AS StopReasons

		FROM OMNICOMM_PSO.inbound.NB

		UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		NB2_nbio_use AS Treatment, 
		NB2_nonbio_other_use AS otherTreatment,
		NB2_nonbio_statushx AS TreatmentStatus,
		'' AS FirstDoseToday,
		NB2_nonbio_firstever AS firstUse, 
		NB2_nonbio_st_dt AS startDate,
		STUFF(COALESCE(', '+NULLIF(NB2_nonbio_rsnstart1__C, ''), '')
			+ COALESCE(', '+NULLIF(NB2_nonbio_rsnstart2__C, ''), '')
			+ COALESCE(', '+NULLIF(NB2_nonbio_rsnstart3__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN [NB2_nonbio_currdose]='Other' THEN [NB2_nonbio_other_currdose] + ' ' + [NB2_nonbio_unit]
	    ELSE [NB2_nonbio_currdose] + ' ' + [NB2_nonbio_unit]
	    END AS Dose,
		CASE WHEN [NB2_nonbio_currfreq_weeks]<>'' THEN [NB2_nonbio_currfreq_weeks] + [NB2_nonbio_currfreq]
		ELSE [NB2_nonbio_currfreq]
		END AS Frequency,
		[NB2_nonbio_dt_stp] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(NB2_nonbio_rsnstop1__C, ''), '')
			+ COALESCE(', '+NULLIF(NB2_nonbio_rsnstop2__C, ''), '')
			+ COALESCE(', '+NULLIF(NB2_nonbio_rsnstop3__C, ''), '')
			, 1, 1, '') AS StopReasons

		FROM OMNICOMM_PSO.inbound.NB_NB2

		UNION

		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName,
		[Form Object Status] AS crfStatus,
		BIO2_bio_use AS Treatment, 
		CASE WHEN LEN(BIO2_bio_oth_use)=0 THEN BIO2_biosim_oth_name
		ELSE BIO2_bio_oth_use
		END AS otherTreatment, 
		BIO.BIO2_bio_statushx AS TreatmentStatus,
		'' AS FirstDoseToday,
		BIO2_bio_firstever AS firstUse, 
		BIO2_bio_st_dt AS startDate,
		STUFF(COALESCE(', '+NULLIF(BIO2_bio_rsnstart1__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO2_bio_rsnstart2__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO2_bio_rsnstart3__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
	    CASE WHEN BIO2_bio_currdose='Other' THEN BIO2_bio_oth_currdose + ' ' + BIO2_bio_unit
	    ELSE BIO2_bio_currdose + ' ' + BIO2_bio_unit
	    END AS Dose,
		CASE WHEN BIO2_bio_currfreqdays_weeks<>'' THEN 'q' + ' ' + BIO2_bio_currfreqdays_weeks + ' ' + SUBSTRING(BIO2_bio_currfreq, 3, LEN(BIO2_bio_currfreq)-2)
	    ELSE BIO2_bio_currfreq
	    END AS Frequency,
		[BIO2_bio_dt_stp] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(BIO2_bio_rsnstop1__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO2_bio_rsnstop2__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO2_bio_rsnstop3__C, ''), '')
			, 1, 1, '') AS StopReasons

		FROM OMNICOMM_PSO.inbound.[BIO]

		UNION
		
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		BIO3_bio_use2 AS Treatment, 
		CASE WHEN LEN(BIO3_bio_oth_use2)=0 THEN BIO3_biosim_oth_name2
		ELSE BIO3_bio_oth_use2
		END AS otherTreatment,
		BIO.BIO3_bio_statushx2 AS TreatmentStatus,
		'' AS FirstDoseToday,
		BIO3_bio_firstever2 AS firstUse, 
		BIO3_bio_st_dt2 AS startDate,
		STUFF(COALESCE(', '+NULLIF(BIO3_bio_rsnstart4__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO3_bio_rsnstart5__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO3_bio_rsnstart6__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN BIO3_bio_currdose2='Other' THEN BIO3_bio_oth_currdose2 + ' ' + BIO3_bio_unit2
	    ELSE BIO3_bio_currdose2 + ' ' + BIO3_bio_unit2
	    END AS Dose,
		CASE WHEN BIO3_bio_currfreqdays_weeks2 <>'' THEN 'q' + ' ' + BIO3_bio_currfreqdays_weeks2 + ' ' + SUBSTRING(BIO3_bio_currfreq2, 3, LEN(BIO3_bio_currfreq2)-2)
	    ELSE BIO3_bio_currfreq2
	    END AS Frequency,
		[BIO3_bio_dt_stp2] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(BIO3_bio_rsnstop4__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO3_bio_rsnstop5__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO3_bio_rsnstop6__C, ''), '')
			, 1, 1, '') AS StopReasons
			 
		FROM OMNICOMM_PSO.inbound.[BIO]

		UNION
		
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		BIO4_bio_use3 AS Treatment, 
		CASE WHEN LEN(BIO4_bio_oth_use3)=0 THEN BIO4_biosim_oth_name3
		ELSE BIO4_bio_oth_use3
		END AS otherTreatment,
		BIO4_bio_statushx3 AS TreatmentStatus,
		'' AS FirstDoseToday,
		BIO4_bio_firstever3 AS firstUse, 
		BIO4_bio_st_dt3 AS startDate,
		STUFF(COALESCE(', '+NULLIF(BIO4_bio_rsnstart7__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO4_bio_rsnstart8__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO4_bio_rsnstart9__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN BIO4_bio_currdose3='Other' THEN BIO4_bio_oth_currdose3 + ' ' + BIO4_bio_unit3
	    ELSE BIO4_bio_currdose3 + ' ' + BIO4_bio_unit3
	    END AS Dose,
		CASE WHEN BIO4_bio_currfreqdays_weeks3 <>'' THEN 'q' + ' ' + BIO4_bio_currfreqdays_weeks3 + ' ' + SUBSTRING(BIO4_bio_currfreq3, 3, LEN(BIO4_bio_currfreq3)-2)
	    ELSE BIO4_bio_currfreq3
	    END AS Frequency,
		[BIO4_bio_dt_stp3] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(BIO4_bio_rsnstop7__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO4_bio_rsnstop8__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO4_bio_rsnstop9__C, ''), '')
			, 1, 1, '') AS StopReasons

		FROM OMNICOMM_PSO.inbound.[BIO]

		UNION
		
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName,
		[Form Object Status] AS crfStatus,
		BIO5_bio_use4 AS Treatment, 
		CASE WHEN LEN(BIO5_bio_oth_use4)=0 THEN BIO5_biosim_oth_name4
		ELSE BIO5_bio_oth_use4
		END AS otherTreatment,		
		BIO5_bio_statushx4 AS TreatmentStatus,
		'' AS FirstDoseToday,
		BIO5_bio_firstever4 AS firstUse, 
		BIO5_bio_st_dt4 AS startDate,
		STUFF(COALESCE(', '+NULLIF(BIO5_bio_rsnstart10__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO5_bio_rsnstart11__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO5_bio_rsnstart12__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN BIO5_bio_currdose4='Other' THEN BIO5_bio_oth_currdose4 + ' ' + BIO5_bio_unit4
	    ELSE BIO5_bio_currdose4 + ' ' + BIO5_bio_unit4
	    END AS Dose,
		CASE WHEN BIO5_bio_currfreqdays_weeks4 <>'' THEN 'q' + ' ' + BIO5_bio_currfreqdays_weeks4 + ' ' + SUBSTRING(BIO5_bio_currfreq4, 3, LEN(BIO5_bio_currfreq4)-2)
	    ELSE BIO5_bio_currfreq4
	    END AS Frequency,
		[BIO5_bio_dt_stp4] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(BIO5_bio_rsnstop10__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO5_bio_rsnstop11__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO5_bio_rsnstop12__C, ''), '')
			, 1, 1, '') AS StopReasons

		FROM OMNICOMM_PSO.inbound.[BIO]

		UNION
		
		SELECT VisitID,
		[Site Object SiteNo] AS SiteID,
		PatientId,
		[Patient Object PatientNo] AS SubjectID,
		[Visit Object Description] AS VisitType,
		[Visit Object VisitDate] AS VisitDate,
		[Form Object Caption] AS crfName, 
		[Form Object Status] AS crfStatus,
		BIO6_bio_use5 AS Treatment, 
		CASE WHEN LEN(BIO6_bio_oth_use5)=0 THEN BIO6_biosim_oth_name5
		ELSE BIO6_bio_oth_use5
		END AS otherTreatment,		
		BIO6_bio_statushx5 AS TreatmentStatus,
		'' AS FirstDoseToday,
		BIO6_bio_firstever5 AS firstUse,
		BIO6_bio_st_dt5 AS startDate, 
		STUFF(COALESCE(', '+NULLIF(BIO6_bio_rsnstart13__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO6_bio_rsnstart14__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO6_bio_rsnstart15__C, ''), '')
			, 1, 1, '') AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		CASE WHEN BIO6_bio_currdose5='Other' THEN BIO6_bio_oth_currdose5 + ' ' + BIO6_bio_unit5
	    ELSE BIO6_bio_currdose5 + ' ' + BIO6_bio_unit5
	    END AS Dose,
		CASE WHEN BIO6_bio_currfreqdays_weeks5 <>'' THEN 'q' + ' ' + BIO6_bio_currfreqdays_weeks5 + ' ' + SUBSTRING(BIO6_bio_currfreq5, 3, LEN(BIO6_bio_currfreq5)-2)
	    ELSE BIO6_bio_currfreq5
	    END AS Frequency,
		[BIO6_bio_dt_stp5] AS stopDate,
		STUFF(COALESCE(', '+NULLIF(BIO6_bio_rsnstop13__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO6_bio_rsnstop14__C, ''), '')
			+ COALESCE(', '+NULLIF(BIO6_bio_rsnstop15__C, ''), '')
			, 1, 1, '') AS StopReasons
			 

		FROM OMNICOMM_PSO.inbound.[BIO]

		UNION

		SELECT NB.VisitID,
		NB.[Site Object SiteNo] AS SiteID,
		NB.PatientId,
		NB.[Patient Object PatientNo] AS SubjectID,
		NB.[Visit Object Description] AS VisitType,
		NB.[Visit Object VisitDate] AS VisitDate,
		NB.[Form Object Caption] AS crfName, 
		NB.[Form Object Status] AS crfStatus,
		'No Treatment' AS Treatment,
		'' AS otherTreatment,
		'' AS TreatmentStatus, 
	    '' AS FirstDoseToday,
		'' AS firstUse,
		'' AS startDate,
		'' AS StartReasons,
		'' AS changeDate,
		'' AS changeReasons,
		'' AS Dose,
		'' AS Frequency,
		'' AS stopDate,
		'' AS StopReasons

		FROM OMNICOMM_PSO.inbound.NB NB
		JOIN OMNICOMM_PSO.inbound.[BIO] BIO ON BIO.VisitID=NB.VisitID
		JOIN OMNICOMM_PSO.inbound.[CT] CT ON CT.VisitID=NB.VisitID
		WHERE (NB.[NB1_no_nonbio]=1 AND BIO.[BIO1_no_bio_sm]=1 AND CT.CT_bio_nonbio_Today<>'Yes')


	UNION

	SELECT VisitID
	  ,[Site Object SiteNo] AS SiteID
	  ,PatientId
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,'Changes Made Today' AS crfName
      ,[Form Object Status] AS crfStatus
      ,[CT2_bionb_name] AS Treatment
      ,CASE WHEN [CT2_bionb_name] LIKE 'Other%' AND [CT2_bionb_other_specify]<>'' THEN [CT2_bionb_other_specify]
            WHEN [CT2_bionb_name] LIKE 'Other%' AND [CT2_biosim_oth_name]<>'' THEN [CT2_biosim_oth_name]
			ELSE ''
			END AS otherTreatment
      ,[CT2_bionb_status] AS TreatmentStatus
      ,[CT2_rx_today_1stdose_rcvd] AS FirstDoseToday
	  ,'' AS firstUse
	  ,CASE WHEN [CT2_bionb_status] ='Prescribed Today' AND [CT2_rx_today_1stdose_rcvd]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS startDate

      ,CASE WHEN [CT2_bionb_status] ='Prescribed Today' THEN STUFF(COALESCE(', '+NULLIF([CT2_bionb_rsntoday1__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday2__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday3__C], ''), '')
			, 1, 1, '')
			ELSE ''
			END AS StartReasons

	   ,CASE WHEN [CT2_bionb_status] ='Changes Prescribed' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate

	   ,CASE WHEN [CT2_bionb_status] ='Changes Prescribed' THEN STUFF(COALESCE(', '+NULLIF([CT2_bionb_rsntoday1__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday2__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday3__C], ''), '')
			, 1, 1, '') 
			ELSE ''
			END AS changeReasons

      ,CASE WHEN [CT2_bionb_presdose] LIKE 'Other%' AND [CT2_bionb_other_presdose]<> '' THEN [CT2_bionb_other_presdose] + ' ' + [CT2_bionb_presdoseunits]
	   ELSE [CT2_bionb_presdose] + ' ' + [CT2_bionb_presdoseunits]
	   END AS Dose

      ,CASE WHEN [CT2_bionb_presfreq] LIKE 'q_%' AND [CT2_bionb_presfreqweeks]<>'' THEN [CT2_bionb_presfreqweeks] + ' ' + REPLACE([CT2_bionb_presfreq], 'q_', '')
	   ELSE [CT2_bionb_presfreq]
	   END AS Frequency

	   ,CASE WHEN [CT2_bionb_status] ='Stopped Today' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS stopDate

	   ,CASE WHEN [CT2_bionb_status] ='Stopped Today' THEN STUFF(COALESCE(', '+NULLIF([CT2_bionb_rsntoday1__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday2__C], ''), '')
			+ COALESCE(', '+NULLIF([CT2_bionb_rsntoday3__C], ''), '')
			, 1, 1, '') 
			ELSE ''
			END AS stopReasons
	  
  FROM [OMNICOMM_PSO].[inbound].[CT]
  WHERE [Site Object SiteNo] NOT IN (/*999, 998,*/ 997)
  AND CT_bio_nonbio_Today='Yes'
  AND [CT2_bionb_name] <>''
  

UNION

	SELECT VisitID
	  ,[Site Object SiteNo] AS SiteID
	  ,PatientId
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,'Changes Made Today' AS crfName
      ,[Form Object Status] AS crfStatus
      ,[CT3_bionb_name2] AS Treatment
      ,CASE WHEN [CT3_bionb_name2] LIKE 'Other%' AND [CT3_bionb_other_specify2]<>'' THEN [CT3_bionb_other_specify2]
            WHEN [CT3_bionb_name2] LIKE 'Other%' AND [CT3_biosim_oth_name2]<>'' THEN [CT3_biosim_oth_name2]
			ELSE ''
			END AS otherTreatment
      ,[CT3_bionb_status2] AS TreatmentStatus
      ,[CT3_rx_today_1stdose_rcvd2] AS FirstDoseToday
	  ,'' AS firstUse
	  ,CASE WHEN [CT3_bionb_status2] ='Prescribed Today' AND [CT3_rx_today_1stdose_rcvd2]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS startDate

      ,CASE WHEN [CT3_bionb_status2] ='Prescribed Today' THEN STUFF(COALESCE(', '+NULLIF([CT3_bionb_rsntoday4__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday5__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday6__C], ''), '')
			, 1, 1, '')
			ELSE ''
			END AS StartReasons

	   ,CASE WHEN [CT3_bionb_status2] ='Changes Prescribed' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate

	   ,CASE WHEN [CT3_bionb_status2] ='Changes Prescribed' THEN STUFF(COALESCE(', '+NULLIF([CT3_bionb_rsntoday4__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday5__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday6__C], ''), '')
			, 1, 1, '') 
			ELSE ''
			END AS changeReasons

       ,CASE WHEN [CT3_bionb_presdose2] LIKE 'Other%' AND [CT2_bionb_other_presdose]<> '' THEN [CT3_bionb_other_presdose2] + ' ' + [CT3_bionb_presdoseunits2]
	   ELSE [CT3_bionb_presdose2] + ' ' + [CT3_bionb_presdoseunits2]
	   END AS Dose

       ,CASE WHEN [CT3_bionb_presfreq2] LIKE 'q_%' AND [CT3_bionb_presfreqweeks2]<>'' THEN [CT3_bionb_presfreqweeks2] + ' ' + REPLACE([CT3_bionb_presfreq2], 'q_', '')
	   ELSE [CT3_bionb_presfreq2]
	   END AS Frequency

	   ,CASE WHEN [CT3_bionb_status2] ='Stopped Today' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS stopDate

	   ,CASE WHEN [CT3_bionb_status2] ='Stopped Today' THEN STUFF(COALESCE(', '+NULLIF([CT3_bionb_rsntoday4__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday5__C], ''), '')
			+ COALESCE(', '+NULLIF([CT3_bionb_rsntoday6__C], ''), '')
			, 1, 1, '') 
			ELSE ''
			END AS stopReasons
	  
  FROM [OMNICOMM_PSO].[inbound].[CT]
  WHERE [Site Object SiteNo] NOT IN (/*999, 998,*/ 997)
  AND CT_bio_nonbio_Today='Yes'
  AND [CT3_bionb_name2] <>''
 

UNION

SELECT VisitID
      ,[Site Object SiteNo] AS SiteID
	  ,PatientId
      ,[Patient Object PatientNo] AS SubjectID
	  ,[Visit Object Description] AS VisitType
      ,[Visit Object VisitDate] AS VisitDate
      ,'Changes Made Today' AS crfName
      ,[Form Object Status] AS crfStatus
      ,[CT4_bionb_name3] AS Treatment
      ,CASE WHEN [CT4_bionb_name3] LIKE 'Other%' AND [CT4_bionb_other_specify3]<>'' THEN [CT4_bionb_other_specify3]
            WHEN [CT4_bionb_name3] LIKE 'Other%' AND [CT4_biosim_oth_name3]<>'' THEN [CT4_biosim_oth_name3]
			ELSE ''
			END AS otherTreatment
      ,[CT4_bionb_status3] AS TreatmentStatus
      ,[CT4_rx_today_1stdose_rcvd3] AS FirstDoseToday
	  ,'' AS FirstUse

	  ,CASE WHEN [CT4_bionb_status3]='Prescribed Today' AND [CT4_rx_today_1stdose_rcvd3]='Yes' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS startDate

	  ,CASE WHEN [CT4_bionb_status3]='Prescribed Today' THEN STUFF(COALESCE(', '+NULLIF([CT4_bionb_rsntoday7__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday8__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday9__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS StartReasons

	  ,CASE WHEN [CT4_bionb_status3]='Changes Prescribed' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate

	  ,CASE WHEN [CT4_bionb_status3]='Changes Prescribed' THEN STUFF(COALESCE(', '+NULLIF([CT4_bionb_rsntoday7__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday8__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday9__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS changeReasons
			
      ,CASE WHEN [CT4_bionb_presdose3] LIKE 'Other%' AND [CT2_bionb_other_presdose]<> '' THEN [CT4_bionb_other_presdose3] + ' ' + [CT4_bionb_presdoseunits3]
	   ELSE [CT4_bionb_presdose3] + ' ' + [CT4_bionb_presdoseunits3]
	   END AS Dose

	  ,CASE WHEN [CT4_bionb_presfreq3] LIKE 'q_%' AND [CT4_bionb_presfreqweeks3]<>'' THEN [CT4_bionb_presfreqweeks3] + ' ' + REPLACE([CT4_bionb_presfreq3], 'q_', '')
	   ELSE [CT4_bionb_presfreq3]
	   END AS Frequency

	  ,CASE WHEN [CT4_bionb_status3]='Stopped Today' THEN [Visit Object VisitDate]
	   ELSE ''
	   END AS changeDate

	  ,CASE WHEN [CT4_bionb_status3]='Stopped Today' THEN STUFF(COALESCE(', '+NULLIF([CT4_bionb_rsntoday7__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday8__C], ''), '')
			+ COALESCE(', '+NULLIF([CT4_bionb_rsntoday9__C], ''), '')
			, 1, 1, '') 
		ELSE ''
		END AS changeReasons


  FROM [OMNICOMM_PSO].[inbound].[CT]
  WHERE [Site Object SiteNo] NOT IN (/*999, 998,*/ 997)
  AND CT_bio_nonbio_Today='Yes'
  AND [CT4_bionb_name3]<>''
			) AS Treatment 
			WHERE Treatment <> ''
			AND SiteID NOT IN (997/*, 998, 999*/)

--ORDER BY SiteID, SubjectID, VisitDate, Treatment, otherTreatment, TreatmentStatus

GO
