/* Вывести те заказы, где постатейная сумма не совпадает с итоговой */
select sor.order_id 
from sales_order sor,
item it,
product pro,
price pr 
where sor.order_id = it.order_id  and
it.product_id = pro.product_id and
pr.product_id = pro.product_id and
((sor.order_date between pr.start_date and pr.end_date) or (sor.order_date > pr.start_date and pr.end_date IS NULL)) 
group by sor.order_id
having 
sum(pr.list_price) <> sum(it.actual_price)
order by sor.order_id 
/*select sor.order_id ,pr.product_id, pr.list_price, it.actual_price
from sales_order sor,
item it,
product pro,
price pr 
where sor.order_id = it.order_id  and
it.product_id = pro.product_id and
pr.product_id = pro.product_id and
((sor.order_date between pr.start_date and pr.end_date) or (sor.order_date > pr.start_date and pr.end_date IS NULL)) and 
pr.list_price <> it.actual_price 
group by sor.order_id,pr.product_id, pr.list_price, it.actual_price 
order by sor.order_id 
*/
/*select * 
from sales_order 
order by order_id*/
/*select * 
from item 
order by order_id */
/*select pr.product_id
from price pr,
item it,
product pro
where pr.product_id = pro.product_id 
and
      pro.product_id = it.product_id  
and 
      pr.list_price <> it.actual_price
	  group by pr.product_id 
	  order by pr.product_id */ 