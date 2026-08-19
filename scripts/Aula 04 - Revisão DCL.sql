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
