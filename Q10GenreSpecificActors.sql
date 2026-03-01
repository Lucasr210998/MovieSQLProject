--Get names of actors

WITH ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Seperate genres of every movie
Genres AS (
	SELECT
	m.title,
	JSON_VALUE(genre.value, '$.name') as genre,
	m.revenue,
	m.id
	FROM movies_metadata_cleaned m
	CROSS APPLY OPENJSON(genres) as genre
),

--Group genres and actors together
GenreActor AS (
	SELECT *
	FROM Genres g
	INNER JOIN ActorName a
	ON g.id = a.actor_id
),

--Get count of each actor and genre
GenreActorCombined AS (
	SELECT 
	g.genre,
	g.actor_name,
	COUNT(*) AS count,
	SUM(g.revenue) as revenue
	FROM GenreActor g
	GROUP BY g.genre,
	g.actor_name
)

--Ordered by revenue
SELECT *
FROM GenreActorCombined
WHERE revenue != 0
ORDER BY revenue DESC;