

IF OBJECT_ID('tempdb..#DayOne') IS NOT NULL DROP TABLE #DayOne;

DECLARE @ParsedInput TABLE (Calories INT
							,Elf INT
							)

SELECT REPLACE(RTRIM(LTRIM(value)), CHAR(10), '') Calories
INTO #DayOne
FROM OPENROWSET(BULK N'D:\Projects\Rust\Advent\elves_way\elves.txt', SINGLE_CLOB) AS Contents
CROSS APPLY string_split(BulkColumn, CHAR(13))

DECLARE @Cal INT, @Total INT  = 0, @Elf INT = 1

WHILE (SELECT TOP 1 Calories FROM #DayOne) IS NOT NULL
BEGIN
	
	SELECT TOP 1 @Cal = CAST(RTRIM(LTRIM(Calories)) AS INT) FROM #DayOne

	IF ISNUMERIC(@Cal) = 1
	BEGIN
		SET @Total =  @Cal + @Total
	END
	
	IF @Cal = 0
	BEGIN
		INSERT INTO @ParsedInput
		SELECT @Total, @Elf 

		SET @Elf = @Elf + 1
		SET @Total = 0

	END

	DELETE TOP (1) FROM #DayOne
		
END

SELECT
	'' SolutionOne,
	MAX(Calories) MaxCal
FROM @ParsedInput


;WITH SolTwo AS (
SELECT TOP 3 Calories
FROM @ParsedInput
ORDER BY Calories DESC
)
SELECT
	'' SolutionTwo
	,SUM(Calories) TopCal
FROM SolTwo
