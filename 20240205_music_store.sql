create database musical_store
/*Q1 :Who is the senior most employee based on job title?  */
  select top 1 title,first_name,last_name from [dbo].[employee]
   order by levels desc

/*Q2 :Which country have  the most invoice?  */
 select top 1 COUNT(*)[count_of_invoice],billing_country from invoice
 group by billing_country 
 order by count_of_invoice desc

 /*What are the top 3 values of total invoice? */
 select  top 3 total from invoice
 order by total desc 

 /* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select  top 1 billing_city,sum (total)[ invoicetotal] from invoice
   group by billing_city
   order by [ invoicetotal] desc 

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select  top 1 c.customer_id,c.first_name ,c.last_name,SUM( i.total) as total_spending  from customer as c
join invoice as i on c.customer_id=i.customer_id
 group by c.customer_id,c.first_name,c.last_name
 order by  total_spending  desc 

 
 
 /* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select  distinct c.email,c.first_name, c.last_name from customer as  c 
join [dbo].[invoice] as i on i.customer_id=c.customer_id
join  [dbo].[invoice_line] as i_l on i.invoice_id=i_l.invoice_id
join [dbo].[track] as t on i_l.track_id =t.track_id
where t.track_id in ( select t.track_id from track as t
                      join genre as g on g.genre_id =t.genre_id
					  where g.name ='Rock')
order by c.email

/*Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select  top 10 a.artist_id ,a.name,  COUNT(a.artist_id)as number_of_songs  from artist as a
join album as al on a.artist_id = al.artist_id
join track as t on t.album_id=al.album_id
join genre as g on t.genre_id =g.genre_id
where g.name='Rock'
group by a.artist_id , a.name
order by number_of_songs desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select t.name,t.milliseconds  from track as t
where t.milliseconds > (select  AVG(t.milliseconds) from track as t  )
order by t.milliseconds desc



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */
with top_selling_artist as (
 select  top 1 a.artist_id, a.name , SUM ( i_l.quantity*i_l.unit_price  ) as total_price from invoice_line as i_l
 join track as t on t.track_id=i_l.track_id
 join album as al on t.album_id =al.album_id
 join artist as a on al.artist_id =a.artist_id
 group by a.artist_id ,a.name
 order by total_price desc  )
  
  SELECT c.customer_id, c.first_name, c.last_name, t_s.name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
join top_selling_artist as t_s on t_s.artist_id = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, t_s.name
order by amount_spent desc


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with popular_genre as (
select c.country , count (il.quantity)as purchase , g.name  , g.genre_id , 
rank () over (partition by [country] order by count (  il.quantity ) desc ) rnk 
from invoice as i 
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id = t.track_id
join genre as g on g.genre_id =t.genre_id
join customer as c on i.customer_id =c.customer_id
group by c.country,g.name,g.genre_id  )
 select * from popular_genre
 where rnk =1

 /* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with top_customer as (
select c.customer_id , c.first_name ,c.last_name ,i.billing_country  ,sum (i.total) as total ,
rank() over ( partition by i.billing_country order by sum (i.total) desc ) rnk 
from customer as c
join invoice as i on c.customer_id = i.customer_id
 join invoice_line as il on i.invoice_id = il.invoice_id
 group by c.customer_id , c.first_name ,c.last_name ,i.billing_country ) 
  select * from top_customer
   where rnk=1
  
