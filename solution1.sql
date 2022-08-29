select * from sales
select * from menu 
select * from members

--Q.1 What is the total amount each customer spent at the restaurant?

select S.customer_id,sum(M.price)as [total price]
from sales S
left join menu M
on S.product_id=M.product_id
group by S.customer_id


----- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct(order_date)) as visited_days
from sales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?

select S.customer_id,M.product_name
from sales S
left join menu M
on S.product_id=M.product_id
where order_date=(select min(order_date) from sales)


---4. What is the most purchased item on the menu and how many times was it purchased by all customers?


select top 1 M.product_name,count(S.product_id) as order_count
from sales S
left join menu M
on S.product_id=M.product_id
group by S.product_id,M.product_name
order by count(S.product_id) desc

---5. Which item was the most popular for each customer


with order_rank As
(
select s.customer_id,m.product_name,count(m.product_name) as order_count,
rank() over(partition by s.customer_id order by count(m.product_name) desc) as order_freq_rank
from sales s
left join menu m
on s.product_id = m.product_id
group by s.customer_id,m.product_name
 )
select Customer_id,product_name,order_count
from order_rank
where order_freq_rank=1



-----or---
select customer_id,product_name,order_count from
(
select s.customer_id,m.product_name,count(m.product_name) as order_count,
rank() over(partition by s.customer_id order by count(m.product_name) desc) as order_freq_rank
from sales s
left join menu m
on s.product_id = m.product_id
group by s.customer_id,m.product_name
 ) as result
 where order_freq_rank =1



----6.Which item was purchased first by the customer after they became a member?
 select customer_id,product_name,join_date from
 (
 select s.customer_id,s.order_date,Me.product_name,m.join_date,
 rank() over(partition by s.customer_id order by order_date ) as order_rank
  from sales s
  left join members m
  on s.customer_id=m.customer_id
  left join menu Me
  on s.product_id=Me.product_id
  where s.order_date>=m.join_date
  ) 
  as result
  where order_rank=1

 ---7.Which item was purchased just before the customer became a member?
 select customer_id,product_name from (
  select s.customer_id,Me.product_name,s.order_date,m.join_date,
 rank() over(partition by s.customer_id order by order_date desc ) as order_rank
  from sales s
  left join members m
  on s.customer_id=m.customer_id
  left join menu Me
  on s.product_id=Me.product_id
  where s.order_date<m.join_date
) as result
where order_rank=1

--8.What is the total items and amount spent for each member before they became a member?

  select s.customer_id,count(Me.product_name) as total_item,sum(Me.price) as amount
  from sales s
  left join members m
  on s.customer_id=m.customer_id
  left join menu Me
  on s.product_id=Me.product_id
  where s.order_date<m.join_date 
  group by s.customer_id



---9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

 select customer_id,sum(points) from
 (
  select s.customer_id,me.product_name,me.price,
  case when me.product_name ='sushi' then me.price*20
       else me.price*10
  end as points
  from sales s
  left join menu me
  on s.product_id=me.product_id
  ) as result
  group by customer_id
 

 ---10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
 ----not just sushi — how many points do customer A and B have at the end of January?

 select s.customer_id,
 sum(case
     when s.order_date between m.join_date and dateadd(day,6,m.join_date)  then  me.price*20
	  when me.product_name='sushi' then me.price*20
      else price*10
     end)  as points     
 from sales s
 left join menu me
 on s.product_id=me.product_id
 left join members m
 on s.customer_id=m.customer_id
group by s.customer_id

 


 
