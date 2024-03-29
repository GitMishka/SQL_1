 /*
This script will script the role members for all roles on the database.

This is useful for scripting permissions in a development environment before refreshing
        development with a copy of production.  This will allow us to easily ensure
        development permissions are not lost during a prod to dev restoration. 

Source: http://www.sqlservercentral.com/links/946619/338463
*/

/*********************************************/
/*********   DB CONTEXT STATEMENT    *********/
/*********************************************/
SELECT '-- [-- DB CONTEXT --] --' AS [-- SQL STATEMENTS --],
                1 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  'USE' + SPACE(1) + QUOTENAME(DB_NAME()) AS [-- SQL STATEMENTS --],
                1 AS [-- RESULT ORDER HOLDER --] 

UNION

SELECT '' AS [-- SQL STATEMENTS --],
                2 AS [-- RESULT ORDER HOLDER --]

UNION


/*********************************************/
/*********    DB ROLE PERMISSIONS    *********/
/*********************************************/
SELECT '-- [-- DB ROLES --] --' AS [-- SQL STATEMENTS --],
                3 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  'EXEC sp_addrolemember @rolename ='
        + SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + 
         SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') 
                  AS [-- SQL STATEMENTS --],
                3 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_role_members AS rm
WHERE   USER_NAME(rm.member_principal_id) IN (  
                        --get user names on the database
                        SELECT [name]
                        FROM sys.database_principals
                        WHERE [principal_id] > 4 -- 0 to 4 are system users/schemas
                        and [type] IN ('G', 'S', 'U','R') 
                        -- S = SQL user, U = Windows user, G = Windows group, R = Role
                        )
--ORDER BY rm.role_principal_id ASC


UNION

SELECT '' AS [-- SQL STATEMENTS --],
                4 AS [-- RESULT ORDER HOLDER --]

UNION

/*********************************************/
/*********  OBJECT LEVEL PERMISSIONS *********/
/*********************************************/
SELECT '-- [-- OBJECT LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --],
                5 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  CASE 
                        WHEN perm.state <> 'W' THEN perm.state_desc 
                        ELSE 'GRANT'
                END
                + SPACE(1) + perm.permission_name + SPACE(1) + 'ON ' + QUOTENAME(SCHEMA_NAME(obj.schema_id)) + 
                 '.' + QUOTENAME(obj.name) --select, execute, etc on specific objects
                + CASE
                               WHEN cl.column_id IS NULL THEN SPACE(0)
                                ELSE '(' + QUOTENAME(cl.name) + ')'
                  END
                + SPACE(1) + 'TO' + SPACE(1) + 
                     QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
                + CASE 
                                WHEN perm.state <> 'W' THEN SPACE(0)
                                ELSE SPACE(1) + 'WITH GRANT OPTION'
                  END
                        AS [-- SQL STATEMENTS --],
                5 AS [-- RESULT ORDER HOLDER --]
FROM    
        sys.database_permissions AS perm
                INNER JOIN
        sys.objects AS obj
                        ON perm.major_id = obj.[object_id]
                INNER JOIN
        sys.database_principals AS usr
                        ON perm.grantee_principal_id = usr.principal_id
                LEFT JOIN
        sys.columns AS cl
                        ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
--WHERE usr.name = @OldUser
--ORDER BY perm.permission_name ASC, perm.state_desc ASC



UNION

SELECT '' AS [-- SQL STATEMENTS --],
                6 AS [-- RESULT ORDER HOLDER --]

UNION

/*********************************************/
/*********    DB LEVEL PERMISSIONS   *********/
/*********************************************/
SELECT '-- [--DB LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --],
                7 AS [-- RESULT ORDER HOLDER --]
UNION
SELECT  CASE 
                        WHEN perm.state <> 'W' THEN perm.state_desc --W=Grant With Grant Option
                        ELSE 'GRANT'
                END
        + SPACE(1) + perm.permission_name --CONNECT, etc
        + SPACE(1) + 'TO' + SPACE(1) + '[' + USER_NAME(usr.principal_id) + ']' COLLATE database_default --TO  
        + CASE 
                        WHEN perm.state <> 'W' THEN SPACE(0) 
                        ELSE SPACE(1) + 'WITH GRANT OPTION' 
          END
                AS [-- SQL STATEMENTS --],
                7 AS [-- RESULT ORDER HOLDER --]
FROM    sys.database_permissions AS perm
        INNER JOIN
        sys.database_principals AS usr
        ON perm.grantee_principal_id = usr.principal_id
--WHERE usr.name = @OldUser

WHERE   [perm].[major_id] = 0
        AND [usr].[principal_id] > 4 -- 0 to 4 are system users/schemas
        AND [usr].[type] IN ('G', 'S', 'U') -- S = SQL user, U = Windows user, G = Windows group

ORDER BY [-- RESULT ORDER HOLDER --]

