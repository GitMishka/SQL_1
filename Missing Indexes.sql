-- SQL Server 2008 Diagnostic Information Queries
-- Glenn Berry 
-- May 2009
-- http://glennberrysqlperformance.spaces.live.com/

-- Missing Indexes for entire instance by Index Advantage
SELECT	user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage
		,migs.last_user_seek
		,mid.statement AS [Database.Schema.Table]
		,mid.equality_columns, mid.inequality_columns, mid.included_columns
		,migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact
		,db.name as database_name
		,mid.object_id
		,OBJECT_NAME(mid.OBJECT_ID,mid.database_id) AS [TableName],
			'CREATE INDEX [IX_' + OBJECT_NAME(mid.OBJECT_ID,mid.database_id) + '_'
			+ REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns,''),', ','_'),'[',''),']','') 
			+ CASE
			WHEN mid.equality_columns IS NOT NULL 
			AND mid.inequality_columns IS NOT NULL THEN '_'
			ELSE ''
			END
			+ REPLACE(REPLACE(REPLACE(ISNULL(mid.inequality_columns,''),', ','_'),'[',''),']','')
			+ ']'
			+ ' ON ' + mid.statement
			+ ' (' + ISNULL (mid.equality_columns,'')
			+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns 
			IS NOT NULL THEN ',' ELSE
			'' END
			+ ISNULL (mid.inequality_columns, '')
			+ ')'
			+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS Create_Statement

FROM	sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
		INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK) ON migs.group_handle = mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK) ON mig.index_handle = mid.index_handle
		Left Outer Join sys.databases as db on db.database_id = mid.database_id
Where	db.name = 'ustetvp00'
		--and OBJECT_NAME(mid.OBJECT_ID,mid.database_id) like '%task%' -- table name
ORDER BY index_advantage DESC;
-- Look at last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
