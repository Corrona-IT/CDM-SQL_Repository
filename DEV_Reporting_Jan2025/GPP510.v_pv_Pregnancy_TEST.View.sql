USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_Pregnancy_TEST]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [GPP510].[v_pv_Pregnancy_TEST] AS

WITH DRUGS AS
(
SELECT SITENUM,
		SUBNUM,
		SUBID,
		VID,
		PAGENAME,
		VISNAME,
		VISITSEQ,
		PAGESEQ,
		drug,
		drugoth,
		CAST(COALESCE(fstdat, pstdat) AS DATE) as startdate,
		CAST(COALESCE(fendat, pendat) AS DATE) as enddate

FROM
(
SELECT d.SITENUM,
	   d.SUBNUM,
	   d.SUBID,
	   d.vID,
	   d.PAGENAME,
	   d.VISNAME,
	   d.VISITSEQ,
	   d.PAGESEQ,
	   replace(d.DRUG_DEC, ' (specify)', '') AS drug,
	   d.DRUGOTH,
	   case WHEN D.PSTDAT LIKE 'UNK-%' THEN ''
	   when d.pstdat like '%-UNK%' THEN replace(d.PSTDAT, '-UNK', '-01') 
	   when D.PSTDAT LIKE 'UNK-%' THEN ''
	   else d.pstdat
	   end as pstdat,
	   case WHEN d.pendat LIKE 'UNK-%' THEN ''
	   when d.pendat like '%-UNK%' THEN replace(d.pendat, '-UNK', '-01') 
	   when d.pendat LIKE 'UNK-%' THEN ''
	   else d.pendat
	   end as pendat,
	   CAST(d.FSTDAT AS date) AS FSTDAT,
	   cast(d.FENDAT as date) AS FENDAT

FROM [ZELTA_GPP_TEST].[dbo].[DRUG] d
where pagename in ('Drug Log', 'Medication History')

) A
)


,PREGAUDIT AS
(
	 SELECT ROW_NUMBER() OVER (PARTITION BY SubAudit.vID, SubAudit.SITENUM, SubAudit.SUBID, SubAudit.PAGENAME ORDER BY SubAudit.SITENUM, SubAudit.SUBNUM, SubAudit.VisitSeq, SubAudit.DATALMDT DESC) AS ROWNUM
      ,SubAudit.[SITENUM]
      ,SubAudit.[SUBID]
	  ,SubAudit.[SUBNUM]
	  ,SubAudit.[VISNAME]
	  ,COALESCE(V.[VISDAT],V.[FLRVISDAT]) AS VisitDate
	  ,SubAudit.[VISITSEQ]
	  ,SubAudit.[PAGENAME]
	  ,SubAudit.[vID]
	  ,SubAudit.[COLNAME]
	  ,'Are you currently pregnant?' AS QTXT
	  ,SubAudit.[DATALMDT]
	  ,SubAudit.[DATALMBY]
	  ,CASE WHEN SubAudit.[DATAVAL]=0 THEN 'No'
	   WHEN SubAudit.[DATAVAL]=1 THEN 'Yes'
	   ELSE CAST(SubAudit.[DATAVAL] AS nvarchar)
	   END AS DATAVALUE

FROM [ZELTA_GPP_TEST].[dbo].[SUB_B_AFLD] SubAudit
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT] V ON V.vID=SubAudit.vID AND V.SUBID=SubAudit.SUBID
WHERE 1=1
AND [COLNAME]='PREGCURR'

UNION

 SELECT ROW_NUMBER() OVER (PARTITION BY SubAudit.vID, SubAudit.SITENUM, SubAudit.SUBID, SubAudit.PAGENAME ORDER BY SubAudit.SITENUM, SubAudit.SUBNUM, SubAudit.VisitSeq, SubAudit.DATALMDT DESC) AS ROWNUM
      ,SubAudit.[SITENUM]
      ,SubAudit.[SUBID]
	  ,SubAudit.[SUBNUM]
	  ,SubAudit.[VISNAME]
	  ,COALESCE(V.[VISDAT],V.[FLRVISDAT]) AS VisitDate
	  ,SubAudit.[VISITSEQ]
	  ,SubAudit.[PAGENAME]
	  ,SubAudit.[vID]
	  ,SubAudit.[COLNAME]
	  ,'Have you been pregnant since the last registry visit?' AS QTXT
	  ,SubAudit.[DATALMDT]
	  ,SubAudit.[DATALMBY]
	  ,CASE WHEN SubAudit.[DATAVAL]=0 THEN 'No'
	   WHEN SubAudit.[DATAVAL]=1 THEN 'Yes'
	   ELSE CAST(SubAudit.[DATAVAL] AS nvarchar)
	   END AS DATAVALUE

FROM [ZELTA_GPP_TEST].[dbo].[SUB_A_AFLD] SubAudit
LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT] V ON V.vID=SubAudit.vID AND V.SUBID=SubAudit.SUBID
WHERE 1=1
AND [COLNAME]='PREG_FU' 
)

--,PREGFORM AS
--(

--SELECT DISTINCT A.[SITENUM]
--      ,A.[SUBID]
--	  ,A.[SUBNUM]
--	  ,A.[VISNAME]
--	  ,COALESCE(V.[VISDAT],V.[FLRVISDAT]) AS VisitDate
--	  ,A.[VISITSEQ]
--	  ,A.[PAGENAME]
--	  ,A.[vID]
--	  ,'' AS [COLNAME]
--	  ,'Have you been pregnant since the last registry visit?' AS QTXT
--	  ,A.[DATALMDT]
--	  ,A.[DATALMBY]
--	  ,A.PREG_FU

--FROM [ZELTA_GPP_TEST].[dbo].[SUB_A] A
--LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT] V ON V.vID=A.vID AND V.SUBID=A.SUBID
--WHERE 1=1
--AND PREG_FU IS NOT NULL

--UNION

--SELECT DISTINCT B.[SITENUM]
--      ,B.[SUBID]
--	  ,B.[SUBNUM]
--	  ,B.[VISNAME]
--	  ,COALESCE(V.[VISDAT],V.[FLRVISDAT]) AS VisitDate
--	  ,B.[VISITSEQ]
--	  ,B.[PAGENAME]
--	  ,B.[vID]
--	  ,'' AS [COLNAME]
--	  ,'Are you currently pregnant?' AS QTXT
--	  ,B.[DATALMDT]
--	  ,B.[DATALMBY]
--	  ,B.PREGCURR

--FROM [ZELTA_GPP_TEST].[dbo].[SUB_B] B
--LEFT JOIN [ZELTA_GPP_TEST].[dbo].[VISIT] V ON V.vID=B.vID AND V.SUBID=B.SUBID
--WHERE 1=1
--AND PREGCURR IS NOT NULL
--)

SELECT *
FROM
(
SELECT ROWNUM
	  ,PFA.[vID]
      ,PFA.[SITENUM]
      ,PFA.[SUBID]
	  ,PFA.[SUBNUM]
	  ,PFA.[VISNAME]
	  ,PFA.VisitDate
	  ,PFA.[VISITSEQ]
	  ,PFA.[PAGENAME]
	  ,PFA.[COLNAME]
	  ,PFA.QTXT
	  ,PFA.[DATALMDT]
	  ,PFA.[DATALMBY]

	   ,STUFF((
	   SELECT DISTINCT ', ' + drug
	   FROM DRUGS  
	   WHERE (DRUGS.SUBID=PFA.SUBID 
	   AND DRUGS.PAGENAME='Drug Log')
	   OR
	   (DRUGS.SUBID=PFA.SUBID
	   AND DRUGS.PAGENAME='Medication History'
	   AND (DATEDIFF(D, PFA.VisitDate, DRUGS.enddate) between 0 and 300
	   OR (DATEDIFF(D, DRUGS.enddate, PFA.VisitDate) between 0 and 120)))   
	   FOR XML PATH('')
        )
        ,1,1,'') AS Treatments

	  ,STUFF((
	   SELECT DISTINCT ', ' + drugOTH
	   FROM DRUGS  
	   WHERE (DRUGS.SUBID=PFA.SUBID 
	   AND DRUGS.PAGENAME='Drug Log')
	   OR
	   (DRUGS.SUBID=PFA.SUBID
	   AND DRUGS.PAGENAME='Medication History'
	   AND (DATEDIFF(D, PFA.VisitDate, DRUGS.enddate) between 0 and 300
	   OR (DATEDIFF(D, DRUGS.enddate, PFA.VisitDate) between 0 and 120))) 
	   FOR XML PATH('')
        )
        ,1,1,'') AS OtherTreatments

	  ,PFA.DATAVALUE AS CURRVAL
	  ,(SELECT [DATAVALUE] FROM PREGAUDIT PFA2 WHERE PFA2.ROWNUM=2 AND PFA.vID=PFA2.vID AND PFA.SUBID=PFA2.SUBID AND PFA.VISNAME=PFA2.VISNAME AND PFA.VISITSEQ=PFA2.VISITSEQ AND PFA.VisitDate=PFA2.VisitDate AND PFA.PAGENAME=PFA2.PAGENAME AND PFA.QTXT=PFA2.QTXT) AS PREVVAL
FROM PREGAUDIT PFA
WHERE 1=1

) A
WHERE 1=1
AND ROWNUM=1
AND ISNULL(CURRVAL, '')<>ISNULL(PREVVAL, '')



--ORDER BY SITENUM, SUBNUM, VISITSEQ, VisitDate, COLNAME, ROWNUM



GO
