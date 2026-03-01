--Extract actors from JSON string

WITH ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Link actors to their movies
ActorAndMovie AS (
	SELECT 
	a.actor_name,
	a.actor_id,
	m.original_title,
	m.budget,
	m.revenue
	FROM ActorName a
	INNER JOIN movies_metadata m
	ON a.actor_id = m.id
),

--Get number of movies and ROI
MovieROI AS (
	SELECT 
	a.actor_name,
	(a.revenue - a.budget) * 1.0 - a.budget AS ROI
	FROM ActorAndMovie a
	WHERE a.budget > 0
	AND a.revenue > 0
),

--Actors with their ROI and movie count
MovieCount AS (
	SELECT 
	m.actor_name,
	AVG(m.ROI) AS avg_roi,
	SUM(m.ROI) AS total_roi,
	COUNT(*) AS movie_count
	FROM MovieROI m
	GROUP BY m.actor_name
)

--Top actor with less than 10 movies
SELECT TOP 1 *
FROM MovieCount
WHERE movie_count < 11
ORDER BY total_roi DESC;
