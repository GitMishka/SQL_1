
SELECT TOP 25 
		@@Servername as server_name
		,IsNull(Db_name(qt.dbid),'Unknown') as database_name
		,SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
			((CASE qs.statement_end_offset
			WHEN -1 THEN DATALENGTH(qt.TEXT)
			ELSE qs.statement_end_offset
			END - qs.statement_start_offset)/2)+1) as query_text
		,qs.execution_count,
		qs.total_logical_reads, qs.last_logical_reads,
		qs.total_logical_writes, qs.last_logical_writes,
		qs.total_worker_time,
		qs.last_worker_time,
		qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
		qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
		qs.last_execution_time,
		qp.query_plan
FROM	sys.dm_exec_query_stats qs
		CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
		CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
Where	qt.TEXT is not null
order by total_worker_time desc
