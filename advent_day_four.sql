

IF OBJECT_ID('tempdb..#DayFour') IS NOT NULL DROP TABLE #DayFour;


DECLARE @ParsedInput TABLE (
					LeftAssignments VARCHAR(100)
					,RightAssignments VARCHAR(100)
					)

SELECT REPLACE(RTRIM(LTRIM(value)), CHAR(10), '') assignments
INTO #DayFour
FROM OPENROWSET(BULK N'D:\Projects\Rust\Advent\elves_way\cleanup.txt', SINGLE_CLOB) AS Contents
CROSS APPLY string_split(BulkColumn, CHAR(13))

DELETE FROM #DayFour
WHERE assignments = ''

INSERT INTO @ParsedInput
SELECT LEFT(assignments,CHARINDEX(',', assignments)-1)
		,RIGHT(assignments,LEN(assignments)-CHARINDEX(',', assignments))
FROM #DayFour

;WITH OverlappingOne AS (
SELECT 
	LeftAssignments
	,RightAssignments
	,CASE
		WHEN (LEFT(RightAssignments,CHARINDEX('-', RightAssignments)-1)
				= LEFT(LeftAssignments,CHARINDEX('-', LeftAssignments)-1))
				AND 
				(RIGHT(RightAssignments,LEN(RightAssignments)-CHARINDEX('-', RightAssignments))
				= RIGHT(LeftAssignments,LEN(LeftAssignments)-CHARINDEX('-', LeftAssignments)))
		THEN 'Overlaps'
		WHEN (CAST(LEFT(RightAssignments,CHARINDEX('-', RightAssignments)-1) AS INT)
				BETWEEN CAST(LEFT(LeftAssignments,CHARINDEX('-', LeftAssignments)-1) AS INT)
				AND CAST(RIGHT(LeftAssignments,LEN(LeftAssignments)-CHARINDEX('-', LeftAssignments))AS INT))
				AND 
				(CAST(RIGHT(RightAssignments,LEN(RightAssignments)-CHARINDEX('-', RightAssignments)) AS INT)
				BETWEEN CAST(LEFT(LeftAssignments,CHARINDEX('-', LeftAssignments)-1) AS INT)
				AND CAST(RIGHT(LeftAssignments,LEN(LeftAssignments)-CHARINDEX('-', LeftAssignments)) AS INT)
				)
		THEN 'Overlaps'
		WHEN (CAST(LEFT(LeftAssignments,CHARINDEX('-', LeftAssignments)-1) AS INT)
				BETWEEN CAST(LEFT(RightAssignments,CHARINDEX('-', RightAssignments)-1) AS INT)
				AND CAST(RIGHT(RightAssignments,LEN(RightAssignments)-CHARINDEX('-', RightAssignments)) AS INT)
				)
				AND 
				(CAST(RIGHT(LeftAssignments,LEN(LeftAssignments)-CHARINDEX('-', LeftAssignments)) AS INT)
				BETWEEN CAST(LEFT(RightAssignments,CHARINDEX('-', RightAssignments)-1) AS INT)
				AND CAST(RIGHT(RightAssignments,LEN(RightAssignments)-CHARINDEX('-', RightAssignments)) AS INT))
		THEN 'Overlaps'
		END Results

FROM @ParsedInput )
SELECT
	'' SolutionOne
	,COUNT(*) TotalCount
FROM OverlappingOne
WHERE Results IS NOT NULL


