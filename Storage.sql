-- IO
-- Look for I/O requests taking longer than 15 seconds in the five most recent SQL Server Error Logs (Query 12) (IO Warnings)
CREATE TABLE #IOWarningResults(LogDate datetime, ProcessInfo sysname, LogText nvarchar(1000));
-- Long I/O requests
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'taking longer than 15 seconds';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'taking longer than 15 seconds';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'taking longer than 15 seconds';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'taking longer than 15 seconds';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'taking longer than 15 seconds';
-- throughput
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'average throughput';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'average throughput';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'average throughput';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'average throughput';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'average throughput';

-- throughput part 2
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'last target outstanding';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'last target outstanding';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'last target outstanding';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'last target outstanding';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'last target outstanding';

-- throughput part 3
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'FlushCache';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'FlushCache';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'FlushCache';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'FlushCache';
	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'FlushCache';

SELECT LogDate, ProcessInfo, LogText
FROM #IOWarningResults
ORDER BY LogDate DESC;
DROP TABLE #IOWarningResults;  

-- add logic to support 2005

-- add stalls, IOPs
-- Drive level latency information (Query 13) (Drive Level Latency)
-- Based on code from Jimmy May
SELECT tab.[Drive], tab.volume_mount_point AS [Volume Mount Point], 
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
	END AS [Read Latency],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END AS [Write Latency],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END AS [Overall Latency],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END AS [Avg Bytes/Transfer]
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point 
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
	  CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
      GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);
