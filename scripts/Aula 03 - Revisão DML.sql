-- inserção
insert into funcionario values 
(11122233344, 'João', 'Silva', 'joaoh@tads.ifrn', 'rua 00', '2000', '2000-01-01', 'm', null, null),
(11122253344, 'Gorji', 'Souza', 'tareco@tads.ifrn', 'rua 00', '2400', '2002-11-05', 'm', null, null);

insert into funcionario(cpf, pnome, unome, email, endereco, salario, data_nasc, sexo) values 
(77777777777, 'Tica', 'Silva', 'Tiquinha@gmail.com', 'Japi', '2521', '1992-05-16', 'F');

-- atualização
update funcionario set sexo='F'  
where cpf='77777777777'
returning cpf, pnome, unome, endereco;

update funcionario set sexo='F'  
where cpf='11122253344'
returning cpf, pnome, unome, endereco, sexo;

-- remoção
delete from funcionario 
where pnome LIKE 'Jo%'
returning cpf, pnome, unome;
