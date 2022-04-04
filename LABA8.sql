--LABA 8-- 
use proekt1 

/8 select t1.name from sys.objects t1 
 join sys.schemas s on s.schema_id = t1.schema_id 
 where type = 'U' and s.principal_id = USER_ID() 

 SELECT t1.name AS table_name, c.name AS column_name, c.is_nullable AS nullable, t.name AS type, c.max_length AS 'length, byte' FROM sys.objects t1
	JOIN sys.columns c ON c.object_id = t1.object_id
	JOIN sys.schemas s ON s.schema_id = t1.schema_id
	JOIN sys.types t ON t.system_type_id = c.system_type_id
		WHERE type = 'U' and s.principal_id = USER_ID()
		ORDER BY 1
