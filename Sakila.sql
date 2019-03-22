use sakila;
#1a. display all actors
SELECT first_name, last_name
FROM actor
#1b.Display first and last names in one column 
SELECT CONCAT(first_name, ' ' ,last_name) As newcolumn
From actor
;
#2a. query Joe's id/first/last name
SELECT actor_id, first_name, last_name
from actor
where first_name = 'Joe'
; 

#2b. all actors w/ GEN
SELECT * FROM actor WHERE last_name LIKE 'GEN%' 
;
#2c. all actors w/ LI
SELECT * FROM actor WHERE last_name LIKE 'LI%' 
;
#2d. 
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')
;
#3a. create 'description column'
ALTER TABLE actor
ADD COLUMN description BLOB 
;
#3b. detele description col
ALTER TABLE actor
 DROP description
 ;
 
 #4a. last name lists and how many actors with the last name
SELECT COUNT(first_name),last_name
 FROM actor
GROUP BY last_name
;
#4b.List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT COUNT(first_name),last_name
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;
;

#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS'
;


# 4d. In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS'
;

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address; 
# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT first_name, last_name, address
FROM address a 
INNER JOIN staff s
ON (a.address_id = s.address_id)
;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

#SELECT s.first_name, s.last_name, p.payment_date, SUM(amount) As 'total amount'
#From staff s 
#INNER JOIN payment p
#ON p.staff_id = s.staff_id
#group by last_name
#and payment_date
#like '2005-08%' 
#;

use sakila;

SELECT first_name, last_name, p.total_amount from staff s
INNER JOIN (
SELECT staff_id, SUM(amount) as total_amount
From payment p  where p.payment_date
like '2005-08%'   group by staff_id) p

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

Select title, count(actor_id) As number_of_actors
from film_actor fa 
inner join film f
on fa.film_id = f.film_id
group by  title
;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(i.film_id) As film_copies
from inventory i 
inner join film f on i.film_id = f.film_id
group by title
;

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
# List the customers alphabetically by last name:
Select p.customer_id,c.last_name, sum(amount) As total_paid
From payment p
inner join customer c on c.customer_id = p.customer_id
group by customer_id 
order by last_name
; 

#7a.Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title, l.language_id, l.name
from film f
inner join language l on f.language_id = l.language_id
where title LIKE 'K%' OR title like 'Q%'

;

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
#actor(actor_id; last_name; first_name) / film(film_id; title) ; film_actor(actor_id; film_id)

select first_name, last_name
from actor
where actor_id in
(select actor_id
from film_actor
where film_id in
(select film_id 
from film
where title = 'Alone Trip'
)
)
;

#7c.You want to run an email marketing campaign in Canada, for which you will need the names and email 
#addresses of all Canadian customers. Use joins to retrieve this information.
#country(country_id, country)
#city(city_id; city ; country_id)
#address(address_id; city_id; )
#customer(customer_id; address_id; firt/last_name; address_id) 

select first_name, last_name 
from customer
where address_id in
(select address_id
from address
where city_id in
(select city_id
from city
where country_id in
(select country_id
from country
where country = 'Canada'
))) ;

#7d. Sales have been lagging among young families, and you wish 
#to target all family movies for a promotion. Identify all 
#movies categorized as _family_ films.

#category(category_id; name)
#film_category(film_id; category_id)
#film(title;film_id)

select title
from film
where film_id in
(select film_id 
from film_category
where category_id in
(select category_id
from category
where name = 'Family'
))
;

#7e.Display the most frequently rented movies in descending order.
#rental(rental_id; inventory_id; customer_id; staff_id)
#inventory(invenotry_id; film_id)
 #film_text(film_id; title)

select s.film_id,inventory_id,title,freq from
(select r.inventory_id,r.freq,film_id from
(select inventory_id,count(*)  as freq from rental group by inventory_id order by freq DESC) r
inner join inventory i on i.inventory_id=r.inventory_id) s
inner join film f  on  f.film_id=s.film_id ;



#7f. Write a query to display how much business, in dollars, each store brought in.
#staff(staff_id; address_id; store_id)
#store(store_id; address_id)
#payment(amount; staf_id, rental_id)

select r.store_id,sum(amount) as total_business

from store r
inner join staff s  on r.store_id = s.store_id
inner join payment p on s.staff_id = p.staff_id
group by store_id
; 

#7g. Write a query to display for each store its store ID, city, and country.
#store(store_id; address_id)
#address(address_id; city_id)
#city(city_id; city; country_id)
#country(country_id; country)

select store_id, city, country
from store s
inner join address a on a.address_id = s.address_id
inner join city c on c.city_id = a.city_id
inner join country n on n.country_id = c.country_id

;

#7h. List the top five genres in gross revenue in descending order
#category(category_id;name)
#film_category(film_id;category_id)
#inventory(inventory_id;film_id;store_id)
#rental(rental_id; inventory_id; staff_id;customer_id)
#payment(rental_id;staff_id;payment_id; amount)

 
select name, sum(amount) as gross_revenue 
from category c
inner join film_category fc on fc.category_id = c.category_id
inner join inventory i on i.film_id = fc.film_id
inner join rental r on r.inventory_id = i.inventory_id
inner join payment p on p.rental_id = r.rental_id
group by name
order by sum(amount) DESC LIMIT 5
;

#8.aIn your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres AS
select name, sum(amount) as gross_revenue 
from category c
inner join film_category fc on fc.category_id = c.category_id
inner join inventory i on i.film_id = fc.film_id
inner join rental r on r.inventory_id = i.inventory_id
inner join payment p on p.rental_id = r.rental_id
group by name
order by sum(amount) DESC LIMIT 5
;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres
;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
