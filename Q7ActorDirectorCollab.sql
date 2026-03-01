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

--Count number of collaborations
CollabCount AS (
	SELECT 
	a.actor_name,
	a.director_name,
	COUNT(*) AS collab_count
	FROM ActorAndDirector a
	GROUP BY a.actor_name,
	a.director_name
)

--Most frequent actor/director combo
SELECT TOP 1 *
FROM CollabCount
WHERE actor_name != director_name
ORDER BY collab_count DESC;