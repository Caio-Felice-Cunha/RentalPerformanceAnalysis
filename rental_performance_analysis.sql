-- ################# Rental Performance Analysis #################
-- Rental frequency, rental duration, customer segmentation,
-- inventory popularity, and employee performance against the
-- MySQL Sakila sample database.
--
-- Comment style standardized on '--' (portable across dialects;
-- MySQL also accepts '#', but '#' is non-portable).
-- Each query selects a human-readable label but GROUPs BY the
-- primary key so rows are never merged when two people share a name.

USE sakila;

-- =====================================================================
-- 1. Rental frequency
-- =====================================================================

-- By customer (top 10):
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    COUNT(rental.rental_id) AS rentals
FROM
    customer
        JOIN
    rental ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY rentals DESC
LIMIT 10;

-- By staff:
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    COUNT(rental.rental_id) AS rentals
FROM
    staff
        JOIN
    rental ON rental.staff_id = staff.staff_id
GROUP BY staff.staff_id
ORDER BY rentals DESC;

-- By store (attributed via inventory ownership, i.e. which store's
-- stock was rented, using inventory.store_id; NOT via the staff
-- member who processed the rental, since a clerk can rent out either
-- store's inventory):
SELECT
    CONCAT(address.address, ', ', city.city) AS store_address,
    COUNT(rental.rental_id) AS rental_frequency
FROM
    store
        JOIN
    address ON store.address_id = address.address_id
        JOIN
    city ON address.city_id = city.city_id
        JOIN
    inventory ON inventory.store_id = store.store_id
        JOIN
    rental ON rental.inventory_id = inventory.inventory_id
GROUP BY store.store_id
ORDER BY rental_frequency DESC;

-- =====================================================================
-- 2. Rental duration (average days between rental and return)
-- =====================================================================

-- By customer:
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    ROUND(AVG(DATEDIFF(r.return_date, r.rental_date))) AS day_diff
FROM
    customer c
        JOIN
    rental r ON r.customer_id = c.customer_id
WHERE
    DATEDIFF(r.return_date, r.rental_date) IS NOT NULL
GROUP BY c.customer_id
ORDER BY day_diff DESC;

-- By movie:
SELECT
    film.title,
    ROUND(AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date))) AS avg_rental_duration
FROM
    film
        INNER JOIN
    inventory ON film.film_id = inventory.film_id
        INNER JOIN
    rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY avg_rental_duration DESC;

-- By category:
SELECT
    category.name AS category,
    ROUND(AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date))) AS avg_rental_duration
FROM
    category
        INNER JOIN
    film_category ON category.category_id = film_category.category_id
        INNER JOIN
    film ON film_category.film_id = film.film_id
        INNER JOIN
    inventory ON film.film_id = inventory.film_id
        INNER JOIN
    rental ON inventory.inventory_id = rental.inventory_id
GROUP BY category.category_id
ORDER BY avg_rental_duration DESC;

-- By store city (the city where the renting store sits; Sakila has
-- only two stores, so this returns two rows. Labeled honestly as
-- store city, not customer city):
SELECT
    city.city,
    ROUND(AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date))) AS avg_rental_duration
FROM
    city
        INNER JOIN
    address ON city.city_id = address.city_id
        INNER JOIN
    store ON address.address_id = store.address_id
        INNER JOIN
    inventory ON inventory.store_id = store.store_id
        INNER JOIN
    rental ON rental.inventory_id = inventory.inventory_id
GROUP BY city.city_id
ORDER BY avg_rental_duration DESC;

-- By customer city (the city of the customer who rented; this is the
-- more meaningful geographic breakdown and returns one row per city
-- that has customers):
SELECT
    city.city,
    ROUND(AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date))) AS avg_rental_duration
FROM
    city
        INNER JOIN
    address ON city.city_id = address.city_id
        INNER JOIN
    customer ON customer.address_id = address.address_id
        INNER JOIN
    rental ON rental.customer_id = customer.customer_id
GROUP BY city.city_id
ORDER BY avg_rental_duration DESC;

-- =====================================================================
-- 3. Customer segmentation: frequency, duration, and revenue
-- =====================================================================
-- Note: the frequency query below is the canonical, un-limited
-- customer-frequency analysis. The top-10 version in section 1 is the
-- same measure restricted to the leaderboard.

-- Frequency:
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.rental_id) AS rental_frequency
FROM
    customer AS c
        INNER JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY rental_frequency DESC;

-- Duration:
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date))) AS avg_rental_duration
FROM
    customer AS c
        INNER JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY avg_rental_duration DESC;

-- Revenue:
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_revenue
FROM
    customer AS c
        INNER JOIN
    payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC;

-- =====================================================================
-- 4. Inventory popularity: which films are rented most and least
-- =====================================================================
SELECT
    f.title,
    COUNT(*) AS rental_count
FROM
    rental AS r
        INNER JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
        INNER JOIN
    film AS f ON i.film_id = f.film_id
GROUP BY f.film_id
ORDER BY rental_count DESC;

-- =====================================================================
-- 5. Employee performance: rentals processed and average duration
-- =====================================================================

-- Number of rentals processed:
SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    COUNT(*) AS rental_count
FROM
    staff AS s
        INNER JOIN
    rental AS r ON s.staff_id = r.staff_id
GROUP BY s.staff_id
ORDER BY rental_count DESC;

-- Average rental duration:
SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    ROUND(AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date))) AS avg_rental_duration
FROM
    staff AS s
        INNER JOIN
    rental AS r ON s.staff_id = r.staff_id
GROUP BY s.staff_id
ORDER BY avg_rental_duration DESC;
