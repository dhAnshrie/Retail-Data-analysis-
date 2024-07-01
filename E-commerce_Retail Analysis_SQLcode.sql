#E-COMMERCE RETAIL DATA ANALYSIS
#SQL PROJECT 1





create database Ecommerce_DA;
use Ecommerce_DA;
select  * from customers_new;
select * from prod_cat_info;
select * from transactions_new;

#1) What is the total number of rows in each of the 3 table  in the database 
select  count(*) from customers_new;
select count(*) from prod_cat_info;
select count(*) from transactions_new;

#2)what is the total number of trasnction that have a return
ALTER TABLE transactions_new  
RENAME COLUMN  ï»¿transaction_id to trans_id;

select  count(*)
from transactions_new  
where total_amt<0;
 
/*3) As you have notice the provided the across the dataset are not in the correct format. As first step please convert the data varibale into 
  date format*/
desc transactions_new;

update  transactions_new
set tran_date = STR_TO_DATE(tran_date, '%d-%m-%Y');

alter table transactions_new 
modify column tran_date date;


/*4)what is the time range of the transactions data available for analysis? Show the  output in number of days , month and year 
simultaneoulsy in different coloums;*/
select 
    tran_date,
    DAY(tran_date) AS day_of_month,
    MONTH(tran_date) AS month,
    YEAR(tran_date) AS year
from transactions_new;


SELECT 
    DATEDIFF(MAX(tran_date), MIN(tran_date)) AS days_range,
    TIMESTAMPDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS months_range,
    TIMESTAMPDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS years_range
FROM transactions_new;


#5) which product category does the sub category "DIY"belongs to 

select prod_cat, prod_subcat from prod_cat_info
where prod_subcat = 'DIY';



#DATA ANALYSIS

#1) which channels is mostly frequenlty used for transcation
select Store_type , count(*) as Transcation 
from transactions_new
group by Store_type 
order by Transcation  desc;

#2)What is the coount of male and female members in the database

select Gender,count(*) AS count_of_customers
from customers_new
group by  Gender
having Gender in ('F','M');

#3)from which city we have the maximum numbers of customers and how many we have ?
select  * from customers_new;
desc customers_new;
ALTER TABLE customers_new
RENAME COLUMN ï»¿customer_Id to cust_name;

select   city_code ,count(cust_name) as customer_count 
from customers_new
group by city_code
order by customer_count desc
limit 1;

#4)how many subcategory are under the book category 

select * from prod_cat_info;

select prod_cat , count(prod_sub_cat_code)
from prod_cat_info
group by prod_cat
having prod_cat='Books';

#5 what is the maximum qunatiity of products ever order 
select * from transactions_new;

select  prod_cat_code, count(Qty)as max_quan
from transactions_new
group by prod_cat_code 
order by  max_quan desc
limit 1;


#6 what is the net total revenu generated  in categories books and electronics 
select * from transactions_new;

select round(SUM(T.total_amt),0) as net_total_revenue
from transactions_new as T
join  prod_cat_info as P on T.prod_cat_code = P.prod_cat_code
where  P.prod_cat in ('books', 'electronics');

#7 how many customers have >10 transcation with us, excluding returns.

 WITH return_table AS (
select  trans_id
from transactions_new  
where total_amt<0

)
SELECT trans_id , count(*) as TS
FROM transactions_new
WHERE trans_id NOT IN (SELECT trans_id FROM return_table)
GROUP BY trans_id
having TS  > 10
;




#8 What is the combine revenue earned by from the electronics and clothing categories from flagship store.
select P.prod_cat ,T.Store_type ,sum(T.total_amt) as CA from prod_cat_info AS P
INNER JOIN transactions_new AS T ON P.prod_cat_code = T.prod_cat_code
group by P.prod_cat, T.Store_type
having P.prod_cat in ('CLothing' , 'Electronics') and T.Store_type= 'Flagship store';

#9 What is the total revenu genrated by the male customers in electronics category ?output should display total revenu by prod sub cat

select  * from customers_new;

alter  table customers_new
rename COLUMN cust_name to  cust_id;
select * from prod_cat_info;
select * from transactions_new;


SELECT P.prod_subcat,rount(SUM(T.total_amt),0) AS total_revenue
FROM transactions_new AS T
JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
JOIN customers_new AS C ON T.cust_id = C.cust_id
WHERE C.Gender = 'M' AND P.prod_cat = 'Electronic'
GROUP BY P.prod_subcat;



#10)what is the percentage of sales and returns by product sub category ; display only top 5 sub category in terms of sales 
WITH sub_category_totals AS (
    SELECT 
        prod_subcat_code,
        SUM(CASE WHEN total_amt > 0 THEN total_amt ELSE 0 END) AS total_sales,
        SUM(CASE WHEN total_amt < 0 THEN -total_amt ELSE 0 END) AS total_returns
    FROM 
        Transactions_new
    GROUP BY 
        prod_subcat_code
),
top_5_sub_categories AS (
    SELECT 
        prod_subcat_code,
        total_sales,
        total_returns,
        (total_sales / (SELECT round(SUM(total_sales),0) FROM sub_category_totals) * 100) AS sales_percentage,
        (total_returns / (SELECT round(SUM(total_returns),0) FROM sub_category_totals) * 100) AS returns_percentage
    FROM 
        sub_category_totals
    ORDER BY 
        total_sales DESC
    LIMIT 5
)
SELECT 
    prod_subcat_code,
    total_sales,
    total_returns,
    sales_percentage,
    returns_percentage
FROM 
    top_5_sub_categories;


/*11)for all customers aged between 25 to 30 years find what is the net revenue
 generated by the consumers in last 30 days of transactions for max transaction 
ata available in the data?*/

SELECT 
    SUM(t.total_amt) AS net_revenue
FROM 
    transactions_new t
JOIN 
    customers_new c ON c.cust_id = t.cust_id
WHERE 
    TIMESTAMPDIFF(YEAR, c.DOB, CURDATE()) BETWEEN 25 AND 30 
AND
  t.tran_date >= (SELECT DATE_SUB(MAX(tran_date), INTERVAL 30 DAY) FROM transactions_new);
  
  #12)which product cateogory has seen the max value of returns in the last 3 months of transcations?
  
  select * from transactions_new;
  SELECT c.prod_cat, SUM(total_amt) AS total_returns
FROM transactions t
JOIN products p ON t.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH) 
  AND t.transaction_type = 'return'  
GROUP BY c.category_name
ORDER BY total_returns DESC
LIMIT 1;
  
  




#13) which store type sells the maximum products; by values of sales amount and quantity sold


select  Store_type
from (
    select Store_type, 
           ROW_NUMBER() OVER (ORDER BY SUM(Qty) DESC, SUM(total_amt) DESC) AS ranked
    from transactions_new
    GROUP BY Store_type
) transactions_new
WHERE ranked  = 1;

#14 What are the categories for which average revenue is above all over average.

select * from transactions_new;
select * from prod_cat_info;

WITH category_avg AS (
    SELECT P.prod_cat_code, AVG(T.total_amt) AS avg_revenue
    FROM transactions_new AS T
    JOIN prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code
    GROUP BY P.prod_cat_code
)
SELECT CA.prod_cat_code, CA.avg_revenue
FROM category_avg AS CA
WHERE CA.avg_revenue > (SELECT AVG(T.total_amt) FROM transactions_new AS T);



 #15 Find the average and total revenue by each subcategory for all the categories which are among top 5 categories in terms of qunatity sold
 
 select * from prod_cat_info;
select * from transactions_new;


WITH TopCategories AS (
    SELECT
        prod_cat_code
    FROM
        Transactions_new
    GROUP BY
        prod_cat_code
    ORDER BY
        SUM(Qty) DESC
    LIMIT 5
)
SELECT
    t.prod_cat_code,
  
    round(SUM(t.total_amt),0) AS total_revenue,
    round(AVG(t.total_amt),0) AS average_revenue
FROM
    Transactions_new t
JOIN
    TopCategories tc ON t.prod_cat_code = tc.prod_cat_code
GROUP BY
    t.prod_cat_code
order by t.prod_cat_code
;
    
    
    
 