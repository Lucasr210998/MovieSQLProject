WITH Ratings AS (
	SELECT 
	ROUND(AVG(r.rating), 1) AS avg_rating,
	r.movieId,
	COUNT(*) AS rating_count
	FROM ratings_small r
	GROUP BY r.movieId
),

--Ratings and movies joined together
RatingWithMovie AS (
	SELECT 
	r.avg_rating,
	r.rating_count,
	m.title,
	m.revenue
	FROM Ratings r
	INNER JOIN movies_metadata_cleaned m
	ON m.id = r.movieId
)

--Lowest ratings with most revenue
SELECT * 
FROM RatingWithMovie
WHERE revenue > 0
ORDER BY avg_rating ASC,
revenue DESC
