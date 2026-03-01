--Split each genre from their movies

WITH Genres AS (
	SELECT 
	m.title,
	m.revenue,
	JSON_VALUE(gen.value, '$.name') AS genre,
	(YEAR(m.release_date) / 10) * 10 AS decade
	FROM movies_metadata_cleaned m
	CROSS APPLY OPENJSON(genres) AS gen
),

--Group genre and decade
GenreAndDecade AS (
	SELECT 
	g.genre,
	SUM(g.revenue) AS total_revenue,
	g.decade
	FROM Genres g
	GROUP BY g.genre,
	g.decade
),

--Ranking each genre within the decade
GenreRanking AS (
	SELECT 
	g.genre,
	g.total_revenue,
	g.decade,
	RANK() OVER(
		PARTITION BY g.decade
		ORDER BY g.total_revenue DESC
	) AS ranking
	FROM GenreAndDecade g
	WHERE g.total_revenue > 0
)

--Genre with most revenue of each decade
SELECT * 
FROM GenreRanking
WHERE ranking = 1
AND decade IS NOT NULL;
