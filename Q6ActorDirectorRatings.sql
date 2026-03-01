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

--Link actors and directors with their ratings
ActorDirectorRatings AS (
	SELECT
	a.actor_name,
	a.director_name,
	m.title,
	r.rating
	FROM ActorAndDirector a
	INNER JOIN movies_metadata m
	ON a.id = m.id
	INNER JOIN ratings r
	ON r.movieId = a.id
),

--Get average rating of each actor/director combo
AverageRating AS (
	SELECT 
	a.actor_name,
	a.director_name,
	AVG(a.rating) AS avg_rating,
	COUNT(*) AS rating_count
	FROM ActorDirectorRatings a
	GROUP BY a.actor_name, 
	a.director_name
)

--Actor Director combo with highest rating
SELECT TOP 1 
a.actor_name,
a.director_name,
ROUND(a.avg_rating, 2) AS avg_rating
FROM AverageRating a
WHERE rating_count > 49;