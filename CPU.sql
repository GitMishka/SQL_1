-- CPU
-- Get CPU Utilization History for last 256 minutes (in one minute intervals) (Query 26) (CPU Utilization History)

Declare @ts_sql varchar(4000)
Set @ts_sql = 'DECLARE @ts_now bigint; 
'
IF (CONVERT(varchar(128), SERVERPROPERTY('ProductVersion')) LIKE '9%')
	BEGIN
	-- This version works with SQL Server 2005
	Set @ts_sql = @ts_sql + 'SET @ts_now = (SELECT cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info WITH (NOLOCK)); '
End Else Begin
	-- 2012
	Set @ts_sql = @ts_sql + 'set @ts_now = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); '
End

Set @ts_sql = @ts_sql + ' 
SELECT TOP(125) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value(''(./Record/@id)[1]'', ''int'') AS record_id, 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') 
			AS [SystemIdle], 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', 
			''int'') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N''RING_BUFFER_SCHEDULER_MONITOR'' 
			AND record LIKE ''%<SystemHealth>%'') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);
'
exec (@ts_sql)
