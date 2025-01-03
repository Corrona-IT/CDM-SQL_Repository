USE [Reporting]
GO
/****** Object:  StoredProcedure [PSA400].[usp_pv_InsertToEventTypeTbl]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Kaye and Garth
-- Create date: 2017-05-09
-- Description:	Found manually mapped table used in Jen's PV reports. Needed way of inserting new pages from MSUs and for notifying Kaye of the new pages for mapping.
-- =============================================
CREATE PROCEDURE [PSA400].[usp_pv_InsertToEventTypeTbl]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare	 @SubjectText as varchar(185), @BodyText nvarchar(max)

    -- Insert statements for procedure here
insert into [Reporting].[PSA400].[t_pv_EventType] (
REVNUM, VISITID, PAGEID, POBJNAME, PAGENAME, PORDER
)
select vd.REVNUM, vd.VISITID, vd.PAGEID, vd.POBJNAME, vd.PAGENAME, vd.PORDER
from [merge_spa].[dbo].[des_vdef] vd
left join [MERGE_SPA].[Jen].[EventType] et
on  vd.REVNUM	= et.REVNUM
and vd.VISITID	= et.VISITID
and vd.PAGEID   = et.PAGEID
where et.REVNUM is null
and (vd.pobjname like '%TAE%' or vd.pobjname like '%PEQ%')-- 2792


exec ('USE [EDC_ETL]

declare	 @SubjectText as varchar(185), @BodyText nvarchar(max)
IF (select distinct 1 from [MERGE_SPA].[Jen].[EventType] where EVENTYPE is null) = 1
begin 
set @SubjectText = ''New rows have been inserted into [MERGE_SPA].[Jen].[EventType]''
set @BodyText = ''WARNING: New rows have been inserted into [MERGE_SPA].[Jen].[EventType]

	select * from [MERGE_SPA].[Jen].[EventType] where EvenType is null

''
exec msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Notification Profile''
,@recipients = ''kmowrey@corrona.org''
,@subject = @SubjectText
,@body = @BodyText

end
')

END

GO
