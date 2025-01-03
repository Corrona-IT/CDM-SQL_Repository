USE [Reporting]
GO
/****** Object:  View [GPP510].[v_pv_AbbrevPregnancy]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/* Can't use join on [ZELTA_GPP].[staging].[dec_afld] due to this error message: 'Cannot resolve the collation conflict between "Latin1_General_CS_AS" and "SQL_Latin1_General_CP1_CI_AS" in the equal to operation' Had to hard code with case statement*/



CREATE VIEW [GPP510].[v_pv_AbbrevPregnancy] AS


WITH DECODER_RING AS
(
SELECT [REVNUM]
      ,[VISITID]
      ,[PAGEID]
      ,[REPORTINGT]
      ,[REPORTINGC]
      ,[CODENAME]
      ,[DISPLAYNAME]
      ,[DORDER]
      ,[DESCRIPTION]
      ,[HIDDEN]
  FROM [ZELTA_GPP].[staging].[dec_afld]
  WHERE 1=1
  --AND REPORTINGT IN ('SUB_A', 'SUB_B')
  AND REPORTINGC IN ('PREGHX', 'PREGCURR', 'PREG_FU')
  )

,PREGFU AS
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
	  ,SubAudit.[DATAVAL]
	  ,CASE WHEN SubAudit.[DATAVAL]=0 THEN 'No'
	        WHEN SubAudit.[DATAVAL]=1 THEN 'Yes'
			ELSE CAST(SubAudit.[DATAVAL] as nvarchar)
		END AS DISPLAYNAME
	  ,SubAudit.[REASON]
FROM [ZELTA_GPP].[dbo].[SUB_B_AFLD] SubAudit
--LEFT JOIN DECODER_RING DA ON SubAudit.DATAVAL=DA.CODENAME AND DA.REPORTINGT='SUB_B' AND DA.COLNAME='PREGCURR'
LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.vID=SubAudit.vID AND V.SUBID=SubAudit.SUBID
WHERE 1=1
AND [COLNAME]='PREGCURR'
AND V.VISDAT IS NOT NULL

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
	  ,SubAudit.[DATAVAL]
	  ,CASE WHEN SubAudit.[DATAVAL]=0 THEN 'No'
	        WHEN SubAudit.[DATAVAL]=1 THEN 'Yes'
			ELSE CAST(SubAudit.[DATAVAL] as nvarchar)
		END AS DISPLAYNAME
	  ,SubAudit.[REASON]
FROM [ZELTA_GPP].[dbo].[SUB_A_AFLD] SubAudit
LEFT JOIN [ZELTA_GPP].[dbo].[VISIT] V ON V.vID=SubAudit.vID AND V.SUBID=SubAudit.SUBID
WHERE 1=1
AND [COLNAME]='PREG_FU' 
AND (V.VISDAT IS NOT NULL OR V.FLRVISDAT IS NOT NULL)
)

SELECT *
FROM
(
SELECT ROWNUM
	  ,PFU.[vID]
      ,PFU.[SITENUM]
      ,PFU.[SUBID]
	  ,PFU.[SUBNUM]
	  ,PFU.[VISNAME]
	  ,PFU.VisitDate
	  ,PFU.[VISITSEQ]
	  ,PFU.[PAGENAME]
	  ,PFU.[COLNAME]
	  ,PFU.QTXT
	  ,PFU.[DATALMDT]
	  ,PFU.[DATALMBY]
	  ,PFU.[DISPLAYNAME] AS CURRVAL
	  ,(SELECT [DISPLAYNAME] FROM PREGFU PFU2 WHERE PFU2.ROWNUM=2 AND PFU.vID=PFU2.vID AND PFU.SUBID=PFU2.SUBID AND PFU.VISNAME=PFU2.VISNAME AND PFU.VISITSEQ=PFU2.VISITSEQ AND PFU.VisitDate=PFU2.VisitDate AND PFU.PAGENAME=PFU2.PAGENAME AND PFU.QTXT=PFU2.QTXT) AS PREVVAL
FROM PREGFU PFU
WHERE 1=1
AND ROWNUM=1
) A
WHERE 1=1
AND ISNULL(CURRVAL, '')<>ISNULL(PREVVAL, '')


--ORDER BY SITENUM, SUBNUM, VISITSEQ, VisitDate, COLNAME, ROWNUM



GO
