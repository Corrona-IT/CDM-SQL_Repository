USE [Reporting]
GO
/****** Object:  View [RA102].[v_Deleted]    Script Date: 11/13/2024 1:41:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [RA102].[v_Deleted] AS


WITH RAV as
(
SELECT VID
      ,SITENUM
	  ,SUBNUM
	  ,DATAVAL
FROM MERGE_RA_Japan.staging.VIS_DATE_AFLD
WHERE COLNAME='VISITDATE'
)

,SPAV AS
(
SELECT VID
      ,SITENUM
	  ,SUBNUM
	  ,CAST(DATAVAL AS date) AS DATAVAL
FROM MERGE_SPA.staging.VS_01_AFLD VS
WHERE COLNAME='VISITDATE'
AND VS.vID IN (SELECT vid FROM MERGE_SPA.staging.DAT_APGS da WHERE da.DELETED='t')
)


,D AS
(
SELECT 'RA-102' AS RegistryName
       ,ROW_NUMBER() OVER (PARTITION BY SITENUM, SUBNUM ORDER BY SITENUM, SUBNUM) AS ROWNBR
       ,A.SITENUM AS SiteID
	   ,A.SUBNUM AS SubjectID
	   ,'Subject' AS AssociatedDeletedObject
	   ,NULL AS VisitDate
	   ,'Not Applicable' AS DeletedPage
	   ,A.REASON AS ReasonForDeletion
	   ,A.LASTMBY AS DeletedBy
	   ,CONVERT(NVARCHAR(12), A.LASTMDT, 101) AS ModifiedDate
	   ,0 AS ORDERING

FROM MERGE_RA_Japan.dbo.DAT_SUB A
WHERE DELETED='t'


UNION

SELECT 'PSA-400' AS RegistryName
       ,ROW_NUMBER() OVER (PARTITION BY SITENUM, SUBNUM ORDER BY SITENUM, SUBNUM) AS ROWNBR
       ,A.SITENUM AS SiteID
	   ,A.SUBNUM AS SubjectID
	   ,'Subject' AS AssociatedDeletedObject
	   ,NULL as VisitDate
	   ,'Not Applicable' AS DeletedPage
	   ,A.REASON AS ReasonForDeletion
	   ,A.LASTMBY AS DeletedBy
	   ,CONVERT(NVARCHAR(12), A.LASTMDT, 101) AS ModifiedDate
	   ,0 AS ORDERING
FROM MERGE_SPA.dbo.DAT_SUB A
WHERE DELETED='t'

UNION

SELECT 'RA-102' AS RegistryName
       ,ROW_NUMBER() OVER (PARTITION BY A.SITENUM, A.SUBNUM, A.VISITID, A.PAGEID, A.PAGENAME 
	                 ORDER BY A.SITENUM, A.SUBNUM, A.VISITID, A.PAGENAME, A.PAGELMDT) AS ROWNBR
      ,A.SITENUM AS SiteID
	  ,A.SUBNUM AS SubjectID
      ,A.VISNAME AS AssociatedDeletedObject
	  ,V.DATAVAL AS VisitDate
	  ,A.PAGENAME AS DeletedPage
	  ,A.REASON AS ReasonForDeletion
	  ,A.PAGELMBY AS DeletedBy
	  ,CONVERT(NVARCHAR(12), A.PAGELMDT, 101) AS ModifiedDate
	  ,(SELECT PORDER FROM MERGE_RA_Japan.dbo.DES_VDEF VDEF WHERE VDEF.PAGENAME=A.PAGENAME AND VDEF.PAGEID=A.PAGEID
	  AND VDEF.VISITID=A.VISITID AND VDEF.VISNAME=A.VISNAME AND VDEF.REVNUM=A.REVNUM) AS ORDERING

FROM MERGE_RA_Japan.staging.DAT_APGS A
LEFT JOIN RAV V ON A.VID=V.VID
WHERE DELETED='t'


UNION

SELECT 'PSA-400' AS RegistryName
       ,ROW_NUMBER() OVER (PARTITION BY A.SITENUM, A.SUBNUM, A.VISITID, A.PAGEID, A.PAGENAME 
	                 ORDER BY A.SITENUM, A.SUBNUM, A.VISITID, A.PAGENAME, A.PAGELMDT) AS ROWNBR
      ,A.SITENUM AS SiteID
	  ,A.SUBNUM AS SubjectID
      ,A.VISNAME AS AssociatedDeletedObject
	  ,V.DATAVAL AS VisitDate
	  ,A.PAGENAME AS DeletedPage
	  ,A.REASON AS ReasonForDeletion
	  ,A.PAGELMBY AS DeletedBy
	  ,CONVERT(NVARCHAR(12), A.PAGELMDT, 101) AS ModifiedDate
	  ,(SELECT PORDER FROM MERGE_SPA.dbo.DES_VDEF VDEF WHERE VDEF.PAGENAME=A.PAGENAME AND VDEF.PAGEID=A.PAGEID
	  AND VDEF.VISITID=A.VISITID AND VDEF.VISNAME=A.VISNAME AND VDEF.REVNUM=A.REVNUM) AS ORDERING

FROM MERGE_SPA.staging.DAT_APGS A
LEFT JOIN SPAV V ON A.VID=V.VID
WHERE A.DELETED='t'
)

SELECT RegistryName
      ,SiteID
	  ,SubjectID
	  ,AssociatedDeletedObject
	  ,CAST(VisitDate AS date) AS VisitDate
	  ,DeletedPage
	  ,ReasonForDeletion
	  ,DeletedBy
	  ,CONVERT(DATE, ModifiedDate) AS DateDeleted
	  ,Ordering

FROM D
WHERE ROWNBR=1

---ORDER BY RegistryName, SiteID, SubjectID, ORDERING, DeletedPage, DateDeleted






GO
