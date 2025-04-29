-- запрос, который считает общее количество покупателей
select 
	count(customer_id) as customers_count 
from 
	customers;

/* Первый отчет о десятке лучших продавцов. Этот запрос предоставляет данные о продавце - seller, 
 * количество проведенных сделок - operations, 
 * суммарную выручку продавца за все время - income */
select 
	concat(e.first_name, ' ' , e.last_name) as seller,
	count(s.sales_id) as operations,
	floor(sum(s.quantity * p.price)) as income
from sales s 
join 
	employees e on e.employee_id = s.sales_person_id 
join 
	products p on p.product_id = s.product_id
group by 
	1
order by 
	income desc limit 10;

/*Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
seller — имя и фамилия продавца
average_income — средняя выручка продавца за сделку с округлением до целого*/
select 
	concat(e.first_name, ' ', e.last_name) as seller, 
    floor(avg(s.quantity * p.price)) as average_income
from 
	employees e
join 
	sales s on e.employee_id = s.sales_person_id 
join 
	products p on s.product_id = p.product_id
group by 
	seller 
having avg(s.quantity * p.price) < (select avg(s2.quantity * p2.price) as mid 
                                            from products as p2 
                                            left join sales as s2
                                            on p2.product_id = s2.product_id)
order by
	average_income;

/*Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. 
seller — имя и фамилия продавца
day_of_week — название дня недели на английском языке
income — суммарная выручка продавца в определенный день недели, округленная до целого числа*/

select 
	concat(e.first_name, ' ' , e.last_name) as seller,
	to_char(s.sale_date, 'day') as day_of_week,
	round(sum(p.price * s.quantity)) as income
from sales s 
join 
	employees e on e.employee_id = s.sales_person_id 
join 
	products p on p.product_id = s.product_id
group by 
	1, 2, TO_CHAR(sale_date, 'ID')
order by 
	TO_CHAR(sale_date, 'ID'),
	income DESC,
	seller;

/*Во втором отчете предоставлены данные по количеству уникальных покупателей и выручке, которую они принесли.
date - дата в указанном формате
total_customers - количество покупателей
income - принесенная выручка */

select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        when c.age > 40 then '40+'
    end as age_category,
    count(*) as age_count 
from 
	customers as c
group by age_category
order by age_category;

/*Третий отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
Таблица отсортирована по id покупателя. Таблица состоит из следующих полей:
customer - имя и фамилия покупателя
sale_date - дата покупки
seller - имя и фамилия продавца */
select distinct on (c.customer_id)
    concat(c.first_name, ' ', c.last_name) as customer,
    s.sale_date as sale_date,
    concat(e.first_name, ' ', e.last_name) as seller
from
    sales s
join
    employees e on e.employee_id = s.sales_person_id
join
    products p on p.product_id = s.product_id
join
    customers c on c.customer_id = s.customer_id
where
    p.price = 0
order by
    c.customer_id,
    s.sale_date;  