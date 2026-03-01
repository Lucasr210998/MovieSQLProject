--Get original language of each movie

WITH Lang AS (
	SELECT 
	m.title,
	m.original_language,
	m.revenue,
	(YEAR(m.release_date) / 10) * 10 AS decade
	FROM movies_metadata_cleaned m
	WHERE m.revenue > 0
),

--Group them into language and decade
LangDate AS (
	SELECT 
	l.original_language,
	l.decade,
	AVG(l.revenue) AS avg_revenue
	FROM Lang l
	GROUP BY l.original_language,
	l.decade
),

--Ranking each lang and decade 
RankedData AS (
	SELECT 
	l.original_language,
	l.decade,
	l.avg_revenue,
	ROW_NUMBER() OVER(
		PARTITION BY l.decade
		ORDER BY l.avg_revenue DESC
	) AS ranking
	FROM LangDate l
)

--Get most profitable langeage of every decade
SELECT * 
FROM RankedData
ORDER BY decade ASC,
avg_revenue DESC
