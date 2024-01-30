Use ReportServer
Go
select	top 1000 ReportPath
		,UserName
		,[Format]
		,ReportAction
		,[Source]
		,TimeStart
		,TimeEnd
		,TimeDataRetrieval
		,TimeProcessing
		,TimeRendering
		,[Status]
		,ByteCount
		,[RowCount]
		,[Parameters]
		,RequestType
		,AdditionalInfo
From	ExecutionLog2
--Where	ReportPath = '/DBA/EPM/PolicyDashboard'
--		And ReportAction = 'Render'
--		And Format is null
--where	timestart < '12-30-2016 14:00'
--		and UserName <> 'TVA\siteScope'
--		and TimeDataRetrieval + TimeProcessing + TimeRendering > 5000
--Where Status <> 'rsSuccess'
Order By TimeStart Desc
