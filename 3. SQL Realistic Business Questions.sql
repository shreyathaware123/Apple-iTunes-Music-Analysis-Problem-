# 1 . Customer Analytics

-- Q1: Which customers have spent the most money on music?
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 10;
-- Returns top 10 highest-spending customers.

-- Q2: What is the average customer lifetime value?
SELECT AVG(total_spent) AS avg_customer_lifetime_value
FROM (
    SELECT c.customer_id, SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS customer_totals;
-- Gives the average money spent per customer across all invoices.

-- Q3: How many customers have made repeat purchases versus one-time purchases?
SELECT 
    CASE WHEN num_invoices > 1 THEN 'Repeat' ELSE 'One-time' END AS purchase_type,
    COUNT(*) AS num_customers
FROM (
    SELECT c.customer_id, COUNT(i.invoice_id) AS num_invoices
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS customer_invoice_counts
GROUP BY purchase_type;
-- Splits customers into one-time and repeat purchasers.

-- Q4: Which country generates the most revenue per customer?
SELECT c.country, SUM(i.total) AS total_revenue, COUNT(DISTINCT c.customer_id) AS num_customers,
       SUM(i.total)/COUNT(DISTINCT c.customer_id) AS revenue_per_customer
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer DESC;

-- Shows average revenue per customer by country, ranked top-down.

-- Q5: Which customers haven't made a purchase in the last 6 months?
SELECT c.customer_id, c.first_name, c.last_name, MAX(i.invoice_date) AS last_purchase_date
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MAX(i.invoice_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
   OR MAX(i.invoice_date) IS NULL
ORDER BY last_purchase_date;

--  Returns customers inactive for the last 6 months (or never purchased).

# 2. Sales & Revenue Analysis

-- Q1: What are the monthly revenue trends for the last two years?
SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS month, SUM(total) AS revenue
FROM invoice
GROUP BY month
ORDER BY month;

SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS month, SUM(total) AS revenue
FROM invoice
WHERE invoice_date >= '2016-01-01'  -- adjust to match your data
GROUP BY month
ORDER BY month;

-- Shows monthly revenue for the last 24 months.

-- Q2: What is the average value of an invoice (purchase)?
SELECT AVG(total) AS avg_invoice_value
FROM invoice;

-- Q3: Which payment methods are used most frequently?
SELECT payment_method, COUNT(*) AS num_purchases
FROM invoice
GROUP BY payment_method
ORDER BY num_purchases DESC;

-- Q4: How much revenue does each sales representative (support rep) contribute?
SELECT e.employee_id, e.first_name, e.last_name, 
       SUM(i.total) AS revenue_contributed
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY revenue_contributed DESC;

-- Q5: Which months or quarters have peak music sales?

# By Month
SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS month, SUM(total) AS revenue
FROM invoice
GROUP BY month
ORDER BY revenue DESC
LIMIT 12;

-- Shows top 12 months by revenue.
-- Useful for identifying peak months.

# By Quarter
SELECT CONCAT(YEAR(invoice_date), '-Q', QUARTER(invoice_date)) AS quarter,
       SUM(total) AS revenue
FROM invoice
GROUP BY quarter
ORDER BY revenue DESC;

-- Shows quarterly revenue trends, helps identify seasonal peaks.

-- 3. Product & Content Analysis.

-- Q1: Which tracks generated the most revenue?
SELECT t.track_id, t.name AS track_name, SUM(il.unit_price * il.quantity) AS revenue
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY revenue DESC
LIMIT 10;

-- Shows top 10 highest-grossing tracks.

-- Q2: Which albums or playlists are most frequently included in purchases?

#Album
SELECT a.album_id, a.title AS album_title, SUM(il.quantity) AS total_units_sold,
       SUM(il.unit_price * il.quantity) AS total_revenue
FROM album a
JOIN track t ON a.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.album_id, a.title
ORDER BY total_units_sold DESC
LIMIT 10;
-- Shows top 10 albums by number of tracks sold and revenue.

#Playlist
SELECT p.playlist_id, p.name AS playlist_name, COUNT(pt.track_id) AS num_tracks,
       SUM(il.unit_price * il.quantity) AS total_revenue
FROM playlist p
JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
LEFT JOIN invoice_line il ON pt.track_id = il.track_id
GROUP BY p.playlist_id, p.name
ORDER BY total_revenue DESC
LIMIT 10;
-- Shows top 10 playlists by revenue (tracks included in purchases).

-- Q3: Are there any tracks or albums that have never been purchased?

#Tracks never purchased
SELECT t.track_id, t.name AS track_name
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;
-- Returns all tracks with zero sales.

#Albums never purchased
SELECT a.album_id, a.title AS album_title
FROM album a
LEFT JOIN track t ON a.album_id = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL
GROUP BY a.album_id, a.title;
-- Returns albums where none of the tracks have ever been purchased.

-- Q4: Average price per track across different genres
SELECT g.genre_id, g.name AS genre_name, 
       AVG(t.unit_price) AS avg_track_price,
       COUNT(t.track_id) AS num_tracks
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.genre_id, g.name
ORDER BY avg_track_price DESC;

-- Shows average unit price per track for each genre.

-- Q5: Number of tracks per genre and their total sales

SELECT g.genre_id, g.name AS genre_name,
       COUNT(t.track_id) AS num_tracks,
       COALESCE(SUM(il.quantity), 0) AS total_units_sold,
       COALESCE(SUM(il.unit_price * il.quantity), 0) AS total_revenue
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;

# 4. Artist & Genre Performance

-- Q1. Who are the top 5 highest-grossing artists?
SELECT ar.artist_id, ar.name AS artist_name,
       SUM(il.unit_price * il.quantity) AS total_revenue
FROM artist ar
JOIN album a ON ar.artist_id = a.artist_id
JOIN track t ON a.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_revenue DESC
LIMIT 5;
-- Shows 5 artists with the highest total revenue.

-- Q2. Which music genres are most popular in terms of:

#Number of tracks sold
SELECT g.genre_id, g.name AS genre_name,
       COALESCE(SUM(il.quantity), 0) AS total_units_sold
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY total_units_sold DESC;

#Total revenue
SELECT g.genre_id, g.name AS genre_name,
       COALESCE(SUM(il.unit_price * il.quantity), 0) AS total_revenue
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;

-- Q3. Are certain genres more popular in specific countries?
SELECT c.country, g.name AS genre_name,
       COALESCE(SUM(il.quantity), 0) AS total_units_sold
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, total_units_sold DESC;

# 5. Employee & Operational Efficiency

-- Q1: Which employees (support reps) are managing the highest-spending customers?
SELECT e.employee_id, e.first_name, e.last_name,
       SUM(i.total) AS revenue_contributed
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY revenue_contributed DESC;
-- Shows top employees by total customer revenue.

-- Q2: Average number of customers per employee
SELECT e.employee_id, e.first_name, e.last_name,
       COUNT(c.customer_id) AS num_customers
FROM employee e
LEFT JOIN customer c ON e.employee_id = c.support_rep_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY num_customers DESC;

-- Calculates how many customers each employee manages.

-- Q3: Which employee regions bring in the most revenue?
SELECT e.city, e.state, e.country,
       SUM(i.total) AS total_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.city, e.state, e.country
ORDER BY total_revenue DESC;

-- Shows revenue contribution by employee location (city/state/country).

# 6. Geographic Trends

-- Q1: Which countries or cities  have the highest number of customers?

# For Countries
SELECT country, COUNT(customer_id) AS num_customers
FROM customer
GROUP BY country
ORDER BY num_customers DESC;

-- Shows top countries by customer count.
# For Cities
SELECT city, country, COUNT(customer_id) AS num_customers
FROM customer
GROUP BY city, country
ORDER BY num_customers DESC
LIMIT 20;

-- Shows top 20 cities with the most customers.

-- Q2: How does revenue vary by region?
SELECT billing_country AS country, billing_state AS state, billing_city AS city,
       SUM(total) AS total_revenue
FROM invoice i
GROUP BY billing_country, billing_state, billing_city
ORDER BY total_revenue DESC
LIMIT 20;

-- Shows revenue by country, state, and city.

-- Q3 Are there any underserved geographic regions  (high users, low sales)??
SELECT c.country, c.city,
       COUNT(c.customer_id) AS num_customers,
       COALESCE(SUM(i.total),0) AS total_revenue
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country, c.city
HAVING num_customers > 10 AND total_revenue < 500
ORDER BY total_revenue ASC;

-- Finds regions with many customers but low revenue → potential growth opportunities.

# 7. Customer Retention & Purchase Patterns

-- Q1. What is the distribution of purchase frequency per customer?
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(i.invoice_id) AS num_purchases
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY num_purchases DESC;

-- Shows how many purchases each customer has made.

-- Q2.How long is the average time between customer purchases?
SELECT c.customer_id, c.first_name, c.last_name,
       AVG(DATEDIFF(i2.invoice_date, i1.invoice_date)) AS avg_days_between_purchases
FROM customer c
JOIN invoice i1 ON c.customer_id = i1.customer_id
JOIN invoice i2 ON c.customer_id = i2.customer_id AND i2.invoice_date > i1.invoice_date
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_days_between_purchases ASC;

-- Calculates average days between purchases for each customer.

-- Q2.What percentage of customers purchase tracks from more than one genre?
SELECT 
    ROUND(
        100 * SUM(CASE WHEN genre_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS pct_multi_genre_customers
FROM (
    SELECT c.customer_id, COUNT(DISTINCT t.genre_id) AS genre_count
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id
) AS customer_genres;

-- Gives the percentage of customers who buy tracks from more than one genre.

# 8. Operational Optimization

-- Q1. What are the most common combinations of tracks purchased together?
SELECT t1.name AS track_1, t2.name AS track_2, COUNT(*) AS combo_count
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
GROUP BY t1.name, t2.name
ORDER BY combo_count DESC
LIMIT 10;
-- Shows top 10 track pairs frequently bought together.

-- Q2. Are there pricing patterns that lead to higher or lower sales?
SELECT t.track_id, t.name AS track_name,
       AVG(il.unit_price) AS avg_price,
       SUM(il.quantity) AS total_units_sold,
       SUM(il.unit_price * il.quantity) AS total_revenue
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY total_units_sold DESC
LIMIT 10;

-- Shows top-selling tracks and their prices.

-- Q3. Which media types (e.g., MPEG, AAC) are declining or increasing in usage?
 SELECT mt.media_type_id, mt.name AS media_type,
       COUNT(t.track_id) AS num_tracks,
       COALESCE(SUM(il.quantity), 0) AS total_units_sold,
       COALESCE(SUM(il.unit_price * il.quantity), 0) AS total_revenue
FROM media_type mt
LEFT JOIN track t ON mt.media_type_id = t.media_type_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY mt.media_type_id, mt.name
ORDER BY total_units_sold DESC;
-- Shows how popular each media type is in terms of tracks and revenue.


