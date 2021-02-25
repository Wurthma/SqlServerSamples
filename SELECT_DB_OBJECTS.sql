--Count PK Grouped by specifics tables
SELECT QRY.PKCOLUMN FROM
	(SELECT count(column_name) AS PKCOLUMN
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
		AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
		AND KU.table_name IN (
			SELECT name FROM sys.objects WHERE type = 'U'
			AND  object_id IN (
				OBJECT_ID('USERS'),
				OBJECT_ID('PRODUCTS'),
				OBJECT_ID('CLIENTS')
			)
		)
	GROUP BY KU.table_name) QRY
WHERE QRY.PKCOLUMN = 0

--Select all PK from specifics tables
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
	AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
	AND KU.table_name IN (
		SELECT name FROM sys.objects WHERE type = 'U'
		AND  object_id IN (OBJECT_ID('USERS'), OBJECT_ID('PRODUCTS'), OBJECT_ID('CLIENTS'))
	);
	
--Select column from table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'TABLE_EXAMPLE'
AND COLUMN_NAME = N'THE_CLOUMN'

-- ALL INDEXES
-- https://stackoverflow.com/a/765892/5522115
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.is_included_column, ic.key_ordinal;
