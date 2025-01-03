USE [Reporting]
GO
/****** Object:  StoredProcedure [BIO750].[usp_op_PatientVerification]    Script Date: 12/5/2024 12:48:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ==========================================================================================================
-- Author:		Kaye Mowrey
-- Create date: 25-Apr-2023
-- Description:	BIO-750 Patient Verification verifies eligibility criteria for the Bio Repository team
-- ==========================================================================================================


CREATE PROCEDURE [BIO750].[usp_op_PatientVerification] AS



BEGIN

  SET NOCOUNT ON;
  

/*
CREATE TABLE [BIO750].[t_op_PatientVerification](
	[RowNum] [int] NULL,
	[SiteID] [int] NOT NULL,
	[SubjectID] [nvarchar] (20) NOT NULL,
	[EDCSiteStatus] [nvarchar](100) NULL,
	[SFSiteStatus] [nvarchar] (150) NULL,
	[eventDefinitionId] [bigint] NULL,
	[VisitType] [nvarchar](30) NULL,
	[eventOccurrence] [int] NULL,
	[LastVisitDate] [date] NULL,
	[birthYear] [int] NULL,
	[gender] [nvarchar](20) NULL,
	[ProviderID] [int] NULL,
	[DateStarted] [nvarchar](50) NULL,
	[DrugStatus] [nvarchar](100) NULL,
	[StartCurrEligible] [nvarchar](200) NULL,
	[AddlStartCurrEligible] [nvarchar](800) NULL,
	[PastEligible] [nvarchar](800) NULL,
	[CurrPastOther][nvarchar](800) NULL 

) ON [PRIMARY]
GO
*/



/**Get last visit and demographics for all active patients, RowNum 1 will be last visit, Include Relapse Evaluations**/

IF OBJECT_ID('tempdb.dbo.#LastVisit') IS NOT NULL BEGIN DROP TABLE #LastVisit END;

SELECT SiteID,
       SubjectID,
	   EDCSiteStatus,
	   SFSiteStatus,
	   eventDefinitionId,
	   VisitType,
	   eventOccurrence,
	   VisitDate,
	   birthYear,
	   gender,
	   ProviderID,
	   ROW_NUMBER() OVER(PARTITION BY SubjectID ORDER BY SiteID, SubjectID, VisitDate DESC) AS VisRowNum
INTO #LastVisit
FROM
(
SELECT DISTINCT SiteID,
       SubjectID,
	   EDCSiteStatus,
	   SFSiteStatus,
	   eventDefinitionId,
	   VisitType,
	   eventOccurrence,
	   VisitDate,
	   birthYear,
	   gender,
	   ProviderID
FROM [NMO750].[t_op_VisitLog] V

UNION

SELECT R.SiteID,
       R.SubjectID,
	   V.EDCSiteStatus,
	   V.SFSiteStatus,
	   R.eventId AS eventDefinitionId,
	   R.EventType AS VisitType,
	   R.eventOccurrence,
	   R.EventOnsetDate AS VisitDate,
	   V.birthYear,
	   V.gender,
	   R.ProviderID

FROM [NMO750].[t_pv_TAEQCListing] R
LEFT JOIN [NMO750].[t_op_VisitLog] V ON V.SubjectID=R.SubjectID
WHERE EventType='Relapse'

) Visits 

--SELECT * FROM #LastVisit WHERE SubjectID='7046-0006' ORDER BY SiteID, SubjectID, VisRowNum


/**Get treatments at all visits**/

IF OBJECT_ID('tempdb.dbo.#Treatment') IS NOT NULL BEGIN DROP TABLE #Treatment END;

SELECT DISTINCT SiteID,
       SubjectID,
	   PatientId,
	   Treatment, 
	   OtherTreatment,
	   CASE WHEN ISNULL(Treatment, '') IN ('eculizumab (Soliris) IV infusion', 'inebilizumab-cdon (Uplizna) IV infusion', 'satralizumab-mwge (Enspryng) SC injection', 'ocrelizumab (Ocrevus) IV infusion', 'ofatumumab (Kesimpta) SC injection', 'ravulizumab-cwvz (Ultomiris) IV infusion', 'rituximab-arrx (Riabni) IV infusion', 'rituximab (Rituxan) IV infusion', 'rituximab-pvvr (Ruxience) IV infusion', 'rituximab-abbs (Truxima) IV infusion', 'rituximab other (specify) IV infusion', 'sarilumab (Kevzara) SC injection', 'tocilizumab (Actemra) IV infusion', 'azathioprine oral', 'mycophenolate mofetil (CellCept) oral', 'intravenous immunoglobulin (IVIg)') THEN 1
	   ELSE 0
	   END AS EligibleMedication,
	   DrugStatus,
	   DateStarted,
	   DateStopped
INTO #Treatment
FROM [Reporting].[NMO750].[t_op_AllDrugs] D1 

--SELECT * FROM #Treatment WHERE SubjectID='7046-0006' 

/**Get treatments**/

IF OBJECT_ID('tempdb.dbo.#Medications') IS NOT NULL BEGIN DROP TABLE #Medications END;

SELECT ROW_NUMBER() OVER(PARTITION BY SubjectID ORDER BY SiteID, SubjectID, EligibleMedication DESC, VisRowNum, DRUGORDER) AS RowNum
      ,VisRowNum
      ,SiteID
	  ,SubjectID
	  ,EDCSiteStatus
	  ,SFSiteStatus
	  ,eventDefinitionId
	  ,VisitType
	  ,eventOccurrence
	  ,VisitDate
	  ,birthYear
	  ,gender
	  ,ProviderID
	  ,DateStarted
	  ,Treatment
	  ,OtherTreatment
	  ,EligibleMedication
	  ,DRUGORDER
	  ,DrugStatus
INTO #Medications
FROM 
(
SELECT DISTINCT LV.VisRowNum,
       LV.SiteID,
       LV.SubjectID,
	   LV.EDCSiteStatus,
	   LV.SFSiteStatus,
	   LV.eventDefinitionId,
	   LV.VisitType,
	   LV.eventOccurrence,
	   LV.VisitDate,
	   LV.birthYear,
	   LV.gender,
	   LV.ProviderID,
	   T.DateStarted,
	   T.DateStopped,
	   Treatment,
	   OtherTreatment,
	   EligibleMedication,
	   CASE WHEN T.EligibleMedication=1 AND T.DrugStatus IN ('Drug started', 'New prescription (initiation unconfirmed)') THEN 10
	   WHEN T.EligibleMedication=1 AND T.DrugStatus='Current use' THEN 20
	   WHEN T.EligibleMedication=1 AND T.DrugStatus IN ('Prescription was never administered') THEN 30
	   WHEN T.EligibleMedication=0 AND T.DrugStatus IN ('Drug started', 'New prescription (initiation unconfirmed)') THEN 35 
	   WHEN T.EligibleMedication=0 AND T.DrugStatus='Current use' THEN 40
	   WHEN T.EligibleMedication=1 AND T.DrugStatus='Past use/stopped' AND ISNULL(T.DateStopped, '')<=ISNULL(LV.VisitDate,'') THEN 50
	   WHEN T.EligibleMedication=0 AND T.DrugStatus='Past use/stopped' AND ISNULL(T.DateStopped, '')<=ISNULL(LV.VisitDate,'') THEN 60
	   WHEN T.EligibleMedication=1 AND T.DrugStatus IN ('Past use') THEN 70
	   ELSE 99
	   END AS DRUGORDER,
	   DrugStatus

FROM #LastVisit LV
LEFT JOIN #Treatment T ON T.SubjectID=LV.SubjectID 
AND (ISNULL(T.DateStarted, '')<=LV.VisitDate OR ISNULL(T.DateStarted, '')='')

) A

--SELECT DISTINCT * FROM #Medications WHERE SubjectID='7046-0006'  ORDER BY SiteID, SubjectID, RowNum, VisitDate DESC


TRUNCATE TABLE [Reporting].[BIO750].[t_op_PatientVerification]

INSERT INTO [Reporting].[BIO750].[t_op_PatientVerification]
(
RowNum,
SiteID,
SubjectID,
EDCSiteStatus,
SFSiteStatus,
eventDefinitionId,
VisitType,
eventOccurrence,
LastVisitDate,
birthYear,
gender,
ProviderID,
DateStarted,
DrugStatus,
StartCurrEligible,
AddlStartCurrEligible,
PastEligible,
CurrPastOther
)


SELECT DISTINCT RowNum,
       SiteID,
	   SubjectID,
	   EDCSiteStatus,
	   SFSiteStatus,
	   eventDefinitionId,
	   VisitType,
	   eventOccurrence,
	   VisitDate AS LastVisitDate,
	   birthYear,
	   gender,
	   ProviderID,
	   DateStarted,
	   DrugStatus,
	   Treatment AS StartCurrEligible,

	   STUFF((
        SELECT DISTINCT ', '+ Treatment
        FROM #Medications T
		WHERE T.SubjectID=M.SubjectID
		AND UPPER(Treatment) NOT LIKE '%OTHER:%'
		AND T.DrugStatus IN ('Drug started', 'Current use', 'New prescription (initiation unconfirmed)')
		AND T.RowNum<>1
		AND T.EligibleMedication=1
		AND T.Treatment<>(SELECT Treatment FROM #Medications T2 WHERE T2.SubjectID=T.SubjectID AND T2.RowNum=1)
        FOR XML PATH('')
        )
        ,1,1,'') AS AddlStartCurrEligible,

	  STUFF((
        SELECT DISTINCT ', '+ Treatment
        FROM #Medications T
		WHERE T.SubjectID=M.SubjectID
		AND UPPER(Treatment) NOT LIKE '%OTHER%'
		AND DrugStatus IN ('Past use', 'Past use/stopped')
		AND T.EligibleMedication=1
        FOR XML PATH('')
        )
        ,1,1,'') AS PastEligible,

		STUFF((
        SELECT DISTINCT ', ' + Treatment
        FROM #Medications T
		WHERE T.SubjectID=M.SubjectID
		AND UPPER(Treatment) LIKE '%OTHER%'
		FOR XML PATH('')
        )
        ,1,1,'') AS CurrPastOther 

FROM #Medications M 
WHERE RowNum=1


--SELECT * FROM [Reporting].[BIO750].[t_op_PatientVerification] WHERE SubjectID = '7046-0006' ORDER BY SiteID, SubjectID


END	

GO
