

IF OBJECT_ID('tempdb..#DayThree') IS NOT NULL DROP TABLE #DayThree;

DECLARE @ParsedInputOne TABLE (LeftCompartment VARCHAR(100)
							,RightCompartment VARCHAR(100)
							)
DECLARE @ParsedInputTwo TABLE (GroupID INT
							,Rucksack VARCHAR(100)
							)

DECLARE @GroupID INT = 0
DECLARE @Sack VARCHAR(100)
DECLARE @Left VARCHAR(100)
DECLARE @Item CHAR(1)
DECLARE @Right VARCHAR(100)
DECLARE @Items TABLE (Letter CHAR(1))
DECLARE @Results TABLE (Letter CHAR(1)
						,[Priority] INT)

SELECT REPLACE(RTRIM(LTRIM(value)), CHAR(10), '') rucksack
INTO #DayThree
FROM OPENROWSET(BULK N'D:\Projects\Rust\Advent\elves_way\rucksack.txt', SINGLE_CLOB) AS Contents
CROSS APPLY string_split(BulkColumn, CHAR(13))


DELETE FROM #DayThree
WHERE rucksack = ''


INSERT INTO @ParsedInputOne
SELECT LEFT(rucksack, LEN(rucksack)/2), RIGHT(rucksack, LEN(rucksack)/2)
FROM #DayThree


WHILE (SELECT TOP 1 LeftCompartment FROM @ParsedInputOne) IS NOT NULL

BEGIN
	SELECT TOP 1 @Left = LeftCompartment, @Right = RightCompartment FROM @ParsedInputOne
	
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
	DELETE TOP (1) FROM @ParsedInputOne

END

SELECT
	'' SolutionOne
	,SUM([Priority]) TotalSum
FROM @Results

DELETE FROM @Results
DELETE FROM @Items


WHILE (SELECT TOP 1 rucksack FROM #DayThree) IS NOT NULL
BEGIN
	
	INSERT INTO @ParsedInputTwo
	SELECT TOP 3 @GroupID, rucksack
	FROM #DayThree

	DELETE TOP (3) FROM #DayThree

	SET @GroupID = @GroupID + 1

END

WHILE (SELECT TOP 1 rucksack FROM @ParsedInputTwo) IS NOT NULL
BEGIN
	SELECT TOP 1 @Sack = rucksack, @GroupID = GroupID FROM @ParsedInputTwo 
	
	WHILE LEN(@Sack) > 0
	BEGIN
		SET @Item = LEFT(@Sack, 1)

		IF (SELECT COUNT(*) FROM @ParsedInputTwo WHERE GroupID = @GroupID AND Rucksack LIKE '%'+ @Item + '%' COLLATE SQL_Latin1_General_CP1_CS_AS)  = 3
		BEGIN
			INSERT INTO @Items
			SELECT @Item
		END
		SET @Sack = RIGHT(@Sack, LEN(@Sack) - 1)
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

	DELETE TOP (3) FROM @ParsedInputTwo 

END

SELECT
	'' SolutionTwo
	,SUM([Priority]) TotalSum
FROM @Results

