set time_zone='-4:00';

select now();

/***PART 2: MARKETING ANALYSIS***/

/*General Email & Sales Prep*/

/*Create a table called WORK.CASE_SALES_EMAIL that contains all of the email data
as well as both the sales_transaction_date and the product_id from sales.
Please use the WORK.CASE_SCOOT_SALES table to capture the sales information.*/
create table work.case_sales_email as 
   select a.*, b.sales_transaction_date, b.product_id
   from ba710case.ba710_emails a
   inner join work.case_scoot_sales b
   using (customer_id);

select * from work.case_sales_email;

/*Create two separate indexes for product_id and sent_date on the newly created
   WORK.CASE_SALES_EMAIL table.*/
create index idx_proid on work.case_sales_email (product_id);
create index idx_sentdate on work.case_sales_email (sent_date);
 
/***Product email analysis****/
/*Bat emails 30 days prior to purchase
   Create a view of the previous table that:
   - contains only emails for the Bat scooter
   - contains only emails sent 30 days prior to the purchase date*/
create view work.case_sales_email_bat as
	select *  from work.case_sales_email
    where product_id = 7 and
    datediff(sales_transaction_date,sent_date)<=30 and
    datediff(sales_transaction_date,sent_date)>=0 and
    sent_date < sales_transaction_date;

select * from work.case_sales_email_bat;

/*Filter emails*/
/*There appear to be a number of general promotional emails not 
specifically related to the Bat scooter.  Create a new view from the 
view created above that removes emails that have the following text
in their subject.

Remove emails containing:
Black Friday
25% off all EVs
It's a Christmas Miracle!
A New Year, And Some New EVs*/
create view work.case_sales_email_bat_remsub as
	select * from work.case_sales_email_bat where
	email_subject not like "%Black Friday%" and 
	email_subject not like "%25% off all EVs%" and
	email_subject not like "%It's a Christmas Miracle!%" and
	email_subject not like "%A New Year, And Some New EVs%";

select * from work.case_sales_email_bat_remsub;


/*Question: How many rows are left in the relevant emails view.*/
/*Code:*/
select count(*) from work.case_sales_email_bat_remsub;

/*Answer: 407 */


/*Question: How many emails were opened (opened='t')?*/
/*Code:*/
select count(*) from work.case_sales_email_bat_remsub
where opened='t';

/*Answer: 100 */


/*Question: What percentage of relevant emails (the view above) are opened?*/
/*Code:*/
select (
	select count(*) from work.case_sales_email_bat_remsub where opened='t'
	)/count(*) pct
from work.case_sales_email_bat_remsub;

/*Answer: 24.57% */ 


/***Purchase email analysis***/
/*Question: How many distinct customers made a purchase (CASE_SCOOT_SALES)?*/
/*Code:*/
select count(distinct customer_id) from work.case_scoot_sales
where product_id =7;

/*Answer:  6659   */


/*Question: What is the percentage of distinct customers made a purchase after 
    receiving an email?*/
/*Code:*/
select (
	select count(distinct customer_id) from work.case_sales_email_bat_remsub 
    where sent_date < sales_transaction_date and bounced = 'f'
	)/count(distinct customer_id) from work.case_scoot_sales where product_id =7;

/*Answer: 6.01%  */


/*Question: What is the percentage of distinct customers that made a purchase 
    after opening an email?*/
/*Code:*/
select (
	select count(distinct customer_id) from work.case_sales_email_bat_remsub 
    where sent_date < sales_transaction_date and opened='t'
	)/count(distinct customer_id) from work.case_scoot_sales
where product_id =7;
                
/*Answer: 1.5%  */

 
/*****LEMON 2013*****/
/*Complete a comparitive analysis for the Lemon 2013 scooter.  
Irrelevant/general subjects are:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom 
 
/***Product email analysis****/
/*Lemon emails 30 days prior to purchase
   Create a view that:
   - contains only emails for the Lemon 2013 scooter
   - contains only emails sent 30 days prior to the purchase date*/
create view work.case_sales_email_lemon2013 as
	select *  from work.case_sales_email
    where product_id = 3 and
    datediff(sales_transaction_date,sent_date)<=30 and
    datediff(sales_transaction_date,sent_date)>=0 and
    sent_date < sales_transaction_date;

select * from work.case_sales_email_lemon2013;

/*Filter emails*/
/*There appear to be a number of general promotional emails not 
specifically related to the Lemon scooter.  Create a new view from the 
view created above that removes emails that have the following text
in their subject.

Remove emails containing:
25% off all EVs
Like a Bat out of Heaven
Save the Planet
An Electric Car
We cut you a deal
Black Friday. Green Cars.
Zoom */
create view work.case_sales_email_lemon2013_remsub as
	select * from work.case_sales_email_lemon2013 where
	email_subject not like "%25% off all EVs%" and 
	email_subject not like "%Like a Bat out of Heaven%" and
	email_subject not like "%Save the Planet%" and
	email_subject not like "%An Electric Car%" and
	email_subject not like "%We cut you a deal%" and
	email_subject not like "%Black Friday. Green Cars.%" and
	email_subject not like "%Zoom%";

select * from work.case_sales_email_lemon2013_remsub;


/*Question: How many rows are left in the relevant emails view.*/
/*Code:*/
select count(*) from work.case_sales_email_lemon2013_remsub;

/*Answer: 514   */


/*Question: How many emails were opened (opened='t')?*/
/*Code:*/
select count(*) from work.case_sales_email_lemon2013_remsub
where opened='t';

/*Answer:  129 */


/*Question: What percentage of relevant emails (the view above) are opened?*/
/*Code:*/
select (
	select count(*) from work.case_sales_email_lemon2013_remsub where opened='t'
	)/count(*) pct
from work.case_sales_email_lemon2013_remsub;
 
/*Answer: 25.14% */ 


/***Purchase email analysis***/
/*Question: How many distinct customers made a purchase (CASE_SCOOT_SALES)?*/
/*Code:*/
select count(distinct customer_id) from work.case_scoot_sales
where product_id =3;

/*Answer:  13854  */


/*Question: What is the percentage of distinct customers made a purchase after 
    receiving an email?*/
/*Code:*/
select (
	select count(distinct customer_id) from work.case_sales_email_lemon2013_remsub
    where sent_date < sales_transaction_date and bounced = 'f'
	)/count(distinct customer_id) from work.case_scoot_sales
where product_id =3;

/*Answer:  3.66%  */
               
		
/*Question: What is the percentage of distinct customers that made a purchase 
    after opening an email?*/
/*Code:*/
select (
	select count(distinct customer_id) from work.case_sales_email_lemon2013_remsub 
    where sent_date < sales_transaction_date and opened='t'
	)/count(distinct customer_id) from work.case_scoot_sales
where product_id =3;
                
/*Answer:  0.92%  */
