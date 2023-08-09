

IF OBJECT_ID('tempdb..#DayThree') IS NOT NULL DROP TABLE #DayThree;

DECLARE @ParsedInput TABLE (LeftCompartment VARCHAR(100)
							,RightCompartment VARCHAR(100)
							)

SELECT REPLACE(RTRIM(LTRIM(value)), CHAR(10), '') rucksack
INTO #DayThree
FROM OPENROWSET(BULK N'D:\Projects\Rust\Advent\elves_way\rucksack.txt', SINGLE_CLOB) AS Contents
CROSS APPLY string_split(BulkColumn, CHAR(13))

INSERT INTO @ParsedInput
SELECT LEFT(rucksack, LEN(rucksack)/2), RIGHT(rucksack, LEN(rucksack)/2)
FROM #DayThree
WHERE rucksack != ''

DECLARE @Left VARCHAR(100)
DECLARE @Item CHAR(1)
DECLARE @Right VARCHAR(100)
DECLARE @Items TABLE (Letter CHAR(1))
DECLARE @Results TABLE (Letter CHAR(1)
						,[Priority] INT)


WHILE (SELECT TOP 1 LeftCompartment FROM @ParsedInput) IS NOT NULL

BEGIN
	SELECT TOP 1 @Left = LeftCompartment, @Right = RightCompartment FROM @ParsedInput
	
	WHILE LEN(@Left) > 0
	BEGIN
		SET @Item = LEFT(@Left, 1)

		IF (SELECT * FROM (SELECT @Right R) T WHERE r LIKE '%' + @Item + '%' COLLATE SQL_Latin1_General_CP1_CS_AS)   IS NOT NULL
		BEGIN
			INSERT INTO @Items
			SELECT @Item
		END
		SET @Left = RIGHT(@Left, LEN(@Left) - 1)
	END

	INSERT INTO @Results
	SELECT 
		DISTINCT 
			Letter
			,CASE	
				WHEN Letter = LOWER(Letter) COLLATE SQL_Latin1_General_CP1_CS_AS THEN 1 + ASCII(Letter) - ASCII('a')
				ELSE 27 + ASCII(Letter) - ASCII('A')
			END [Priority]
	FROM @Items


	DELETE FROM @Items
	DELETE TOP (1) FROM @ParsedInput

END

SELECT
	'' SolutionOne
	,SUM([Priority]) TotalSum
FROM @Results




