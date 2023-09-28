-- This is the solution for 1st case study of the challenge
-- CREATING DATA SET
CREATE DATABASE DannysDiner;
USE DannysDiner;
-- Create the 'sales' table
CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);

-- Insert data into the 'sales' table
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

-- Create the 'menu' table
CREATE TABLE menu (
    product_id INTEGER,
    product_name VARCHAR(5),
    price INTEGER
);

-- Insert data into the 'menu' table
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

-- Create the 'members' table
CREATE TABLE members (
    customer_id VARCHAR(1),
    join_date DATE
);

-- Insert data into the 'members' table
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


SELECT 
    *
FROM
    members;
SELECT 
    *
FROM
    menu;
SELECT 
    *
FROM
    Sales;

-- SOLUTIONS

SELECT 
    customer_id, SUM(price) AS Total_amount
FROM
    Sales
        JOIN
    menu USING (product_id)
GROUP BY customer_id;

-- 2 How many dates customer visited the restauraunt

SELECT 
    customer_id, COUNT(DISTINCT order_date) AS no_of_visit
FROM
    sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT customer_id ,product_name FROM (
SELECT DISTINCT customer_id,order_date, dense_rank() OVER(partition by customer_id order by order_date ASC) as datemin, product_id, product_name
FROM SALES
JOIN menu
USING (product_id)) as t1
WHERE datemin =1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_id,most_purchased FROM (
SELECT  *,rank() OVER(order by most_purchased DESC) as rn FROM (
SELECT product_id , count(product_id) as most_purchased 
FROM sales 
GROUP BY product_id) as ct ) as ct1
WHERE rn =1;


-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name FROM (
SELECT * ,rank() over(partition by customer_id order by most DESC) as rn FROM (
SELECT DISTINCT customer_id,product_id, product_name,count(product_id) over(partition by customer_id,product_name) as most
FROM sales
JOIN menu
USING (product_id)) as ct) as ct2
WHERE rn  =1;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id,order_date,product_name FROM (
SELECT  m.customer_id as customer_id,order_date, dense_rank() OVER(partition by customer_id order by order_date ASC) as datemin,
 product_id, product_name
FROM SALES as s
JOIN menu
USING (product_id)
JOIN members as m
ON order_date >= join_date and m.customer_id = s.customer_id ) as t1
WHERE datemin =1;


-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id,order_date,product_name FROM (
SELECT  m.customer_id as customer_id,order_date, dense_rank() OVER(partition by customer_id order by order_date DESC) as datemin,
 product_id, product_name
FROM SALES as s
JOIN menu
USING (product_id)
JOIN members as m
ON order_date < join_date and m.customer_id = s.customer_id ) as t1
WHERE datemin =1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT DISTINCT
    customer_id,
    SUM(price) AS total,
    COUNT(product_id) AS total_items
FROM
    (SELECT 
        m.customer_id AS customer_id,
            order_date,
            price,
            product_id,
            product_name
    FROM
        SALES AS s
    JOIN menu USING (product_id)
    JOIN members AS m ON order_date < join_date
        AND m.customer_id = s.customer_id) AS t1
GROUP BY customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    customer_id, SUM(price) AS total
FROM
    (SELECT 
        customer_id,
            order_date,
            IF(product_name = 'sushi', price * 20, price * 10) AS price,
            product_id,
            product_name
    FROM
        SALES AS s
    JOIN menu USING (product_id)) AS t2
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
SELECT 
    customer_id, SUM(price) AS total
FROM
    (SELECT 
        customer_id,
            order_date,
            (CASE
                WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 7 DAY) THEN price * 20
                ELSE price * 10
            END) AS price,
            product_id,
            product_name
    FROM
        SALES AS s
    JOIN menu USING (product_id)
    JOIN members USING (customer_id)) AS t2
GROUP BY customer_id;

