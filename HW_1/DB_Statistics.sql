CREATE PROCEDURE Get_Statistics
	@p_DatabaseName NVARCHAR(MAX),
	@p_SchemaName NVARCHAR(MAX),
	@p_TableName NVARCHAR(MAX) 
AS
BEGIN

DECLARE @v_TableList TABLE ([Table_Catalog] varchar(100), 
							[Table_Schema] varchar(100), 
							[Table_Name] varchar(100), 
							[Column_Name] varchar(100), 
							[Data_Type] varchar(100)) ;

INSERT INTO @v_TableList 
SELECT [TABLE_CATALOG], 
	   [TABLE_SCHEMA], 
	   [TABLE_NAME], 
	   [COLUMN_NAME], 
	   iif([CHARACTER_MAXIMUM_LENGTH] is not null, concat([DATA_TYPE], '(', [CHARACTER_MAXIMUM_LENGTH], ')'), [DATA_TYPE])
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = @p_DatabaseName
AND TABLE_SCHEMA = @p_SchemaName
AND TABLE_NAME like @p_TableName

DECLARE @v_Query NVARCHAR(MAX) ;

WITH tbl_list AS 
(
		SELECT [Table_Catalog],	
			   [Table_Schema],		
			   [Table_Name], 
			   [Column_Name],
			   [Data_Type],
			   LEAD([Column_Name]) OVER(order by [Table_Name], [Column_Name]) as [lead_row]
		FROM @v_TableList
),
query_not_agg AS
(
		SELECT CASE WHEN [lead_row] is not null THEN 
						'SELECT DISTINCT ''' + Table_Catalog + ''' as [Database name], 
								''' + Table_Schema + ''' as [Schema name], 
								''' + Table_Name + ''' as [Table name], 
								[Table total row count] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' ),
								''' + Column_Name + ''' as [Column name],
								''' + Data_Type + ''' as [Data type],
								[Count of DISTINCT values] = (SELECT COUNT(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' ),
								[Count of NULL values] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' IS NULL),
								[Only UPPERCASE strings] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' = UPPER( ' + Column_Name + ' ) COLLATE SQL_Latin1_General_CP1_CS_AS),
								[Only LOWERCASE strings] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' = LOWER( ' + Column_Name + ' ) COLLATE SQL_Latin1_General_CP1_CS_AS),
								[Most used value] = CAST((SELECT TOP 1 ' + Column_Name + ' FROM (SELECT ' + Column_Name + ', COUNT(*) as [cnt] FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' GROUP BY ' + Column_Name + ') x Order by [cnt] desc) AS VARCHAR(50) ),
								[MIN value] = CAST((SELECT MIN(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ') AS VARCHAR(50) ),
								[MAX value] = CAST((SELECT MAX(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ') AS VARCHAR(50) )
						 FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' UNION ALL ' 
					ELSE 
						'SELECT DISTINCT ''' + Table_Catalog + ''' as [Database name], 
								''' + Table_Schema + ''' as [Schema name], 
								''' + Table_Name + ''' as [Table name], 
								[Table total row count] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + '),
								''' + Column_Name + ''' as [Column name],
								''' + Data_Type + ''' as [Data type],
								[Count of DISTINCT values] = (SELECT COUNT(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' ),
								[Count of NULL values] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' IS NULL),
								[Only UPPERCASE strings] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' = UPPER( ' + Column_Name + ' ) COLLATE SQL_Latin1_General_CP1_CS_AS),
								[Only LOWERCASE strings] = (SELECT COUNT(*) FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' WHERE ' + Column_Name + ' = LOWER( ' + Column_Name + ' ) COLLATE SQL_Latin1_General_CP1_CS_AS),
								[Most used value] = CAST((SELECT TOP 1 ' + Column_Name + ' FROM (SELECT ' + Column_Name + ', COUNT(*) as [cnt] FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' GROUP BY ' + Column_Name + ') x Order by [cnt] desc) AS VARCHAR(50) ),
								[MIN value] = CAST((SELECT MIN(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ') AS VARCHAR(50) ),
								[MAX value] = CAST((SELECT MAX(' + Column_Name + ') FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ') AS VARCHAR(50) )
						 FROM ' + Table_catalog + '.' + Table_Schema + '.' + Table_Name + ' ' 
			   END as [query_text]
		FROM tbl_list
)


SELECT @v_Query = STRING_AGG(CAST([query_text] as nvarchar(MAX)), ' ' ) WITHIN GROUP (ORDER BY [query_text])
FROM query_not_agg ;

EXEC SP_EXECUTESQL @v_Query ;

END
GO


/* There are examples below for verifying:  */

 --EXEC Get_Statistics 'TRN', 'hr', '%'
 --EXEC Get_Statistics 'TRN', 'hr', 'departments'
