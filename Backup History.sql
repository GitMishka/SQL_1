use msdb
Go
SELECT	database_name
		,user_name
		,backup_start_date
		,backup_finish_date
		,type
		,physical_device_name
		,recovery_model
		,is_copy_only
		--,compressed_backup_size/1024/1024 as size_MB
		--,backup_size/1024/1024 as size_MB
		,bs.*
		,bmf.*
FROM	backupset as bs
		left outer join backupmediafamily as bmf on bs.media_set_id = bmf.media_set_id
Where	
		 type = 'D'
		--and database_name = 'eComp'
		-- and compressed_backup_size/1024/1024 > 1024
		--and backup_start_date > DateAdd(d,-7,GetDate())
		
		--and physical_device_name not like 'VNB%'
		--And is_copy_only = 0
		--and user_name = 'tva\bmorris1'
Order By bs.database_name, bs.backup_start_date desc

