--Extract actors from JSON string

WITH ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Seperate cew from JSON string
Crew AS (
	SELECT 
	JSON_VALUE(crew.value, '$.name') AS name,
	JSON_VALUE(crew.value, '$.job') AS role,
	c.id
	FROM credits c
	CROSS APPLY OPENJSON(crew) as crew
),

--Seperate directors
Directors AS (
	SELECT *
	FROM Crew
	WHERE role = 'Director'
),

--Pair actors and directors that worked together
ActorAndDirector AS (
	SELECT 
	d.name AS director_name,
	a.actor_name,
	d.id
	FROM ActorName a
	INNER JOIN Directors d
	ON a.actor_id = d.id
),

--Ranking each actor per director
PairRanking AS (
	SELECT 
	a.director_name,
	a.actor_name,
	COUNT(*) AS apperances,
	ROW_NUMBER() OVER (
		PARTITION BY a.director_name
		ORDER BY COUNT(*) DESC
	) AS ranking
	FROM ActorAndDirector a
	GROUP BY a.director_name,
	a.actor_name
)

--Highest ranking actor per director
SELECT *
FROM PairRanking
WHERE ranking = 1
ORDER BY apperances DESC;