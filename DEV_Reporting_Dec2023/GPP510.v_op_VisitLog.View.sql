USE [Reporting]
GO
/****** Object:  View [GPP510].[v_op_VisitLog]    Script Date: 12/22/2023 12:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GPP510].[v_op_VisitLog] as
Select 
V.SITENUM as SiteID,
V.SUBID as SubjectID,
V.VISNAME as [Visit Type],
V.VisitSEQ as VisitSequence,
V.VISDAT as VisitDate,
V.PROVID as ProviderID
from [Zelta_GPP].[dbo].[VISIT] V

---------------------------------------------------
--select * from [Zelta_GPP].[dbo].[VISIT] V
--select * from Reporting.[GPP510].[v_op_VisitLog]
---------------------------------------------------
GO
