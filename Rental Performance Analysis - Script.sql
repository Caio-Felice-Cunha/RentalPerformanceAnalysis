################# Rental Performance Analysis: rental frequency, rental duration, and average rental #################
USE sakila;
# Rental Performance Analysis:
## rental frequency
### By customer:
SELECT 
    CONCAT(first_name, ' ', last_name) full_name,
    COUNT(inventory_id) AS Rentals
FROM
    customer
        JOIN
    rental ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY COUNT(inventory_id) DESC
LIMIT 10;


### By staff:
SELECT 
    CONCAT(first_name, ' ', last_name) full_name,
    COUNT(inventory_id) Rentals
FROM
    staff
		JOIN
    rental ON rental.staff_id = staff.staff_id
GROUP BY
	full_name 
ORDER BY 
	COUNT(inventory_id) DESC;

### By store:
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
    staff ON store.store_id = staff.store_id
        JOIN
    rental ON staff.staff_id = rental.staff_id
GROUP BY store_address
ORDER BY 
	COUNT(inventory_id) DESC;

# Rental Performance Analysis:
## rental duration
### By customer:
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) full_name,
    ROUND(AVG(DATEDIFF(r.return_date, r.rental_date))) day_diff
FROM
    customer c
        JOIN
    rental r ON r.customer_id = c.customer_id
WHERE
    DATEDIFF(r.return_date, r.rental_date) IS NOT NULL
GROUP BY CONCAT(c.first_name, ' ', c.last_name)
ORDER BY AVG(DATEDIFF(r.return_date, r.rental_date)) DESC;

### By movie:
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
ORDER BY (AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date))) DESC;

### By category:
SELECT 
    category.name as category,
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
ORDER BY AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date)) DESC;

### By city:
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
    staff ON store.store_id = staff.store_id
        INNER JOIN
    rental ON staff.staff_id = rental.staff_id
GROUP BY city.city_id
ORDER BY AVG(TIMESTAMPDIFF(DAY,
        rental.rental_date,
        rental.return_date)) DESC;


-- Customer Segmentation Analysis: frequency, duration, and revenue.
## Frequency
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT r.rental_id) AS rental_frequency
FROM
    customer AS c
        INNER JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY 
	c.customer_id
ORDER BY 
	rental_frequency DESC;

## Duration:
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date)) AS avg_rental_duration
FROM 
    customer AS c
    INNER JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    avg_rental_duration DESC;

## revenue
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_revenue
FROM 
    customer AS c
    INNER JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    total_revenue DESC;



-- Inventory Analysis: which DVDs are popular and which are not.
SELECT 
    f.title,
    COUNT(*) AS rental_count
FROM 
    rental AS r
    INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
    INNER JOIN film AS f ON i.film_id = f.film_id
GROUP BY 
    f.film_id
ORDER BY 
    rental_count DESC;

-- Employee Performance Analysis: number of rentals they processed and the average rental duration.
## number of rentals they processed
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    COUNT(*) AS rental_count
FROM 
    staff AS s
    INNER JOIN rental AS r ON s.staff_id = r.staff_id
GROUP BY 
    s.staff_id
ORDER BY 
    rental_count DESC;
    
## average rental duration.
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date)) AS avg_rental_duration
FROM 
    staff AS s
    INNER JOIN rental AS r ON s.staff_id = r.staff_id
GROUP BY 
    s.staff_id
ORDER BY 
    avg_rental_duration DESC







