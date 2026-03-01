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

--Link pairs to their movies
MovieLinks AS (
	SELECT 
	m.title,
	a.actor_name,
	a.director_name,
	m.revenue
	FROM ActorAndDirector a
	INNER JOIN movies_metadata m
	ON a.id = m.id
),

--Get revenue of each pair
TotalRevenue AS (
	SELECT 
	m.actor_name,
	m.director_name,
	SUM(m.revenue) AS total_revenue
	FROM MovieLinks m
	GROUP BY m.actor_name,
	m.director_name
)

--Actor director pair with the most revenue
SELECT TOP 1 *
FROM TotalRevenue
ORDER BY total_revenue DESC;