--Seperate cew from JSON string

WITH Crew AS (
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

--Link directors to their movies
DirectorAndMovie AS (
	SELECT 
	d.name,
	m.title,
	m.revenue,
	m.budget
	FROM Directors d
	INNER JOIN movies_metadata m
	ON d.id = m.id
	WHERE m.revenue > 0
	AND m.budget > 0
),

--Get total directors revenue
TotalRevenue AS (
	SELECT 
	d.name,
	SUM(d.revenue) AS total_revenue
	FROM DirectorAndMovie d
GROUP BY d.name
)

--Get director with the most revenue
SELECT TOP 1 *
FROM TotalRevenue
ORDER BY total_revenue DESC;