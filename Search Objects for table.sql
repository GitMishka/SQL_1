-- source: http://blog.sqlauthority.com/2006/12/10/sql-server-find-stored-procedure-related-to-table-in-database-search-in-all-stored-procedure/
----Option 1
SELECT DISTINCT so.name
FROM syscomments sc
INNER JOIN sysobjects so ON sc.id=so.id
WHERE sc.TEXT LIKE '%INTF_PADS_EXAM_SUB%'
----Option 2
SELECT DISTINCT o.name, o.xtype
FROM syscomments c
INNER JOIN sysobjects o ON c.id=o.id
WHERE c.TEXT LIKE '%INTF_PADS_EXAM_SUB%'
