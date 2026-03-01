--Get decade of each movie

WITH Decade AS (
	SELECT 
	m.title,
	(YEAR(m.release_date) / 10) * 10 AS decade,
	m.id,
	m.revenue
	FROM movies_metadata_cleaned m
	WHERE m.revenue > 0
),

--Get names of actors
ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Combine actors and decades
ActorAndDecade AS (
	SELECT *
	FROM Decade d
	INNER JOIN ActorName a
	ON d.id = a.actor_id
),

--Group together
GroupedData AS (
	SELECT 
	a.actor_name,
	a.decade,
	SUM(revenue) AS revenue
	FROM ActorAndDecade a
	GROUP BY a.actor_name,
	a.decade
),

--Rank every actor
Ranking AS (
	SELECT 
	g.actor_name,
	g.decade,
	ROW_NUMBER() OVER(
		PARTITION BY g.decade
		ORDER BY g.revenue DESC
	) AS Rank,
	g.revenue
	FROM GroupedData g
	--ORDER BY g.decade ASC, g.revenue DESC
)

--Top 3 of every decade
SELECT *
FROM Ranking
WHERE Rank <= 3
ORDER BY decade ASC,
revenue DESC;