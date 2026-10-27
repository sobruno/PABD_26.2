--QUESTÃO 1 - Cadastro de Cliente e Perfil
begin;

insert into customer (store_id, first_name, last_name, email, address_id, activebool, create_date, active)
values (1, 'Bruno', 'Teste', 'bruno.teste@email.com', 5, true, current_date, 1);

select customer_id, first_name, last_name
from customer
where email = 'bruno.teste@email.com';

insert into address (address, district, city_id, phone, last_update)
values (null, 'Centro', 1, '84999999999', now());

-- RESPOSTA: Não, depois do ROLLBACK, a consulta retorna 0 linhas. Pois o cliente só existia dentro da transaction, visível apenas para a sua sessão
-- ,e nunca foi confirmado. O ROLLBACK descarta tudo o que foi feito desde o BEGIN.


--QUESTÃO 2 - Gestão de Estoque e Suprimentos
begin;

insert into inventory (film_id, store_id, last_update)
values (1, 1, now());

savepoint estoque_atualizado;

insert into inventory (film_id, store_id, last_update)
values (99999, 1, now());

rollback to estoque_atualizado;

select inventory_id, film_id, store_id
from inventory
order by inventory_id desc
limit 5;

insert into inventory (film_id, store_id, last_update)
values (2, 1, now());

commit;

select inventory_id, film_id, store_id
from inventory
order by inventory_id desc
limit 5;

-- RESPOSTA: Ficam salvos os dois registros válidos, utilizando o savepoint, você previne de que uma operação concluída com sucesso seja excluída
-- , visto que o rollback ou commit vão descartar somente os comandos que estiveram depois do savepoint.


--QUESTÃO 3 - Concorrência na Gestão de Estoque e Suprimentos
-- CENARIO CONSIDERANDO A -> B
-- sessão A

begin;

update inventory 
set store_id = 2, last_update = now() 
where inventory_id = 4582;

-- sessão B

begin;

delete * 
from inventory 
where inventory_id = 4582;

-- B está esperando por A

-- sessão A
commit;

-- sessão B (destrava sozinha pós commit de A)
commit;

-- exclusão confirmada



-- CENARIO CONSIDERANDO B -> A
-- sessão B

begin;

delete * 
from inventory 
where inventory_id = 4582;

-- sessão A

begin;

update inventory 
set store_id = 2, last_update = now() 
where inventory_id = 4582;

-- A está esperando por B

-- sessão B
commit;

-- sessão A (destrava sozinha pós commit de B)
-- update 0, pois a linha não existe mais
commit;
