--Get ratings of each movies

WITH MovieRatings AS (
	SELECT 
	r.movieId,
	COUNT(*) AS rating_count
	FROM ratings r
	GROUP BY r.movieId
),


--Link ratings to their movies
MovieRatingLink AS (
	SELECT 
	mc.title,
	mc.id,
	mr.rating_count,
	mc.tagline,
	c.cast
	FROM movies_metadata_cleaned mc
	LEFT JOIN MovieRatings mr
	ON mc.id = mr.movieId
	LEFT JOIN credits c
	ON c.id = mr.movieId
)

--Final percentage
SELECT 
ROUND(
100.0 * SUM(
	CASE
	WHEN rating_count IS NOT NULL
	AND tagline IS NOT NULL
	AND cast IS NOT NULL
	THEN 1 ELSE 0
	END
) / COUNT(*),2) AS percent_with_no_nulls
FROM MovieRatingLink



