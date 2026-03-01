--Group ratings together

WITH Ratings AS (
	SELECT 
	ROUND(AVG(r.rating), 1) AS avg_rating,
	r.movieId,
	COUNT(*) AS rating_count
	FROM ratings_small r
	GROUP BY r.movieId
),

--Get ratings with more than 99 and score of 4 or higher
GoodRatings AS (
	SELECT *
	FROM Ratings
	WHERE rating_count > 99
	AND avg_rating > 3.9
),

--Join ratings to the matching movie
MovieWithRating AS (
SELECT 
m.title,
g.rating_count,
g.avg_rating,
m.revenue
FROM GoodRatings g
INNER JOIN movies_metadata_cleaned m
ON g.movieId = m.id
)

--Movie that generated the highest revenue
SELECT TOP 1 *
FROM MovieWithRating
ORDER BY revenue DESC