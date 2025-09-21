-- Connecting to Database 
USE advanced_sql;

-- SHowing all the tables in the database
SHOW TABLES;

/* Q. Market research team is intrested in seeing how many customes
have spent $0-$10 on our products, $10-$20, and so on for every $10 range. */

-- calculating total spent for each customers within bins
WITH bin AS(
		SELECT o.customer_id, 
			SUM(o.units * p.unit_price) AS total_spend,
			FLOOR(SUM(o.units * p.unit_price)/10) * 10 as total_spend_bin
		FROM orders o
		JOIN products p
		ON o.product_id = p.product_id
		GROUP BY  o.customer_id
		
)
SELECT total_spend_bin, count(customer_id) AS num_customer
FROM bin
GROUP BY total_spend_bin
ORDER BY total_spend_bin;

/* Q. The market research team wants to do deep dive on the Q2 2024 orders
data. In addition also requested to include a ship_date column for them that is 
2 days after the orders_date. */

-- Extracting orders for 2024

SELECT order_id,order_date,
	DATE_ADD(order_date, INTERVAL 2 DAY) AS ship_date
FROM orders
WHERE  Year(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

/* Update products_ids to include the factory name and product name */

SELECT factory, product_id
FROM products
ORDER BY factory, product_id;

-- Removing apostrophes and replace space with hypens
SELECT factory, product_id,
REPLACE(REPLACE(factory,"'","")," ","-") AS factory_clean
FROM products
ORDER BY factory, product_id;

-- Creating new ID column called factory_product_id
WITH factory As (
		SELECT factory, product_id,
		REPLACE(REPLACE(factory,"'","")," ","-") AS factory_clean
		FROM products
		ORDER BY factory, product_id
)

SELECT factory_clean, product_id,
	CONCAT(factory_clean,"-", product_id) AS factory_product_id
FROM factory;

/* Remove 'Wonka Bar' from any products that contain that term? */

SELECT product_name,
	REPLACE(product_name,'Wonka Bar - ','') AS new_product_name
FROM products;

/* Q. Looking at the orders and product tables, 
which prduct exits in one table, but not the other?
*/

SELECT
	p.product_id,
    p.product_name,
    o.product_id AS product_id_in_orders
FROM products p
LEFT JOIN orders o
ON o.product_id = p.product_id
WHERE o.product_id  IS NULL;


-- Q.Which products are within 25 cent of each other in terms of unit price ?

--  Viewing product table

SELECT * FROM products;
-- Join the products table within itself so each candy is paired wit a different candy
SELECT
    p1.product_name,
    p1.unit_price,
    p2.product_name,
    p2.unit_price,
    p1.unit_price - p2.unit_price AS diff_price
FROM products p1
join products p2 
ON p1.product_id != p2.product_id
WHERE  p1.unit_price - p2.unit_price BETWEEN -0.25 AND 0.25
ORDER BY  p1.unit_price - p2.unit_price DESC;

-- Rewriting using cross Join

SELECT 
	p1.product_name,
    p1.unit_price,
    p2.product_name,
    p2.unit_price,
    (p1.unit_price - p2.unit_price) AS diff_price
FROM products p1
CROSS JOIN products p2
WHERE ABS(p1.unit_price - p2.unit_price) < 0.25
      AND p1.product_name < p2.product_name
ORDER BY p1.unit_price - p2.unit_price DESC;


/* Q. List the products from most to least expensive,
 along with how much each product differs from the average unit price
 */

SELECT 
	product_id,
    product_name,
    unit_price,
    (SELECT AVG(unit_price) FROM products) AS avg_unit_price,
    unit_price - (SELECT AVG(unit_price) FROM products) AS diff_from_avg
FROM products
ORDER BY unit_price - (SELECT AVG(unit_price) FROM products) DESC;

/* Q. Provide list of factories along with the names of the products
they produce and the number of products they produce */
SELECT fn.factory,fn.product_name, fc.product_count
FROM 
(SELECT factory, product_name FROM products) fn
LEFT JOIN
(SELECT 
    factory,
    COUNT(product_id) AS product_count
FROM products
GROUP BY 
    factory ) fc
ON fn.factory = fc.factory;


/* Q. Return products where unit price is less than 
	the unit price of all products from Wicked Choccy's
*/

SELECT unit_price
FROM products
WHERE factory = "Wicked Choccy's" ; 

SELECT 
	product_name,
    factory,
    unit_price
FROM products
WHERE unit_price < ALL(SELECT unit_price
					FROM products
					WHERE factory = "Wicked Choccy's" );
/* Sugar Shack and The Other Factory just added two new products that do not have divisions
assigned to them. Update those NULL values to have a value of "Other" */

SELECT product_name,factory,division,
COALESCE(division,"Other") AS division_other
FROM products;

-- FInd the most common division for each factory and repalce "Other" with most common one. 
WITH np AS (

		SELECT factory,division, COUNT(product_name) num_products
		FROM products
		WHERE division IS NOT NULL
		GROUP BY factory, division
),
 np_rank AS (
		SELECT factory,division,num_products,
		ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank
		FROM np
),

top_division AS(

		SELECT factory, division
		 FROM np_rank
		 WHERE np_rank = 1
)
SELECT p.product_name,p.factory, p.division,
	COALESCE(p.division,"Other") AS division_other,
    td.division AS division_top
 FROM products p 
 LEFT JOIN top_division td
 ON p.factory = td.factory
 ORDER BY p.factory, p.division;

 
-- Q. Retrun number of orders over $200
SELECT * FROM orders;
SELECT * FROM products;


WITH total_amount AS (
	SELECT 
		o.order_id,
	   SUM(o.units * p.unit_price) AS total_amount_spent
	FROM orders o
	LEFT JOIN products p
	ON p.product_id = o.product_id 
    GROUP BY o.order_id
    HAVING SUM(o.units * p.unit_price) > 200
    ORDER BY SUM(o.units * p.unit_price) DESC)
    
    SELECT
		COUNT(*) 
        FROM total_amount;

/* Q. Return list of factories along with the names of produts they produce
 and the number of products they produce */
 
 SELECT * FROM products;
 WITH pn AS(
	 SELECT 
		factory,
		product_name
	FROM products),
  pc AS (SELECT 
			factory,
			count(product_id) AS num_products
		FROM products
		GROUP by
			factory)

SELECT 
	pn.factory,
    pn.product_name,
    pc.num_products
FROM pn
LEFT JOIN pc
ON pn.factory = pc.factory
ORDER BY pn.factory, pn.product_name;


-- For each customer, add a column for transaction number

SELECT customer_id, order_id, order_date, transaction_id,
ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY transaction_id ) AS transation_num
FROM orders
ORDER BY customer_id, transaction_id;

/* Q. Create  a product rank field that returns a 1 for the most popular product in order,
 2 for second most,  and so on ? */
 
 SELECT order_id, product_id,units, 
 ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) product_rn
 FROM orders
 ORDER BY order_id,product_rn;
 
 -- IF there is tie keep the tie and do not skip to the next number after

SELECT order_id, product_id,units, 
 DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rn
 FROM orders
 ORDER BY order_id,product_rn;
 
 -- Check the order_id  that ends with 44262 from the result preview
 SELECT order_id, product_id,units, 
 DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) product_rn
 FROM orders
 WHERE order_id LIKE '%44262%'
 ORDER BY order_id,product_rn;
 
 --  Q. Return 2nd most popular product within each order
 
WITH row_num AS(
 SELECT order_id,product_id,units,
 DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rn
 FROM orders
 ORDER BY order_id, units
 )
 
 SELECT * 
 FROM row_num
 WHERE product_rn = 2; 
 
 /* Q. Return a table that contains info about each customer and their orders, 
 the number of units in each orders, and the change in units from order to order */
 
 -- View the column of interest
 SELECT customer_id, order_id, product_id, units
 FROM orders;
 
 -- For each customer return total units within each order
 
 SELECT customer_id, order_id, SUM(units) AS total_units
 FROM orders
 GROUP BY customer_id, order_id 
 ORDER BY customer_id;
 
 -- Add on the transaction id to keep track of the order of the orders
 
 SELECT customer_id, order_id,MIN(transaction_id), SUM(units) AS total_units
 FROM orders
 GROUP BY customer_id, order_id 
 ORDER BY customer_id, MIN(transaction_id);
 
 -- Turn the Query into CTEs and View the column of interest
WITH my_cte As (
SELECT customer_id, order_id,MIN(transaction_id) AS min_tid, SUM(units) AS total_units
 FROM orders
 GROUP BY customer_id, order_id 
 ORDER BY customer_id, min_tid
 )
 
 SELECT customer_id,order_id, total_units, 
 LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) prior_units
 FROM my_cte;
 
 -- Final Query
 WITH my_cte As (
	SELECT customer_id, order_id,MIN(transaction_id) AS min_tid, SUM(units) AS total_units
	 FROM orders
	 GROUP BY customer_id, order_id 
	 ORDER BY customer_id, min_tid
 ),
 prior_cte AS(
	 SELECT customer_id,order_id, total_units, 
	 LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) prior_units
	 FROM my_cte)
     
SELECT Customer_id, order_id,total_units, prior_units,
total_units - prior_units AS diff_units
 FROM prior_Cte;
 
 -- Q. Find top 1% of customers based on how much they spent
 WITH ts AS (
 
		 SELECT o.customer_id,SUM(o.units*p.unit_price) AS total_spent
		 FROM orders o
		 LEFT JOIN products p
		 ON o.product_id = p.product_id
		 GROUP BY o.customer_id
		 ORDER BY total_spent DESC
),
sp AS(
		SELECT Customer_id, total_spent,
		NTILE(100) OVER(ORDER BY total_spent DESC) AS spend_pct
		FROM ts 
)
		
SELECT * 
FROM sp  
WHERE spend_pct = 1;
