-- Unit 10 Assignment - SQL


-- Create these queries to develop greater fluency in SQL, an important database language.

USE sakila

-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor. 

SELECT * FROM actor

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. `

SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' 
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?`
     
SELECT first_name, last_name
FROM actor
WHERE first_name IN('Joe')

-- 2b. Find all actors whose last name contain the letters GEN:`

SELECT *
FROM actor
WHERE last_name 
LIKE '%gen%'

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name 
LIKE '%li%'
ORDER BY last_name DESC, first_name DESC

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country, country_id
FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China')

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name

SELECT * FROM actor

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB

SELECT * FROM actor

-- 3c. Now delete the middle_name column.

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE actor
DROP COLUMN middle_name

SELECT * FROM actor

SET SQL_SAFE_UPDATES = 1;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) as 'Number of Actors With Last Name'
FROM actor 
GROUP by last_name

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) as 'Number of Actors With Last Name'
FROM actor 
GROUP by last_name 
HAVING COUNT(*) > 1

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

-- STILL NOT WORKING!

UPDATE actor
SET first_name = 'Harpo'
where first_name = 'Groucho' AND last_name = 'Williams'

SELECT * 
FROM actor
WHERE first_name = 'Harpo' AND last_name = 'Williams'

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name 
--     after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
--     Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the 
--     grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
--     (Hint: update the record using a unique identifier.)

UPDATE actor
SET 	first_name = CASE
			WHEN first_name = 'Harpo' THEN 'Groucho'
			ELSE 'MUCHO GROUCHO'
		END 
WHERE actor_id = 172

SELECT * 
FROM actor
WHERE actor_id = 172

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESC address

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the 
--     tables staff and address:

SELECT * FROM address
SELECT * FROM staff

SELECT address.address, staff.first_name, staff.last_name
FROM staff
	INNER JOIN address ON address.address_id=staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 

SELECT * FROM payment
SELECT * FROM staff

SELECT a.first_name, a.last_name, a.staff_id, SUM(b.amount) AS 'Total Rung'
FROM staff a
	JOIN payment b ON a.staff_id=b.staff_id
GROUP BY staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
--     Use inner join.

SELECT * FROM film_actor
SELECT * FROM film

SELECT a.title, COUNT(a.film_id) AS 'Total Actors' 
FROM film a
	INNER JOIN film_actor b ON a.film_id = b.film_id
GROUP BY a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM film
SELECT * FROM inventory

SELECT a.title, COUNT(a.film_id) AS 'Total Copies' 
FROM film a
	INNER JOIN inventory b ON a.film_id = b.film_id
GROUP BY a.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
--     List the customers alphabetically by last name:

SELECT * FROM payment
SELECT * FROM customer

SELECT a.customer_id, a.last_name, a.first_name, SUM(b.amount) AS 'Total Paid'
FROM customer a
	JOIN payment b ON a.customer_id=b.customer_id
GROUP BY a.customer_id
ORDER BY last_name

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
--     consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries 
--     to display the titles of movies starting with the letters K and Q whose language is English. 

SELECT * FROM film
SELECT * FROM language

SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(SELECT language_id FROM language where name='English')

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM film_actor
SELECT * FROM actor


SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id from film where title='ALONE TRIP'))

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email 
--     addresses of all Canadian customers. Use joins to retrieve this information.

SELECT * FROM address
SELECT * FROM customer
SELECT * FROM country
SELECT * FROM city

SELECT a.last_name, a.first_name, a.email, d.country
FROM customer a
	INNER JOIN address b ON a.address_id=b.address_id
    INNER JOIN city c ON b.city_id=c.city_id
    INNER JOIN country d ON c.country_id=d.country_id
WHERE d.country='Canada'


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a 
--     promotion. Identify all movies categorized as family films. 

SELECT * FROM film
SELECT * FROM film_category
SELECT * FROM category

SELECT title
FROM film 
WHERE film_id
	IN (SELECT film_id FROM film_category WHERE category_id 
		IN (SELECT category_id from category where name='Family'))

-- 7e. Display the most frequently rented movies in descending order.

SELECT * FROM rental
SELECT * FROM inventory
SELECT * FROM film

SELECT a.title, COUNT(A.film_id) as 'Number of Rentals'
FROM film a
	JOIN inventory b ON a.film_id=b.film_id
    JOIN rental c ON b.inventory_id=c.inventory_id
GROUP BY a.film_id
ORDER BY 2 DESC

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM payment
SELECT * FROM staff

SELECT a.store_id, SUM(b.amount) as 'Total Revenue'
FROM staff a
	JOIN payment b ON a.staff_id=b.staff_id
GROUP BY a.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT * FROM store
SELECT * FROM address
SELECT * FROM country
SELECT * FROM city

SELECT a.store_id, c.city, d.country
FROM store a
	INNER JOIN address b ON a.address_id=b.address_id
    INNER JOIN city c ON b.city_id=c.city_id
    INNER JOIN country d ON c.country_id=d.country_id


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
--     following tables: category, film_category, inventory, payment, and rental.)

SELECT * FROM payment
SELECT * FROM rental
SELECT * FROM category
SELECT * FROM film_category
SELECT * FROM inventory

SELECT e.name, SUM(a.amount) as 'Total Revenue'
FROM payment a
	JOIN rental b ON a.rental_id=b.rental_id
    JOIN inventory c ON b.inventory_id=c.inventory_id
    JOIN film_category d ON c.film_id=d.film_id
    JOIN category e ON d.category_id=e.category_id
GROUP BY e.name
ORDER BY 2 DESC LIMIT 5

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five 
--     genres by gross revenue. Use the solution from the problem above to create a view. If you 
--     haven't solved 7h, you can substitute another query to create a view.

DROP VIEW IF EXISTS top_five_genres; 
CREATE VIEW top_five_genres AS
SELECT e.name, SUM(a.amount) as 'Total Revenue'
FROM payment a
	JOIN rental b ON a.rental_id=b.rental_id
    JOIN inventory c ON b.inventory_id=c.inventory_id
    JOIN film_category d ON c.film_id=d.film_id
    JOIN category e ON d.category_id=e.category_id
GROUP BY e.name
ORDER BY 2 DESC LIMIT 5

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;