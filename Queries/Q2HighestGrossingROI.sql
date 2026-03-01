--Extract actors from JSON string

WITH ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Find RIO of each movie
MovieROI AS (
	SELECT 
	a.actor_name,
	m.title,
	m.id,
	(m.revenue - m.budget) * 1.0 - m.budget AS ROI
	FROM movies_metadata m
	INNER JOIN ActorName a
	ON a.actor_id = m.id
	WHERE m.budget > 0
	AND m.revenue > 0
),

--Get total and average roi of each actor
TotalROI AS (
	SELECT 
	m.actor_name,
	SUM(m.ROI) AS total_roi,
	AVG(m.ROI) AS avg_roi,
	COUNT(*) AS movie_count
	FROM MovieROI m
	GROUP BY m.actor_name
)

--Find Actor with most ROI
SELECT TOP 1 *
FROM TotalROI
ORDER BY total_roi DESC