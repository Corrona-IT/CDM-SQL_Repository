USE [Reporting]
GO
/****** Object:  View [RA100].[v_op_ModifiedIDs]    Script Date: 1/3/2025 4:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ===============================================================================================================
-- Author:		P. Brooks, G. Fitzsimmons, K. Mowrey
-- Create date: 09Jun2023
-- Description:	View to obtain list of all IDs that have been modified in the TrialMaster EDC for the RA Registry. 
-- Will list full history of the ID changes that have occurred.
-- ===============================================================================================================

		 --SELECT * FROM
CREATE VIEW [RA100].[v_op_ModifiedIDs] AS


with audits as (
       select min(a.statechangedatetime) AuditDate,
              a.TrlObjectPatientId,a.datavalue PatientNumber
       from [172.16.81.24].[DataModel_TMCORe_production].[dbo].[Audits] a
       where a.[TrlObjectTypeId] IN (6)
       and a.datavalue is not null
       group by a.TrlObjectPatientId,a.datavalue
),

changed as (
       select TrlObjectPatientId 
       from audits
       group by TrlObjectPatientId having count(*) > 1
)

select a.AuditDate,a.TrlObjectPatientId,
       a.PatientNumber,com.Comment
from audits a
join changed c on c.TrlObjectPatientId = a.TrlObjectPatientId
left join (
              select distinct trlobjectpatientid, c.response
                      ,c.FromUserName, c.comment
              from [172.16.81.24].[DataModel_TMCORe_production].[dbo].[comments] c
              join [172.16.81.24].[TMCORe_production].[dbo].[ProItems] proi
              on proi.proitemid = c.proitemid
              where proi.caption = 'Patient Number'
) com
on com.trlobjectpatientid = a.trlobjectpatientid
and com.response = a.PatientNumber
--order by TrlObjectPatientId,a.AuditDate
GO
