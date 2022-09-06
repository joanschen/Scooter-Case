/*All tables should be created in your WORK schema, unless otherwise noted*/

/*Set Time Zone*/

set time_zone='-4:00';

select now();

/*Preliminary Data Collection
select * to investigate your tables.*/
select * from ba710case.ba710_prod;
select * from ba710case.ba710_sales;
select * from ba710case.ba710_emails;

/*Investigate production dates and prices from the prod table*/
select * from ba710case.ba710_prod
   where product_type='scooter'
   order by base_msrp;

/***PRELIMINARY ANALYSIS***/

/*Create a new table in WORK that is a subset of the prod table
which only contains scooters.
Result should have 7 records.*/
create table work.case_scoot_names as 
   select * from ba710case.ba710_prod
   where product_type = 'scooter';
   
select * from work.case_scoot_names;

/*Use a join to combine the table above with the sales information*/
create table work.case_scoot_sales as
   select a.model, a.product_type, a.product_id,
		  b.customer_id, b.sales_transaction_date, 
          date(b.sales_transaction_date) as sale_date,
          b.sales_amount, b.channel, b.dealership_id
   from work.case_scoot_names a
   inner join ba710case.ba710_sales b
      on a.product_id=b.product_id;
      
select * from work.case_scoot_sales;

/*Create a list partition for the case_scoot_sales table on product_id. (Hint: Alter table)  
Create one partition for each product_type.  Since there are two release dates for the
Lemon model, create a partition for Lemon_2010 and a partition for Lemon_2013.
Name each partition as the product's name.*/
alter table work.case_scoot_sales
	partition by list (product_id)
    (partition bat values in (7),
    partition blade values in (5),
    partition bat_limited_edition values in (8),
    partition lemon_limited_edition values in (2),
    partition lemon_zester values in (12),
    partition lemon_2010 values in (1),
    partition lemon_2013 values in (3));
    
/***PART 1: INVESTIGATE BAT SALES TRENDS***/  

/*Select Bat models from your table.*/
select * from work.case_scoot_sales partition (bat);

/*Count the number of Bat sales from your table.*/
select count(*) from work.case_scoot_sales partition (bat);

/*What is the total revenue of Bat sales?*/
select sum(sales_amount) from work.case_scoot_sales partition (bat);

/*When was most recent Bat sale?*/
select max(sale_date) from work.case_scoot_sales partition (bat);

/*Summarize the number of sales (count) and sales total (sum of amount) by date
   for each product.
Create a table in your WORK schema that contains one record for each date & product id 
   combination.
Include model, product_id, sale_date, a column for count of sales, 
   and a column for sum of sales*/
create table work.case_scoot_daily_sales as 
   select model, product_id, sale_date, count(product_id) sales_count, sum(sales_amount) total_sales
   from work.case_scoot_sales
   group by sale_date, product_id;

select  * from work.case_scoot_daily_sales ;

/***Bat Sales Analysis*********************************/
/*Now quantify the sales trends. Create columns for cumulative sales, total sales 
   for the past 7 days, and percentage increase in cumulative sales compared to 7 
   days prior using the following steps:*/
   
/*CUMULATIVE SALES
   Create a table that is a subset of the table above including all columns, 
   but only include Bat scooters.   Create a new column that contains the 
   cumulative sales amount (one row per date).
Hint: Window Functions, Over*/
create table work.case_scoot_bat_cumu as 
   select *, sum(total_sales) over(order by sale_date) as cumu_day
   from work.case_scoot_daily_sales where model = 'bat';

select * from work.case_scoot_bat_cumu;

/*SALES PAST 7 DAYS
   Add a column to the table created above (or create a new table with an additional
   column) that computes a running total of sales for the previous 7 days.
   (i.e., for each record the new column should contain the sum of sales for 
   the current date plus the sales for the preceeding 6 records).

When the Word document is released with PART 2, paste a sample of your 
Results Grid to the Word document.*/
create table work.case_scoot_bat_cumu_7days as 
	select *, sum(total_sales) over(rows between 6 preceding and current row) cumu_7days
	from work.case_scoot_bat_cumu ;

select * from work.case_scoot_bat_cumu_7days;

/*GROWTH IN CUMULATIVE SALES OVER THE PAST WEEK
   Add a column to the table created above (or create a new table with an additional 
   column) that computes the cumulative sales growth in the past week as a percentage change
   of cumulative sales (current record) compared to the cumulative sales from the 
   same day of the previous week (seven records above).  
(Formula: (Current Cumulative Sales - Cumulative Sales 7 Days Ago) / Cumulative Sales 7 Days Ago
(Hint: Use the lag function.)

When the Word document is released with PART 2, paste a sample of your 
Results Grid to the Word document.*/
create table work.case_scoot_bat_wow as 
	select *,
	lag(cumu_day,7) over() cumu_preweek,
	concat(round((cumu_day/lag(cumu_day,7) over() -1 )* 100,2),'%') wow
	from work.case_scoot_bat_cumu_7days;

select * from work.case_scoot_bat_wow;

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer:  On 2016-12-06 the cumulative weekly sales growth dropped below 10%.

select * from work.case_scoot_bat_wow where wow < 10 order by sale_date;

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer:  It took 57 days for cumulative sales growth to drop below 10% since the launch date.

select datediff('2016-12-06',min(sale_date)) from work.case_scoot_bat_wow;
*/


/***Bat Limited Edition Sales Analysis*********************************/
/*Is the launch timing (October) a potential cause for the drop?
Replicate the Bat Sales Analysis for the Bat Limited Edition.
As above, complete the steps to calculate CUMULATIVE SALES, SALES PAST 7 DAYS,
and CUMULATIVE SALES GROWTH IN PAST WEEK*/
create table work.case_scoot_batlimit_cumu as 
   select  *, sum(total_sales) over(order by sale_date) as cumu_day
   from work.case_scoot_daily_sales where model = 'bat limited edition';

select * from work.case_scoot_batlimit_cumu;

create table work.case_scoot_batlimit_cumu_7days as 
	select *, sum(total_sales) over(rows between 6 preceding and current row) cumu_7days
	from work.case_scoot_batlimit_cumu ;

select * from work.case_scoot_batlimit_cumu_7days;

create table work.case_scoot_batlimit_wow as 
	select *,
	lag(cumu_day,7) over() cumu_preweek,
	concat(round((cumu_day/lag(cumu_day,7) over() -1 )* 100,2),'%') wow
	from work.case_scoot_batlimit_cumu_7days;

select * from work.case_scoot_batlimit_wow;

/*When Part 2 is released tomorrow, please include a screenshot of your results grid
   for your final Bat Limited Edition Sales Analysis Table*/

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer:  On 2017-04-29 the cumulative weekly sales growth dropped below 10%.

select * from work.case_scoot_batlimit_wow where wow < 10 order by sale_date;

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer:  It took 73 days for cumulative sales growth to drop below 10% since the launch date.

select datediff('2017-04-29',min(sale_date)) from work.case_scoot_batlimit_wow;

Question: Is there a difference in the behavior in cumulative sales growth 
between the Bat edition and either the Bat Limited edition? (Make a statement comparing
the growth statistics.)
Answer: When Comparing the days between the launch date and the date with a growth rate below 10%, 
the bat edition has 57 days, whereas the bat limited edition has 73 days. 
Therefore, we can conclude that the product popularity of the bat limited edition lasts longer than that of the bat edition. 
*/


/***Lemon 2013 Sales Analysis*********************************/
/*The Bat Limited was at a higher price point than the Bat.
Let's take a look at the 2013 Lemon model, since it's also a similar price point.  
Replicate the Bat Sales Analysis for the 2013 Lemon scooter.
As above, complete the steps to calculate CUMULATIVE SALES, SALES PAST 7 DAYS,
and CUMULATIVE SALES GROWTH IN PAST WEEK*/
create table work.case_scoot_lemon2013_cumu as 
   select  *, sum(total_sales) over(order by sale_date) as cumu_day
   from work.case_scoot_daily_sales where product_id = 3;

select * from work.case_scoot_lemon2013_cumu;

create table work.case_scoot_lemon2013_cumu_7days as 
	select *, sum(total_sales) over(rows between 6 preceding and current row) cumu_7days
	from work.case_scoot_lemon2013_cumu ;

select * from work.case_scoot_lemon2013_cumu_7days;

create table work.case_scoot_lemon2013_wow as 
	select *,
	lag(cumu_day,7) over() cumu_preweek,
	concat(round((cumu_day/lag(cumu_day,7) over() -1 )* 100,2),'%') wow
	from work.case_scoot_lemon2013_cumu_7days;

select * from work.case_scoot_lemon2013_wow;

/*When Part 2 is released tomorrow, please include a screenshot of your results grid
   for your final 2013 Lemon Sales Analysis Table*/

/*Question: On what date does the cumulative weekly sales growth drop below 10%?
Answer:    On 2013-07-01 the cumulative weekly sales growth dropped below 10%.

select * from work.case_scoot_lemon2013_wow where wow < 10 order by sale_date;

Question: How many days since the launch date did it take for cumulative sales growth
to drop below 10%?
Answer:   It took 61 days for cumulative sales growth to drop below 10% since the launch date.

select datediff('2013-07-01',min(sale_date)) from work.case_scoot_lemon2013_wow;

Question: Is there a difference in the behavior in cumulative sales growth 
between the Bat edition and the 2013 Lemon edition?  (Make a statement comparing
the growth statistics.)
Answer: When Comparing the days between the launch date and the date with a growth rate below 10%, 
the bat edition has 57 days, whereas the 2013 lemon edition has 61 days. 
Therefore, we can conclude that the product popularity of the 2013 lemon edition lasts a little longer than that of the bat edition.
*/

  