
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

--1. Write a query to calculate the price of 'Starry Night' plus 10% tax.
select price ,price*1.1 as tenpercenttax from artworks
where title='Starry Night'

--2. Write a query to display the artist names in uppercase.
select upper(name) as capital from artists;

--3. Write a query to extract the year from the sale date of 'Guernica'.
select year(sale_date) as cyear from sales JOIN artworks on  artworks.artwork_id=sales.artwork_id
where title='Guernica'

--4. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select total_amount from sales JOIN artworks on  artworks.artwork_id=sales.artwork_id
where title='Mona Lisa'


Section2 

select * from artists;
--5. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
select "name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
where quantity> (select avg(quantity) from sales s where  artwork_id = artwork_id)

--6. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
select "name",birth_year from artists e JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
where birth_year < (select avg(birth_year) from artists n where e.country=n.country )

--7. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
CREATE NONCLUSTERED INDEX name_index
ON sales([artwork_id])

exec sp_helpindex sales
--8. Write a query to display artists who have artworks in multiple genres.

select "Name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
group by "Name"
having count(artworks.genre) > 1

--9. Write a query to rank artists by their total sales amount and display the top 3 artists.

select top 3 "Name", DENSE_RANK () OVER(order by total_amount desc) as rank from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id

--10. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
--No artist
select "Name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id 
where genre='Cubism'
INTERSECT
select "Name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id 
where genre='Surrealism'

--11. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

select top 2 price,RANK() OVER (order by price desc) as  rank,quantity from artworks 
JOIN sales on  artworks.artwork_id=sales.artwork_id 

--12. Write a query to find the average price of artworks for each artist.

select "Name",avg(price) as individualavg from artworks JOIN artists  on artists.artist_id = artworks.artist_id 
group by "Name"

--13. Write a query to find the artworks that have the highest sale total for each genre.

select genre,max(total_amount) as maximum from sales JOIN artworks on artworks.artwork_id = sales.artwork_id
group by genre

--14. Write a query to find the artworks that have been sold in both January and February 2024.
select datepart(month,sale_date) from sales;

select title,sale_date from artworks JOIN artists on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
where datepart(month,sale_date)=1 AND datepart(Year,sale_date)=2024
UNION
select title,sale_date from artworks JOIN artists on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
where datepart(month,sale_date)=2 AND datepart(Year,sale_date)=2024
--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select "Name" from artworks JOIN artists on artists.artist_id = artworks.artist_id 
group by "Name"
having avg(price) >  ALL(select avg(price) from artworks where genre='Renaissance')


Section3

--16. Write a query to create a view that shows artists who have created artworks in multiple genres.
Create view showsartists
As
select "Name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
group by "Name"
having count(artworks.genre) > 1
--no artists have created artworks in multiple genres.
select * from showsartists;
--17. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

select "Name" from artists a JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on artworks.artwork_id=sales.artwork_id
group by "Name",title
having price > (select avg(price) from artists b JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id  where a.name=b.name)


--18. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.

select "Name" from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
where (select avg(price) from artworks) > (select avg(price) from artists JOIN artworks on artists.artist_id = artworks.artist_id 
JOIN sales on  artworks.artwork_id=sales.artwork_id
group by "Name")

### Section 4: 4 Marks Questions

19. Write a query to export the artists and their artworks into XML format.
 SELECT
        a.artist_id AS "@artist_id",
        a.name AS "name",
        a.country AS "country",
        a.birth_year AS "birth_year",
        (
        SELECT
            an.artwork_id AS "@artwork_id",
            an.title AS "title",
            an.genre AS "genre",
            an.price AS "price"
        FROM artworks an
        WHERE an.artist_id = a.artist_id
        FOR XML PATH('artwork'), TYPE
      )
    FROM artists a
    FOR XML PATH('artist'), ROOT('artists');
20. Write a query to convert the artists and their artworks into JSON format.
select
   artists.artist_id as 'artists.artist_id',
   artists.[name] as 'artists.name',
   artists.country as 'artists.country',
   artists.birth_year as 'artists.birth_year',
   artworks.artwork_id as 'artworks.artwork_id',
   artworks.title as 'artworks.title',
   artworks.artist_id as 'artworks.artist_id',
   artworks.genre as 'artworks.genre'
   from artists JOIN artworks on artworks.artist_id=artists.artist_id
   FOR JSON Path, Root ('Artists')

### Section 5: 5 Marks Questions

--21. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

create function dbo.totalquantitysold()
returns @mtvf Table(
newquantity int ,
newgenre Varchar(20)
)
As
begin 
select genre,sum(quantity) from sales JOIN artworks on  artworks.artwork_id =sales.artwork_id
group by genre,quantity
having genre=newgenre AND quantity=newquantity
end;

select * from dbo.totalquantitysold (1,'Renaissance');

--22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

create function dbo.averagesalesamount(@newgenre varchar(20))
returns int
As
begin
return(select avg(total_amount) from sales JOIN artworks on  artworks.artwork_id =sales.artwork_id
where genre=@newgenre)
end;
select  dbo.averagesalesamount('Cubism') 


--23. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
NTILE

--24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
create table artworks_log(
artwork_id INT IDENTITY PRIMARY KEY,
title Varchar(20),
changeddescription Varchar(40)
);

create trigger trg_modify
As
select * from artworks
After Update 
Begin
if Update(artwork_id)

insert into artworks_log values(a.title,'Updation Happened')
end;



--25. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
create procedure newsaleandupdate
As
begin 
begin try
begin transaction
commit transaction
end try

begin catch 

end catch
end;

select * from artists;
select * from artworks;
select * from sales;

Alter procedure newsaleandupdate(@newsaleid int, @artid int, @saldate datetime, @quan int, @tot_amount DECIMAL(10,2))
As
Return
begin 
begin try 
begin Transaction
if not exists(select * from sales where quantity >0)
throw 5000,'Negetive values exists',1;

insert into sales values(@newsaleid , @artid , @saldate , @quan, @tot_amount );

update sales
set total_amount=total_amount + @tot_amount
where total_amount>0

commit transaction

end try

begin catch
Rollback Transaction;
print 'Checking'
end catch
end;

exec newsaleandupdate @newsaleid=5 , @artid=5, @saldate='2024-07-05', @quan=3, @tot_amount=200000.00

select * from sales;


Normalization (5 Marks)

26. **Question:**
    Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

c:\Users\tejaswini.sanala\Pictures\Screenshots\Screenshot (189).png

### ER Diagram (5 Marks)

27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.

CREATE TABLE [Customer] (
  [id] int,
  [customer_name] Varchar(10),
  [customer_email] varchar(30)
);

CREATE INDEX [pk] ON  [Customer] ([id]);

CREATE TABLE [Orders] (
  [o_id] int,
  [id] int,
  [order_date] datetime,
  [order_quantity] int,
  [total_amount] decimal(10,2),
  CONSTRAINT [FK_Orders.id]
    FOREIGN KEY ([id])
      REFERENCES [Customer]([id])
);

CREATE INDEX [pk] ON  [Orders] ([o_id]);

CREATE INDEX [fk] ON  [Orders] ([id]);

CREATE TABLE [Products] (
  [p_id] int,
  [id] int,
  [Product_name] varchar(20),
  [Product_category] varchar(20),
  [product_price] decimal(10,2),
  CONSTRAINT [FK_Products.id]
    FOREIGN KEY ([id])
      REFERENCES [Customer]([id])
);

CREATE INDEX [pk] ON  [Products] ([p_id]);

CREATE TABLE [injunction table] (
  [i_id] int,
  [p_id] int,
  [o_id] int
);

CREATE INDEX [pk] ON  [injunction table] ([i_id]);

CREATE INDEX [fk] ON  [injunction table] ([p_id], [o_id]);
