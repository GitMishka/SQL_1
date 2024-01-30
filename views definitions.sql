
Select	smv.object_id
		,smv.definition
FROM	sys.all_views AS v
		Inner JOIN sys.sql_modules AS smv ON smv.object_id = v.object_id
where	smv.definition like '%Sql_device_filesystems%'
