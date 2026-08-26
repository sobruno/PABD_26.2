select * from funcionario;

select pnome, numero_departamento from funcionario;

select unome || ' ' || numero_departamento from funcionario;

-- alias
select pnome || ' ' || numero_departamento as "Nome + departamento" from funcionario;

select pnome || ' ' || numero_departamento as "Nome + departamento", salario*0.11 inss from funcionario;

select pnome || ' ' || numero_departamento as "Nome + departamento", salario*0.11, round(salario*0.11, 2) inss from funcionario;

select cpf, pnome, unome from funcionario
where numero_departamento = 1 and salario >= 1000;

select cpf, pnome, unome from funcionario
where salario between(2000,10000);

select cpf, pnome, unome from funcionario
where endereco like '%PI';


-- Ordenação

select * from funcionario 
order by data_nasc DESC;

select * from funcionario 
order by salario DESC
limit 1;

-- agregação

select count(*) from funcionario;

select count(distinct numero_departamento) from funcionario;

select sum(salario) folha_salarial from funcionario;

select round(avg(salario), 2) media_salarial from funcionario;

select min(salario) menor_salario, max(salario) maior_salario from funcionario;

select unome, pnome, salario from funcionario
where salario = (select max(salario) from funcionario) OR salario = (select min(salario) from funcionario);

select  unome, pnome, salario from funcionario
where salario >= (select avg(salario) from funcionario);

select 
    count(*) total_funcionarios, 
    sum(salario) folha_salarial, 
    min(salario) menor_salario, 
    max(salario) maior_salario, 
    round(avg(salario), 2) media_salarial 
from 
funcionario;

-- join

select f.pnome ||' ' || f.unome nome, d.nome departamento from funcionario f
join departamento d on  f.numero_departamento = d.numero
order by f.pnome, f.unome;

select f.pnome ||' ' || f.unome nome, s.unome supervisor from funcionario f
join funcionario s on  f.cpf_supervisor = s.cpf
order by f.pnome, f.unome;

-- left join inclui "on's" nulos
select f.pnome ||' ' || f.unome nome, s.unome supervisor from funcionario f
left join funcionario s on  f.cpf_supervisor = s.cpf
order by f.pnome, f.unome;

select 
   f.pnome || ' ' || f.unome funcionario,
   coalesce(s.pnome || ' ' || s.unome, 'Sem supervisor') supervisor
from funcionario s
right join funcionario f
   on f.cpf_supervisor = s.cpf
order by s.pnome nulls last, f.pnome, f.unome;

-- Mudanças para visualizar FULL JOIN
update funcionario
set numero_departamento = null
where cpf = '33344455566';

insert into departamento(numero, nome, cpf_gerente, data_ini)
values (4, 'Marketing', null, current_date);

select 
   coalesce(d.nome, 'Sem departamento') departamento,
   coalesce(f.pnome || ' ' || f.unome, 'Sem funcionário') funcionario
from departamento d
full join funcionario f
   on d.numero = f.numero_departamento
order by departamento nulls last, funcionario nulls last;

-- exists, not exists

-- Listar funcionários que são gerentes de algum departamento
select 
   f.pnome || ' ' || f.unome funcionario
from funcionario f
where exists (
   select *
   from departamento d
   where d.cpf_gerente = f.cpf
)
order by funcionario;

-- Existe algum funcionário que não é gerente?
select 
   f.pnome || ' ' || f.unome funcionario
from funcionario f
where not exists (
   select *
   from departamento d
   where d.cpf_gerente = f.cpf
)
order by funcionario;

-- Funções de agrupamento: group by, having

-- Qual o salário médio dos funcionários em cada departamento?
select 
   numero_departamento,
   round(avg(salario), 2) media_salarial
from funcionario
group by numero_departamento
order by numero_departamento;

-- Qual o salário médio dos funcionários em cada departamento (sem valores nulos) WHERE?
select 
   numero_departamento,
   round(avg(salario), 2) media_salarial
from funcionario
where numero_departamento is not null
group by numero_departamento
order by numero_departamento;

-- Qual o salário médio dos funcionários em cada departamento (sem valores nulos) HAVING?
select 
   numero_departamento,
   round(avg(salario), 2) media_salarial
from funcionario
group by numero_departamento
having numero_departamento is not null
order by numero_departamento;

-- Qual o número de funcionários que trabalham em cada departamento?
select
   numero_departamento,
   count(*) qtd_funcionarios
from funcionario f
group by numero_departamento
order by numero_departamento;

-- Listar: numero e nome do departamento, quantidade de funcionários, média salarial e folha salarial
select 
   d.numero numero_departamento,
   d.nome nome_departamento,
   count(f.cpf) qtd_funcionarios,
   round(avg(f.salario), 2) media_salarial,
   sum(f.salario) folha_salarial
from funcionario f
right join departamento d
   on f.numero_departamento = d.numero
group by d.numero
order by numero_departamento;