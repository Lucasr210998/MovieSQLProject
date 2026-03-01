--Extract actors from JSON string

WITH ActorName AS (
	SELECT 
	JSON_VALUE(actor.value, '$.name') AS actor_name,
	c.id AS actor_id
	FROM credits c
	CROSS APPLY OPENJSON(cast) as actor
),

--Join actors to their movies
ActorAndMovie AS (
	SELECT 
	m.original_title,
	m.budget,
	m.revenue,
	a.actor_name,
	m.id
	FROM movies_metadata m
	INNER JOIN ActorName a
	ON a.actor_id = m.id
),

--Group Each actor for total revenue
IndividualActor AS (
	SELECT 
	a.actor_name,
	SUM(a.revenue) AS total_revenue
	FROM ActorAndMovie a
	GROUP BY a.actor_name
)

--Find highest grossing actor
SELECT TOP 1 *
FROM IndividualActor
ORDER BY total_revenue DESC;