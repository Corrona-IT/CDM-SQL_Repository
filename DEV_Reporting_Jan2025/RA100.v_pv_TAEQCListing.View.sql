USE [Reporting]
GO
/****** Object:  View [RA100].[v_pv_TAEQCListing]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [RA100].[v_pv_TAEQCListing] AS

WITH TAES AS 

(
SELECT 
	AS1_CRF.[VisitId],
	AS1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN AS1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN AS1_CRF.[Form Object Caption] ELSE AS1_CRF.[Visit Object Caption] END AS [VisitName],
	AS1_CRF.[AS1_PHID] AS [ProviderID],
	'ANA' AS [EventType],
	[AS2_AETERMA] AS [Event],
	CASE WHEN RIGHT([AS2_AESTDAT],1)='/' AND LEN([AS2_AESTDAT])=8 THEN LEFT([AS2_AESTDAT],7) + '/01'
		 WHEN RIGHT([AS2_AESTDAT],2)='//' AND LEN([AS2_AESTDAT])=6 THEN LEFT([AS2_AESTDAT],4) + '/01/01'
	ELSE [AS2_AESTDAT] 
	END AS [EventOnsetDate],
	AS1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[AS12_ASOUT] AS [EventOutcome],
	[AS5B_AEHOSPYN] AS [Hospitalized],
	[AS5A_AECONFYN] AS [ConfirmedEvent],
	[AS5A_AESPEC1] AS [IfNoEvent],
	AS1_CRF.[Form Object Status] AS [Page1CRFStatus],
	AS2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN AS1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(AS1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), AS1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	AS1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	AS2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[AS4_BTRGM] AS [BiologicAtEvent],
	[AS4_BTRGMOTH] AS [BiologicAtEventOther],
	[AS5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN AS1_CRF.[AS5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	AS1_CRF.[AS1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([AS5B_AESPEC3], '') <> '' THEN [AS5B_AENOSRC] + ' - ' + [AS5B_AESPEC3] 
		 WHEN ISNULL([AS5B_AESPEC2], '') <> '' THEN [AS5B_AENOSRC] + ' - ' + [AS5B_AESPEC2] ELSE [AS5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[AS1] AS1_CRF ON AS1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[AS2] AS2_CRF ON AS2_CRF.[VisitId] = AS1_CRF.[VisitId] AND AS2_CRF.[Form Object InstanceNo] = AS1_CRF.[Form Object InstanceNo]

UNION

SELECT
	CAN1_CRF.[VisitId],
	CAN1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN CAN1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN CAN1_CRF.[Form Object Caption] ELSE CAN1_CRF.[Visit Object Caption] END AS [VisitName],
	CAN1_CRF.[CAN1_PHID] AS [ProviderID],
	'CA' AS [EventType],
	[CAN2_AETERMC] AS [Event],
	CASE WHEN RIGHT([CAN2_AESTDAT],1)='/' AND LEN([CAN2_AESTDAT])=8 THEN LEFT([CAN2_AESTDAT],7) + '/01'
		 WHEN RIGHT([CAN2_AESTDAT],2)='//' AND LEN([CAN2_AESTDAT])=6 THEN LEFT([CAN2_AESTDAT],4) + '/01/01'
	ELSE [CAN2_AESTDAT] 
	END AS [EventOnsetDate],
	CAN1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[CAN12_CANOUT] AS [EventOutcome],
	[CAN5B_AEHOSPYN] AS [Hospitalized],
	[CAN5A_AECONFYN] AS [ConfirmedEvent],
	[CAN5A_AESPEC1] AS [IfNoEvent],
	CAN1_CRF.[Form Object Status] AS [Page1CRFStatus],
	CAN2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN CAN1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(CAN1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), CAN1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	CAN1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	CAN2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[CAN4_BTRGM] AS [BiologicAtEvent],
	[CAN4_BTRGMOTH] AS [BiologicAtEventOther],
	[CAN5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN CAN1_CRF.[CAN5B_AEDOC] LIKE '%#PDF#%' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	CAN1_CRF.[CAN1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([CAN5B_AESPEC3], '') <> '' THEN [CAN5B_AENOSRC] + ' - ' + [CAN5B_AESPEC3] 
		 WHEN ISNULL([CAN5B_AESPEC2], '') <> '' THEN [CAN5B_AENOSRC] + ' - ' + [CAN5B_AESPEC2] ELSE [CAN5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.SiteId
	INNER JOIN [OMNICOMM_RA100].[dbo].[CAN1] CAN1_CRF ON CAN1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[CAN2] CAN2_CRF ON CAN2_CRF.[VisitId] = CAN1_CRF.[VisitId] AND CAN2_CRF.[Form Object InstanceNo] = CAN1_CRF.[Form Object InstanceNo]

UNION

SELECT
	CV1_CRF.[VisitId],
	CV1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN CV1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN CV1_CRF.[Form Object Caption] ELSE CV1_CRF.[Visit Object Caption] END AS [VisitName],
	CV1_CRF.[CV1_PHID] AS [ProviderID],
	'CV' AS [EventType],
	[CV2_AETERMCV] AS [Event],
	CASE WHEN RIGHT([CV2_AESTDAT],1)='/' AND LEN([CV2_AESTDAT])=8 THEN LEFT([CV2_AESTDAT],7) + '/01'
		 WHEN RIGHT([CV2_AESTDAT],2)='//' AND LEN([CV2_AESTDAT])=6 THEN LEFT([CV2_AESTDAT],4) + '/01/01'
	ELSE [CV2_AESTDAT] 
	END AS [EventOnsetDate],
	CV1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[CV9_CV901] AS [EventOutcome],
	[CV5B_AEHOSPYN] AS [Hospitalized],
	[CV5A_AECONFYN] AS [ConfirmedEvent],
	[CV5A_AESPEC1] AS [IfNoEvent],
	CV1_CRF.[Form Object Status] AS [Page1CRFStatus],
	CV2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN CV1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(CV1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), CV1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	CV1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	CV2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[CV4_BTRGM] AS [BiologicAtEvent],
	[CV4_BTRGMOTH] AS [BiologicAtEventOther],
	[CV5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN CV1_CRF.[CV5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	CV1_CRF.[CV1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([CV5B_AESPEC3], '') <> '' THEN [CV5B_AENOSRC] + ' - ' + [CV5B_AESPEC3] 
		 WHEN ISNULL([CV5B_AESPEC2], '') <> '' THEN [CV5B_AENOSRC] + ' - ' + [CV5B_AESPEC2] ELSE [CV5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[CV1] CV1_CRF ON CV1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[CV2] CV2_CRF ON CV2_CRF.[VisitId] = CV1_CRF.[VisitId] AND CV2_CRF.[Form Object InstanceNo] = CV1_CRF.[Form Object InstanceNo]

UNION

SELECT
	GI1_CRF.[VisitId],
	GI1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN GI1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN GI1_CRF.[Form Object Caption] ELSE GI1_CRF.[Visit Object Caption] END AS [VisitName],
	GI1_CRF.[GI1_PHID] AS [ProviderID],
	'GI' AS [EventType],
	[GI2_AETERMGI] AS [Event],
	CASE WHEN RIGHT([GI2_AESTDAT],1)='/' AND LEN([GI2_AESTDAT])=8 THEN LEFT([GI2_AESTDAT],7) + '/01'
		 WHEN RIGHT([GI2_AESTDAT],2)='//' AND LEN([GI2_AESTDAT])=6 THEN LEFT([GI2_AESTDAT],4) + '/01/01'
	ELSE [GI2_AESTDAT] 
	END AS [EventOnsetDate],
	GI1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[GI10_GI10A] AS [EventOutcome],
	[GI5B_AEHOSPYN] AS [Hospitalized],
	[GI5A_AECONFYN] AS [ConfirmedEvent],
	[GI5A_AESPEC1] AS [IfNoEvent],
	GI1_CRF.[Form Object Status] AS [Page1CRFStatus],
	GI2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN GI1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(GI1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), GI1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	GI1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	GI2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[GI4_BTRGM] AS [BiologicAtEvent],
	[GI4_BTRGMOTH] AS [BiologicAtEventOther],
	[GI5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN GI1_CRF.[GI5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	GI1_CRF.[GI1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([GI5B_AESPEC3], '') <> '' THEN [GI5B_AENOSRC] + ' - ' + [GI5B_AESPEC3] 
		 WHEN ISNULL([GI5B_AESPEC2], '') <> '' THEN [GI5B_AENOSRC] + ' - ' + [GI5B_AESPEC2] ELSE [GI5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[GI1] GI1_CRF ON GI1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[GI2] GI2_CRF ON GI2_CRF.[VisitId] = GI1_CRF.[VisitId] AND GI2_CRF.[Form Object InstanceNo] = GI1_CRF.[Form Object InstanceNo]

UNION

SELECT
	HE1_CRF.[VisitId],
	HE1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN HE1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN HE1_CRF.[Form Object Caption] ELSE HE1_CRF.[Visit Object Caption] END AS [VisitName],
	HE1_CRF.[HE1_PHID] AS [ProviderID],
	'HEP' AS [EventType],
	[HE2_AETERMH] AS [Event],
	CASE WHEN RIGHT([HE2_AESTDAT],1)='/' AND LEN([HE2_AESTDAT])=8 THEN LEFT([HE2_AESTDAT],7) + '/01'
		 WHEN RIGHT([HE2_AESTDAT],2)='//' AND LEN([HE2_AESTDAT])=6 THEN LEFT([HE2_AESTDAT],4) + '/01/01'
	ELSE [HE2_AESTDAT] 
	END AS [EventOnsetDate],
	HE1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[HE13_HE1301] AS [EventOutcome],
	[HE5B_AEHOSPYN] AS [Hospitalized],
	[HE5A_AECONFYN] AS [ConfirmedEvent],
	[HE5A_AESPEC1] AS [IfNoEvent],
	HE1_CRF.[Form Object Status] AS [Page1CRFStatus],
	HE2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN HE1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(HE1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), HE1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	HE1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	HE2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[HE4_BTRGM] AS [BiologicAtEvent],
	[HE4_BTRGMOTH] AS [BiologicAtEventOther],
	[HE5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN HE1_CRF.[HE5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	HE1_CRF.[HE1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([HE5B_AESPEC3], '') <> '' THEN [HE5B_AENOSRC] + ' - ' + [HE5B_AESPEC3] 
		 WHEN ISNULL([HE5B_AESPEC2], '') <> '' THEN [HE5B_AENOSRC] + ' - ' + [HE5B_AESPEC2] ELSE [HE5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[HE1] HE1_CRF ON HE1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[HE2] HE2_CRF ON HE2_CRF.[VisitId] = HE1_CRF.[VisitId] AND HE2_CRF.[Form Object InstanceNo] = HE1_CRF.[Form Object InstanceNo]

UNION

SELECT
	INF1_CRF.[VisitId],
	INF1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN INF1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN INF1_CRF.[Form Object Caption] ELSE INF1_CRF.[Visit Object Caption] END AS [VisitName],
	INF1_CRF.[INF1_PHID] AS [ProviderID],
	'INF' AS [EventType],
	[INF2_AETERMI] AS [Event],
	CASE WHEN RIGHT([INF2_AESTDAT],1)='/' AND LEN([INF2_AESTDAT])=8 THEN LEFT([INF2_AESTDAT],7) + '/01'
		 WHEN RIGHT([INF2_AESTDAT],2)='//' AND LEN([INF2_AESTDAT])=6 THEN LEFT([INF2_AESTDAT],4) + '/01/01'
	ELSE [INF2_AESTDAT] 
	END AS [EventOnsetDate],
	INF1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[INF9_INF9A] AS [EventOutcome],
	[INF5B_AEHOSPYN] AS [Hospitalized],
	[INF5A_AECONFYN] AS [ConfirmedEvent],
	[INF5A_AESPEC1] AS [IfNoEvent],
	INF1_CRF.[Form Object Status] AS [Page1CRFStatus],
	INF2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN INF1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(INF1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), INF1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	INF1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	INF2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[INF4_BTRGM] AS [BiologicAtEvent],
	[INF4_BTRGMOTH] AS [BiologicAtEventOther],
	[INF5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN INF1_CRF.[INF5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	INF1_CRF.[INF1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([INF5B_AESPEC3], '') <> '' THEN [INF5B_AENOSRC] + ' - ' + [INF5B_AESPEC3] 
		 WHEN ISNULL([INF5B_AESPEC2], '') <> '' THEN [INF5B_AENOSRC] + ' - ' + [INF5B_AESPEC2] ELSE [INF5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[INF1] INF1_CRF ON INF1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[INF2] INF2_CRF ON INF2_CRF.[VisitId] = INF1_CRF.[VisitId] AND INF2_CRF.[Form Object InstanceNo] = INF1_CRF.[Form Object InstanceNo]

UNION

SELECT
	NE1_CRF.[VisitId],
	NE1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN NE1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN NE1_CRF.[Form Object Caption] ELSE NE1_CRF.[Visit Object Caption] END AS [VisitName],
	NE1_CRF.[NE1_PHID] AS [ProviderID],
	'NE' AS [EventType],
	[NE2_AETERMN] AS [Event],
	CASE WHEN RIGHT([NE2_AESTDAT],1)='/' AND LEN([NE2_AESTDAT])=8 THEN LEFT([NE2_AESTDAT],7) + '/01'
		 WHEN RIGHT([NE2_AESTDAT],2)='//' AND LEN([NE2_AESTDAT])=6 THEN LEFT([NE2_AESTDAT],4) + '/01/01'
	ELSE [NE2_AESTDAT] 
	END AS [EventOnsetDate],
	NE1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[NE11_NE11A] AS [EventOutcome],
	[NE5B_AEHOSPYN] AS [Hospitalized],
	[NE5A_AECONFYN] AS [ConfirmedEvent],
	[NE5A_AESPEC1] AS [IfNoEvent],
	NE1_CRF.[Form Object Status] AS [Page1CRFStatus],
	NE2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN NE1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(NE1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), NE1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	NE1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	NE2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[NE4_BTRGM] AS [BiologicAtEvent],
	[NE4_BTRGMOTH] AS [BiologicAtEventOther],
	[NE5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN NE1_CRF.[NE5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	NE1_CRF.[NE1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([NE5B_AESPEC3], '') <> '' THEN [NE5B_AENOSRC] + ' - ' + [NE5B_AESPEC3] 
		 WHEN ISNULL([NE5B_AESPEC2], '') <> '' THEN [NE5B_AENOSRC] + ' - ' + [NE5B_AESPEC2] ELSE [NE5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[NE1] NE1_CRF ON NE1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[NE2] NE2_CRF ON NE2_CRF.[VisitId] = NE1_CRF.[VisitId] AND NE2_CRF.[Form Object InstanceNo] = NE1_CRF.[Form Object InstanceNo]

UNION

SELECT
	SB1_CRF.[VisitId],
	SB1_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN SB1_CRF.[Visit Object Caption] LIKE '%TAE%' THEN SB1_CRF.[Form Object Caption] ELSE SB1_CRF.[Visit Object Caption] END AS [VisitName],
	SB1_CRF.[SB1_PHID] AS [ProviderID],
	'SSB' AS [EventType],
	[SB2_AETERMS] AS [Event],
	CASE WHEN RIGHT([SB2_AESTDAT],1)='/' AND LEN([SB2_AESTDAT])=8 THEN LEFT([SB2_AESTDAT],7) + '/01'
		 WHEN RIGHT([SB2_AESTDAT],2)='//' AND LEN([SB2_AESTDAT])=6 THEN LEFT([SB2_AESTDAT],4) + '/01/01'
	ELSE [SB2_AESTDAT] 
	END AS [EventOnsetDate],
	SB1_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[SB14_SB14A] AS [EventOutcome],
	[SB5B_AEHOSPYN] AS [Hospitalized],
	[SB5A_AECONFYN] AS [ConfirmedEvenet?],
	[SB5A_AESPEC1] AS [IfNoEvent],
	SB1_CRF.[Form Object Status] AS [Page1CRFStatus],
	SB2_CRF.[Form Object Status] AS [Page2CRFStatus],
	CASE WHEN SB1_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(SB1_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), SB1_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	SB1_CRF.[Form Object LastChange] AS [Page1LastModDate],
	SB2_CRF.[Form Object LastChange] AS [Page2LastModDate],
	[SB4_BTRGM] AS [BiologicAtEvent],
	[SB4_BTRGMOTH] AS [BiologicAtEventOther],
	[SB5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN SB1_CRF.[SB5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	SB1_CRF.[SB1_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([SB5B_AESPEC3], '') <> '' THEN [SB5B_AENOSRC] + ' - ' + [SB5B_AESPEC3] 
		 WHEN ISNULL([SB5B_AESPEC2], '') <> '' THEN [SB5B_AENOSRC] + ' - ' + [SB5B_AESPEC2] ELSE [SB5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[SB1] SB1_CRF ON SB1_CRF.[PatientId] = PAT.[PatientId]
	LEFT JOIN [OMNICOMM_RA100].[dbo].[SB2] SB2_CRF ON SB2_CRF.[VisitId] = SB1_CRF.[VisitId] AND SB2_CRF.[Form Object InstanceNo] = SB1_CRF.[Form Object InstanceNo]

UNION

SELECT
	GEN_CRF.[VisitId],
	GEN_CRF.[FormId],
	SIT.[Site Information_Site Number] AS [SiteID],
	PAT.[Patient Information_Patient Number] AS [SubjectID],
	CASE WHEN GEN_CRF.[Visit Object Caption] LIKE '%TAE%' THEN GEN_CRF.[Form Object Caption] ELSE GEN_CRF.[Visit Object Caption] END AS [VisitName],
	GEN_CRF.[GEN1B_PHID] AS [ProviderID],
	'GEN' AS [EventType],
	[GEN2_AETERMG] AS [Event],
	CASE WHEN RIGHT([GEN2_AESTDAT],1)='/' AND LEN([GEN2_AESTDAT])=8 THEN LEFT([GEN2_AESTDAT],7) + '/01'
		 WHEN RIGHT([GEN2_AESTDAT],2)='//' AND LEN([GEN2_AESTDAT])=6 THEN LEFT([GEN2_AESTDAT],4) + '/01/01'
	ELSE [GEN2_AESTDAT] 
	END AS [EventOnsetDate],
	GEN_CRF.[Visit Object VisitDate] AS [FollowupVisitDate],
	[GEN6_GEN601] AS [EventOutcome],
	[GEN5B_AEHOSPYN] AS [Hospitalized],
	[GEN5A_AECONFYN] AS [ConfirmedEvent],
	[GEN5A_AESPEC1] AS [IfNoEvent],
	GEN_CRF.[Form Object Status] AS [Page1CRFStatus],
	'' AS [Page2CRFStatus],
	CASE WHEN GEN_CRF.[TAEIS_TAEATTST] > 0 THEN 'Yes' ELSE 'No' END AS [TAEISAttest],
	CASE WHEN ISNULL(GEN_CRF.[TAEIS_TAEISDAT], '') <> '' THEN CONVERT(VARCHAR(11), GEN_CRF.[TAEIS_TAEISDAT], 101) ELSE '' END AS [TAEISAttestDate],
	GEN_CRF.[Form Object LastChange] AS [Page1LastModDate],
	'' AS [Page2LastModDate],
	[GEN4_BTRGM] AS [BiologicAtEvent],
	[GEN4_BTRGMOTH] AS [BiologicAtEventOther],
	[GEN5B_AESRCDOC] AS [SourceDocuments],
	CASE WHEN [GEN5B_AEDOC] LIKE '%#PDF%#' THEN 'NO' ELSE 'YES' END AS [FileAttached],
	GEN_CRF.[GEN1B_ADMUSE] AS [AcknowledgementofReceipt],
	CASE WHEN ISNULL([GEN5B_AESPEC3], '') <> '' THEN [GEN5B_AENOSRC] + ' - ' + [GEN5B_AESPEC3] 
		 WHEN ISNULL([GEN5B_AESPEC2], '') <> '' THEN [GEN5B_AENOSRC] + ' - ' + [GEN5B_AESPEC2] ELSE [GEN5B_AENOSRC] END AS [ReasonNoSource]
FROM [OMNICOMM_RA100].[dbo].[SITE] SIT 
	INNER JOIN [OMNICOMM_RA100].[dbo].[PAT] PAT ON PAT.SiteId = SIT.[SiteId]
	INNER JOIN [OMNICOMM_RA100].[dbo].[GEN] GEN_CRF ON GEN_CRF.[PatientId] = PAT.[PatientId]
	)


SELECT [VisitId]
      ,[FormId]
      ,CAST([SiteID] AS INT) AS [SiteID]
      ,[SubjectID]
      ,[VisitName]
      ,[ProviderID]
      ,[EventType]
      ,[Event]
	  ,CASE WHEN ISNULL([EventOnsetDate],'') = '' THEN NULL 
	        ELSE CAST([EventOnsetDate] AS DATE) 
	   END AS [EventOnsetDate]
      ,CASE WHEN ISNULL([FollowUpVisitDate],'') = '' THEN NULL 
	        ELSE CAST([FollowupVisitDate] AS DATE) 
	   END AS [FollowupVisitDate]
      ,[EventOutcome]
      ,[Hospitalized]
      ,[ConfirmedEvent]
      ,[IfNoEvent]
      ,[Page1CRFStatus]
      ,[Page2CRFStatus]
      ,[TAEISAttest]
      ,[TAEISAttestDate]
      ,CAST([Page1LastModDate] AS DATE) AS [Page1LastModDate]
      ,CAST([Page2LastModDate] AS DATE) AS [Page2LastModDate]
      ,[BiologicAtEvent]
      ,[BiologicAtEventOther]
      ,[SourceDocuments]
      ,[FileAttached]
      ,[AcknowledgementofReceipt]
      ,[ReasonNoSource]
  FROM TAES



GO
