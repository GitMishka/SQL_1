select 
		serverproperty('MachineName') MachineName
		,serverproperty('ServerName') ServerInstanceName
		,replace(cast(serverproperty('Edition')as varchar),'Edition','') EditionInstalled
		,serverproperty('productVersion') ProductBuildLevel
		,serverproperty('productLevel') SPLevel
		,serverproperty('Collation') Collation_Type
		,serverproperty('IsClustered') [IsClustered?]
		,convert(varchar,getdate(),102) QueryDate
