USE [Reporting]
GO
/****** Object:  View [RA100].[dwh_qa_bv_documents]    Script Date: 9/22/2023 10:25:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





		 --SELECT * FROM
CREATE VIEW [RA100].[dwh_qa_bv_documents] AS


SELECT * FROM OPENQUERY (REDSHIFT, 'SELECT * FROM corrona_dwh_qa.bv_documents')
GO
