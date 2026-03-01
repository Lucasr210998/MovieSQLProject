--Every movie by decade with revenue

WITH Decade AS (
	SELECT 
	m.title,
	m.revenue,
	(YEAR(m.release_date) / 10) * 10 AS decade
	FROM movies_metadata_cleaned m
	WHERE m.revenue > 0
),

--Ranking each movie DENSE_RANK
DenseRankDecade AS (
	SELECT 
	d.title,
	d.decade,
	d.revenue,
	DENSE_RANK() OVER(
		PARTITION BY d.decade
		ORDER BY d.revenue DESC
	) AS Ranking
	FROM Decade d
)

--Top 10 of every decade
SELECT * 
FROM DenseRankDecade
WHERE Ranking < 11
AND decade IS NOT NULL;