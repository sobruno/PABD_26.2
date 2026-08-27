-- 1.	Liste os produtos com preço superior a R$ 1000.
select * from products
where price > 1000;

-- 2.	Liste os produtos ordenados pelo preço, do maior para o menor.
select * from products
order by price desc;

-- 3.	Aumente o preço de todos os produtos da `Dell` em 10%.
update products
set price = (price*1.1)
where name like '%Dell%';

-- 4.	Exclua todos os produtos que sejam do tipo `Macbook`.
delete from products
where name like '%Mac%';

-- 5.	Exclua um produto que não possua pedidos associados.
delete from products p
where not exists(
    select op.product_id from orders_products op
    where op.product_id = p.id 
);

-- 6.	Liste todos os pedidos realizados nos últimos 30 dias.
select * from orders
where order_date > now() - interval '30 days';

-- 7.	Liste os pedidos e os respectivos nomes de usuário.
select o.order_date, o.status, o.total, o.user_id, u.name from orders o 
join users u 
on o.user_id = u.id; 

-- 8.	Liste todos os usuários e seus pedidos, inclusive usuários sem pedidos.
select o.order_date, o.status, o.total, o.user_id, u.name from orders o 
right join users u 
on o.user_id = u.id; 

-- 9.	Liste todos os usuários (id, nome e email) que realizaram pelo menos um pedido.
select * from users u
where exists(
    select * from orders o 
    where o.user_id = u.id
);

-- 10.	Liste produtos que nunca foram vendidos.
select * from products p
where not exists(
    select * from orders_products op 
    where op.product_id = p.id
);

-- 11.	Liste usuários que nunca realizaram pedidos.
select * from users u
where not exists(
    select * from orders o
    where o.user_id = u.id
);

-- 12.	Liste os produtos com preço acima da média em ordem decrescente.
select * from products
where price > (select avg(price) from products)
order by price desc;

-- 13.	Liste a quantidade de pedidos realizados por cada usuário.
select count(u.id) Qnt_de_pedidos, u.name Nome from users u
join orders o 
on o.user_id = u.id
group by u.name
order by u.name; -- em ordem alfabética


-- 14.	Listar os três produtos mais vendidos.
select count(p.id) Top_3_mais_vendidos, p.name from products p
join orders_products op
on op.product_id = p.id
group by p.name
order by Top_3_mais_vendidos desc
LIMIT 3;

-- 15.	Gerar um relatório com: usuários, quantidade de pedidos e valor total comprado.
select u.name Nome, count(o.id) Qnt_de_pedidos, coalesce(sum(o.total), 0) Valor_total from users u
left join orders o
on o.user_id = u.id
group by u.id, u.name
order by Valor_total desc;
