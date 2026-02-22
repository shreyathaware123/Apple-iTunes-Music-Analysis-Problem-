### 1. ️View all rows in a table

SELECT * FROM artist;
SELECT * FROM employee;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM media_type;
SELECT * FROM playlist;
SELECT * FROM playlist_track;
SELECT * FROM track;

### 2️. Count rows in each table

SELECT COUNT(*) FROM album;
SELECT COUNT(*) FROM artist;
SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM invoice_line;
SELECT COUNT(*) FROM media_type;
SELECT COUNT(*) FROM playlist;
SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM playlist_track;

### 3️. Join parent and child tables

--  Tracks with their album and artist:
SELECT t.track_id, t.name AS track_name, a.title AS album_title, ar.name AS artist_name
FROM track t
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
LIMIT 10;

### 4️. Aggregation

-- Total sales per customer:
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

### 5️. Playlist tracks

SELECT p.name AS playlist_name, t.name AS track_name
FROM playlist_track pt
JOIN playlist p ON pt.playlist_id = p.playlist_id
JOIN track t ON pt.track_id = t.track_id
LIMIT 10;

