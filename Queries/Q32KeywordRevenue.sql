
--Creating procedure to get number and average revenue of a specific keyword

CREATE OR ALTER PROCEDURE dbo.KeywordRevenue
	@phrase NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
	COUNT(*) AS movie_count,
	AVG(revenue) AS avg_revenue
	FROM movies_metadata_cleaned mc
	WHERE tagline LIKE '%' + @phrase + '%'
	OR overview LIKE '%' + @phrase + '%'

END;
GO

EXEC dbo.KeywordRevenue @phrase = 'wood'
