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