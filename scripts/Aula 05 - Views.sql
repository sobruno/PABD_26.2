drop view if exists v_users_orders;

create view v_users_orders as
select u.name Nome, count(o.id) Qnt_de_pedidos, coalesce(sum(o.total), 0) Valor_total from users u
left join orders o
on o.user_id = u.id
group by u.id, u.name;

select * from v_users_orders order by Valor_total desc;


-- relatorio de vendas de produto
drop view if exists v_relatorio_de_vendas;

create view v_relatorio_de_vendas as
select p.id, p.name, sum(op.quantity) Quantidade, sum(o.total) Valor_total from products p
join orders_products op
on op.product_id = p.id
join orders o
on op.order_id = o.id
where o.status <> 'canceled'
group by p.id, p.name;

select * from v_relatorio_de_vendas order by id;


-- relatorio detalhado
drop view if exists v_detalhamento_de_vendas;

create view v_detalhamento_de_vendas as
select o.id, u.name nome, u.email, o.order_date data_do_pedido, o.status, p.name nome_produto, op.quantity quantidade from orders o
join orders_products op
on op.order_id = o.id
join products p
on p.id = op.product_id
join users u
on o.user_id = u.id;



-- Relatorio de estoque
drop view if exists v_relatorio_de_estoque;

create view v_relatorio_de_estoque as
select * from products
where stock > 0;

select * from v_relatorio_de_estoque order by id;