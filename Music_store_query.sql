Q1: Who is the senior most employee based on job title? 

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


Q2: Which countries have the most Invoices? 

Select count(*) as c , billing_country
From Invoice
GROUP BY billing_country
order BY c desc

Q3: What are top 3 values of total invoice? 

SELECT total
FROM Invoice
ORDER BY total des

Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals

select Billing_city,sum(total) as Total_invoive 
from Invoice
Group BY Billing_city
order by Total_invoive
limit 1

Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.

select c.first_name, c.last_name, c.customer_id, 
SUM (i.total) as Total_spending
from customer as c
JOIN Invoice as i
ON c.customer_id = i.customer_id
Group By c.customer_id
Order By Total_spending desc
Limit 1


Question Set 2 - Moderate

Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.

select c.email, c.first_name, c.last_name, g.name
from Customer as c
JOIN Invoice as i
On c.customer_id= i.customer_id
JOIN invoice_line as il
ON il.invoice_id = i.invoice_id
JOIN Track as t
ON il.track_id = t.track_id
JOIN genre as g
ON t.genre_id= g.genre_id
where g.name LIKE 'Rock'
Group by c.customer_id, G.name
Order By c.Email asc


Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.


select a.artist_id, a.name, count(a.artist_id) as Number_of_songs
from artist as a
JOIN album as al
ON a.artist_id = al.artist_id
JOIN track as t
ON t.album_id = al.album_id 
JOIN genre as g
ON t.genre_id = g.Genre_id
where g.name like 'Rock' 
group by a.artist_id 
Order By Number_of_songs DESC
limit 10



Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_track_length
	              FROM track )
ORDER BY milliseconds DESC;

 Question Set 3 - Advance

1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1