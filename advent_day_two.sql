IF OBJECT_ID('tempdb..#DayTwo') IS NOT NULL DROP TABLE #DayTwo;

DECLARE @Points TABLE (
						Letter CHAR(1)
						,Score INT
					)
DECLARE @Guide TABLE (
						LeftHand CHAR(1)
						,RightHand CHAR(1)
						,SEQ INT

					)
DECLARE @MyRules TABLE (
						Hand CHAR(1)
						,Item VARCHAR(55)
					)

DECLARE @ElfRules TABLE (
						Predict CHAR(1)
						,Points INT
					)

DECLARE @Wins TABLE (
						Item VARCHAR(55)
						,Beats VARCHAR(55)
						,Points INT
					)


SELECT REPLACE(RTRIM(LTRIM(value)), CHAR(10), '') Turn, ROW_NUMBER() OVER( ORDER BY (SELECT NULL))SEQ
INTO #DayTwo
FROM OPENROWSET(BULK N'D:\Projects\Rust\Advent\elves_way\guide.txt', SINGLE_CLOB) AS Contents
CROSS APPLY string_split(BulkColumn, CHAR(13))

INSERT INTO @Guide
SELECT LEFT(Turn, 1),RIGHT(Turn,1) , SEQ
FROM #DayTwo

INSERT INTO @Points
SELECT 'A', 1
INSERT INTO @Points
SELECT 'B', 2
INSERT INTO @Points
SELECT 'C', 3
INSERT INTO @Points
SELECT 'X', 1
INSERT INTO @Points
SELECT 'Y', 2
INSERT INTO @Points
SELECT 'Z', 3

INSERT INTO @Wins
SELECT 'Rock', 'Scissors', 3
INSERT INTO @Wins
SELECT 'Paper', 'Rock', 3
INSERT INTO @Wins
SELECT 'Scissors', 'Paper', 3

INSERT INTO @MyRules
SELECT 'A', 'Rock'
INSERT INTO @MyRules
SELECT 'B', 'Paper'
INSERT INTO @MyRules
SELECT 'C', 'Scissors'
INSERT INTO @MyRules
SELECT 'X', 'Rock'
INSERT INTO @MyRules
SELECT 'Y', 'Paper'
INSERT INTO @MyRules
SELECT 'Z', 'Scissors'



;WITH ScoreBoardOne AS (
SELECT 
	g.LeftHand
	,g.RightHand
	,CASE 
		WHEN w1.Item = w2.Beats THEN 6 + p2.Score 
		WHEN w1.Beats = w2.item THEN 0 + p2.Score
		WHEN w1.item  = w2.item THEN 3 + p2.Score
	END MatchPoints
FROM @Guide g
	JOIN @Points p1
		ON p1.Letter = g.LeftHand
	JOIN @Points p2
		ON p2.Letter = g.RightHand
	JOIN @MyRules r1 
		ON r1.Hand = g.LeftHand 
	JOIN @MyRules r2
		ON r2.Hand = g.RightHand
	JOIN @Wins w1
		ON w1.Item = r1.Item
	JOIN @Wins w2
		ON w2.Item = r2.Item
)
SELECT
	'' SolutionOne
	,SUM(MatchPoints) TotalPoints
FROM ScoreBoardOne


INSERT INTO @ElfRules
SELECT 'X', 0
INSERT INTO @ElfRules
SELECT 'Y', 3
INSERT INTO @ElfRules
SELECT 'Z', 6


;WITH OutCome AS (

SELECT g.LeftHand
		,CASE	
			WHEN er.Points = 3 THEN g.LeftHand
			WHEN er.Points = 0 THEN mr1.Hand
			WHEN er.Points = 6 THEN (SELECT Hand FROM @MyRules WHERE Hand NOT IN ('X', 'Y', 'Z') AND hand != g.LeftHand AND hand != mr1.Hand)
		END MyHand
		,er.Points
FROM @Guide g
	JOIN @ElfRules er
		ON er.Predict = g.RightHand
	JOIN @MyRules mr
		ON mr.Hand = g.LeftHand 
	JOIN @Wins w
		ON w.Item = mr.Item
	JOIN @MyRules mr1
		ON mr1.Item = w.Beats
WHERE mr1.Hand NOT IN ('X', 'Y', 'Z')
	
), ScoreBoardTwo AS (
SELECT oc.LeftHand
		,MyHand
		,oc.Points + p.Score  MatchPoints
FROM OutCome oc
JOIN @Points p
	ON oc.MyHand = p.Letter

)
SELECT 
	'' SolutionTwo
	,SUM(MatchPoints) TotalPoints
FROM ScoreBoardTwo
