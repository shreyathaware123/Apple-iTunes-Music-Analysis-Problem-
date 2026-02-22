Create database iTunes_Music_Store;
Use itunes_Music_Store;

# Creating the Tables

-- *** Parent Tables ***

--  1. Table -> artist
Create table artist (
artist_id int primary key,
name varchar(255) not null
);

--  2. Table -> genre
Create table genre (
genre_id int primary key,
name varchar(120) not null
);

-- 3. Table -> media_type
Create table media_type (
media_type_id int primary key,
name varchar(120) not null
);

--  4. Table -> employee
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    reports_to INT,
    levels varchar(50),
    birthdate DATETIME,
    hire_date DATETIME,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),
    FOREIGN KEY (reports_to) REFERENCES employee(employee_id)
);

-- 5. Table -> customer
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    company VARCHAR(80),
    address VARCHAR(255),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100) NOT NULL,
    support_rep_id INT,
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
); 

--  6. Table -> playlist
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(120)
);


-- *** Child Tables ***

-- 1. Table -> album
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
); 

-- 2. Table -> track
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    album_id INT,
    media_type_id INT NOT NULL,
    genre_id INT,
    composer VARCHAR(220),
    milliseconds INT NOT NULL,
    bytes INT,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

-- 3. Table -> invoice
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_date DATETIME NOT NULL,
    billing_address VARCHAR(255),
    billing_city VARCHAR(40),
    billing_state VARCHAR(40),
    billing_country VARCHAR(40),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
); 

-- 4. Table -> invoice_line
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    track_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
); 

-- 5. Table -> playlist_track
CREATE TABLE playlist_track (
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
); 


SHOW VARIABLES LIKE 'secure_file_priv';

# Step 1: Loading Parent Tables

-- 1️ artist
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/artist.csv'
INTO TABLE artist
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(artist_id, name);

-- 2.genre
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/genre.csv'
INTO TABLE genre
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(genre_id, name); 

-- 3. media_type
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/media_type.csv'
INTO TABLE media_type
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(media_type_id, name);

-- 4. employee

-- Disable foreign key checks temporarily while loading:
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employee.csv'
INTO TABLE employee
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(employee_id, last_name, first_name, title, @reports_to, levels, @birthdate, @hire_date, address, city, state, country, postal_code, phone, fax, email)
SET reports_to = NULLIF(@reports_to, ''),
    birthdate = STR_TO_DATE(@birthdate, '%d-%m-%Y %H:%i'),
    hire_date = STR_TO_DATE(@hire_date, '%d-%m-%Y %H:%i');

-- Re-enable foreign key checks:
SET FOREIGN_KEY_CHECKS = 1;

-- 5. customer

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
INTO TABLE customer
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id, first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, @support_rep_id)
SET support_rep_id = NULLIF(@support_rep_id, '');

SET FOREIGN_KEY_CHECKS = 1;

-- 6. playlist
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/playlist.csv'
INTO TABLE playlist
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(playlist_id, name); 

# Step 2 - Load child tables

-- 1. album 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/album.csv'
INTO TABLE album
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(album_id, title, artist_id);

-- 2. track
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE track
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price); 

-- 3. invoice
-- Disable foreign key checks temporarily while loading:
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice.csv'
INTO TABLE invoice
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice_id, customer_id, @invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total)
SET invoice_date = STR_TO_DATE(@invoice_date, '%d-%m-%Y');

-- Re-enable foreign key checks:
SET FOREIGN_KEY_CHECKS = 1;

-- 4. invoice_line
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_line.csv'
INTO TABLE invoice_line
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice_line_id, invoice_id, track_id, unit_price, quantity);

SET FOREIGN_KEY_CHECKS = 1;

-- 5. playlist_track

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/playlist_track.csv'
INTO TABLE playlist_track
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(playlist_id, track_id);

SET FOREIGN_KEY_CHECKS = 1; 

