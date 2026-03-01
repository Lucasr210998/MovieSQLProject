--Split each genre from their movies

WITH Genres AS (
	SELECT 
	m.title,
	m.revenue,
	JSON_VALUE(gen.value, '$.name') AS genre
	FROM movies_metadata_cleaned m
	CROSS APPLY OPENJSON(genres) AS gen
),

--Group each genre
GenreGrouped AS (
	SELECT 
	g.genre,
	SUM(g.revenue) AS total_revenue,
	COUNT(*) AS movie_count
	FROM Genres g
	GROUP BY g.genre
)

--Revenue of genres that appear at least 5 times
SELECT *
FROM GenreGrouped
WHERE movie_count > 5
ORDER BY total_revenue DESC;