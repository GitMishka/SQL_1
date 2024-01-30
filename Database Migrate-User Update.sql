Declare @Users Table (
	UserName Varchar(255)
	,UserSID uniqueidentifier
)
Insert Into @Users
Exec sp_change_users_login @Action = 'Report'

select	*
		--,'exec sp_change_users_login @Action = ''update_one'', @UserNamePattern = ''' + UserName + ''' , @LoginName = ''' + UserName + ''''
		,'Alter User ' + UserName + ' With Login = [' + UserName + ']
		Go'
From	@Users
Where	UserName Not In ('dbo')

--sp_change_users_login @Action = 'update_one', @UserNamePattern = 'SpectrumDB', @LoginName = 'SpectrumDB'
--GO
 
 select	*
From	sys.database_principals 
Where	Type In ('U','G') -- Users = U, Groups = G
		-- and name <> 'dbo'
		 And name Collate SQL_Latin1_General_CP1_CI_AS Not In (
			select	name
			From	master.sys.syslogins
		)
