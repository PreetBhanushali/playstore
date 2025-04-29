-- Your task is to identify the most promising categories (TOP 5) for 
-- launching new free apps based on their average ratings.

SELECT
	Category,
	ROUND(avg(rating),2) as avg_rating
FROM
	playstore
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--  your objective is to pinpoint the three categories that generate the 
--  most revenue from paid apps. This calculation is based on the product 
--  of the app price and its number of installations.

SELECT
	Category,
	SUM(Price*Installs) as total_revenue
FROM
	playstore
WHERE 
	Type = 'Paid'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- you're tasked with calculating the percentage of games within
--  each category. This information will help the company understand
--  the distribution of gaming apps across different categories.

SELECT
	Category,
	(ROUND(((ROUND(COUNT(App)*100,3))/(SELECT COUNT(App) FROM playstore)),3))||'%' AS percentage_of_apps
FROM
	playstore
GROUP BY 1
ORDER BY 2 ASC;


-- As a data analyst at a mobile app-focused market research 
-- firm you’ll recommend whether the company should develop paid 
--  free apps for each category based on the ratings of that category.
SELECT 
	Category,
	CASE
		WHEN avg_rating<next_avg_rating THEN 'Paid'
		WHEN Next_avg_rating IS NULL THEN Type
		ELSE 'Free'
	END as Type_Of_App_To_Make
FROM
(
	WITH cte as
	(
	SELECT
		Category,
		Type,
		ROUND(AVG(Rating),2) as avg_rating,
		COUNT(Category) OVER(PARTITION BY Category) as num_of_times,
		LEAD(ROUND(AVG(Rating),2)) OVER(PARTITION BY Category) as Next_avg_rating
	FROM
		playstore
	GROUP BY 1,2
	)
	SELECT
		Category,Type,avg_rating,next_avg_rating
	FROM
		cte
	WHERE 
		(num_of_times = 2 AND next_avg_rating IS NOT NULL)
		OR
		num_of_times = 1
);


-- he/she assigned you the task to clean the genres column and make two genres out of it, 
-- rows that have only one genre will have other column as blank.
UPDATE playstore 
SET genre2=(
SELECT
-- 	SUBSTR(Genres, 1, INSTR(Genres, ';') - 1) AS genre1
    SUBSTR(Genres, INSTR(Genres, ';') + 1) AS genre2
FROM
	playstore b
where playstore.App = b.App	
);

ALTER TABLE playstore
DROP COLUMN Genres;



-- Your senior manager wants to know which apps are not performing as par in their particular category, 
-- however he is not interested in handling too many files or list for every category and
-- he/she assigned  you with a task of creating a dynamic tool where 
-- he/she  can input a category of apps he/she  interested in  and your tool then provides real-time 
-- feedback by displaying apps within that category that have ratings lower than the average rating for
-- that specific category.



CREATE PROCEDURE get_apps_below_avg_rating(IN p_category VARCHAR(255))
BEGIN
    -- Declare a variable to store the average price of the category
    DECLARE avg_rating DECIMAL(10, 2);

    -- Calculate the average price for the given category
    SELECT AVG(Rating) INTO avg_rating
    FROM playstore
    WHERE category = p_category;

    -- Select products whose price is less than the average price
    SELECT App,Rating,category
    FROM playstore
    WHERE category = p_category
    AND rating < avg_rating;
END;


	
	







