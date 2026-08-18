drop table if exists funcionario cascade;
drop table if exists departamento cascade;

create table funcionario(
    cpf char(11) primary key,
    pnome varchar(50) not null,
    unome varchar(50) not null,
    email  varchar(50) not null unique,
    endereco varchar(100),
    salario numeric(7,2),
    data_nasc date,
    sexo char(1),
    cpf_supervisor char(11),
    numero_departamento smallint,

    constraint funcionario_salario_check
    check (salario >= 2000 and salario <= 15000)

);

create table departamento(
    numero smallint primary key,
    nome varchar(50) unique,
    cpf_gerente char(11),
    data_ini not null,

    constraint departamento_cpf_gerente_fk
    foreign key (cpf_gerente)
    references funcionario(cpf)
    on delete set null
    on update cascade

);

/*
-- Adicionar um novo atributo
alter table departamento
add column data_ini date;

-- Alteração de atributo
alter table departamento
alter column data_ini set not null;

-- Excluir atributo
alter table departamento
drop column data_ini;

-- Adicionar Default
alter table funcionario
alter column endereco set default 'rua dos bobos';

-- Excluir Default
alter table funcionario
alter column endereco drop default;

-- Adicionar constraint
alter table funcionario
add constraint funcionario_sexo_check
check (sexo in ('m', 'M', 'f', 'F', 'o', 'O'));

-- Excluir cosntraint
alter table funcionario
drop constraint if exists funcionario_sexo_check;

-- Adicionar chave estrangeira para supervisor
alter table funcionario
add constraint funcionario_cpf_supervisor_fk
foreign key (cpf_supervisor)
references funcionario(cpf)
on delete set null
on update cascade;

-- Adicionar chave estrangeira para departamento
alter table funcionario
add constraint funcionario_num_dep_fk
foreign key (numero_departamento)
references departamento(numero)

-- pode ser "no action", "cascade", "set null", "set default", "restrict", 
on delete no action
on update cascade;
*/

