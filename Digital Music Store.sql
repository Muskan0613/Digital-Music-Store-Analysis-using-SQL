
-- Who is the senior most employee based on job title?

Select * From employee
Order By levels desc
limit 1;

-- Which countries have the most Invoices?

Select Count(*) as c, billing_country
From Invoice
Group By billing_country
Order By c desc;

-- What are top 3 values of Total Invoice?

Select Total from Invoice
Order By total desc
limit 3;

-- Which city has the best customers? We would like to throw a promotional music festival in
-- the city we made the most money. Write a query that returns one city that has the highest sum
-- of invoice totals. Return both the city name and sum of all invoice totals.

Select Sum(total) as invoice_total, billing_city
From invoice
Group by billing_city
Order by invoice_total desc;

-- Who is the best customer? The customer who has spent the most money will be decalred the 
-- best customer. Write a query that returns the person who has spent the most money.

Select customer.customer_id, customer.first_name, customer.last_name,
Sum(invoice.total) as total
From customer
Join invoice on customer.customer_id = invoice.customer_id
Group by customer.customer_id
Order By total desc
limit 1

-- Write query to return the email, first name, last name, & genre of all the rock music
-- listeners. Return your list ordered alphabetically by email starting with A.

Select distinct email, first_name, last_name
from customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in ( 
	Select track_id from track
				 Join genre on track.genre_id = genre.genre_id
				 where genre.name like 'Rock')
Order by email;

-- Let's invite the artist who have written the most rock music in our dataset. Write a query
-- that returns the Artist name and total track count of the top 10 rock bands.

Select artist.artist_id, artist.name, Count(artist.artist_id) as number_of_songs
From track
Join album on album.album_id = track.album_id
Join artist on artist.artist_id = album.artist_id
Join genre on genre.genre_id = track.genre_id
Where genre.name like 'Rock'
Group by artist.artist_id
Order by number_of_songs desc
limit 10;

-- Return all the track names that have a song length longer than average song length.
-- Return the name and milliseconds for eack track. Order by the song length with the longest song
-- listed first.

Select name, milliseconds
from track
where milliseconds > ( Select Avg(milliseconds) as avg_track_length
					 from track )
Order by milliseconds desc;

-- Find out how much amount spent by each customer on artists? Write a query to return customer
-- name, artist and total spent.

With best_selling_artist as ( 
	Select artist.artist_id as artist_id, artist.name as artist_name, 
    Sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
    from invoice_line
	Join track on track.track_id = invoice_line.track_id
	Join album on album.album_id = track.album_id
	Join artist on artist.artist_id = album.artist_id
	Group by 1
	Order by 3 desc
	limit 1
)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
Sum(il.unit_price * il.quantity) as amount_spent
from invoice i
Join customer c on c.customer_id = i.customer_id
Join invoice_line il on il.invoice_id = i.invoice_id
Join track t on t.track_id = il.track_id
Join album alb on alb.album_id = t.album_id
Join best_selling_artist bsa on bsa.artist_id = alb.artist_id
Group by 1,2,3,4
Order by 5 desc;

-- We want to find out the most popular music genre for each country. We determine the most
-- popular genre as the genre with the highest amount of purchases. Write a query that return each
-- country along with the top genre. For countries where the maximum number of purchases is shared
-- return all genres.

With popular_genre As (
	Select customer.country, genre.name, genre.genre_id, Count(invoice_line.quantity) As purchases, 
	Row_number() over (Partition by customer.country Order by Count (invoice_line.quantity) desc) as RowNo
	From invoice_line
	Join invoice on invoice.invoice_id = invoice_line.invoice_id
	Join customer on customer.customer_id = invoice.customer_id
	Join track on track.track_id = invoice_line.track_id
	Join genre on genre.genre_id = track.genre_id
	Group By 1, 2, 3
	Order By 1 asc
)
Select * from popular_genre Where RowNo <= 1;

-- Write a query that determines the customer that has spent the most on music for each country. Write a 
-- query that returns the country along with the top customer and hoq much they spent for countries. Where
-- the top amount spent is shared, provide all cusotmers who spent this amount.

With Recursive
Customer_with_country as (
	Select customer.customer_id, first_name, last_name, billing_country, Sum(total) as total_spending
	from invoice
	Join customer on customer.customer_id = invoice.customer_id
	Group By 1, 2, 3, 4
	Order By 2, 3 desc),
		
Country_max_spending as (
	Select billing_country, max(total_spending) as max_spending 
	from customer_with_country
	Group By Billing_country)
	
Select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
Join country_max_spending as ms on cc.billing_country = ms.billing_country
Where cc.total_spending = ms.max_spending
Order By 1;





































































