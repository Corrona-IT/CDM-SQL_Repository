USE [Reporting]
GO
/****** Object:  StoredProcedure [MULTI].[usp_op_RegistryCountsScheduler]    Script Date: 9/3/2024 2:31:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [MULTI].[usp_op_RegistryCountsScheduler] as
declare @maxDateFromTarget date = (
	select max(DownloadDate) from --select * from 
		[Reporting].[MULTI].[t_op_RegistryCounts]
		--where DownloadDate < '2022-01-01'
	)
      , @nightlyLoadDate date = getdate()

--select @maxDateFromTarget
--select @nightlyLoadDate


-- convert both dates to 1st of month
-- i.e. has the target table table been loaded for the month?
-- this will save us if we don't fix a bad load when the 1st happens to land on a weekend
set @maxDateFromTarget = (SELECT cast(DATEADD(month, DATEDIFF(month, 0, @maxDateFromTarget), 0) as date))
set @nightlyLoadDate   = (SELECT cast(DATEADD(month, DATEDIFF(month, 0, @nightlyLoadDate  ), 0) as date))

--select @maxDateFromTarget
--select @nightlyLoadDate

if coalesce(@maxDateFromTarget,'1901-01-01') <> coalesce(@nightlyLoadDate,'1901-01-01')
begin 
	exec [Reporting].[MULTI].[usp_op_RegistryCounts]
end
else 
begin 
	select 'Month already loaded'
end
GO
