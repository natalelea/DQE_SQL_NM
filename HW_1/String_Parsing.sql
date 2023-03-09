WITH json_string AS
	(
		SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' [str]
	),

	some_transformations1 AS 
	(
		SELECT replace(replace([str], '[', ''), ']', '') as [cleaned_data]
		FROM json_string
	),

	some_transformations2 AS 
	(
		SELECT LEFT([cleaned_data], CHARINDEX('}', [cleaned_data])) as [element],
			   STUFF([cleaned_data], 1, CHARINDEX('}', [cleaned_data]) + 2, '') as [other]
		FROM some_transformations1

			UNION ALL

		SELECT LEFT([other], CHARINDEX('}', [other])),
			   STUFF([other], 1, CHARINDEX('}', [other]) + 2, '')
		FROM some_transformations2

		WHERE [other] > ''
	),

	some_transformations3 AS
	(
		SELECT SUBSTRING([element], CHARINDEX(': ', [element]) + 3, (CHARINDEX('", ', [element]) - CHARINDEX(': ', [element])) - 3 ) as [employee_id],
			   STUFF([element], 1, CHARINDEX(', "', [element]), '') as [rest_fields]
		FROM some_transformations2
	),

	some_transformations4 AS
	(
		SELECT [employee_id],
			   SUBSTRING([rest_fields], CHARINDEX(': ', [rest_fields]) + 3, (CHARINDEX('", ', [rest_fields]) - CHARINDEX(': ', [rest_fields])) - 3 ) as [department_id]
		FROM some_transformations3
	),

	parsed_data AS
	(
		SELECT cast([employee_id] as BIGINT) as [employee_id],
			   iif([department_id]= '', NULL, cast([department_id] as INT)) as [department_id]
		FROM some_transformations4
	)
	

SELECT [employee_id], [department_id]
FROM parsed_data ;

