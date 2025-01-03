USE [Reporting]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_HB_All_Registries_20190215pre]    Script Date: 1/3/2025 4:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Garth Fitzsimmons
-- Create date: 9-2018
-- Description:	CDM to drop file here "D:\CDMShare\PII\" and execute this procedure to truncate and reload them to registry specific tables
-- =============================================


CREATE PROCEDURE --		exec 
	[dbo].[usp_Load_HB_All_Registries_20190215pre]
	-- Add the parameters for the stored procedure here

	
AS



BEGIN

/*

*/


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	

declare @files table (ID int IDENTITY, [FileName] varchar(100))
declare @sql as nvarchar(max)


insert into @files execute xp_cmdshell 'dir D:\CDMShare\PII\ /b'


IF OBJECT_ID('tempdb..#files') IS NOT NULL BEGIN DROP TABLE #files END;
select f.[FileName], u.[TableName] 
into #files
from @files f
join
(
select 'CORRONA_PHI_HB_IBD_Registry_HB_ICF_Status_'	as [FileName], '[IBD600].[t_HB]' as [TableName] union
select 'CORRONA_PHI_HB_MS_Registry_HB_ICF_Status_'	as [FileName], '[MS700].[t_HB]'  as [TableName] union
select 'CORRONA_PHI_HB_PSO_Registry_HB_ICF_Status_'	as [FileName], '[PSO500].[t_HB]' as [TableName] union
--select 'CORRONA_PHI_HB_RA_Registry_HB_ICF_Status_'	as [FileName], '[RA100].[t_HB]'  as [TableName] union
select 'CORRONA_PHI_HB_SPA_Registry_HB_ICF_Status_' as [FileName], '[PSA400].[t_HB]' as [TableName] 
) u
on  f.[FileName] like u.[FileName] + '%'

	--		select * from #files


set @sql = ''
select @sql = @sql 
	+ '
	truncate table ' + [TableName] + '
	BULK INSERT ' + [TableName] + ' FROM ''D:\CDMShare\PII\' + [FileName] + ''' WITH ( FIRSTROW = 2, FIELDTERMINATOR =''","'', ROWTERMINATOR =''"\n'')
	update ' + [TableName] + ' set [TRNAME] = NULL where [TRNAME] = ''"''
	'
	--+ ' select top 1 * from ' + [TableName] 
from #files



	--		select
			exec 
	(@sql)
	
/*
	select * from IBD600.t_HB
	select * from MS700.t_HB
	select * from PSO500.t_HB
	select * from RA100.t_HB
	select * from PSA400.t_HB	

	truncate table IBD600.t_HB
	truncate table MS700.t_HB
	truncate table PSO500.t_HB
	truncate table RA100.t_HB
	truncate table PSA400.t_HB



drop table IBD600.t_HB
create table IBD600.t_HB (
TRNAME	varchar(50)
,TRNO	varchar(50)
,TRCAP	varchar(50)
,STNAME	varchar(255)
,STNO	int not null
,SITEC	varchar(255)
,SUBJID	varchar(50) not null
,VISITN	varchar(50)
,VISITDT	date
,CRFNAME	varchar(255)
,CRFSTAT	varchar(50)
,CPHID	int
,DLPES	varchar(50)
,DATECNST	varchar(50)
,GAVEPII	varchar(50)
,GAVEAUTH	varchar(50)
,PARTWD	varchar(50)
,PARTWDDT	date
,FULLWD2	varchar(50)
,FULLWDDT	date
,ADM_WDRW	varchar(50)
,WDRW_RSN	int
,ADM_WDDT	date
,TRIALID	bigint
,SITEID	bigint
,PATIENTID	bigint
,VISITID	int
,FORMID	int
,DATAMIN	datetime
,DATAMAX	datetime
,STATMIN	datetime
,STATMAX	datetime,

 CONSTRAINT [PK_IBD600_t_HB] PRIMARY KEY CLUSTERED 
(
SUBJID
)
)



drop table MS700.t_HB
create table MS700.t_HB (
TRNAME	varchar(50)
,TRNO	varchar(50)
,TRCAP	varchar(50)
,STNAME	varchar(255)
,STNO	int not null
,SITEC	varchar(255)
,SUBJID	varchar(50) not null
,VISITN	varchar(50)
,VISITDT	date
,CRFNAME	varchar(255)
,CRFSTAT	varchar(50)
,CPHID	int
,DLPES	varchar(50)
,DATECNST	varchar(50)
,GAVEPII	varchar(50)
,GAVEAUTH	varchar(50)
,PARTWD	varchar(50)
,PARTWDDT	date
,FULLWD2	varchar(50)
,FULLWDDT	date
,ADM_WDRW	varchar(50)
,WDRW_RSN	int
,ADM_WDDT	date
,TRIALID	bigint
,SITEID	bigint
,PATIENTID	bigint
,VISITID	int
,FORMID	int
,DATAMIN	datetime
,DATAMAX	datetime
,STATMIN	datetime
,STATMAX	datetime,
 CONSTRAINT [PK_MS700_t_HB] PRIMARY KEY CLUSTERED 
(
SUBJID
)
)



drop table PSO500.t_HB
create table PSO500.t_HB (
TRNAME	varchar(50)
,TRNO	varchar(50)
,TRCAP	varchar(50)
,STNAME	varchar(255)
,STNO	int not null
,SITEC	varchar(255)
,SUBJID	varchar(50) not null
,VISITN	varchar(50)
,VISITDT	date
,CRFNAME	varchar(255)
,CRFSTAT	varchar(50)
,CPHID	int
,PIIDAT	date
,ICFDAT	date
,ADMWDRW	varchar(50)
,STWDRWDT	date
,PTWDRWDT	date
,WDRWRSN	varchar(255)
,PARTWD	varchar(50)
,PARTWDDT	date
,FULLWD	varchar(50)
,FULLWDDT	date
,ADM_WDDT	date
,TRIALID	bigint
,SITEID	bigint
,PATIENTID	bigint
,VISITID	int
,FORMID	int
,DATAMIN	datetime
,DATAMAX	datetime
,STATMIN	datetime
,STATMAX	datetime,
 CONSTRAINT [PK_PSO500_t_HB] PRIMARY KEY CLUSTERED 
(
SUBJID
)
)

drop table RA100.t_HB
create table RA100.t_HB (
TRNAME	varchar(50)
,TRNO	varchar(50)
,TRCAP	varchar(50)
,STNAME	varchar(255)
,STNO	int not null
,SITEC	varchar(255)
,SUBJID	varchar(50) not null
,VISITN	varchar(50)
,VISITDT	date
,CRFNAME	varchar(255)
,CRFSTAT	varchar(50)
,CPHID	int
,V14CNSNT	varchar(50)
,DATECNST	date
,TYPECNST	varchar(50)
,ELIG_GRP	varchar(50)
,ADM_WDRW	varchar(50)
,PHIDAT	date
,MR_SIGN	varchar(50)
,NOMR_RSN	varchar(255)
,PARTWD	varchar(50)
,PARTWDDT	date
,FULLWD	varchar(50)
,FULLWDDT	date
,ADM_WDDT	date
,TRIALID	bigint
,SITEID	bigint
,PATIENTID	bigint
,VISITID	int
,FORMID	int
,DATAMIN	datetime
,DATAMAX	datetime
,STATMIN	datetime
,STATMAX	datetime,
 CONSTRAINT [PK_RA100_t_HB] PRIMARY KEY CLUSTERED 
(
SUBJID
)
)



drop table PSA400.t_HB
create table PSA400.t_HB (
TRNAME	varchar(50)
,TRNO	varchar(50)
,TRCAP	varchar(50)
,STNAME	varchar(255)
,STNO	int not null
,SITEC	varchar(255)
,SUBJID	varchar(50) not null
,VISITN	varchar(50)
,VISITDT	date
,CRFNAME	varchar(255)
,CRFSTAT	varchar(50)
,CPHID	int
,PSAV2EN	varchar(50)
,DATECNST	date
,GAVEPII	varchar(50)
,GAVEAUTH	varchar(50)
,PARTWD	varchar(50)
,PARTWDDT	date
,FULLWD	varchar(50)
,FULLWDDT	date
,ADM_WDRW	varchar(50)
,WDRW_RSN	varchar(255)
,ADM_WDDT	date
,TRIALID	bigint
,SITEID	bigint
,PATIENTID	bigint
,VISITID	int
,FORMID	int
,DATAMIN	datetime
,DATAMAX	datetime
,STATMIN	datetime
,STATMAX	datetime,
 CONSTRAINT [PK_PSA400_t_HB] PRIMARY KEY CLUSTERED 
(
SUBJID
)
)


  
  

*/	


END


GO
