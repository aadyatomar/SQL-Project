use orders;
show tables;

#Ans 1
select CUSTOMER_EMAIL, CUSTOMER_CREATION_DATE,  
case
when Year(CUSTOMER_CREATION_DATE) <2005 THEN 'Category A'
when Year(CUSTOMER_CREATION_DATE) >=2005 and Year(CUSTOMER_CREATION_DATE) <2011 then 'Category B'
When Year(CUSTOMER_CREATION_DATE) >=2011 then 'Category C' 
end as 'Categories',
concat(case
when CUSTOMER_GENDER = 'M' THEN 'Mr' else 'Ms'
end , ' ', concat(upper(CUSTOMER_FNAME), ' ', upper(CUSTOMER_LNAME))) name1 from online_customer;


#Ans 2
select  P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, P.PRODUCT_PRICE, P.PRODUCT_DESC, 
P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE as inventory_value,
case
when PRODUCT_PRICE > 200000 THEN PRODUCT_PRICE*0.80
when PRODUCT_PRICE >100000 AND PRODUCT_PRICE < 200000 THEN PRODUCT_PRICE*0.85
when PRODUCT_PRICE <= 100000 then PRODUCT_PRICE*0.90
END as NEW_PRICE
from product P LEFT OUTER JOIN (select distinct product_id from order_items) O
ON P.PRODUCT_ID=O.PRODUCT_ID
order by inventory_value desc;

#ANS3
select pro.Product_class_code, pro.Product_class_DESC, COUNT(pro.PRODUCT_CLASS_CODE) as product_type, (p.product_quantity_avail*P.product_price) as inventory_value
from product_class pro
JOIN PRODUCT P ON PRO.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
WHERE (p.product_quantity_avail*P.product_price) > 100000
group by PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESC, INVENTORY_VALUE
ORDER BY inventory_value DESC;

#ANS 4
Select c.CUSTOMER_ID, concat(c.CUSTOMER_FNAME, ' ', c.CUSTOMER_LNAME) as full_name, c.CUSTOMER_EMAIL, c.CUSTOMER_PHONE, a.country
FROM ONLINE_CUSTOMER c inner join ADDRESS a
on c.ADDRESS_ID=a.ADDRESS_ID
where customer_id  in (select CUSTOMER_ID from order_header where 
ORDER_STATUS = 'Cancelled');

#ANS 5
select s.SHIPPER_NAME, a.CITY, count(oc.customer_id) as no_of_customers , count(o.order_status) as no_of_consignments
from order_header o inner join shipper s
on o.SHIPPER_ID = s.SHIPPER_ID
inner join online_customer oc 
on oc.CUSTOMER_ID = o.CUSTOMER_ID
inner join address a
on a.address_id= oc.address_id
where order_status ='Shipped'
and shipper_name = 'DHL'
Group by s.shipper_name, a.city;

#Ans 6
select p.product_id , p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL as Quantity_sold, p.PRODUCT_QUANTITY_AVAIL as Quantitiy_available, 
case 
when pc.product_class_desc in ('Electronics', 'computer') and oi.PRODUCT_QUANTITY=p.PRODUCT_QUANTITY_AVAIL then "No Sales in past, give discount to reduce inventory"
when pc.product_class_desc in ('Electronics', 'computer') and p.PRODUCT_QUANTITY_AVAIL< 0.1*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Low Inventory, need to add inventory"
when pc.product_class_desc in ('Electronics', 'computer') and p.PRODUCT_QUANTITY_AVAIL< 0.5*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Medium Inventory, need to add some inventory"
when pc.product_class_desc in ('Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL=p.PRODUCT_QUANTITY_AVAIL then "No Sales in past, give discount to reduce inventory"
when pc.product_class_desc in ('Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL< 0.2*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Low Inventory, need to add inventory"
when pc.product_class_desc in ('Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL< 0.6*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Medium Inventory, need to add some inventory"
when pc.product_class_desc in ('Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL>= 0.6*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Sufficient Inventory"
when pc.product_class_desc not in ('Electronics', 'computer', 'Mobiles', 'watches') and oi.PRODUCT_QUANTITY=p.PRODUCT_QUANTITY_AVAIL then "No Sales in past, give discount to reduce inventory"
when pc.product_class_desc not in ('Electronics', 'computer', 'Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL< 0.3*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Low Inventory, need to add inventory"
when pc.product_class_desc not in ('Electronics', 'computer', 'Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL< 0.7*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Medium Inventory, need to add some inventory"
when pc.product_class_desc not in ('Electronics', 'computer', 'Mobiles', 'watches') and p.PRODUCT_QUANTITY_AVAIL>= 0.7*(oi.PRODUCT_QUANTITY-p.PRODUCT_QUANTITY_AVAIL) then "Sufficient Inventory"
end as Inventory_status
from product p
left join order_items oi on p.product_id = oi.product_id
left join order_header oh on oi.order_id = oh.order_id
left join product_class pc on p.PRODUCT_CLASS_CODE= pc.PRODUCT_CLASS_CODE;


#Ans 7
select o.order_id, P.Len*P.Width*P.Height as volume  
from product p inner join order_items o
on p.product_id = o.product_id
Where 'volume' < 18000000
order by volume desc limit 1;


#ANS 8
SELECT oc.CUSTOMER_ID, concat(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) as full_name, count(payment_mode) as Total_quantity ,PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE as total_value
from online_customer oc inner join order_header oh
on oc.customer_id=oh.customer_id
inner join order_items oi
on oi.order_id=oh.order_id
inner join product p
on p.product_id=oi.product_id
WHERE PAYMENT_MODE= 'Cash'
and customer_lname LIKE 'G%'
group by oc.customer_id, full_name, total_value;


#Ans 9
Select p.product_id, p.product_desc, p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE as total_value
from online_customer oc inner join order_header oh
on oc.customer_id=oh.customer_id
inner join order_items oi
on oi.order_id = oh.order_id
inner join product p
on p.product_id=oi.product_id
inner join address a
on a.address_id=oc.address_id
where p.product_id = '201'
and a.city not in ('Delhi','Bangalore');





#ANS 10
select oi.order_id, oc.customer_id, concat(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) as full_name, count(oi.order_id)
from online_customer oc inner join order_header oh
on oc.customer_id=oh.customer_id
inner join order_items oi
on oi.order_id=oh.order_id
inner join address a
on a.address_id=a.address_id
where mod(oh.order_id,2)<>0
and a.pincode not like '5%'
group by oi.order_id, oc.customer_id, full_name;

