USE [Reporting]
GO
/****** Object:  View [RA100].[dwh_v_op_VisitLog]    Script Date: 4/2/2024 11:30:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





		 --SELECT * FROM
CREATE VIEW [RA100].[dwh_v_op_VisitLog] AS


SELECT * FROM OPENQUERY (REDSHIFT, 'SELECT * FROM reporting.v_visit_log')
GO
