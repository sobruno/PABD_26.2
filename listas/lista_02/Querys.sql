-- 1. View de Performance da Equipe

drop view if exists v_staff_performance;
create view v_staff_performance as
select
    s.staff_id,
    concat(s.first_name, ' ', s.last_name) as nome_funcionario,
    concat(c.city, ' / ', co.country) as endereco_loja,
    coalesce(count(distinct r.rental_id), 0) as total_locacoes,
    coalesce(sum(p.amount), 0) as total_arrecadado
from staff s
left join store st on st.store_id = s.store_id
left join address a on a.address_id = st.address_id
left join city c on c.city_id = a.city_id
left join country co on co.country_id = c.country_id
left join rental r on r.staff_id = s.staff_id
left join payment p on p.rental_id = r.rental_id and p.staff_id = s.staff_id
group by
    s.staff_id,
    s.first_name,
    s.last_name,
    c.city,
    co.country;

-- 2. View Materializada de Receita por Categoria

drop materialized view if exists mv_category_total_sales;
create materialized view mv_category_total_sales as
select
    c.name as categoria,
    coalesce(sum(p.amount), 0) as total_receita
from category c
left join film_category fc on fc.category_id = c.category_id
left join inventory i on i.film_id = fc.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
group by c.category_id, c.name;

create unique index idx_mv_category_total_sales_categoria
on mv_category_total_sales (categoria);

-- Recarregar os dados da MV sem bloquear consultas dos usuários
refresh materialized view concurrently mv_category_total_sales;


-- 3. Otimizando Filmes Atrasados

drop index if exists idx_rental_open;
create index idx_rental_open
on rental (rental_id)
where return_date is null;

-- Consulta usada pelo processo de cobrança
explain analyze
select *
from rental
where return_date is null;


-- 4. Busca Inteligente de Sinopses

drop index if exists idx_film_description_tsv;
create index idx_film_description_tsv
on film using gin (to_tsvector('english', description));

-- Busca por filmes que mencionam 'documentary' e 'drama' na descrição
explain analyze
select *
from film
where to_tsvector('english', description) @@ to_tsquery('english', 'documentary & drama');


-- 5. Histórico do Cliente

drop index if exists idx_customer_payment_history;
create index idx_customer_payment_history
on payment (customer_id, payment_date desc);

explain analyze
select *
from payment
where customer_id = 1
order by payment_date desc
limit 10;

-- A coluna customer_id deve vir primeiro porque a consulta filtra por igualdade e depois ordena por data mais recente


--6. Login Case-Insensitive

drop index if exists idx_customer_login_insensitive;
create index idx_customer_login_insensitive
on customer (lower(email));

explain analyze
select *
from customer
where lower(email) = lower('MARY.SMITH@SAKILACUSTOMER.org');


--7. Validação de Datas

create or replace function check_return_date()
    returns trigger
    language plpgsql
as $$
begin
    if NEW.return_date IS NOT NULL AND NEW.return_date < NEW.rental_date then
        raise exception 'A data de devolução não pode ser anterior à data de locação.';
    end if;
    return NEW;
end;
$$;

create trigger trg_check_return_date
before insert or update on rental
for each row
execute function check_return_date();

insert into rental (rental_date, inventory_id, customer_id, return_date)
values (now(), 1, 1, now() - interval '1 day'); -- Deve gerar erro, pois a data de devolução é anterior à data de locação

insert into rental (rental_date, inventory_id, customer_id, return_date)
values ('2023-03-16', 1, 1, '2007-03-16'); -- Deve gerar erro, pois a data de devolução é anterior à data de locação


--8. Auditoria de Preços

drop table if exists film_cost_audit;
create table film_cost_audit (
    film_id integer not null,
    old_cost numeric(5,2) not null,
    new_cost numeric(5,2) not null,
    changed_at timestamp without time zone default now()
);

create or replace function log_film_cost_change()
returns trigger
language plpgsql
as $$
begin
    insert into film_cost_audit (film_id, old_cost, new_cost, changed_at)
    values (new.film_id, old.replacement_cost, new.replacement_cost, now());
    return new;
end;
$$;

create trigger trg_film_cost_audit
after update of replacement_cost on film
for each row
when (old.replacement_cost is distinct from new.replacement_cost)
execute function log_film_cost_change();


--9. Proteção de Catálogo

drop function if exists prevent_language_delete() cascade;
create or replace function prevent_language_delete()
returns trigger
language plpgsql
as $$
begin
    if exists (
        select 1
        from film
        where language_id = old.language_id
    ) then
        raise exception 'Não foi possível excluir o idioma % porque existem filmes vinculados a ele.', old.name;
    end if;

    return old;
end;
$$;

create trigger trg_prevent_language_delete
before delete on language
for each row
execute function prevent_language_delete();


--10. Sincronização de Estatísticas

drop table if exists customer_rental_stats;
create table customer_rental_stats (
    customer_id integer primary key,
    total_rentals integer default 0 not null
);

insert into customer_rental_stats (customer_id, total_rentals)
select customer_id, count(*)
from rental
group by customer_id
on conflict (customer_id) do update set total_rentals = excluded.total_rentals;

create or replace function update_customer_rental_stats()
returns trigger
language plpgsql
as $$
begin
    insert into customer_rental_stats (customer_id, total_rentals)
    values (new.customer_id, 1)
    on conflict (customer_id)
    do update set total_rentals = customer_rental_stats.total_rentals + 1;

    return new;
end;
$$;

create trigger trg_update_customer_rental_stats
after insert on rental
for each row
execute function update_customer_rental_stats();