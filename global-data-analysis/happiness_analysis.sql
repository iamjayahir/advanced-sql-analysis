-- Connecting to Database 
USE advanced_sql;

-- SHowing all the tables in the database
SHOW TABLES;


-- Apply function to two columns

SELECT year, country,happiness_score,
	UPPER(country) AS country_upper,
    ROUND(happiness_score,1) AS hs_rounded
FROM happiness_scores;

-- Creating bins
WITH pm AS(
	SELECT country,population,
		FLOOR(population/1000000) AS pop_m-- floor() function convert value into nearest int 
		
	FROM country_stats
)
SELECT pop_m,count(country) As num_countries
FROM pm
GROUP by pop_m
ORDER BY pop_m;

-- CASE Statements 
SELECT student_name, grade_level,
CASE grade_level
		WHEN 9 THEN 'Freshman'
		WHEN 10 THEN "Sophomore"
		WHEN 11 THEN 'junior'
		ELSE 'Senior' 
END student_class
FROM students;

-- Basic Join
SELECT *
FROM happiness_scores;

SELECT *
FROM country_stats;

SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    cs.continent
FROM happiness_scores hs
INNER JOIN country_stats cs
ON cs.country = hs.country ;

-- INNER JOIN

SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    cs.continent
FROM happiness_scores hs
JOIN country_stats cs
ON cs.country = hs.country
WHERE cs.country IS NULL;

-- LEFT JOIN
SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    cs.continent,
    cs.country
FROM happiness_scores hs
LEFT JOIN country_stats cs
ON cs.country = hs.country
WHERE cs.country is null;

-- Right Join
SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    cs.continent,
    cs.country
FROM happiness_scores hs
RIGHT JOIN country_stats cs
ON cs.country = hs.country
WHERE hs.country IS NULL;

-- Q 1.1 List the all the countries which are not in the country_stats but present in happiness_score table

SELECT 
	DISTINCT hs.country
FROM happiness_scores hs
LEFT JOIN country_stats cs
ON cs.country = hs.country
WHERE cs.country IS NULL;

-- JOIN using multiple conditions 
SELECT * 
FROM happiness_scores
LIMIT  5;

SELECT * 
FROM inflation_rates
LIMIT  5;

SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    ir.inflation_rate
FROM happiness_scores hs
JOIN inflation_rates ir
ON ir.year = hs.year
AND ir.country_name = hs.country;
/*
Before joining with only one column  based on country only it is returnning 28707 rows.
After join with both column year and country it is retuuning 179 rows
SELECT 
	count(*)
FROM happiness_scores hs
JOIN inflation_rates ir
ON ir.year = hs.year 
AND ir.country_name = hs.country;

*/

-- SELF JOIN

CREATE TABLE IF NOT EXISTS employees (
employee_id INT PRIMARY KEY,
employee_name VARCHAR(50),
salary int,
manager_id INT
);

UPDATE  employees
SET salary = 85000
WHERE employee_id = 4;

SELECT * from employees;

-- Find the employees with same salary

SELECT 
	e1.employee_name,
    e1.salary,
    e2.employee_name,
    e2.salary
FROM employees e1
JOIN employees e2
ON e1.salary = e2.salary
WHERE e1.employee_id > e2.employee_id; 

-- Employee with greater salary
SELECT 
	e1.employee_name,
    e1.salary,
    e2.employee_name,
    e2.salary
FROM employees e1
JOIN employees e2
ON e1.salary > e2.salary;

-- Employees And their Managers

SELECT 
	e1.employee_id,
    e1.employee_name,
    e1.manager_id,
    e2.employee_name AS manager_name
FROM employees e1 
LEFT JOIN employees e2
ON e1.manager_id = e2.employee_id;

-- Union with different column name
SELECT *
FROM happiness_scores;

SELECT * 
FROM happiness_scores_current; -- Data for current year 2024

SELECT 
	DISTINCT(year)
FROM happiness_scores;

SELECT 
	year,
    country,
    happiness_score
FROM happiness_scores
UNION
SELECT 
	2024,
    country,
    ladder_score
FROM happiness_scores_current;

-- Return the diffrence between each country's happiness score and the average 

SELECT
	year,
	country,
    happiness_score,
    happiness_score - (SELECT AVG(happiness_score) FROM happiness_scores) AS diff_from_avg
FROM happiness_scores;

/*
 Return a country happiness score for the year as well as the average hapiness 
 score for the country across year */

SELECT 
		hs.year,
        hs.country,
        hs.happiness_score,
        country_hs.avg_hs_by_country
FROM happiness_scores hs
LEFT JOIN 
		( SELECT country,AVG(happiness_score) AS avg_hs_by_country
		  FROM happiness_scores
		  GROUP BY country) AS country_hs 
ON hs.country = country_hs.country;

-- For the USA happiness score each year and avg happiness score for the country across all the year.

SELECT 
		hs.year,
        hs.country,
        hs.happiness_score,
        country_hs.avg_hs_by_country
FROM happiness_scores hs
LEFT JOIN 
		( SELECT country,AVG(happiness_score) AS avg_hs_by_country
		  FROM happiness_scores
		  GROUP BY country) AS country_hs 
ON hs.country = country_hs.country
WHERE hs.country = 'United States';

/* Return year where the happiness score is whole point greater than the 
   the country's average happiness score by combiding current year data (2024) also*/
SELECT 
	DISTINCT year
FROM happiness_scores;

-- 2024 data 
SELECT *
FROM happiness_scores_current;


SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024, country, ladder_score  FROM happiness_scores_current;

SELECT 
		hs.year,
        hs.country,
        hs.happiness_score,
        country_hs.avg_hs_by_country
FROM (SELECT year, country, happiness_score FROM happiness_scores
	  UNION ALL
	SELECT 2024, country, ladder_score  FROM happiness_scores_current) hs
LEFT JOIN 
		( SELECT country,AVG(happiness_score) AS avg_hs_by_country
		  FROM happiness_scores
		  GROUP BY country) AS country_hs 
ON hs.country = country_hs.country
WHERE hs.happiness_score > country_hs.avg_hs_by_country +1;


-- Return regions with above average happiness score

SELECT 
	AVG(happiness_score)
FROM 
	happiness_scores;
    
SELECT *
FROM happiness_scores
WHERE happiness_score > (SELECT  AVG(happiness_score) FROM  happiness_scores);

SELECT 
	region,
    avg(happiness_score) as avg_hs
FROM happiness_scores
GROUP BY
	region
Having avg(happiness_score) >(SELECT  AVG(happiness_score) FROM  happiness_scores);

-- Scores that are greter than ANY 2024 scores
select count(*) from happiness_scores;
SELECT *
FROM happiness_scores
WHERE happiness_score > ANY(SELECT ladder_score FROM happiness_scores_current);

-- Scores that are greter than ALL 2024 scores
select count(*) from happiness_scores;
SELECT *
FROM happiness_scores
WHERE happiness_score > ALL (SELECT ladder_score FROM happiness_scores_current);

/* return happiness score of countries 
   that exist in the inflation rates table */
SELECT * 
FROM happiness_scores hs
WHERE EXISTS (
	SELECT i.country_name 
    FROM inflation_rates i
    WHERE i.country_name = hs.country);
    
-- Alterntive to EXISTS is INNER join

SELECT * 
FROM happiness_scores hs
INNER JOIN inflation_rates i
ON i.country_name = hs.country
AND i.year = hs.year;


-- USING CTEs 

-- 1. CTE enhance Readability
-- Comparing CTE with Subquery 
/* SUB Query - Return the happiness score along with 
	the average happiness score for each country*/
    
SELECT 
	country,
	AVG(happiness_score) 
FROM happiness_scores
GROUP BY country;


SELECT 
	hs.country,
    hs.happiness_score,
    country_hs.avg_hs_score
FROM happiness_scores hs
LEFT JOIN (
	SELECT 
	country,
	AVG(happiness_score) as avg_hs_score
FROM happiness_scores
GROUP BY country) AS country_hs
ON hs.country = country_hs.country;

/* CTE: Return the happiness score along with the 
	average hapiness score for each country
*/

WITH country_hs AS (
	SELECT 
		country,
        AVG(happiness_score) AS avg_hs_score
	FROM happiness_scores
    GROUP BY country ) 
    
SELECT 
	hs.year,
    hs.country,
    hs.happiness_score,
    country_hs.avg_hs_score
FROM happiness_scores hs
LEFT JOIN country_hs 
ON country_hs.country = hs.country;
    
-- Compare 2023 Vs 2024 happiness score side by side

WITH hs2023 AS( 
	 SELECT *
	 FROM happiness_scores
	 WHERE year  = 2023),
	 
     hs2024 AS(
	 SELECT * 
	 FROM happiness_scores_current)

SELECT
	hs2023.country,
    hs2023.happiness_score AS hs_2023,
    hs2024.country,
    hs2024.ladder_score AS hs_2024
FROM hs2023 
INNER JOIN hs2024
ON hs2023.country = hs2024.country;


/* ompare the hhappiness score for country year2023 and 2024 and 
 return those country which happiness score is increased.*/

SELECT *
FROM (
	WITH hs2023 AS( 
	 SELECT *
	 FROM happiness_scores
	 WHERE year  = 2023),
	 
     hs2024 AS(
	 SELECT * 
	 FROM happiness_scores_current)

SELECT
	hs2023.country,
    hs2023.happiness_score AS hs_2023,
    hs2024.ladder_score AS hs_2024
FROM hs2023 
INNER JOIN hs2024
ON hs2023.country = hs2024.country) AS hs_23_24

WHERE hs_2024 > hs_2023;

-- SubQuery vs CTEs vs Temp Table vs View

-- SubQuery

SELECT 
	*
FROM (

SELECT year, country,happiness_score FROM happiness_scores

UNION ALL

SELECT 2024, country, ladder_score FROM happiness_scores_current) AS sub_query;
	
-- CTEs

WITH CTEs AS (
SELECT year , country,happiness_score FROM happiness_scores

UNION ALL

SELECT 2024,country, ladder_score FROm happiness_scores_current)

SELECT *
FROM CTEs;

-- Temporary Table

CREATE TEMPORARY TABLE my_temp AS
SELECT year, country, happiness_score FROM happiness_scores

UNION ALL

SELECT 2024, country,ladder_score FROM happiness_scores_current;

SELECT * FROM my_temp;

-- Views

CREATE view my_view AS 
SELECT year,country,happiness_score FROM happiness_scores
UNION ALL
SELECT 2024,country,ladder_score FROM happiness_scores_current;


SELECT * FROM my_view;

-- REtrun all row numbers

SELECT year, country,happiness_score, 
ROW_NUMBER() OVER() AS row_num
FROM happiness_scores;

-- Retrun all row numbers within each window 
SELECT year, country,happiness_score, 
ROW_NUMBER() OVER(PARTITION BY country )AS row_num
FROM happiness_scores;

/* return all row number withib each  window
 where the rows are ordered by happiness score  for highest to lowest*/
 
 SELECT year, country,happiness_score, 
ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score DESC) AS row_num
FROM happiness_scores;

-- Calculate the diffrerence in happiness score over time by country
WITH hs_prior AS (

	SELECT country,year, happiness_score,
	LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) AS prior_hp_score
	FROM happiness_scores
)
SELECT country, year,happiness_score,prior_hp_score,
	happiness_score - prior_hp_score AS hs_change
FROM hs_prior;

-- View the top 25% of happiness scores for the each region
WITH hs_pct AS(
	SELECT region,country,happiness_score,
	NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC )  AS hs_percentile
	FROM happiness_scores
	WHERE year = 2023
	ORDER BY region , happiness_score desc
)

SELECT * 
FROM hs_pct
WHERE hs_percentile = 1;

    






