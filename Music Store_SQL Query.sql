# Q.1 Which countries have the most Invoices? 

select count(*) as invoice_count, billing_country as country 
from invoice
group by billing_country
limit 1

# Q.2 What are top 3 values of total invoice?

select * from invoice
order by total desc
limit 3;

/* Q.3 Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

select round(sum(total)) as invoice_totals, billing_city
from invoice
group by billing_city
order by invoice_totals desc
limit 1;

/* Q.4 Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money. */

select customer.customer_id, customer.first_name, round(sum(total)) as total_Spent
from invoice join customer 
on invoice.customer_id = customer.customer_id
group by customer.customer_id, customer.first_name
order by sum(total) desc
limit 1;

/* Q.5 Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A. */

select customer.email, customer.first_name, customer.last_name, genre.name as Genre
from customer join invoice
on customer.customer_id =invoice.customer_id
join invoice_line
on invoice.invoice_id=invoice_line.invoice_id
join track 
on invoice_line.track_id=track.track_id
join genre
on track.genre_id=genre.genre_id
where genre.name="Rock"
order by email ;

/* Q.6 Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.name as artist_name, count(track_id) as track_count
from genre join track
on genre.genre_id=track.genre_id
join album2
on track.album_id=album2.album_id
join artist
on album2.artist_id=artist.artist_id
where genre.name="Rock"
group by artist_name 
order by track_count desc
limit 10;

/* Q.7 Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first. */

select name , milliseconds
from track
where milliseconds> (select avg(milliseconds) as avg_song_length from track)
order by milliseconds desc;

/*Q.8 Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent.*/

SELECT customer.first_name as customer_name,artist.name as artist_name ,round(SUM(invoice.total)) as total_Spent,
ROW_NUMBER() OVER(PARTITION BY customer.first_name ORDER BY round(SUM(invoice.total)) DESC) AS RowNo 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
join invoice_line 
on invoice.invoice_id=invoice_line.invoice_id
join track
on invoice_line.track_id=track.track_id
join album2
on album2.album_id=track.album_id
join artist 
on artist.artist_id=album2.artist_id
GROUP BY 1,2
ORDER BY 1 ASC, 3 DESC

/* Q.9 We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genre. */

WITH popular_genre AS 
(
    SELECT customer.country, genre.name,sum(invoice_line.quantity) AS purchase,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY SUM(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 1,2
	ORDER BY 1 ASC, 3 DESC
)
SELECT country, name,purchase FROM popular_genre WHERE RowNo <= 1

/* Q.10 Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount, */

WITH Top_customer AS 
(
    SELECT customer.country as country, customer.first_name as customer_name,round(SUM(invoice.total)) as total_Spent,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY round(SUM(invoice.total)) DESC) AS RowNo 
    FROM invoice 
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2
	ORDER BY 1 ASC, 3 DESC
)
SELECT country, customer_name,total_Spent FROM Top_customer WHERE RowNo <= 1
