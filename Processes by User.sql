
Declare @Search varchar(255);
Declare @blocked int
Declare @encrypted int
Set @Search = 'controlsa'
set @blocked = 0
set @encrypted = 0;
select	sp.spid
		,sl.name as login_name
		,nt_username
		,db_name(dbid) as database_name
		,@@servername as db_server
		,sp.[status]
		,cn.encrypt_option
		,client_net_address
		,hostname
		,sp.*		
		,'kill ' + cast(spid as varchar(5)) as killcommand
From	sys.sysprocesses as sp
		Left Outer join master.sys.syslogins as sl on sl.sid = sp.sid
		Left Outer Join sys.dm_exec_connections as cn on cn.session_id = sp.spid 
Where	(lower(sl.name) like '%' + @Search + '%'
		Or lower(nt_username) like '%' + @Search + '%'
		Or lower(DB_NAME(dbid)) like '%' +  @Search + '%'
		Or lower(cast(spid as varchar)) like '%' +  @Search + '%'
		Or Lower(hostname) like '%' +  @Search + '%'
		Or Lower(program_name) like '%' + @Search + '%')
		And (blocked <> 0 or @blocked = 0)
		And (cn.encrypt_option = 'TRUE' or @encrypted = 0)
		--And db_name(dbid) Like 'RiverNavigation%'
		--and hostname not in ('','CHAPWSCCMPRI1','CHAPWSCCMMP1')
Order By  sp.spid desc

--kill 115 with statusonly
--dbcc inputbuffer(146)

--DECLARE @Handle binary(20) 
--SELECT @Handle = sql_handle 
--FROM master.dbo.sysprocesses 
--WHERE spid = 79

--SELECT * 
--FROM ::fn_get_sql(@Handle) 

