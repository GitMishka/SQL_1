-- Memory
Declare @MaxMemory Int
Set @MaxMemory = 0

SELECT @MaxMemory = Cast(value as int)
FROM sys.configurations
WHERE name = 'max server memory (MB)'

SELECT	[object_name],
		[counter_name],
		[cntr_value] As PLE,
		(@MaxMemory / 4096)*300 As PLEThreshold,
		@@SERVERNAME As ServerName
FROM	sys.dm_os_performance_counters
WHERE	[object_name] LIKE '%Manager%'
		AND [counter_name] = 'Page life expectancy'
			
-- Look for waiting queries.
SELECT	resource_semaphore_id
		,waiter_count
		,grantee_count
		,target_memory_kb
		,max_target_memory_kb
		,total_memory_kb
		,available_memory_kb
FROM	sys.dm_exec_query_resource_semaphores

-- look for large memory requests/grants
SELECT	session_id
		,dop
		,request_time
		,grant_time
		,requested_memory_kb
		,granted_memory_kb
		,'kill ' + cast(session_id as varchar(5)) as kill_query
FROM	sys.dm_exec_query_memory_grants 
order by requested_memory_kb desc

