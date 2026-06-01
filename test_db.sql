-- 1. Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS `rede_lojas_roupas`;

USE rede_lojas_roupas;

-- 2. Tabelas Base (Independêntes)
DROP TABLE IF EXISTS `estados`;
CREATE TABLE `estados` (
  `id_estado` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `sigla` char(2) NOT NULL,
  PRIMARY KEY (`id_estado`),
  UNIQUE KEY `sigla` (`sigla`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `cargos`;
CREATE TABLE `cargos` (
  `id_cargo` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `salario_base` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_cargo`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `categorias`;
CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `fornecedores`;
CREATE TABLE `fornecedores` (
  `id_fornecedor` int NOT NULL AUTO_INCREMENT,
  `razao_social` varchar(150) NOT NULL,
  `cnpj` varchar(18) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `endereco` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_fornecedor`),
  UNIQUE KEY `cnpj` (`cnpj`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `clientes`;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `cpf` varchar(14) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `data_cadastro` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cpf` (`cpf`),
  KEY `idx_clientes_nome` (`nome`)
) ENGINE=InnoDB;

-- 3. Tabelas de Segundo Nível (Dependem das bases)
DROP TABLE IF EXISTS `cidades`;
CREATE TABLE `cidades` (
  `id_cidade` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `id_estado` int NOT NULL,
  PRIMARY KEY (`id_cidade`),
  KEY `id_estado` (`id_estado`),
  CONSTRAINT `cidades_ibfk_1` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `produtos`;
CREATE TABLE `produtos` (
  `id_produto` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `descricao` text,
  `preco` decimal(10,2) NOT NULL,
  `tamanho` varchar(10) DEFAULT NULL,
  `cor` varchar(50) DEFAULT NULL,
  `id_categoria` int NOT NULL,
  `id_fornecedor` int NOT NULL,
  PRIMARY KEY (`id_produto`),
  KEY `id_categoria` (`id_categoria`),
  KEY `id_fornecedor` (`id_fornecedor`),
  KEY `idx_produtos_nome` (`nome`),
  CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  CONSTRAINT `produtos_ibfk_2` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedores` (`id_fornecedor`)
) ENGINE=InnoDB;

-- 4. Tabelas de Estrutura Organizacional
DROP TABLE IF EXISTS `filiais`;
CREATE TABLE `filiais` (
  `id_filial` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `cnpj` varchar(18) NOT NULL,
  `endereco` varchar(255) NOT NULL,
  `id_cidade` int NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `data_abertura` date DEFAULT NULL,
  PRIMARY KEY (`id_filial`),
  UNIQUE KEY `cnpj` (`cnpj`),
  KEY `id_cidade` (`id_cidade`),
  CONSTRAINT `filiais_ibfk_1` FOREIGN KEY (`id_cidade`) REFERENCES `cidades` (`id_cidade`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `funcionarios`;
CREATE TABLE `funcionarios` (
  `id_funcionario` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `cpf` varchar(14) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `data_contratacao` date NOT NULL,
  `id_cargo` int NOT NULL,
  `id_filial` int NOT NULL,
  PRIMARY KEY (`id_funcionario`),
  UNIQUE KEY `cpf` (`cpf`),
  KEY `id_cargo` (`id_cargo`),
  KEY `id_filial` (`id_filial`),
  KEY `idx_funcionarios_nome` (`nome`),
  CONSTRAINT `funcionarios_ibfk_1` FOREIGN KEY (`id_cargo`) REFERENCES `cargos` (`id_cargo`),
  CONSTRAINT `funcionarios_ibfk_2` FOREIGN KEY (`id_filial`) REFERENCES `filiais` (`id_filial`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `estoque`;
CREATE TABLE `estoque` (
  `id_estoque` int NOT NULL AUTO_INCREMENT,
  `id_filial` int NOT NULL,
  `id_produto` int NOT NULL,
  `quantidade` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_estoque`),
  UNIQUE KEY `id_filial` (`id_filial`,`id_produto`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `estoque_ibfk_1` FOREIGN KEY (`id_filial`) REFERENCES `filiais` (`id_filial`),
  CONSTRAINT `estoque_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produtos` (`id_produto`)
) ENGINE=InnoDB;

-- 5. Tabelas de Transação (Vendas e afins)
DROP TABLE IF EXISTS `vendas`;
CREATE TABLE `vendas` (
  `id_venda` int NOT NULL AUTO_INCREMENT,
  `data_venda` datetime DEFAULT CURRENT_TIMESTAMP,
  `id_cliente` int DEFAULT NULL,
  `id_funcionario` int NOT NULL,
  `id_filial` int NOT NULL,
  `valor_total` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id_venda`),
  KEY `id_cliente` (`id_cliente`),
  KEY `id_funcionario` (`id_funcionario`),
  KEY `id_filial` (`id_filial`),
  KEY `idx_vendas_data` (`data_venda`),
  CONSTRAINT `vendas_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `vendas_ibfk_2` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionarios` (`id_funcionario`),
  CONSTRAINT `vendas_ibfk_3` FOREIGN KEY (`id_filial`) REFERENCES `filiais` (`id_filial`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `itens_venda`;
CREATE TABLE `itens_venda` (
  `id_item` int NOT NULL AUTO_INCREMENT,
  `id_venda` int NOT NULL,
  `id_produto` int NOT NULL,
  `quantidade` int NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_item`),
  KEY `id_venda` (`id_venda`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `itens_venda_ibfk_1` FOREIGN KEY (`id_venda`) REFERENCES `vendas` (`id_venda`),
  CONSTRAINT `itens_venda_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produtos` (`id_produto`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `pagamentos`;
CREATE TABLE `pagamentos` (
  `id_pagamento` int NOT NULL AUTO_INCREMENT,
  `id_venda` int NOT NULL,
  `forma_pagamento` varchar(50) NOT NULL,
  `valor` decimal(12,2) NOT NULL,
  `status_pagamento` varchar(50) DEFAULT 'PAGO',
  PRIMARY KEY (`id_pagamento`),
  KEY `id_venda` (`id_venda`),
  CONSTRAINT `pagamentos_ibfk_1` FOREIGN KEY (`id_venda`) REFERENCES `vendas` (`id_venda`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `entregas`;
CREATE TABLE `entregas` (
  `id_entrega` int NOT NULL AUTO_INCREMENT,
  `id_venda` int NOT NULL,
  `id_funcionario_entregador` int NOT NULL,
  `endereco_entrega` varchar(255) NOT NULL,
  `status_entrega` varchar(50) DEFAULT 'EM PREPARACAO',
  `data_envio` datetime DEFAULT NULL,
  `data_entrega` datetime DEFAULT NULL,
  PRIMARY KEY (`id_entrega`),
  KEY `id_venda` (`id_venda`),
  KEY `id_funcionario_entregador` (`id_funcionario_entregador`),
  CONSTRAINT `entregas_ibfk_1` FOREIGN KEY (`id_venda`) REFERENCES `vendas` (`id_venda`),
  CONSTRAINT `entregas_ibfk_2` FOREIGN KEY (`id_funcionario_entregador`) REFERENCES `funcionarios` (`id_funcionario`)
) ENGINE=InnoDB;

INSERT INTO estados (nome, sigla) VALUES ('Acre', 'AC');
INSERT INTO estados (nome, sigla) VALUES ('Alagoas', 'AL');
INSERT INTO estados (nome, sigla) VALUES ('Amapá', 'AP');
INSERT INTO estados (nome, sigla) VALUES ('Amazonas', 'AM');
INSERT INTO estados (nome, sigla) VALUES ('Bahia', 'BA');
INSERT INTO estados (nome, sigla) VALUES ('Ceará', 'CE');
INSERT INTO estados (nome, sigla) VALUES ('Distrito Federal', 'DF');
INSERT INTO estados (nome, sigla) VALUES ('Espírito Santo', 'ES');
INSERT INTO estados (nome, sigla) VALUES ('Goiás', 'GO');
INSERT INTO estados (nome, sigla) VALUES ('Maranhão', 'MA');
INSERT INTO estados (nome, sigla) VALUES ('Mato Grosso', 'MT');
INSERT INTO estados (nome, sigla) VALUES ('Mato Grosso do Sul', 'MS');
INSERT INTO estados (nome, sigla) VALUES ('Minas Gerais', 'MG');
INSERT INTO estados (nome, sigla) VALUES ('Pará', 'PA');
INSERT INTO estados (nome, sigla) VALUES ('Paraíba', 'PB');
INSERT INTO estados (nome, sigla) VALUES ('Paraná', 'PR');
INSERT INTO estados (nome, sigla) VALUES ('Pernambuco', 'PE');
INSERT INTO estados (nome, sigla) VALUES ('Piauí', 'PI');
INSERT INTO estados (nome, sigla) VALUES ('Rio de Janeiro', 'RJ');
INSERT INTO estados (nome, sigla) VALUES ('Rio Grande do Norte', 'RN');
INSERT INTO estados (nome, sigla) VALUES ('Rio Grande do Sul', 'RS');
INSERT INTO estados (nome, sigla) VALUES ('Rondônia', 'RO');
INSERT INTO estados (nome, sigla) VALUES ('Roraima', 'RR');
INSERT INTO estados (nome, sigla) VALUES ('Santa Catarina', 'SC');
INSERT INTO estados (nome, sigla) VALUES ('São Paulo', 'SP');
INSERT INTO estados (nome, sigla) VALUES ('Sergipe', 'SE');
INSERT INTO estados (nome, sigla) VALUES ('Tocantins', 'TO');

INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 0', 3148.62);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 1', 1729.91);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 2', 3154.2);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 3', 11221.21);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 4', 4951.35);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 5', 7024.85);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 6', 1533.5);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 7', 5106.49);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 8', 11919.2);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 9', 5112.5);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 10', 3802.92);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 11', 9856.42);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 12', 8058.66);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 13', 3112.6);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 14', 3576.63);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 15', 11241.9);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 16', 10956.28);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 17', 2615.91);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 18', 2996.26);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 19', 2528.61);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 20', 3228.86);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 21', 6882.94);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 22', 11377.53);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 23', 6240.88);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 24', 2030.69);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 25', 2066.47);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 26', 11818.35);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 27', 4337.87);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 28', 7222.27);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 29', 7002.79);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 30', 2142.14);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 31', 3633.46);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 32', 9680.88);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 33', 4518.19);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 34', 4205.63);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 35', 8491.61);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 36', 7604.56);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 37', 10176.89);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 38', 4452.02);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 39', 11397.51);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 40', 8202.59);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 41', 7823.34);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 42', 4955.12);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 43', 2094.67);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 44', 11382.64);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 45', 8821.7);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 46', 8683.32);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 47', 8945.38);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 48', 8647.46);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 49', 3401.38);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 50', 3486.81);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 51', 8601.63);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 52', 5533.62);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 53', 10492.03);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 54', 11554.71);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 55', 2440.06);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 56', 3338.36);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 57', 11746.31);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 58', 10426.98);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 59', 11426.27);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 60', 2021.69);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 61', 11078.23);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 62', 5490.41);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 63', 4827.34);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 64', 5412.36);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 65', 6059.34);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 66', 5733.01);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 67', 4365.48);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 68', 3793.49);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 69', 4770.43);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 70', 6277.53);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 71', 8287.29);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 72', 3350.55);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 73', 9628.45);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 74', 8520.27);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 75', 7698.12);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 76', 5200.49);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 77', 8750.98);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 78', 6366.81);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 79', 3191.87);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 80', 3364.52);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 81', 10580.43);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 82', 6068.03);
INSERT INTO cargos (nome, salario_base) VALUES ('Caixa 83', 8953.02);
INSERT INTO cargos (nome, salario_base) VALUES ('Estoquista 84', 7139.17);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 85', 11515.77);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 86', 10076.88);
INSERT INTO cargos (nome, salario_base) VALUES ('Financeiro 87', 6896.13);
INSERT INTO cargos (nome, salario_base) VALUES ('Supervisor 88', 1986.8);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 89', 3802.61);
INSERT INTO cargos (nome, salario_base) VALUES ('Gerente 90', 3411.05);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 91', 1950.43);
INSERT INTO cargos (nome, salario_base) VALUES ('Atendente 92', 6025.2);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 93', 6905.54);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 94', 11261.45);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 95', 1728.38);
INSERT INTO cargos (nome, salario_base) VALUES ('Analista 96', 10192.32);
INSERT INTO cargos (nome, salario_base) VALUES ('RH 97', 6906.26);
INSERT INTO cargos (nome, salario_base) VALUES ('Entregador 98', 2789.31);
INSERT INTO cargos (nome, salario_base) VALUES ('Vendedor 99', 11889.83);

INSERT INTO categorias (nome) VALUES ('Saias 0');
INSERT INTO categorias (nome) VALUES ('Camisetas 1');
INSERT INTO categorias (nome) VALUES ('Vestidos 2');
INSERT INTO categorias (nome) VALUES ('Sapatos 3');
INSERT INTO categorias (nome) VALUES ('Acessórios 4');
INSERT INTO categorias (nome) VALUES ('Tênis 5');
INSERT INTO categorias (nome) VALUES ('Calças 6');
INSERT INTO categorias (nome) VALUES ('Acessórios 7');
INSERT INTO categorias (nome) VALUES ('Shorts 8');
INSERT INTO categorias (nome) VALUES ('Blusas 9');
INSERT INTO categorias (nome) VALUES ('Jaquetas 10');
INSERT INTO categorias (nome) VALUES ('Calças 11');
INSERT INTO categorias (nome) VALUES ('Blusas 12');
INSERT INTO categorias (nome) VALUES ('Jaquetas 13');
INSERT INTO categorias (nome) VALUES ('Vestidos 14');
INSERT INTO categorias (nome) VALUES ('Tênis 15');
INSERT INTO categorias (nome) VALUES ('Camisetas 16');
INSERT INTO categorias (nome) VALUES ('Sapatos 17');
INSERT INTO categorias (nome) VALUES ('Calças 18');
INSERT INTO categorias (nome) VALUES ('Calças 19');
INSERT INTO categorias (nome) VALUES ('Calças 20');
INSERT INTO categorias (nome) VALUES ('Calças 21');
INSERT INTO categorias (nome) VALUES ('Vestidos 22');
INSERT INTO categorias (nome) VALUES ('Shorts 23');
INSERT INTO categorias (nome) VALUES ('Vestidos 24');
INSERT INTO categorias (nome) VALUES ('Shorts 25');
INSERT INTO categorias (nome) VALUES ('Vestidos 26');
INSERT INTO categorias (nome) VALUES ('Tênis 27');
INSERT INTO categorias (nome) VALUES ('Saias 28');
INSERT INTO categorias (nome) VALUES ('Blusas 29');
INSERT INTO categorias (nome) VALUES ('Tênis 30');
INSERT INTO categorias (nome) VALUES ('Vestidos 31');
INSERT INTO categorias (nome) VALUES ('Sapatos 32');
INSERT INTO categorias (nome) VALUES ('Camisetas 33');
INSERT INTO categorias (nome) VALUES ('Camisetas 34');
INSERT INTO categorias (nome) VALUES ('Sapatos 35');
INSERT INTO categorias (nome) VALUES ('Calças 36');
INSERT INTO categorias (nome) VALUES ('Calças 37');
INSERT INTO categorias (nome) VALUES ('Jaquetas 38');
INSERT INTO categorias (nome) VALUES ('Camisetas 39');
INSERT INTO categorias (nome) VALUES ('Vestidos 40');
INSERT INTO categorias (nome) VALUES ('Calças 41');
INSERT INTO categorias (nome) VALUES ('Blusas 42');
INSERT INTO categorias (nome) VALUES ('Vestidos 43');
INSERT INTO categorias (nome) VALUES ('Blusas 44');
INSERT INTO categorias (nome) VALUES ('Jaquetas 45');
INSERT INTO categorias (nome) VALUES ('Shorts 46');
INSERT INTO categorias (nome) VALUES ('Calças 47');
INSERT INTO categorias (nome) VALUES ('Sapatos 48');
INSERT INTO categorias (nome) VALUES ('Vestidos 49');
INSERT INTO categorias (nome) VALUES ('Blusas 50');
INSERT INTO categorias (nome) VALUES ('Jaquetas 51');
INSERT INTO categorias (nome) VALUES ('Tênis 52');
INSERT INTO categorias (nome) VALUES ('Saias 53');
INSERT INTO categorias (nome) VALUES ('Tênis 54');
INSERT INTO categorias (nome) VALUES ('Calças 55');
INSERT INTO categorias (nome) VALUES ('Acessórios 56');
INSERT INTO categorias (nome) VALUES ('Shorts 57');
INSERT INTO categorias (nome) VALUES ('Blusas 58');
INSERT INTO categorias (nome) VALUES ('Sapatos 59');
INSERT INTO categorias (nome) VALUES ('Vestidos 60');
INSERT INTO categorias (nome) VALUES ('Sapatos 61');
INSERT INTO categorias (nome) VALUES ('Tênis 62');
INSERT INTO categorias (nome) VALUES ('Saias 63');
INSERT INTO categorias (nome) VALUES ('Shorts 64');
INSERT INTO categorias (nome) VALUES ('Tênis 65');
INSERT INTO categorias (nome) VALUES ('Calças 66');
INSERT INTO categorias (nome) VALUES ('Vestidos 67');
INSERT INTO categorias (nome) VALUES ('Vestidos 68');
INSERT INTO categorias (nome) VALUES ('Calças 69');
INSERT INTO categorias (nome) VALUES ('Camisetas 70');
INSERT INTO categorias (nome) VALUES ('Shorts 71');
INSERT INTO categorias (nome) VALUES ('Camisetas 72');
INSERT INTO categorias (nome) VALUES ('Shorts 73');
INSERT INTO categorias (nome) VALUES ('Camisetas 74');
INSERT INTO categorias (nome) VALUES ('Jaquetas 75');
INSERT INTO categorias (nome) VALUES ('Camisetas 76');
INSERT INTO categorias (nome) VALUES ('Tênis 77');
INSERT INTO categorias (nome) VALUES ('Camisetas 78');
INSERT INTO categorias (nome) VALUES ('Jaquetas 79');
INSERT INTO categorias (nome) VALUES ('Blusas 80');
INSERT INTO categorias (nome) VALUES ('Acessórios 81');
INSERT INTO categorias (nome) VALUES ('Shorts 82');
INSERT INTO categorias (nome) VALUES ('Camisetas 83');
INSERT INTO categorias (nome) VALUES ('Vestidos 84');
INSERT INTO categorias (nome) VALUES ('Blusas 85');
INSERT INTO categorias (nome) VALUES ('Acessórios 86');
INSERT INTO categorias (nome) VALUES ('Jaquetas 87');
INSERT INTO categorias (nome) VALUES ('Acessórios 88');
INSERT INTO categorias (nome) VALUES ('Calças 89');
INSERT INTO categorias (nome) VALUES ('Camisetas 90');
INSERT INTO categorias (nome) VALUES ('Calças 91');
INSERT INTO categorias (nome) VALUES ('Camisetas 92');
INSERT INTO categorias (nome) VALUES ('Calças 93');
INSERT INTO categorias (nome) VALUES ('Jaquetas 94');
INSERT INTO categorias (nome) VALUES ('Acessórios 95');
INSERT INTO categorias (nome) VALUES ('Camisetas 96');
INSERT INTO categorias (nome) VALUES ('Calças 97');
INSERT INTO categorias (nome) VALUES ('Acessórios 98');
INSERT INTO categorias (nome) VALUES ('Jaquetas 99');

INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Conceição - EI', '59.834.701/0001-79', 'gcassiano@lopes.br', '0500-226-2511', 'Quadra de Teixeira, 51, Nova Pampulha, 54435-999 Lima / MS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Luz', '87.520.316/0001-92', 'cassianomelina@cunha.com', '71 5702-0206', 'Colônia da Mata, 26, Vila Primeiro De Maio, 90674042 Cunha das Pedras / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Marques', '03.862.497/0001-45', 'rrodrigues@moraes.edu.br', '41 7866-7005', 'Jardim de Castro, 242, Vila Santo Antônio Barroquinha, 42434-599 Brito da Praia / PE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Rocha', '60.942.873/0001-45', 'rcorreia@pastor.com', '+55 (051) 9913 8938', 'Alameda da Mota, 363, Lorena, 58969-413 Rocha / PA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Borges Ltda.', '86.452.103/0001-08', 'nsouza@gomes.com', '+55 81 2082-1584', 'Loteamento Olívia Ribeiro, 57, Nova Granada, 86497999 Cunha / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pastor S/A', '05.218.347/0001-29', 'marqueskamilly@freitas.br', '0500 724 4273', 'Estação de Aparecida, 53, Vila Santo Antônio Barroquinha, 81771601 Duarte / PR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Castro S.A.', '72.563.019/0001-57', 'luiz-miguelferreira@castro.edu.br', '61 4003-6349', 'Largo Lara Martins, 2, Buritis, 09253102 Santos de Novais / PR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sampaio', '95.427.801/0001-44', 'valmeida@mendonca.net', '0300-987-8533', 'Colônia Manuela Nunes, 17, Corumbiara, 98712-134 Mendes do Amparo / RR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Vasconcelos S/A', '13.052.864/0001-07', 'vieiralorenzo@cavalcante.br', '11 4861-8071', 'Vale de Vargas, 374, Granja Werneck, 18015-432 Monteiro / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Fonseca', '93.645.721/0001-30', 'joao-gabriel80@sousa.com.br', '84 2212-2103', 'Travessa Gonçalves, 57, Alípio De Melo, 28681-263 Pacheco de Rios / SP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Fogaça', '63.048.925/0001-22', 'raquel67@garcia.gov.br', '+55 51 3944 5793', 'Vereda da Rosa, 552, Vila Antena, 23369-731 Gonçalves de da Cruz / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Costa Moraes S.A.', '29.760.183/0001-25', 'jdias@sa.com.br', '+55 (021) 9183 0151', 'Favela Ana Vitória Montenegro, 818, Conjunto Califórnia I, 70742-719 Pacheco / SE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novais da Mota S/A', '24.568.973/0001-90', 'vsilva@rodrigues.br', '+55 (051) 6521-3227', 'Morro Almeida, 60, Paquetá, 36053851 Azevedo / SE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Alves', '12.908.475/0001-60', 'gomesthales@montenegro.org', '+55 (011) 2284-0423', 'Rua Lopes, 15, Barão Homem De Melo 3ª Seção, 03608-426 da Conceição da Praia / RJ');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sá Ltda.', '87.302.564/0001-67', 'joao-gabrielmelo@brito.net', '21 3773-0849', 'Distrito Henry Gonçalves, 33, Monsenhor Messias, 59792946 Casa Grande das Pedras / BA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pires', '28.349.675/0001-60', 'ayllaguerra@casa.com', '(084) 1414-5902', 'Loteamento Pacheco, 703, Santa Maria, 34069040 Novaes / AL');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pacheco Rezende - EI', '69.310.485/0001-16', 'gsousa@barros.com', '+55 31 1691 4664', 'Colônia Lima, 65, Vila Paquetá, 17779724 Pinto / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Vargas - EI', '04.275.831/0001-27', 'uda-mota@araujo.com.br', '0900 122 9515', 'Vila da Cruz, 81, Tupi A, 00722000 Caldeira de Montenegro / RR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sampaio', '49.025.671/0001-04', 'vitor-gabriel34@caldeira.com', '+55 (011) 1581 5714', 'Lago Porto, 9, Conjunto Taquaril, 10123717 da Paz / ES');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Rocha Cardoso e Filhos', '12.094.578/0001-33', 'eribeiro@melo.br', '0900-542-9676', 'Travessa de Cavalcante, Nova Floresta, 25932-826 Cirino / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Fogaça', '48.725.093/0001-48', 'andre50@caldeira.gov.br', '+55 (051) 2317-2959', 'Viela de Aparecida, Estrela Do Oriente, 57832-561 Aragão dos Dourados / CE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novais', '79.403.258/0001-99', 'das-neveslivia@martins.edu.br', '+55 (071) 2469 2187', 'Ladeira da Rosa, Vila Formosa, 42091-035 Rezende / SE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Freitas Ltda.', '08.736.594/0001-05', 'fda-paz@sa.com.br', '0500 168 5169', 'Fazenda Vasconcelos, 15, Alta Tensão 1ª Seção, 93679386 Aragão / PR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Conceição', '32.867.109/0001-17', 'vitor-hugo75@fogaca.com', '+55 (071) 9665 8014', 'Quadra Giovanna Rocha, 59, Vila São Dimas, 66566-594 Camargo / AC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Peixoto e Filhos', '68.905.473/0001-71', 'zteixeira@da.com.br', '31 9639-4181', 'Via Natália Lima, 819, Vila Santa Monica 1ª Seção, 43104720 Lopes dos Dourados / SC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Nogueira', '01.396.427/0001-13', 'oporto@da.com', '(041) 4636 1178', 'Aeroporto de Sales, Vila Formosa, 74552-446 Gomes / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Garcia', '43.592.716/0001-38', 'ana-juliaandrade@caldeira.br', '+55 (041) 8145-2416', 'Rodovia Fernando Jesus, 15, Vila Santa Monica 1ª Seção, 03148-477 Cavalcanti da Prata / MS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cirino - EI', '96.845.370/0001-07', 'ecosta@macedo.com.br', '(051) 1317-0270', 'Setor de Nogueira, 815, Vila Ouro Minas, 65840-353 Fernandes / PB');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Mata S/A', '62.413.058/0001-14', 'vitoria90@viana.gov.br', '+55 41 3953-2916', 'Sítio de Oliveira, Santa Rita, 14638177 Cavalcanti / CE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costa', '82.493.675/0001-84', 'maysa25@rocha.br', '41 8702-3162', 'Rua Gustavo Monteiro, 7, Vila Satélite, 05477408 Gomes do Oeste / TO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Gomes - ME', '51.438.267/0001-04', 'mporto@da.net', '(011) 4809-8944', 'Estrada Manuella Castro, 674, Santa Maria, 48900464 Câmara das Flores / AC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novaes - ME', '15.687.024/0001-38', 'cirinoliam@lima.br', '+55 71 5856 1998', 'Alameda Pires, 57, Vila Paris, 09712-450 da Conceição Verde / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pereira - EI', '45.706.831/0001-11', 'dsiqueira@brito.gov.br', '+55 61 1726-0694', 'Travessa de Almeida, 89, Jardim América, 30525649 Albuquerque / RO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Jesus', '70.642.935/0001-57', 'moraesigor@porto.br', '(084) 5326-1070', 'Ladeira de da Rosa, 83, Jardim Do Vale, 21222561 Mendonça da Serra / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pimenta', '75.831.692/0001-19', 'luiz-miguel77@siqueira.gov.br', '(084) 7482 1015', 'Largo Agatha Moraes, 96, Jardim Do Vale, 34188-543 Fogaça / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Caldeira - ME', '81.734.956/0001-19', 'krodrigues@fogaca.com.br', '+55 41 2850 0586', 'Esplanada Antônio Barbosa, 2, São Tomaz, 04181328 da Luz / RN');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Costa', '16.432.975/0001-29', 'antonellajesus@azevedo.br', '(021) 7924 4418', 'Campo Almeida, 68, Vila São Dimas, 13651-347 Santos das Flores / PE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costa Farias - EI', '86.341.075/0001-51', 'cirinocaroline@barros.gov.br', '31 8249-4429', 'Quadra da Cunha, 2, Maria Virgínia, 58411778 Sá / SP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Gonçalves', '59.241.670/0001-42', 'helena11@farias.com', '(021) 8622 4204', 'Lago Cirino, Mantiqueira, 57795-843 Nunes de Pacheco / SC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Rezende', '75.210.439/0001-48', 'mariahmendonca@porto.org', '+55 84 0216-1278', 'Vale Asafe Cassiano, 74, Suzana, 14290-686 Nogueira de Caldeira / PB');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costa', '18.690.753/0001-31', 'jteixeira@camara.com', '+55 (021) 1095-8582', 'Largo de Leão, 34, Miramar, 64933150 Pinto de Goiás / GO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sá Ltda.', '05.329.746/0001-67', 'iborges@albuquerque.edu.br', '(021) 3771-9688', 'Rodovia Brayan da Costa, 5, Bonfim, 33427-023 Mendonça dos Dourados / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Conceição - EI', '52.713.986/0001-40', 'heitor12@sousa.gov.br', '(031) 4042 9271', 'Praia de Machado, Luxemburgo, 78161-487 Porto / PA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Caldeira', '65.479.301/0001-95', 'olivia84@lima.edu.br', '84 6359-9552', 'Estrada Mendonça, 15, Pilar, 35054313 Guerra do Galho / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Rezende', '74.560.829/0001-85', 'piresana-cecilia@nascimento.br', '+55 (061) 0240-0683', 'Pátio Alves, 200, Concórdia, 38493071 Castro / SE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Garcia', '74.952.813/0001-18', 'diogocardoso@fogaca.br', '(041) 1718-8342', 'Feira Cavalcante, 37, Novo Tupi, 63068-667 Cunha / MA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pereira', '27.594.603/0001-15', 'dpinto@ribeiro.com', '+55 11 0609-7877', 'Feira Pacheco, 48, Vila Da Ária, 14264072 Machado / RS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novais', '18.902.754/0001-00', 'alvesrafaela@lopes.com.br', '(011) 2552-3197', 'Praia Antonella da Rosa, 32, Nossa Senhora Aparecida, 92253-555 Câmara das Flores / MA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sousa', '98.134.062/0001-90', 'dante83@cunha.br', '61 9937-8404', 'Chácara Enrico Sales, 26, Vila Maloca, 33406-541 da Rosa / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Monteiro - ME', '04.673.958/0001-02', 'henry-gabrielda-rosa@moraes.br', '81 3264 4802', 'Condomínio de Aragão, 3, Estrela Do Oriente, 75623545 Gomes / GO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Lima', '86.297.105/0001-70', 'benjamin47@nogueira.net', '+55 51 5176 1272', 'Estação Ravy Oliveira, 52, Vila Cemig, 71863030 Fogaça de da Conceição / CE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novaes', '32.408.617/0001-37', 'joaquimvasconcelos@marques.org', '+55 (051) 0838-3546', 'Viaduto Barros, 96, Vila Nova Cachoeirinha 2ª Seção, 34255-343 Cardoso / PI');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costela - EI', '93.874.015/0001-60', 'pviana@lima.gov.br', '+55 21 0715 6044', 'Colônia Carlos Eduardo Castro, 79, Apolonia, 56429162 Melo do Norte / SC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Duarte', '05.764.819/0001-49', 'aurora02@das.br', '+55 (021) 4803 7715', 'Feira Ana Clara Rezende, 33, Vila Suzana Segunda Seção, 89118882 Cunha / AC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Fogaça - ME', '09.475.368/0001-80', 'qcostela@cavalcanti.edu.br', '+55 41 2755 2069', 'Rodovia Hadassa Campos, Monte Azul, 64786-926 Azevedo / RO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pereira Lima e Filhos', '74.368.192/0001-20', 'joaquimsales@andrade.com', '+55 (081) 1113 7247', 'Estação da Conceição, 98, Vila Sesc, 57458-022 Dias / RN');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cavalcante - ME', '34.587.629/0001-00', 'fariasesther@barbosa.br', '21 9420 0645', 'Setor Olívia da Cruz, 78, Indaiá, 50573668 Pimenta / MT');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Melo', '62.453.780/0001-82', 'nathan34@silva.com.br', '+55 51 1303 9222', 'Favela de Rodrigues, 4, Xangri-Lá, 23153443 Cavalcanti / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Costa Ltda.', '51.648.092/0001-51', 'camaraayla@da.org', '+55 71 8221-7226', 'Lago Vasconcelos, 60, Canadá, 00166-557 Nascimento do Norte / PE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Melo', '89.643.025/0001-17', 'machadogael@oliveira.com', '0800-074-7081', 'Fazenda Viana, 8, Grotinha, 62736043 Caldeira do Sul / MA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Fonseca', '06.319.274/0001-24', 'fcampos@peixoto.com.br', '+55 21 8074 2174', 'Vereda de da Costa, 81, Cônego Pinheiro 1ª Seção, 67764-264 Ramos / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Freitas Ltda.', '58.024.913/0001-28', 'cecilia63@moura.com.br', '+55 31 2627 9421', 'Via Pacheco, 26, Santana Do Cafezal, 95352503 Porto / ES');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Porto', '29.178.064/0001-69', 'tsouza@pinto.com', '0300 343 3692', 'Área Dias, 86, Barro Preto, 07798-299 da Cruz / TO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Novais Ltda.', '52.138.469/0001-95', 'emoreira@gomes.com', '81 5244-1747', 'Pátio Luiz Felipe Pereira, 644, Marieta 1ª Seção, 15795840 Duarte dos Dourados / DF');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Casa Grande Marques - EI', '74.108.523/0001-92', 'fogacaasafe@garcia.br', '+55 (071) 4644-8340', 'Ladeira Benjamim da Luz, São Jorge 1ª Seção, 25614624 da Mota de Minas / RS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('das Neves', '69.158.732/0001-00', 'luan88@pereira.br', '+55 21 5225 1888', 'Alameda Nogueira, 17, Bandeirantes, 29757491 Nascimento do Campo / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Machado Sousa S/A', '05.476.319/0001-01', 'miguel12@duarte.com.br', '41 1753-1723', 'Trevo Campos, Liberdade, 64756232 Abreu / BA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Correia Barbosa Ltda.', '42.561.390/0001-19', 'da-motaenzo@peixoto.com.br', '0900 180 0994', 'Setor Ribeiro, 4, Grota, 90465-255 Correia do Galho / MS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cunha Moraes e Filhos', '02.591.687/0001-02', 'julia35@martins.com.br', '+55 (021) 4164 8041', 'Conjunto de Ribeiro, 46, Nossa Senhora Da Conceição, 46640-330 Macedo Grande / GO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Costa', '51.627.843/0001-53', 'rodrigocasa-grande@da.com', '0900-879-2171', 'Esplanada Thomas da Rocha, 50, Vila Nova Cachoeirinha 3ª Seção, 23842-230 Gonçalves das Pedras / MT');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cavalcanti Monteiro Ltda.', '52.094.317/0001-38', 'moreirajoao-felipe@nunes.gov.br', '(061) 7047 9282', 'Rodovia de da Mata, Pantanal, 96982286 Sampaio Grande / PR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Viana Siqueira S/A', '16.573.948/0001-76', 'alexandrecassiano@freitas.br', '+55 (011) 2347-6758', 'Loteamento Nicole Ramos, 683, Savassi, 07294-869 Cunha / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('das Neves', '38.740.625/0001-62', 'wmartins@fogaca.edu.br', '81 5236-8404', 'Chácara Olívia Pimenta, 69, Santana Do Cafezal, 69180421 Rodrigues / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Cunha S.A.', '19.743.805/0001-53', 'marcos-vinicius84@ferreira.br', '61 5380 2289', 'Ladeira Mariah da Conceição, 84, Grota, 80260856 Marques de Pereira / BA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cavalcanti', '15.387.069/0001-97', 'noah32@garcia.gov.br', '41 1037 8660', 'Praça de Montenegro, 87, Vila Atila De Paiva, 25888287 Mendonça do Galho / AL');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Mendonça', '97.510.264/0001-27', 'pgoncalves@siqueira.gov.br', '(061) 9492-8107', 'Quadra de da Cruz, 31, Nova Cachoeirinha, 63076427 da Costa / SE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Pires', '14.530.267/0001-03', 'portomiguel@leao.br', '+55 (081) 4077-2664', 'Condomínio Natália Pinto, 64, São Sebastião, 20516-855 Vieira de Goiás / PE');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Vasconcelos da Costa e Filhos', '61.307.298/0001-71', 'xguerra@almeida.com', '0900-867-2565', 'Passarela Macedo, 93, Cardoso, 36257766 Aparecida do Oeste / RJ');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Macedo da Mota - ME', '39.147.860/0001-98', 'elisa14@fernandes.com', '+55 84 2087 8641', 'Vale de Peixoto, 92, Novo Santa Cecilia, 75984077 Vargas / RO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Jesus', '45.027.896/0001-30', 'da-conceicaomanuella@das.com.br', '0900-001-9426', 'Alameda de da Rosa, 758, Alto Barroca, 36156060 Aparecida / MA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costela S.A.', '26.378.905/0001-93', 'nunesmurilo@silva.gov.br', '21 3279 7268', 'Vale de Albuquerque, Dom Bosco, 07776450 Almeida / RS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Carvalho Ltda.', '01.946.753/0001-57', 'arthur-gabriel34@mendonca.com', '+55 51 5915 0987', 'Rodovia Danilo Rocha, 2, Bernadete, 59864341 Cassiano / GO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Ferreira Gomes - EI', '79.120.384/0001-36', 'raul12@novais.com.br', '+55 (021) 9492-5976', 'Ladeira de Cassiano, 59, Baleia, 28414646 Pires das Pedras / TO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Nascimento', '31.045.768/0001-05', 'daniel33@silveira.com', '+55 51 1782 0947', 'Vila de Cirino, Anchieta, 86187754 Moura do Galho / BA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Ferreira da Rocha - ME', '70.419.263/0001-15', 'ravi-lucca59@cirino.br', '(084) 6099 5034', 'Trecho de Fernandes, 4, Jaraguá, 69265-060 Montenegro Alegre / AM');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Dias Ltda.', '27.019.834/0001-03', 'viniciusnovais@mendes.gov.br', '+55 (011) 5226-7993', 'Ladeira Lorena Garcia, 41, Conjunto Floramar, 29196-786 Martins / AC');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Souza Cavalcanti - ME', '67.938.504/0001-28', 'ribeiroryan@farias.gov.br', '+55 (051) 8447 9404', 'Lagoa Mariah Brito, 542, Biquinhas, 25692-661 Sales de Santos / PR');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Sampaio e Filhos', '16.930.257/0001-82', 'sophie59@macedo.net', '81 0508-8681', 'Avenida de Cavalcanti, 52, Monte Azul, 08545-270 Borges Paulista / PA');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Viana', '51.620.897/0001-97', 'yda-mota@porto.gov.br', '+55 (021) 1188-5585', 'Parque Pastor, 53, Petropolis, 02943-173 Leão / AP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Alves Moura e Filhos', '49.671.253/0001-86', 'wcavalcante@souza.com', '0300 310 8565', 'Travessa Pastor, 359, Vila Atila De Paiva, 19509-604 Machado / RO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Camargo', '83.165.902/0001-05', 'benicio31@pinto.br', '+55 11 4191 2909', 'Feira João Rezende, Conjunto Jatoba, 53483746 Alves / TO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costela S/A', '08.269.531/0001-96', 'da-pazjoao-felipe@guerra.br', '21 9251-1495', 'Campo José Pedro Araújo, Ipiranga, 46750636 Sousa de Fonseca / AL');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Silveira', '31.480.967/0001-41', 'matteoribeiro@cirino.net', '+55 (084) 8279 4023', 'Esplanada de da Rosa, 51, Santa Terezinha, 83637085 Montenegro / RN');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Abreu', '34.162.975/0001-38', 'uda-rosa@cunha.com', '+55 81 3578 1932', 'Setor Fogaça, 90, Havaí, 04185518 Barbosa / MS');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Barbosa', '17.425.896/0001-53', 'miguel62@gomes.com', '0500 498 3261', 'Setor de Moreira, 25, Esperança, 02680-243 Viana Verde / MG');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Cassiano', '15.429.037/0001-07', 'luancirino@novaes.com.br', '+55 61 0690 7627', 'Trevo de Lopes, 6, Vila Canto Do Sabiá, 52588-902 Ramos / MT');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Silveira Casa Grande S.A.', '45.820.317/0001-02', 'viniciusda-mata@barbosa.org', '(051) 5707-0836', 'Passarela da Conceição, 95, Pindura Saia, 69093-297 Garcia / ES');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Costela Rodrigues S/A', '72.458.610/0001-44', 'limajose-miguel@rezende.org', '+55 (071) 6906 8769', 'Via Otto Viana, 95, Alto Barroca, 18192-355 Borges / RO');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('da Rosa Cardoso e Filhos', '93.506.184/0001-47', 'hda-mata@carvalho.gov.br', '41 9685 0176', 'Sítio Theo da Cunha, 14, Olhos Dágua, 30566360 Araújo / SP');
INSERT INTO fornecedores (razao_social, cnpj, email, telefone, endereco) VALUES ('Borges', '81.520.976/0001-97', 'oaraujo@da.gov.br', '(041) 7787 9815', 'Viela Aragão, Castanheira, 67250932 Camargo do Galho / RN');

INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Evelyn Monteiro', '976.518.423-91', 'oliver69@example.net', '+55 (011) 5885-4488', '2022-09-03 12:08:38');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sofia Santos', '845.960.371-75', 'raul58@example.org', '+55 41 3204-0511', '2021-05-30 12:58:47');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Giovanna da Mata', '817.624.953-09', 'mariane03@example.com', '+55 61 5174-1576', '2023-01-01 19:14:48');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sophie Marques', '579.380.612-12', 'mateus77@example.org', '(041) 9991 1705', '2024-12-12 00:12:47');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Caio Nascimento', '106.783.245-90', 'da-cruzluiz-gustavo@example.com', '+55 71 2301-7966', '2022-06-26 07:40:11');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Vitória Fonseca', '869.534.027-92', 'moraesaylla@example.org', '(084) 1759 4954', '2022-07-03 07:52:40');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Luiz Gustavo Albuquerque', '854.392.607-65', 'sgoncalves@example.org', '31 5787-7900', '2022-10-07 07:13:54');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Theodoro das Neves', '930.467.281-31', 'monteiroemanuel@example.net', '31 7482 8234', '2021-10-16 10:45:09');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('João Miguel da Rosa', '564.790.123-99', 'gustavo-henrique25@example.net', '71 5338-7587', '2021-07-17 16:09:57');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Melissa Leão', '678.193.024-96', 'brendapastor@example.net', '61 2682 1903', '2021-11-14 18:53:11');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dr. Yan Azevedo', '409.537.821-23', 'almeidaandre@example.org', '+55 (061) 5827-6465', '2025-03-18 18:21:28');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Vitor Gabriel Melo', '590.123.764-16', 'gustavo-henriqueborges@example.org', '81 1507 3711', '2022-12-15 02:22:20');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Montenegro', '809.615.327-77', 'pietronascimento@example.net', '(081) 8481-2062', '2022-04-17 17:48:37');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Vitor Gabriel Carvalho', '419.805.623-42', 'noahaparecida@example.com', '61 5352 2788', '2023-05-15 00:20:06');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Laura Costa', '089.173.425-23', 'danilovieira@example.org', '61 5567 9464', '2023-08-06 17:48:48');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Ana Vitória Monteiro', '579.380.621-03', 'liviarezende@example.com', '0900-463-3687', '2023-01-19 22:46:31');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Olivia Lopes', '389.157.042-23', 'melina50@example.com', '+55 (021) 3202-8790', '2023-08-31 05:08:37');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Evelyn Rocha', '362.914.587-64', 'kevinfernandes@example.net', '61 1178 7021', '2023-01-10 11:50:49');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Rodrigo Barbosa', '435.891.602-33', 'nina83@example.com', '(084) 2750-5086', '2025-02-19 18:41:55');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Augusto da Mata', '201.896.347-31', 'manuellaaragao@example.net', '84 9912 0080', '2024-12-28 11:04:22');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dr. Benício Costela', '638.497.210-78', 'siqueirajulia@example.com', '(084) 2576-0052', '2025-09-18 05:19:45');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Isaque Gonçalves', '217.403.869-22', 'pastorana@example.com', '0900 462 3450', '2024-07-23 20:56:35');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dra. Heloisa Castro', '357.920.816-03', 'qguerra@example.com', '0500-612-9906', '2022-12-29 19:32:49');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dr. Valentim Cunha', '691.802.347-04', 'clarice14@example.org', '(081) 5208-5664', '2021-08-21 21:12:15');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Srta. Maysa Souza', '825.149.670-58', 'babreu@example.net', '71 0891 9489', '2023-06-15 11:57:52');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Júlia Vargas', '873.602.514-35', 'tramos@example.com', '0300-787-5160', '2025-12-24 04:39:43');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Juan Novais', '472.631.590-07', 'ester37@example.com', '+55 51 8171 1299', '2024-02-22 14:29:00');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Henry Câmara', '315.698.240-70', 'isilveira@example.com', '11 2828 5764', '2022-12-06 17:44:10');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sra. Ayla Teixeira', '069.814.573-93', 'yviana@example.net', '+55 61 8096-4315', '2025-05-02 23:57:37');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Clara Camargo', '984.276.031-69', 'macedoisabel@example.org', '71 3590 4581', '2024-03-24 00:27:59');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Rael Teixeira', '170.462.359-61', 'qporto@example.net', '+55 11 1537 9919', '2024-01-28 12:01:12');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Lunna Rezende', '954.160.823-05', 'brenda71@example.com', '+55 61 6222 6920', '2021-10-11 17:25:44');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('João Felipe Novaes', '743.650.812-17', 'matteoribeiro@example.net', '+55 11 4701 9172', '2022-02-24 10:42:20');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Srta. Luísa Moraes', '415.726.398-73', 'anna-liz59@example.org', '(051) 5826-6759', '2021-06-06 02:19:25');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Eduarda Freitas', '234.685.719-09', 'carolina06@example.com', '+55 (031) 9552-9262', '2023-04-08 13:28:44');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Enrico Pacheco', '427.980.153-32', 'alvesotto@example.com', '71 8203-7749', '2024-02-13 08:32:16');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Srta. Mirella Pastor', '590.381.427-14', 'montenegronina@example.com', '61 2616-8635', '2026-03-11 14:46:48');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Arthur Gabriel Cassiano', '406.371.259-16', 'murilo58@example.net', '0800-102-0258', '2024-11-14 14:22:08');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Igor Teixeira', '152.360.897-86', 'renan42@example.com', '+55 (011) 2135 4026', '2025-10-05 23:13:39');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Arthur Gabriel Oliveira', '078.491.623-31', 'hellenada-paz@example.org', '0800 940 2082', '2024-12-01 23:18:42');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Júlia Vargas', '280.317.569-02', 'ana-luizamoura@example.net', '61 9359-6735', '2023-05-16 16:23:46');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Srta. Isabela Cunha', '962.014.587-94', 'limaluiz-miguel@example.org', '31 5541-3233', '2024-06-28 01:40:53');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Davi Lucca Alves', '395.047.216-99', 'camilaviana@example.org', '+55 21 3824 7270', '2021-12-05 01:45:17');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Jade da Cunha', '658.923.014-51', 'mouraluiza@example.net', '+55 (041) 7016-7397', '2025-06-16 12:15:01');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('João Gabriel Gonçalves', '431.287.950-88', 'fariasmelissa@example.net', '+55 81 7551-6477', '2025-04-20 09:53:42');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Ana Carolina Dias', '479.582.310-32', 'davifreitas@example.org', '0800 966 3257', '2024-11-15 07:11:59');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Apollo Pastor', '450.279.631-06', 'milenaazevedo@example.com', '+55 (021) 0771 4074', '2022-02-18 04:57:12');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Vitor Hugo Macedo', '918.236.547-46', 'maria-juliaazevedo@example.org', '+55 71 2482-7219', '2022-01-23 21:03:17');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Théo Macedo', '783.051.296-59', 'emanuel87@example.org', '0800-198-4364', '2025-02-10 02:24:12');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Luísa Marques', '579.062.413-80', 'maria-cecilia67@example.org', '41 7657-3454', '2025-11-27 16:47:52');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Cassiano', '368.120.475-62', 'benjamin69@example.com', '+55 81 0513-7076', '2024-03-05 08:11:44');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Davi Vargas', '148.935.607-00', 'vianaisaque@example.org', '(051) 5754-7698', '2024-03-31 16:52:27');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Matheus Teixeira', '546.930.218-06', 'novaisluiza@example.org', '(071) 4773 2695', '2024-01-05 01:18:51');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sr. Mateus Leão', '597.483.602-29', 'marcos-viniciusfreitas@example.com', '+55 61 3324-8339', '2021-06-20 06:43:24');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Ester Nogueira', '138.567.294-37', 'zsousa@example.com', '(081) 3185-2439', '2022-07-10 02:57:42');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Paulo Fonseca', '546.180.927-85', 'emanuella21@example.net', '(071) 0105-4494', '2025-01-21 15:54:25');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sra. Juliana Moraes', '584.197.602-85', 'gustavonascimento@example.org', '84 4452 8533', '2023-05-26 22:13:28');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Isis Costela', '104.875.932-60', 'bernardo49@example.org', '0300 707 4709', '2021-08-19 14:41:34');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sr. Arthur Gabriel Alves', '296.375.108-77', 'kcassiano@example.net', '0800-639-6594', '2024-01-06 02:58:58');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Rodrigo Andrade', '918.240.637-50', 'nicole35@example.com', '(011) 6934 1929', '2025-01-26 17:04:27');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Ágatha Câmara', '526.813.970-30', 'liamribeiro@example.com', '+55 61 8859 1523', '2026-03-18 05:01:07');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Cauã Novais', '940.265.183-70', 'peixotomaria-sophia@example.org', '+55 (041) 0134 0201', '2021-07-06 19:00:08');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Bianca Brito', '357.691.082-40', 'qaraujo@example.org', '51 3444 3156', '2021-07-06 18:44:08');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Ana Beatriz Rezende', '469.872.103-22', 'nathan44@example.com', '+55 (051) 3126-0292', '2026-04-04 01:33:27');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Yago Aragão', '907.156.382-03', 'rsantos@example.org', '(084) 8856 1106', '2025-05-04 01:10:04');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Davi Teixeira', '415.302.896-70', 'rhavida-luz@example.org', '0500-765-3362', '2024-05-31 05:44:24');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Caio Novais', '470.128.936-13', 'correiamatteo@example.org', '+55 (081) 1055 7156', '2022-05-08 23:54:30');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Rafaela Porto', '596.041.378-75', 'arthurdias@example.com', '0900 271 8222', '2021-07-31 09:27:03');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Enrico Freitas', '815.027.364-62', 'manuella54@example.org', '+55 (084) 2224 9162', '2021-12-07 09:23:22');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Natália Machado', '548.037.216-53', 'ceciliacamargo@example.org', '(061) 3162 3038', '2024-01-10 12:13:44');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Emanuelly Farias', '564.927.031-70', 'agathacavalcanti@example.net', '31 9168 6122', '2023-07-05 23:23:30');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Diogo Rodrigues', '975.138.640-39', 'camarakamilly@example.com', '(031) 5678 0662', '2022-01-20 08:44:01');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Anna Liz Aparecida', '380.145.297-23', 'heitorgoncalves@example.net', '(051) 1328-5681', '2026-05-07 08:52:10');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Davi Luiz Rios', '527.918.634-19', 'da-rochaoliver@example.com', '+55 21 7833 6873', '2025-07-18 06:29:49');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Luiz Felipe Novais', '695.148.720-02', 'montenegrojade@example.org', '+55 21 0463-3303', '2023-09-28 23:02:03');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Luigi Melo', '306.495.781-39', 'novaescecilia@example.org', '+55 21 8102 3344', '2025-06-28 08:18:07');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Renan Cavalcante', '109.523.786-12', 'juan79@example.com', '11 2246-9188', '2022-07-31 20:18:51');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dr. Otávio Siqueira', '062.497.381-69', 'albuquerquethomas@example.net', '(084) 2825-5943', '2023-11-28 11:33:48');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Levi Azevedo', '216.739.805-03', 'nascimentoyasmin@example.org', '71 1372-9462', '2026-03-11 23:50:23');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sra. Maria Helena Pereira', '542.970.631-07', 'luaravasconcelos@example.org', '+55 (021) 5274 4231', '2023-12-18 21:10:57');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sophie Sales', '936.471.528-46', 'aazevedo@example.net', '21 2588-8180', '2021-09-27 02:40:58');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Emanuelly Souza', '159.843.260-51', 'juanramos@example.com', '(081) 5730-2578', '2024-03-16 06:32:55');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sr. Enzo Gabriel Cavalcante', '102.793.685-77', 'pfogaca@example.com', '0500 872 4323', '2021-09-12 04:24:11');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Raul Montenegro', '159.208.764-76', 'felipeoliveira@example.org', '41 1082 9843', '2025-01-02 23:47:02');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Bárbara Siqueira', '132.487.569-00', 'dante90@example.com', '+55 (061) 7426 3561', '2026-01-05 18:41:23');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Isaque Viana', '274.093.816-04', 'gduarte@example.com', '(051) 9462-9431', '2021-09-20 15:59:16');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Joaquim Guerra', '680.512.749-11', 'benjamim18@example.com', '21 7674-4584', '2021-11-07 14:06:34');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Luiz Fernando Sales', '782.615.093-03', 'ravida-cruz@example.com', '(071) 0225 7029', '2026-02-15 13:53:25');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Srta. Alana Vargas', '057.631.842-62', 'tpires@example.org', '+55 21 9270 0306', '2022-07-26 06:41:59');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Rael Sá', '758.136.209-40', 'sara85@example.net', '51 5213 4627', '2025-11-12 05:21:47');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Maria Júlia Campos', '280.514.367-17', 'vfogaca@example.org', '+55 (081) 2517 3931', '2026-04-15 17:47:06');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Samuel Machado', '370.592.681-03', 'hmelo@example.com', '71 2032 5499', '2022-09-29 23:35:09');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Mateus Pacheco', '634.581.792-91', 'julia22@example.org', '0900 568 4808', '2021-10-29 09:32:41');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Bárbara Araújo', '567.124.938-46', 'joao-pedro44@example.org', '61 1334-2682', '2024-11-03 16:17:32');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Dra. Ísis da Costa', '985.673.421-55', 'limalorenzo@example.org', '61 8275-9992', '2023-10-13 01:36:16');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Olívia Porto', '219.586.437-00', 'nascimentoleo@example.net', '0800 535 5590', '2023-08-11 13:56:52');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sr. Rodrigo Dias', '352.807.149-41', 'gael-henrique53@example.com', '(011) 4382-4831', '2024-07-31 12:14:51');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Carlos Eduardo Freitas', '038.745.269-92', 'sabrina37@example.org', '0900-070-4167', '2022-06-20 21:18:02');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Sra. Stephany Camargo', '079.428.516-30', 'rebecapacheco@example.org', '0800 885 5995', '2021-07-11 20:13:20');
INSERT INTO clientes (nome, cpf, email, telefone, data_cadastro) VALUES ('Elisa Marques', '065.481.932-70', 'carolina80@example.net', '+55 (031) 1622 4546', '2023-07-23 01:59:04');

INSERT INTO cidades (nome, id_estado) VALUES ('Marques do Norte', 24);
INSERT INTO cidades (nome, id_estado) VALUES ('Farias', 8);
INSERT INTO cidades (nome, id_estado) VALUES ('Cassiano das Flores', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Borges dos Dourados', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Vargas', 15);
INSERT INTO cidades (nome, id_estado) VALUES ('Albuquerque', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Fonseca da Mata', 1);
INSERT INTO cidades (nome, id_estado) VALUES ('Aragão do Galho', 26);
INSERT INTO cidades (nome, id_estado) VALUES ('Alves dos Dourados', 25);
INSERT INTO cidades (nome, id_estado) VALUES ('Gonçalves da Mata', 18);
INSERT INTO cidades (nome, id_estado) VALUES ('Viana de Minas', 9);
INSERT INTO cidades (nome, id_estado) VALUES ('da Luz das Pedras', 13);
INSERT INTO cidades (nome, id_estado) VALUES ('Casa Grande', 27);
INSERT INTO cidades (nome, id_estado) VALUES ('Cassiano', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Fogaça do Sul', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Novaes', 4);
INSERT INTO cidades (nome, id_estado) VALUES ('Pinto', 18);
INSERT INTO cidades (nome, id_estado) VALUES ('Moreira Verde', 20);
INSERT INTO cidades (nome, id_estado) VALUES ('Albuquerque das Flores', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Aparecida da Serra', 16);
INSERT INTO cidades (nome, id_estado) VALUES ('Abreu', 25);
INSERT INTO cidades (nome, id_estado) VALUES ('Casa Grande do Amparo', 21);
INSERT INTO cidades (nome, id_estado) VALUES ('Teixeira dos Dourados', 4);
INSERT INTO cidades (nome, id_estado) VALUES ('Câmara das Flores', 3);
INSERT INTO cidades (nome, id_estado) VALUES ('Machado das Flores', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Barbosa do Galho', 7);
INSERT INTO cidades (nome, id_estado) VALUES ('Silveira', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Guerra', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Rodrigues', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Aparecida do Sul', 23);
INSERT INTO cidades (nome, id_estado) VALUES ('Araújo', 22);
INSERT INTO cidades (nome, id_estado) VALUES ('Cunha', 21);
INSERT INTO cidades (nome, id_estado) VALUES ('Garcia de da Costa', 16);
INSERT INTO cidades (nome, id_estado) VALUES ('Santos de Nascimento', 25);
INSERT INTO cidades (nome, id_estado) VALUES ('Marques', 11);
INSERT INTO cidades (nome, id_estado) VALUES ('Silveira do Amparo', 24);
INSERT INTO cidades (nome, id_estado) VALUES ('Pimenta', 27);
INSERT INTO cidades (nome, id_estado) VALUES ('Fernandes do Galho', 20);
INSERT INTO cidades (nome, id_estado) VALUES ('da Luz de Goiás', 10);
INSERT INTO cidades (nome, id_estado) VALUES ('Almeida de Pereira', 1);
INSERT INTO cidades (nome, id_estado) VALUES ('Leão', 4);
INSERT INTO cidades (nome, id_estado) VALUES ('da Cruz de Duarte', 1);
INSERT INTO cidades (nome, id_estado) VALUES ('Barros da Serra', 10);
INSERT INTO cidades (nome, id_estado) VALUES ('Melo da Mata', 13);
INSERT INTO cidades (nome, id_estado) VALUES ('das Neves', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Sampaio', 11);
INSERT INTO cidades (nome, id_estado) VALUES ('Gomes', 26);
INSERT INTO cidades (nome, id_estado) VALUES ('Sampaio dos Dourados', 24);
INSERT INTO cidades (nome, id_estado) VALUES ('Caldeira da Praia', 10);
INSERT INTO cidades (nome, id_estado) VALUES ('Viana', 21);
INSERT INTO cidades (nome, id_estado) VALUES ('Gomes', 10);
INSERT INTO cidades (nome, id_estado) VALUES ('Siqueira do Sul', 27);
INSERT INTO cidades (nome, id_estado) VALUES ('Leão', 13);
INSERT INTO cidades (nome, id_estado) VALUES ('Aragão da Prata', 4);
INSERT INTO cidades (nome, id_estado) VALUES ('Borges', 15);
INSERT INTO cidades (nome, id_estado) VALUES ('Ferreira do Amparo', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Fogaça', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Melo de Vieira', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Jesus do Sul', 23);
INSERT INTO cidades (nome, id_estado) VALUES ('da Mata do Oeste', 2);
INSERT INTO cidades (nome, id_estado) VALUES ('Almeida', 27);
INSERT INTO cidades (nome, id_estado) VALUES ('Andrade das Pedras', 1);
INSERT INTO cidades (nome, id_estado) VALUES ('Lima', 3);
INSERT INTO cidades (nome, id_estado) VALUES ('da Conceição das Flores', 6);
INSERT INTO cidades (nome, id_estado) VALUES ('Brito de Cavalcanti', 10);
INSERT INTO cidades (nome, id_estado) VALUES ('Rocha do Norte', 22);
INSERT INTO cidades (nome, id_estado) VALUES ('Pastor', 12);
INSERT INTO cidades (nome, id_estado) VALUES ('da Paz', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Farias', 8);
INSERT INTO cidades (nome, id_estado) VALUES ('Sá', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Monteiro', 11);
INSERT INTO cidades (nome, id_estado) VALUES ('Nascimento de Rios', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Costa de Araújo', 18);
INSERT INTO cidades (nome, id_estado) VALUES ('Oliveira', 12);
INSERT INTO cidades (nome, id_estado) VALUES ('Pereira de Nascimento', 20);
INSERT INTO cidades (nome, id_estado) VALUES ('Caldeira', 15);
INSERT INTO cidades (nome, id_estado) VALUES ('Viana do Campo', 3);
INSERT INTO cidades (nome, id_estado) VALUES ('Novais', 18);
INSERT INTO cidades (nome, id_estado) VALUES ('Caldeira', 7);
INSERT INTO cidades (nome, id_estado) VALUES ('Souza de Moura', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Castro de Novais', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Correia de Minas', 20);
INSERT INTO cidades (nome, id_estado) VALUES ('Mendes da Prata', 9);
INSERT INTO cidades (nome, id_estado) VALUES ('Nascimento', 26);
INSERT INTO cidades (nome, id_estado) VALUES ('Fogaça', 3);
INSERT INTO cidades (nome, id_estado) VALUES ('Costela', 26);
INSERT INTO cidades (nome, id_estado) VALUES ('Leão', 16);
INSERT INTO cidades (nome, id_estado) VALUES ('da Costa Grande', 7);
INSERT INTO cidades (nome, id_estado) VALUES ('da Cruz', 2);
INSERT INTO cidades (nome, id_estado) VALUES ('Pereira das Flores', 8);
INSERT INTO cidades (nome, id_estado) VALUES ('Fonseca de Goiás', 2);
INSERT INTO cidades (nome, id_estado) VALUES ('Garcia', 21);
INSERT INTO cidades (nome, id_estado) VALUES ('da Mata', 18);
INSERT INTO cidades (nome, id_estado) VALUES ('Aparecida', 19);
INSERT INTO cidades (nome, id_estado) VALUES ('Casa Grande das Flores', 14);
INSERT INTO cidades (nome, id_estado) VALUES ('Cirino', 25);
INSERT INTO cidades (nome, id_estado) VALUES ('Lopes Paulista', 21);
INSERT INTO cidades (nome, id_estado) VALUES ('Porto', 17);
INSERT INTO cidades (nome, id_estado) VALUES ('Siqueira de Goiás', 24);
INSERT INTO cidades (nome, id_estado) VALUES ('Vargas do Sul', 18);

INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Qui', 'Doloribus numquam velit quasi quisquam quisquam.', 375.17, 'G', 'Branco', 35, 70);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Modi', 'Magni maiores hic corrupti totam occaecati deserunt. Ut officiis excepturi tenetur.', 405.07, 'P', 'Verde', 65, 83);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Expedita', 'Est fugiat laboriosam adipisci fugiat deleniti. Voluptas commodi sunt eos assumenda facere.', 856.07, 'P', 'Marrom', 26, 10);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Culpa', 'Aliquam quasi occaecati fuga voluptate. Dolorum culpa nam esse unde tenetur.', 123.69, 'XG', 'Cinza', 19, 19);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Fugiat', 'Quia culpa quod expedita enim. Occaecati ipsa inventore aperiam.', 622.26, 'XG', 'Vermelho', 48, 68);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Recusandae', 'Deserunt incidunt incidunt quia optio tempora non tempora. Voluptates aut eius deserunt accusantium.', 763.43, 'M', 'Rosa', 5, 7);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Consectetur', 'Voluptatibus nostrum repellat ullam. Rem deserunt beatae maiores quam at similique.', 255.93, 'XG', 'Preto', 77, 42);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Cum', 'Earum veniam distinctio corrupti. Ut odit blanditiis deleniti quasi asperiores reiciendis.', 121.85, 'XG', 'Cinza', 35, 25);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Possimus', 'Velit qui consequuntur iste.', 718.49, 'XG', 'Amarelo', 31, 1);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Ea', 'Quae dolore ipsum quia ea. Exercitationem quia animi ad recusandae. Est velit impedit quia sunt.', 171.94, 'XG', 'Vermelho', 62, 16);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Rerum', 'Eum debitis autem voluptate. Repellat cum tempora optio placeat laboriosam.', 367.22, 'XG', 'Azul', 66, 12);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Soluta', 'Non excepturi sunt sed suscipit. Facilis dignissimos optio inventore sint.', 650.57, 'GG', 'Rosa', 31, 81);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Iure', 'Ipsam molestiae dolore fuga alias. Modi aut omnis unde consequatur. Et assumenda accusamus libero.', 478.9, 'XG', 'Branco', 85, 89);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Consequatur', 'Voluptatem laboriosam qui voluptate enim voluptatibus veritatis. Mollitia perspiciatis cum saepe eum praesentium ut.', 797.81, 'PP', 'Preto', 100, 65);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Dicta', 'Eius praesentium magnam sed autem deleniti iusto. Similique sapiente magnam quos blanditiis adipisci corporis.', 174.92, 'G', 'Preto', 88, 23);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Dolores', 'Porro dicta libero odit temporibus dignissimos veniam. Libero quod sapiente vero. Doloribus illum inventore voluptatem.', 41.61, 'G', 'Roxo', 56, 25);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Labore', 'Neque cumque quas debitis quasi delectus tempore. Minus sequi nemo hic quis quia.', 738.7, 'GG', 'Verde', 63, 38);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Officiis', 'Magni quasi dolorem sit sapiente. Nam voluptatem ea quidem quo. Dolores saepe aut deserunt repellat corrupti.', 817.22, 'XG', 'Marrom', 25, 18);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Fuga', 'Sint fugiat in temporibus consequatur vero. Ad dolorem a odio atque laboriosam consequuntur.', 736.89, 'P', 'Cinza', 69, 11);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Qui', 'Voluptas saepe tenetur voluptatibus dolor. Dolor odio beatae modi officiis.', 598.36, 'G', 'Rosa', 49, 84);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Cumque', 'Cupiditate hic incidunt nostrum a. Sapiente quo magni officia quod. Iste est enim accusantium iste.', 486.44, 'PP', 'Azul', 97, 22);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Jaquetas Hic', 'Earum ut inventore quidem cum hic aperiam repellendus. Sapiente voluptatibus ad unde cumque repellat voluptatibus.', 889.33, 'GG', 'Rosa', 90, 16);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Tempore', 'Laborum fugiat fugit blanditiis quae fugit.', 777.16, 'PP', 'Amarelo', 64, 70);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Voluptas', 'Eum aliquid quibusdam facere. Maiores soluta in inventore voluptates.', 663.1, 'P', 'Cinza', 28, 23);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Nobis', 'Cum corporis harum necessitatibus quos deserunt. Odit expedita ea iusto beatae saepe.', 528.84, 'P', 'Amarelo', 63, 59);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Fuga', 'Dolorem eos consectetur voluptatem error. Quis enim necessitatibus iure labore iusto.', 524.87, 'PP', 'Roxo', 61, 85);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Quae', 'Temporibus enim maxime. Nihil quidem ipsa quod laboriosam laborum impedit.', 182.72, 'M', 'Vermelho', 6, 7);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Laborum', 'Dolor exercitationem odit libero fugiat. Ea sequi magni rerum neque porro.', 137.95, 'XG', 'Azul', 74, 44);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Consequatur', 'Ipsum minima qui laboriosam odio unde. Non cum ut totam modi. Eaque deleniti ipsa assumenda sequi dolor.', 407.69, 'M', 'Cinza', 96, 83);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Assumenda', 'Totam minima repudiandae ea quasi at. Cumque alias eligendi ea. Quo harum officia totam veniam.', 213.23, 'GG', 'Marrom', 37, 47);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Neque', 'Soluta reiciendis nulla dicta.
Totam recusandae molestiae consequatur. Beatae ad odit dolorum.', 32.62, 'XG', 'Verde', 21, 60);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Dolorum', 'Harum soluta quaerat veniam. Quam tenetur occaecati temporibus itaque libero blanditiis. Consectetur eum sed mollitia.', 616.28, 'XG', 'Azul', 3, 69);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Voluptate', 'Molestias cumque ipsa nihil quia quasi. Sunt maxime at iste quo voluptatum. Officiis beatae dignissimos nulla ducimus.', 542.42, 'M', 'Preto', 91, 78);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Rerum', 'Tempore quidem possimus cum cupiditate facere. Totam quibusdam quasi atque animi.', 437.81, 'GG', 'Vermelho', 44, 66);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Accusamus', 'Aperiam veniam aut nobis corrupti.', 546.95, 'PP', 'Cinza', 69, 85);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Neque', 'Officiis ipsa voluptatem incidunt ipsam ut ipsum similique.
Minus consequatur veritatis cumque eaque.', 119.09, 'P', 'Amarelo', 38, 96);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Nam', 'Eos reprehenderit voluptates iusto. Libero id in. Quo excepturi provident odio provident omnis ullam consequuntur.', 531.91, 'XG', 'Preto', 89, 91);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Amet', 'Unde amet officia eveniet saepe. Architecto dolore nostrum nisi enim repellendus.', 801.67, 'M', 'Preto', 2, 71);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Explicabo', 'Facere molestias inventore doloremque inventore eum consequatur. Eaque magnam cumque beatae aspernatur a dolorem.', 171.27, 'P', 'Roxo', 33, 29);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Cumque', 'Ab enim quaerat quam ratione. Error quas corrupti labore labore aperiam cupiditate quibusdam.', 330.49, 'XG', 'Vermelho', 82, 48);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Jaquetas Incidunt', 'Ducimus assumenda aliquam id vitae delectus laborum. Ea in dolores adipisci nesciunt quo in quis.', 477.49, 'XG', 'Marrom', 38, 91);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Velit', 'Quae alias sapiente amet alias alias ratione. Perspiciatis odio dignissimos possimus rerum officiis.', 771.33, 'M', 'Preto', 89, 60);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Illum', 'Deleniti excepturi perspiciatis tempore facere distinctio facere. Dicta tempore debitis.', 381.8, 'GG', 'Verde', 39, 10);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Ullam', 'Sunt rem reiciendis quos neque impedit sapiente. In deleniti quaerat a dolore aspernatur saepe.', 196.21, 'XG', 'Azul', 36, 51);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Autem', 'Ipsam quos omnis molestias sint. Illum totam explicabo delectus veniam.', 326.89, 'M', 'Verde', 60, 35);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Jaquetas Ipsa', 'Neque nihil pariatur voluptatum quas nihil voluptates.', 100.87, 'P', 'Marrom', 48, 84);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Jaquetas Quibusdam', 'Temporibus reiciendis neque dicta. Ullam reprehenderit maxime. Nostrum recusandae qui culpa.', 312.0, 'PP', 'Marrom', 36, 43);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Unde', 'Expedita aliquid quaerat.
Est est animi ut. Quae vero dignissimos sit.
Voluptatibus a dolorum architecto.', 856.91, 'XG', 'Amarelo', 75, 46);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Illo', 'Molestiae quas et error animi provident. In vero aliquid facilis.', 206.87, 'P', 'Preto', 20, 19);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Quia', 'Consequatur voluptas at harum harum aliquid aperiam. Dolorem repellat reprehenderit.', 815.96, 'GG', 'Roxo', 97, 88);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Nobis', 'Illum iusto ab. Non eaque hic eveniet sequi illo. Ipsum harum suscipit deleniti.', 517.45, 'P', 'Amarelo', 37, 4);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Sapiente', 'Nostrum delectus minus possimus ea nemo. Asperiores sed iste facere.', 245.82, 'P', 'Amarelo', 60, 48);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Vel', 'Alias impedit maxime officiis. Libero sint nesciunt debitis recusandae quo.', 461.97, 'XG', 'Vermelho', 66, 62);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Et', 'Accusamus soluta eligendi error quaerat eligendi. Sit maiores consectetur delectus veniam eos voluptatem.', 319.05, 'G', 'Azul', 44, 26);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Pariatur', 'Aliquam recusandae mollitia omnis. Reiciendis ipsum at non. Neque nihil accusamus tenetur.', 545.41, 'PP', 'Cinza', 20, 63);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Atque', 'Quos tenetur fugit dolore assumenda ea. Minus est adipisci voluptatibus illum.', 856.62, 'P', 'Azul', 23, 31);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Enim', 'Porro quae quisquam. Eum tempora impedit. Soluta nesciunt enim eum aperiam.', 435.35, 'XG', 'Cinza', 3, 100);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Occaecati', 'Earum minima sint ut incidunt voluptatem perspiciatis. Nihil velit quae porro.', 197.66, 'G', 'Verde', 20, 43);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Dignissimos', 'Hic laudantium dignissimos sed cumque. Ab dolor aspernatur magni. Dolore quis quaerat est.', 822.72, 'M', 'Preto', 16, 73);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Unde', 'Accusamus doloremque soluta illo repudiandae harum. Voluptatum asperiores veniam ullam necessitatibus totam.', 260.69, 'GG', 'Verde', 52, 32);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Placeat', 'Assumenda quas error molestiae. Voluptas natus error iste. Quod enim ipsam totam ab aliquid.', 844.88, 'P', 'Marrom', 45, 73);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Earum', 'Nesciunt occaecati deserunt aut modi quos labore.
Architecto dolorum modi labore necessitatibus totam nostrum.', 883.63, 'GG', 'Cinza', 75, 91);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Ullam', 'Minus voluptates fugit quia eaque quae. Fugiat repellat maxime voluptatibus. Vitae veniam nulla molestias.', 250.02, 'G', 'Preto', 95, 88);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Impedit', 'Modi tempora placeat nemo ullam. Sapiente iste itaque modi natus debitis.', 821.87, 'P', 'Branco', 78, 16);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Dolorum', 'Quis quasi repudiandae recusandae magni. Modi esse porro enim nemo quaerat.', 353.09, 'M', 'Azul', 44, 15);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Jaquetas Ea', 'Rerum id magni laboriosam facilis. Iusto odit tempore exercitationem at nostrum recusandae.', 248.14, 'XG', 'Marrom', 37, 3);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Tênis Modi', 'Mollitia omnis fugiat asperiores voluptates molestiae. Repudiandae praesentium quia dolor.', 228.52, 'M', 'Amarelo', 19, 2);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Quaerat', 'Quis nobis culpa harum. Illo libero dolorum. Numquam autem reiciendis esse amet numquam pariatur expedita.', 788.0, 'P', 'Azul', 26, 83);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Earum', 'Nemo quas tenetur exercitationem dolore nemo possimus. Quisquam sunt excepturi inventore esse.', 603.95, 'M', 'Amarelo', 71, 14);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Enim', 'Perferendis sint enim alias voluptas. Excepturi error laborum cupiditate soluta eius consequatur.', 652.81, 'G', 'Marrom', 15, 58);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Eum', 'Rem sint illo ad molestiae. Illum eligendi tempore velit sit modi. Sunt alias consequuntur ipsa.', 827.26, 'GG', 'Roxo', 75, 3);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Maiores', 'Debitis facere illo cupiditate tempora rem. Ad illum eos voluptates impedit ratione dignissimos.', 167.89, 'XG', 'Marrom', 63, 75);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Soluta', 'Aperiam saepe earum. Adipisci quibusdam sint. Asperiores modi enim asperiores architecto asperiores.', 463.3, 'PP', 'Preto', 20, 56);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Sequi', 'Suscipit recusandae facilis mollitia laboriosam. Dicta ipsum ad soluta. Maxime esse distinctio cupiditate.', 592.73, 'PP', 'Cinza', 58, 74);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Vestidos Odio', 'Aliquam temporibus optio expedita voluptatum excepturi.', 180.29, 'PP', 'Vermelho', 13, 70);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios In', 'Voluptatibus neque totam dolorum repudiandae illum.', 100.25, 'PP', 'Vermelho', 98, 18);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Asperiores', 'Voluptatem iste suscipit dolore libero. Exercitationem quis suscipit labore culpa harum. Alias nisi harum occaecati.', 482.03, 'GG', 'Vermelho', 54, 64);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças A', 'Natus autem ducimus eaque quod. Sunt nam dicta recusandae quos voluptate cumque. Alias facere architecto quisquam sint.', 94.79, 'GG', 'Amarelo', 76, 6);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Distinctio', 'Dignissimos quis porro. Molestiae pariatur ipsam.', 514.48, 'P', 'Marrom', 27, 1);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Dolorem', 'Enim commodi vitae. Magnam recusandae in illo vel.', 112.35, 'G', 'Amarelo', 2, 37);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Autem', 'Amet est sed. Sit dolore id exercitationem modi. Modi vero quasi. Repellendus quam amet deleniti.', 497.28, 'PP', 'Azul', 86, 31);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Unde', 'Odit eius eos. Corporis cupiditate quidem molestiae ad.', 101.01, 'M', 'Preto', 9, 30);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Tempore', 'Sequi dolorum repellat expedita voluptate repellendus porro. Suscipit cupiditate illum.', 303.52, 'P', 'Preto', 38, 7);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Aspernatur', 'Sed dignissimos eum iusto tempore. Unde hic ducimus enim amet accusantium reprehenderit.', 63.03, 'P', 'Verde', 80, 37);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Voluptatum', 'Reprehenderit adipisci doloribus enim. Expedita sequi laborum totam provident porro.', 266.73, 'PP', 'Vermelho', 64, 82);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Nisi', 'Molestiae soluta non. Quam ex necessitatibus. Quidem voluptatum omnis officia veritatis recusandae delectus.', 428.51, 'G', 'Verde', 69, 86);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Soluta', 'Itaque distinctio quis esse qui. Reiciendis itaque non natus laudantium. Mollitia quia itaque sequi.', 96.56, 'G', 'Cinza', 71, 92);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Non', 'Soluta ea possimus nostrum. Reiciendis cum voluptas totam beatae et.', 810.88, 'GG', 'Vermelho', 11, 67);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Nobis', 'Cum non ipsa. Nam tenetur quia in quibusdam explicabo. Cumque similique quo eius quisquam nobis.', 289.35, 'M', 'Amarelo', 22, 12);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Hic', 'Consequatur sapiente molestiae explicabo eveniet doloribus. Aperiam iste odit alias corrupti.', 575.72, 'GG', 'Cinza', 86, 44);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Unde', 'Sequi eaque suscipit et. Quas tempore ipsum reprehenderit quaerat sapiente ipsam.', 33.28, 'PP', 'Branco', 31, 23);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Acessórios Cum', 'Doloremque officia maiores. A incidunt quis animi eius eum laboriosam non. Cupiditate quasi officiis vero.', 196.96, 'P', 'Azul', 71, 26);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Quibusdam', 'Dolores sint non neque repellendus nemo perspiciatis vitae. Possimus amet earum cumque sit modi.', 413.32, 'G', 'Rosa', 97, 62);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Possimus', 'Cumque ipsam nihil. Numquam incidunt consectetur repudiandae ratione hic expedita eveniet.', 704.65, 'XG', 'Branco', 3, 70);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Camisetas Ex', 'Dolorum sit id veritatis voluptatem mollitia nemo voluptates. Aut facere placeat quam culpa tempora pariatur.', 735.83, 'XG', 'Marrom', 27, 9);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Calças Dolorem', 'Cupiditate perspiciatis hic dignissimos ut inventore. Nostrum porro sint dolorem fuga asperiores quod eligendi.', 241.27, 'GG', 'Roxo', 48, 42);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Blusas Placeat', 'Magnam labore laborum placeat. Eum doloribus quisquam assumenda dicta inventore.', 132.97, 'M', 'Marrom', 53, 2);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Shorts Vero', 'Reiciendis perspiciatis ex nihil eaque unde. Asperiores laudantium impedit quas repellendus quasi commodi.', 96.51, 'PP', 'Vermelho', 51, 83);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Saias Consectetur', 'Praesentium iusto quaerat fugit dolor sapiente. Ex necessitatibus tenetur cum. Maxime delectus similique.', 802.52, 'M', 'Rosa', 20, 24);
INSERT INTO produtos (nome, descricao, preco, tamanho, cor, id_categoria, id_fornecedor) VALUES ('Sapatos Facilis', 'Fuga ut sed nostrum.
Necessitatibus sunt beatae possimus autem. Alias doloremque enim odio harum.', 464.51, 'PP', 'Marrom', 37, 62);

INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Moreira 0', '12.836.907/0001-74', 'Rodovia Azevedo, 87, Dom Silverio, 84520-606 Fogaça da Praia / MG', 67, '+55 (031) 9750-0386', '2020-09-19');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Novaes 1', '05.741.269/0001-42', 'Alameda de da Luz, 4, Vila São João Batista, 88507-657 Pimenta dos Dourados / AC', 72, '11 9716 8826', '2023-01-05');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Martins de Cavalcante 2', '54.169.832/0001-65', 'Área Nunes, 82, Nova America, 38246123 Almeida Grande / SE', 48, '(021) 5838 6535', '2024-12-14');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cassiano do Amparo 3', '86.902.137/0001-57', 'Conjunto Lorenzo Nunes, Lagoa, 36925-515 Cunha / PB', 93, '0500 926 3013', '2014-04-22');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Câmara 4', '17.623.408/0001-12', 'Lago Luísa Aragão, 20, Vila Copacabana, 00507-802 Macedo Grande / TO', 15, '+55 (084) 8629-1373', '2013-03-03');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Costa do Oeste 5', '06.138.274/0001-28', 'Praça de Fonseca, 60, Vila Vista Alegre, 83841210 Aragão da Mata / BA', 75, '0800-749-5673', '2022-02-20');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Ribeiro Grande 6', '96.420.718/0001-06', 'Núcleo Isabela Melo, 49, Cidade Nova, 16148-457 Sá / PA', 71, '+55 (081) 8581 1461', '2014-08-26');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Borges 7', '25.368.047/0001-33', 'Setor Moreira, 596, Barão Homem De Melo 3ª Seção, 08026378 Sampaio do Norte / RR', 53, '+55 (021) 4084 7443', '2024-08-17');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Rocha das Pedras 8', '50.193.264/0001-87', 'Conjunto de Cirino, 755, Tres Marias, 51965-806 Correia / GO', 70, '+55 (061) 1536 3507', '2013-07-07');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Nogueira 9', '57.230.914/0001-66', 'Alameda Jesus, 86, Boa Vista, 20365548 Abreu da Mata / SC', 94, '+55 (011) 1753-8978', '2013-02-16');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Vasconcelos Alegre 10', '96.057.431/0001-63', 'Morro Pires, 13, São Bernardo, 30815101 Cunha dos Dourados / PI', 1, '+55 (041) 6744-2131', '2023-06-26');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cavalcante 11', '25.379.841/0001-82', 'Ladeira Pedro Lucas Souza, 50, Vila Das Oliveiras, 01765310 Dias de Ramos / RO', 78, '+55 71 0120-8407', '2017-03-11');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sampaio do Norte 12', '92.084.761/0001-97', 'Trecho Nicole Novais, Sion, 68188967 Martins de Oliveira / ES', 2, '81 8864-0305', '2019-03-09');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Carvalho 13', '81.496.753/0001-31', 'Distrito Azevedo, 3, Marçola, 78927136 Monteiro da Prata / AP', 37, '(061) 2686 4097', '2017-11-30');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Martins 14', '73.926.518/0001-24', 'Viaduto de Macedo, 81, Vila Petropolis, 04419-542 Sá de Araújo / MA', 36, '0300 135 2113', '2017-11-02');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cirino de Pires 15', '94.573.806/0001-12', 'Morro Luan Cassiano, 1, São João Batista, 10117-138 Carvalho / BA', 79, '(081) 6986-5513', '2020-06-26');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Mendonça Alegre 16', '79.830.645/0001-01', 'Largo Abreu, 52, São Jorge 3ª Seção, 51536-877 Farias da Mata / PR', 61, '+55 (011) 0521 0258', '2020-09-15');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Silva 17', '27.634.159/0001-14', 'Alameda Maria Viana, 91, Cruzeiro, 55711546 Machado / MA', 35, '+55 31 9510 4070', '2021-10-14');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Freitas 18', '78.243.951/0001-89', 'Esplanada de Mendonça, Santa Efigênia, 19234-979 Costela de Rezende / SC', 18, '(021) 3656-2126', '2025-12-26');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sá de Lopes 19', '62.738.541/0001-79', 'Rua Isabela Sousa, 27, Monsenhor Messias, 57255551 Pastor / PB', 30, '(061) 1974-1069', '2020-11-07');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial das Neves 20', '14.096.278/0001-19', 'Morro Sá, 80, Vila Da Paz, 60507-748 Ferreira / MA', 78, '(041) 5590-5540', '2019-03-02');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Leão do Norte 21', '43.596.807/0001-41', 'Jardim João Felipe Campos, Cidade Jardim, 21226049 da Cunha / AC', 44, '0500 945 0932', '2023-12-27');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Azevedo 22', '21.698.704/0001-50', 'Estação José Teixeira, 975, Primeiro De Maio, 16055-111 Dias Paulista / MS', 4, '+55 (084) 1658 7274', '2012-03-31');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cunha 23', '89.304.725/0001-87', 'Travessa Peixoto, 84, Sion, 40128-973 Montenegro / RS', 28, '+55 71 6083 5967', '2011-12-29');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Brito de Minas 24', '08.256.139/0001-02', 'Pátio Rezende, 59, João Pinheiro, 51927-580 Gomes de Goiás / RN', 87, '+55 11 2371-8357', '2014-09-15');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Costa dos Dourados 25', '54.089.126/0001-03', 'Campo de Casa Grande, 4, Jardim Guanabara, 20653-095 Oliveira das Pedras / PR', 16, '+55 61 8634 8271', '2014-04-20');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Teixeira dos Dourados 26', '23.164.890/0001-72', 'Largo Valentim da Cruz, 35, Mala E Cuia, 70350-083 Souza de Almeida / PA', 26, '11 7219 4333', '2023-01-05');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Monteiro 27', '45.130.278/0001-11', 'Ladeira Augusto da Rocha, Novo Santa Cecilia, 43658-043 da Rosa do Campo / GO', 12, '+55 71 8885 5294', '2021-07-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Mendes de Goiás 28', '38.426.791/0001-99', 'Praça de Albuquerque, 17, Funcionários, 60600-475 Borges dos Dourados / RR', 6, '+55 (081) 3062-5628', '2020-07-03');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Abreu dos Dourados 29', '31.069.427/0001-70', 'Setor Augusto Aparecida, Baleia, 15961-451 Farias de Mendes / RO', 24, '+55 (061) 0964-3755', '2012-06-12');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Lopes 30', '10.736.485/0001-30', 'Trevo de Machado, 9, Vila Bandeirantes, 57373675 Correia do Norte / MA', 54, '(041) 0066-8123', '2018-02-21');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Campos 31', '70.519.634/0001-30', 'Recanto Samuel Nascimento, 43, Bonsucesso, 84619-038 Monteiro / MS', 83, '(071) 9858 7031', '2023-03-27');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sá 32', '93.874.526/0001-81', 'Ladeira Daniela Mendonça, 31, São Salvador, 35332512 Ribeiro do Campo / DF', 49, '0800 411 6598', '2019-02-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cirino de Lima 33', '12.978.630/0001-14', 'Vale de Marques, 480, Coração Eucarístico, 06558-029 Duarte da Prata / PA', 35, '21 6645 2480', '2014-02-21');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Nogueira Alegre 34', '09.613.754/0001-91', 'Fazenda Caleb Alves, Barro Preto, 25053056 Oliveira Paulista / GO', 61, '+55 21 0826-1227', '2023-08-19');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Oliveira 35', '86.403.129/0001-66', 'Estação Fernandes, 74, Santa Branca, 98111583 Caldeira / RS', 2, '(021) 5070-5791', '2012-04-14');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Teixeira 36', '07.359.612/0001-14', 'Aeroporto de Rezende, 86, Funcionários, 81102-649 Abreu Paulista / RN', 44, '+55 11 0439 2298', '2019-01-27');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Mata 37', '83.546.912/0001-90', 'Largo Yasmin Costela, 350, Bacurau, 93355-944 Cunha de Aragão / ES', 90, '0800 303 9884', '2013-07-08');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Porto 38', '48.139.672/0001-09', 'Loteamento Silva, 78, Santa Isabel, 05273-505 Guerra Paulista / RJ', 7, '41 6024 9283', '2020-09-06');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Siqueira 39', '17.435.862/0001-40', 'Lago Breno Borges, 63, Vila Canto Do Sabiá, 10598-309 Martins de Costela / AL', 9, '84 4692 8087', '2020-01-03');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Martins 40', '79.402.365/0001-00', 'Morro Costela, 55, Ouro Preto, 56347-578 Almeida do Sul / PR', 47, '84 0483-4845', '2026-01-24');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sales 41', '32.690.451/0001-94', 'Viela de Nascimento, 9, Nazare, 46863-520 da Conceição Grande / SC', 80, '+55 (051) 5083-4498', '2018-06-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Mota da Praia 42', '98.437.021/0001-73', 'Ladeira de Dias, 176, Olaria, 20472-444 Cavalcanti do Sul / RS', 86, '+55 (061) 6229 4791', '2019-06-13');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Oliveira 43', '78.639.254/0001-41', 'Parque de Teixeira, 73, Santa Sofia, 47922-147 da Rosa / RO', 37, '+55 31 9043-9721', '2013-09-11');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Conceição 44', '26.709.514/0001-04', 'Loteamento de da Mata, 85, Funcionários, 49544592 Andrade Verde / RO', 25, '+55 (021) 5360 3660', '2014-02-20');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cardoso de Porto 45', '32.486.571/0001-74', 'Passarela de Barbosa, 83, União, 85175-126 Gomes / MG', 61, '+55 (051) 1868-0011', '2017-04-19');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Carvalho 46', '72.365.984/0001-15', 'Rua de Araújo, 52, Jardim América, 28156-431 Rios de Minas / PB', 37, '81 0121 1830', '2015-09-08');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Farias das Flores 47', '28.509.741/0001-11', 'Favela Lima, 80, Boa Esperança, 46125-693 Marques / SC', 23, '0500 035 4984', '2016-04-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Porto Verde 48', '69.578.231/0001-83', 'Vale Vasconcelos, 30, Diamante, 37937-993 Caldeira de Teixeira / MA', 77, '+55 (041) 4655-6223', '2016-03-09');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Vasconcelos 49', '39.680.524/0001-06', 'Fazenda da Costa, 8, Vila Real 2ª Seção, 25098453 Viana Alegre / PR', 6, '(031) 2068 2230', '2026-04-09');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Ferreira 50', '10.264.753/0001-68', 'Viaduto Melo, 38, Nova Gameleira, 47681175 Carvalho / RO', 32, '84 3414-0163', '2015-08-10');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cardoso do Norte 51', '68.295.731/0001-45', 'Passarela de Macedo, 34, União, 25312-395 Oliveira / PA', 92, '+55 31 8913-9487', '2023-05-14');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Fonseca da Serra 52', '29.715.643/0001-01', 'Rua de Cavalcanti, 7, Santa Branca, 05326388 Cardoso da Serra / RS', 41, '(041) 9399-3525', '2020-03-01');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Rezende 53', '03.168.497/0001-40', 'Vila Alice Sousa, 5, Lorena, 34657104 Correia / PA', 60, '(041) 1187-1454', '2022-08-31');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Silva dos Dourados 54', '18.496.073/0001-81', 'Vila de Pacheco, 42, Santa Lúcia, 88809-949 Vasconcelos da Praia / PR', 42, '61 0452-3646', '2013-04-28');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Albuquerque 55', '93.758.146/0001-81', 'Vereda Novais, 355, Vila Nova Dos Milionarios, 89827-409 Aparecida de Minas / AL', 2, '(021) 5391 4276', '2019-06-10');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Nascimento de da Costa 56', '74.296.150/0001-20', 'Parque Melina Ribeiro, Vila Nova Dos Milionarios, 08023-173 Sousa / PB', 46, '(011) 3865 8045', '2024-08-19');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cirino 57', '10.287.364/0001-58', 'Aeroporto Clara Machado, 65, Prado, 18236-079 Cirino / ES', 17, '+55 (031) 3244 8213', '2016-04-19');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Guerra da Prata 58', '80.543.912/0001-49', 'Favela Alícia Vargas, 43, Bairro Das Indústrias Ii, 51340658 Mendonça / BA', 50, '+55 81 6036-1278', '2022-11-17');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial das Neves Verde 59', '65.291.347/0001-86', 'Praça de Moraes, 19, Vila Nova Gameleira 1ª Seção, 23547117 Vasconcelos / AM', 61, '41 4330 1795', '2015-03-12');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Alves de Fogaça 60', '49.057.286/0001-30', 'Sítio de da Cruz, 7, Lourdes, 53136-343 Sá / AM', 89, '+55 71 7172-9418', '2021-06-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cirino 61', '52.948.370/0001-59', 'Campo de das Neves, 94, Guarani, 24028330 Moura do Sul / PA', 26, '41 5119-1333', '2019-02-17');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sampaio 62', '12.387.046/0001-94', 'Esplanada Fogaça, 30, Sport Club, 45237311 Machado de Silva / RJ', 40, '0300-740-3099', '2025-02-25');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Paz das Pedras 63', '01.792.436/0001-23', 'Recanto Renan da Conceição, 56, Cachoeirinha, 71208497 Rezende dos Dourados / RN', 67, '11 2663 7029', '2012-06-09');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Almeida da Prata 64', '87.124.063/0001-38', 'Esplanada de Pacheco, 95, Bacurau, 73117214 Caldeira Grande / BA', 45, '+55 (011) 0385 8894', '2019-06-18');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Rocha das Flores 65', '29.408.576/0001-74', 'Pátio de Pimenta, 15, Jardim Montanhês, 25138024 da Mota de Martins / AM', 2, '+55 (051) 8402-4874', '2015-05-27');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Câmara do Amparo 66', '90.528.637/0001-48', 'Núcleo Rodrigues, 460, Vila Nova Cachoeirinha 1ª Seção, 81773-913 Aragão de Borges / RJ', 74, '81 4275-7408', '2021-06-06');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Macedo 67', '13.480.572/0001-67', 'Setor Rafaela Duarte, 9, Esperança, 14528-486 Cunha do Galho / BA', 21, '+55 (031) 8716-5840', '2017-04-23');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial da Cruz 68', '58.137.906/0001-32', 'Fazenda Luiz Henrique Silveira, 91, Guarani, 99495934 Cavalcanti do Campo / MG', 12, '0900-061-9549', '2022-07-15');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Albuquerque Grande 69', '98.746.205/0001-15', 'Campo Lopes, 7, Antonio Ribeiro De Abreu 1ª Seção, 28509684 Lima do Campo / PB', 61, '(051) 5773-8463', '2022-10-08');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Correia do Norte 70', '28.693.175/0001-40', 'Vereda Fogaça, 46, Cônego Pinheiro 2ª Seção, 60320679 Rocha / CE', 22, '0500 768 5258', '2015-12-01');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Pimenta 71', '42.891.305/0001-80', 'Vila Alves, Vila São João Batista, 76298-299 Fonseca de Ferreira / GO', 96, '+55 (061) 1952 4419', '2013-04-27');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Vasconcelos da Serra 72', '30.897.462/0001-14', 'Avenida de Sá, 594, Biquinhas, 61383481 Peixoto / RJ', 9, '31 9483-7838', '2019-01-01');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Costela 73', '28.641.397/0001-10', 'Núcleo de Cunha, 65, Goiania, 10930087 Pires do Sul / SP', 53, '0800 565 5751', '2020-07-28');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Novais do Galho 74', '45.176.208/0001-02', 'Chácara Rafaela Silva, 53, Vila Nova, 84259-757 Novais / PA', 79, '+55 (021) 7811 6927', '2014-07-18');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Mendonça de Minas 75', '91.407.256/0001-73', 'Aeroporto Luísa Sales, 2, Concórdia, 62991392 Silveira / AL', 98, '+55 (081) 7845-2250', '2013-05-04');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Pereira da Mata 76', '60.913.825/0001-29', 'Recanto de Carvalho, Mariquinhas, 85335-722 Moraes das Flores / AL', 79, '(084) 2927 8609', '2026-05-17');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Marques Grande 77', '94.573.086/0001-95', 'Conjunto Pedro Miguel Cunha, 45, Horto, 94627-442 Brito de Camargo / SP', 16, '+55 (084) 1028 8635', '2014-11-05');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Jesus da Mata 78', '35.610.798/0001-78', 'Conjunto de Cassiano, 8, Calafate, 45581364 Casa Grande / DF', 13, '+55 11 0921 9716', '2017-11-02');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Aragão do Galho 79', '78.205.416/0001-33', 'Lago Vinícius Costa, 18, Santa Tereza, 96349225 Correia / DF', 74, '31 7623-8366', '2019-10-14');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Ferreira da Mata 80', '13.982.704/0001-59', 'Colônia Eduarda da Rosa, 411, Nova Suíça, 85497-790 Almeida Grande / PB', 53, '(021) 9812-0120', '2017-07-10');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Silva 81', '18.042.973/0001-59', 'Vereda Fernanda Castro, 6, Marieta 2ª Seção, 17764797 Vieira de Silva / MA', 68, '61 5619-8008', '2014-12-16');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Gomes dos Dourados 82', '78.149.256/0001-52', 'Vila Aragão, 5, Antonio Ribeiro De Abreu 1ª Seção, 99356462 Azevedo / TO', 21, '71 0568-0199', '2019-12-08');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Nascimento 83', '38.647.192/0001-03', 'Pátio Sophia Garcia, 8, Fazendinha, 75237846 da Rosa / CE', 48, '(061) 3678 8496', '2012-02-24');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Farias de Vasconcelos 84', '63.958.241/0001-68', 'Rua Pastor, 6, Santa Rita, 60487536 Pereira da Serra / PR', 10, '0500 426 2742', '2023-10-23');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Pires de Monteiro 85', '41.830.269/0001-82', 'Avenida de Aragão, 41, Vila Santa Monica 1ª Seção, 27481-706 Caldeira do Oeste / BA', 9, '+55 41 5485-4590', '2013-08-09');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Leão de Minas 86', '70.421.985/0001-04', 'Praça de Brito, 49, Nossa Senhora Da Aparecida, 85987-024 Gonçalves da Serra / DF', 90, '(031) 2176 1203', '2014-01-31');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Rios do Campo 87', '57.931.082/0001-05', 'Chácara Maria Liz Vasconcelos, 92, Aparecida, 74538-347 Albuquerque de Borges / SE', 18, '21 0044 1252', '2023-09-11');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Cavalcanti 88', '67.401.892/0001-03', 'Chácara de Novais, 18, Vila Madre Gertrudes 4ª Seção, 32481423 da Rosa / PI', 63, '+55 (051) 5590-4319', '2026-02-24');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Peixoto Paulista 89', '58.207.493/0001-15', 'Conjunto da Rosa, 95, Engenho Nogueira, 64348248 Araújo Paulista / MT', 74, '+55 (041) 7406 7693', '2026-05-15');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Pereira das Pedras 90', '87.639.450/0001-07', 'Quadra Santos, 15, Jardim Do Vale, 84345583 Azevedo Paulista / MT', 62, '+55 (031) 4693 1547', '2016-11-08');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Mendes de Minas 91', '76.841.503/0001-51', 'Ladeira de Souza, 93, Alta Tensão 2ª Seção, 16920051 Mendonça / SC', 13, '+55 (081) 3361 3532', '2011-06-12');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Porto 92', '81.374.605/0001-44', 'Campo de Sales, 14, Palmeiras, 32506296 Albuquerque / SP', 26, '+55 (051) 4694 8101', '2015-02-23');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Leão Alegre 93', '18.403.927/0001-38', 'Lagoa Rezende, Vila Madre Gertrudes 1ª Seção, 27096-546 Vieira / MA', 55, '+55 (061) 5402-1169', '2020-08-17');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Sá de Alves 94', '62.078.134/0001-82', 'Colônia Silva, Saudade, 52634594 Duarte / MA', 92, '+55 81 9222-8870', '2025-06-06');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Santos 95', '40.361.759/0001-14', 'Fazenda de Duarte, 75, Havaí, 49520844 Castro / RS', 25, '+55 21 6471-0744', '2018-03-13');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Gonçalves do Sul 96', '61.498.327/0001-20', 'Parque Ribeiro, 33, Vila Da Luz, 16621205 da Luz / MA', 69, '+55 (051) 3227 1507', '2015-03-07');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Borges 97', '49.267.805/0001-95', 'Ladeira Evelyn Martins, 86, Barroca, 79801-695 Farias / RR', 44, '21 3642 2701', '2023-01-01');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Garcia 98', '18.059.726/0001-65', 'Pátio Isabel Andrade, 65, Boa Vista, 67525795 Câmara / MS', 64, '+55 21 1624-9278', '2014-01-12');
INSERT INTO filiais (nome, cnpj, endereco, id_cidade, telefone, data_abertura) VALUES ('Filial Silveira 99', '40.125.673/0001-92', 'Feira Campos, Universitário, 77169-323 Novaes / MT', 76, '+55 (041) 0858 6876', '2022-05-19');

INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Enzo Sales', '203.478.691-22', 'domgarcia@example.com', '+55 (041) 4303 4775', '2025-06-08', 46, 41);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Clara Nascimento', '270.164.839-40', 'sarah02@example.net', '(051) 8541 4710', '2017-06-02', 24, 46);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luigi Abreu', '679.345.218-55', 'emanuel11@example.org', '(011) 0619-5344', '2017-06-09', 53, 44);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luiz Felipe Silva', '354.690.721-34', 'muriloduarte@example.net', '+55 84 9783-2094', '2019-07-27', 86, 47);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Eduardo Aragão', '193.785.204-05', 'elisa76@example.net', '71 7493-2396', '2020-07-02', 71, 91);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Mateus Correia', '561.307.892-03', 'erodrigues@example.org', '(061) 3815-8483', '2020-01-12', 6, 40);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Liam Marques', '574.631.029-80', 'asafepacheco@example.net', '+55 31 9302-1338', '2018-08-23', 41, 76);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Dr. Josué Macedo', '489.120.563-60', 'catarinacastro@example.net', '+55 61 0713 3096', '2021-04-15', 31, 22);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Heitor Sales', '379.204.865-56', 'bento27@example.net', '41 0562-6885', '2023-10-14', 88, 37);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Kamilly Alves', '924.378.651-28', 'emachado@example.com', '(084) 5399 0677', '2025-12-07', 62, 51);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Bento Cunha', '907.854.162-85', 'sophie82@example.org', '81 7297 4779', '2020-03-12', 11, 48);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Felipe Teixeira', '704.152.396-99', 'raul30@example.org', '(041) 3627 2472', '2024-09-24', 79, 72);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Stephany Dias', '625.047.831-08', 'josuebarbosa@example.net', '84 4400 4496', '2018-06-25', 38, 72);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luara Cavalcanti', '362.479.018-87', 'maria-alicemoreira@example.com', '51 8420 4866', '2023-04-12', 61, 98);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Augusto Nunes', '307.598.142-79', 'natalia85@example.net', '(051) 0778 7299', '2025-01-09', 60, 47);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maria Fernanda Vargas', '031.456.827-17', 'paulopereira@example.org', '61 2472 7468', '2020-12-20', 94, 21);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ágatha Correia', '649.108.573-20', 'ioliveira@example.com', '0800 775 3157', '2016-09-17', 32, 66);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Kamilly da Cunha', '170.945.836-48', 'carvalhocecilia@example.com', '+55 61 4711 6510', '2023-05-17', 33, 26);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luara Novais', '126.538.497-55', 'mcamara@example.net', '(011) 3308-6438', '2021-01-12', 52, 27);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Pedro Araújo', '581.634.297-55', 'joao-pedro78@example.com', '(051) 8195 0726', '2023-11-09', 30, 44);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maria Alice Sá', '105.382.769-59', 'raquelfreitas@example.com', '(051) 4458 5913', '2017-10-04', 11, 19);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Júlia Rezende', '643.108.972-31', 'xteixeira@example.org', '31 1277-6141', '2020-12-25', 12, 45);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Gabriel Correia', '368.974.512-82', 'enzo24@example.net', '+55 (061) 1546-5184', '2024-08-10', 60, 41);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Isadora Macedo', '321.569.748-37', 'rezendeluisa@example.com', '31 0359-0685', '2024-12-19', 97, 49);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sr. José Miguel da Paz', '034.761.589-93', 'joao-guilherme98@example.org', '+55 71 1880-2150', '2016-07-15', 32, 59);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('João Vitor Abreu', '469.017.382-69', 'davi64@example.com', '(071) 8182 6231', '2025-06-01', 5, 44);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Olívia Câmara', '930.485.216-15', 'fernanda17@example.com', '(011) 1151-6879', '2022-04-08', 78, 21);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maria Helena Lima', '924.680.753-74', 'gabriel10@example.net', '+55 31 5923-6179', '2023-05-03', 37, 100);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Lorenzo Viana', '932.067.481-78', 'lucas-gabrielpimenta@example.com', '51 3821 9733', '2023-05-23', 65, 90);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luana Viana', '513.298.076-77', 'nascimentosabrina@example.org', '+55 51 9444 7313', '2023-05-28', 79, 38);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Heloísa Cunha', '094.738.615-75', 'arthur-gabrielsa@example.com', '31 1353 6747', '2025-12-02', 29, 71);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ana Lívia Sales', '971.546.823-37', 'oliviaborges@example.org', '0900 635 7664', '2017-04-18', 85, 24);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maysa Fogaça', '754.806.132-35', 'fogacaemanuelly@example.com', '+55 (021) 2406 9177', '2019-03-26', 64, 53);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sr. Pedro Marques', '530.217.964-43', 'luigi87@example.com', '+55 (021) 4227-5424', '2019-06-05', 89, 82);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Dr. Gustavo Henrique Araújo', '043.691.587-10', 'naparecida@example.org', '81 6366-6246', '2019-01-13', 69, 1);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Theodoro Moura', '512.097.483-04', 'zmontenegro@example.org', '+55 (021) 5128 9464', '2017-07-13', 1, 46);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Diogo Pimenta', '026.754.913-06', 'ravi-luccamendonca@example.org', '31 4251-8277', '2025-09-27', 98, 25);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Dr. Theo Oliveira', '293.576.084-00', 'castroluiz-gustavo@example.com', '0300 797 2752', '2020-11-30', 38, 78);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Eloah Carvalho', '710.586.392-77', 'luiz-fernando14@example.net', '61 2240 7213', '2016-07-26', 84, 100);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Isabelly Ramos', '836.974.120-78', 'da-matavalentim@example.com', '+55 (021) 2596 7661', '2016-09-28', 28, 15);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Daniel Peixoto', '486.715.032-08', 'lda-luz@example.net', '+55 71 6969 6730', '2019-04-01', 21, 91);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Matheus Sampaio', '075.498.621-76', 'diasnoah@example.net', '84 2122 5632', '2025-12-21', 14, 98);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maria Liz Monteiro', '201.867.934-13', 'oliversantos@example.org', '+55 (041) 5446-1259', '2023-03-30', 58, 39);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ayla Cirino', '936.218.540-70', 'julianaguerra@example.net', '+55 (041) 8000 9481', '2023-01-01', 45, 34);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Emanuelly Aragão', '743.256.190-70', 'kmoura@example.org', '+55 81 4931 8453', '2024-02-03', 13, 15);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sr. Rael Campos', '075.312.496-34', 'qmonteiro@example.net', '(061) 1870-5067', '2019-07-18', 6, 25);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Rael Silva', '758.216.493-82', 'helena92@example.net', '71 4440-6315', '2020-08-08', 47, 53);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Yuri da Rocha', '207.916.543-70', 'dbarros@example.com', '71 5982 4141', '2018-06-15', 99, 34);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Yago Almeida', '179.364.582-55', 'jgomes@example.org', '84 1174 5354', '2018-04-17', 95, 75);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Marcelo Cirino', '307.152.896-59', 'vasconcelosleo@example.org', '+55 (031) 2316 9489', '2016-06-11', 36, 50);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sra. Evelyn Pastor', '960.752.481-02', 'davi-luiz66@example.net', '51 0578 7048', '2021-01-03', 84, 91);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Giovanna Albuquerque', '564.782.310-62', 'pereiraleo@example.net', '21 8540 5308', '2018-05-16', 40, 51);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Rafael Gonçalves', '918.465.273-09', 'isadoracamargo@example.net', '+55 84 8573-4516', '2022-07-01', 96, 57);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Renan Fernandes', '395.862.704-83', 'maria-fernanda30@example.org', '0800 863 9625', '2024-11-16', 75, 41);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Alexandre Mendes', '503.468.219-24', 'davi97@example.org', '(071) 1970 9233', '2025-01-12', 29, 13);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Cauã Cardoso', '945.260.317-80', 'arthurda-paz@example.net', '+55 11 9020-3245', '2016-07-20', 73, 29);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Eduarda da Conceição', '813.054.629-98', 'juanmoura@example.net', '+55 61 1685 0483', '2021-01-22', 43, 13);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Camila da Costa', '905.468.371-66', 'agatha22@example.org', '(061) 2435-9315', '2018-08-31', 59, 48);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ana Beatriz Aparecida', '056.914.837-57', 'dgarcia@example.org', '51 9769 9352', '2024-09-19', 82, 61);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Natália Nogueira', '508.624.931-70', 'eloahsilva@example.org', '+55 41 0392-4927', '2020-02-06', 78, 92);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sr. Enzo Gabriel Costela', '931.824.605-60', 'teixeiramaria-julia@example.org', '0500-662-8519', '2023-04-03', 20, 30);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Lavínia Sousa', '439.081.267-03', 'lorenafogaca@example.com', '+55 84 4433-0398', '2021-12-15', 38, 83);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ryan Moura', '039.261.857-59', 'fariasluiz-fernando@example.com', '(051) 2136-2665', '2024-10-07', 90, 58);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Beatriz Campos', '810.673.245-26', 'da-rosaisaque@example.org', '+55 61 0432 3772', '2016-06-20', 59, 7);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Josué Correia', '720.914.356-43', 'andradebryan@example.com', '+55 71 6358-2735', '2022-08-30', 54, 99);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Noah Costela', '483.790.162-03', 'sarafreitas@example.net', '41 0095 5816', '2023-11-01', 21, 36);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Srta. Cecilia Abreu', '526.413.987-37', 'duarteisabel@example.net', '+55 (081) 0728 4894', '2023-12-27', 67, 11);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Caroline Cassiano', '913.872.460-03', 'caldeiraisabelly@example.net', '+55 71 5776-2214', '2025-09-27', 44, 30);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Davi Lucas Vieira', '162.740.953-06', 'smoreira@example.com', '+55 41 1317-8174', '2022-09-13', 44, 2);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Júlia Carvalho', '853.962.014-60', 'carolinepacheco@example.com', '(051) 3167-7200', '2017-02-10', 69, 46);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Gabrielly Lima', '164.932.785-46', 'das-nevesrodrigo@example.net', '+55 81 2428-5564', '2021-06-13', 46, 23);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sr. Asafe Duarte', '628.374.590-38', 'maria-flor91@example.net', '71 4632 0739', '2020-08-19', 84, 38);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Isadora Lima', '162.547.390-70', 'araujomaria-flor@example.net', '+55 (031) 3391 2394', '2025-01-22', 9, 33);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Bianca Abreu', '741.805.936-10', 'kda-costa@example.org', '+55 51 1711 0506', '2020-12-23', 61, 43);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luan Camargo', '601.859.723-30', 'lopesmirella@example.org', '+55 (051) 2507-3887', '2021-07-05', 10, 2);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Jade da Rosa', '418.750.936-48', 'ida-mota@example.org', '(011) 4482-3155', '2023-06-29', 34, 72);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Lucas Gabriel Carvalho', '275.364.109-99', 'msantos@example.com', '81 5442 0253', '2017-11-07', 43, 56);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Yasmin Fernandes', '573.189.604-66', 'miguel01@example.com', '+55 (084) 3067 0540', '2024-06-11', 28, 7);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luan Marques', '370.218.946-78', 'levi98@example.net', '0500-077-9732', '2024-07-04', 54, 21);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Benício da Rosa', '651.793.284-46', 'arthur-miguel08@example.org', '(051) 1337-0396', '2022-04-04', 83, 94);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Antonella Montenegro', '408.913.657-10', 'cguerra@example.org', '81 6504-3581', '2020-12-06', 24, 43);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Gustavo Barros', '564.729.801-01', 'sarahfreitas@example.com', '(084) 9382-7746', '2021-07-27', 76, 75);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Srta. Julia da Mata', '657.394.812-28', 'fariasguilherme@example.org', '31 1515-1182', '2022-03-25', 67, 71);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Matteo Pires', '706.198.352-30', 'siqueiramilena@example.org', '+55 (021) 3512-2267', '2023-01-22', 89, 47);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Noah Ramos', '461.587.903-20', 'da-rosaenrico@example.net', '11 5972 4468', '2023-06-07', 61, 60);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Luigi da Mata', '479.850.126-30', 'hadassafernandes@example.org', '0900 372 4579', '2024-02-14', 73, 28);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Dr. Bryan Gonçalves', '879.521.463-19', 'brunoviana@example.net', '+55 (021) 2488 5621', '2025-03-03', 48, 40);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Vinícius Pinto', '562.098.174-67', 'anovaes@example.org', '+55 (021) 4863 9321', '2024-08-11', 31, 58);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Maria Clara Araújo', '914.857.063-00', 'ana-sophia31@example.net', '(081) 2417 6261', '2024-10-10', 72, 23);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Isis Castro', '380.512.469-42', 'saleskaique@example.net', '(061) 1296-6823', '2022-09-03', 84, 5);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Alexia das Neves', '065.238.749-74', 'nicolas80@example.com', '+55 (081) 7339 9944', '2025-09-10', 54, 50);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Melina Costela', '149.286.570-20', 'emanuella88@example.net', '+55 51 9511 2530', '2021-03-02', 94, 34);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Isabelly Moraes', '809.463.172-40', 'antonioalmeida@example.net', '51 5467 7733', '2025-11-05', 6, 90);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Vinícius Siqueira', '719.650.842-49', 'fmartins@example.com', '(021) 1551-9324', '2020-01-27', 25, 30);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Rafaela Vieira', '741.529.603-61', 'pmachado@example.net', '(081) 1946-3613', '2019-12-20', 70, 24);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Allana Garcia', '195.342.068-06', 'isisandrade@example.com', '(084) 6473-5120', '2018-08-24', 3, 20);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Sophie Santos', '705.369.124-16', 'cmacedo@example.net', '(041) 6292 3128', '2025-10-16', 92, 85);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Srta. Cecília Pereira', '078.641.539-84', 'novaisjuliana@example.net', '(021) 7833 1439', '2017-09-21', 6, 74);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('José Rodrigues', '420.569.387-74', 'fariasmiguel@example.com', '+55 (021) 2262-0620', '2019-05-18', 12, 24);
INSERT INTO funcionarios (nome, cpf, email, telefone, data_contratacao, id_cargo, id_filial) VALUES ('Ana Cecília Nunes', '287.046.139-96', 'zrocha@example.net', '+55 84 9544-8215', '2017-03-25', 37, 57);

INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (56, 28, 247);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (22, 57, 475);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (8, 50, 403);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (94, 44, 448);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (45, 16, 91);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (65, 19, 281);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (8, 76, 372);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (27, 34, 359);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (70, 7, 136);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (32, 39, 209);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (31, 54, 304);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (36, 84, 359);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (8, 34, 404);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (82, 42, 468);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (50, 84, 291);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (3, 44, 22);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (63, 13, 268);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (68, 10, 428);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (10, 83, 7);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (26, 34, 335);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (86, 43, 159);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (91, 56, 158);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (21, 8, 237);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (51, 84, 247);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (29, 99, 364);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (87, 27, 85);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (7, 79, 353);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (66, 31, 422);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (39, 22, 417);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (39, 97, 491);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (49, 96, 379);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (80, 95, 459);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (80, 38, 6);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (78, 22, 146);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (50, 30, 498);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (20, 81, 445);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (73, 34, 245);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (39, 92, 315);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (4, 14, 78);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (15, 39, 59);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (54, 76, 398);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (53, 86, 114);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (53, 49, 192);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (93, 43, 294);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (65, 71, 262);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (90, 52, 215);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (11, 72, 487);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (62, 10, 3);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (73, 63, 322);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (55, 88, 493);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (32, 23, 257);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (58, 12, 170);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (12, 52, 284);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (48, 58, 129);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (23, 89, 453);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (6, 43, 364);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (88, 90, 271);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (94, 7, 267);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (66, 20, 193);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (74, 23, 402);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (80, 17, 414);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (91, 14, 97);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (43, 75, 423);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (77, 91, 426);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (65, 61, 257);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (29, 35, 321);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (84, 92, 43);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (36, 16, 108);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (48, 38, 228);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (72, 62, 174);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (1, 53, 170);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (11, 18, 391);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (81, 23, 495);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (88, 81, 187);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (50, 53, 276);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (5, 45, 43);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (31, 99, 57);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (14, 11, 164);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (72, 27, 200);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (18, 11, 61);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (74, 33, 352);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (70, 37, 125);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (77, 28, 373);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (7, 71, 260);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (23, 99, 25);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (46, 41, 420);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (67, 18, 455);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (89, 41, 398);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (90, 16, 259);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (7, 76, 447);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (90, 4, 219);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (2, 37, 227);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (38, 79, 433);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (53, 16, 62);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (74, 89, 72);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (98, 43, 219);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (42, 91, 190);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (12, 95, 296);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (36, 42, 465);
INSERT IGNORE INTO estoque (id_filial, id_produto, quantidade) VALUES (84, 56, 234);

INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-30 23:21:35', 32, 30, 6, 2564.74);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-03-12 05:37:55', 43, 89, 13, 4917.43);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-09-19 11:40:13', 65, 19, 83, 2669.83);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-03-03 15:43:16', 71, 72, 4, 4491.12);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-05 21:45:38', 55, 69, 23, 3816.47);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-15 10:38:30', 11, 57, 95, 2138.08);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-11-04 01:16:05', 46, 18, 32, 105.82);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-03-30 15:54:13', 81, 28, 67, 3090.11);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-11-16 21:00:50', 20, 24, 59, 2035.26);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-10 02:51:16', 5, 61, 89, 2200.37);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-09-08 22:52:11', 53, 100, 95, 2247.69);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-10-21 23:43:54', 20, 45, 36, 1240.71);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-06 11:23:26', 51, 8, 61, 2696.84);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-06-30 20:24:42', 4, 31, 17, 1253.19);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-02-05 14:47:26', 23, 32, 19, 2804.66);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-01-08 01:47:03', 70, 1, 99, 2284.8);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-03-19 00:08:06', 48, 39, 78, 3931.49);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-28 09:59:17', 58, 55, 18, 3921.06);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-09-10 23:50:20', 77, 53, 26, 4702.11);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-10 14:57:57', 82, 65, 77, 4695.69);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-06 23:40:30', 76, 33, 53, 2310.96);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-07 17:19:19', 57, 83, 46, 2137.62);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-19 21:59:42', 60, 9, 18, 3723.25);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-03-30 09:28:50', 14, 77, 64, 2608.51);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-03-04 16:52:56', 69, 55, 9, 596.71);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-01-06 03:05:29', 83, 43, 7, 1495.11);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-04 20:11:26', 66, 54, 55, 4633.19);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-10-08 16:50:00', 37, 38, 44, 3027.08);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-20 14:16:32', 51, 33, 35, 911.3);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-01-22 02:47:50', 29, 50, 92, 3245.25);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-16 11:07:56', 11, 68, 38, 4304.05);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-05-09 14:24:50', 4, 91, 17, 2692.01);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-02-24 21:56:46', 44, 63, 92, 2611.79);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-05-06 07:12:27', 5, 26, 38, 3348.56);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-11 09:38:24', 86, 95, 52, 3261.12);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-10 03:40:51', 2, 43, 17, 1661.9);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-08-30 18:38:44', 25, 68, 84, 1898.65);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-29 17:08:27', 59, 64, 16, 4014.58);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-23 10:27:54', 40, 78, 39, 3577.59);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-05-19 15:22:33', 74, 3, 9, 2200.24);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-01-22 22:53:39', 38, 9, 81, 1791.24);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-11-18 18:09:40', 9, 74, 50, 3550.87);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-06-15 19:07:35', 91, 24, 96, 3464.45);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-31 21:03:28', 33, 24, 33, 2106.9);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-19 22:48:51', 45, 20, 82, 1600.81);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-10-10 18:13:00', 72, 81, 77, 190.64);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-05-13 17:39:33', 13, 15, 43, 1226.84);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-06-23 10:05:26', 64, 11, 72, 3329.53);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-05-18 14:54:36', 62, 35, 27, 1767.44);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-06-13 21:01:10', 29, 18, 81, 1492.7);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-11-25 04:15:31', 89, 87, 33, 2736.58);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-06-23 10:12:00', 72, 81, 42, 2283.52);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-11-21 12:16:50', 52, 100, 15, 1193.22);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-10-30 18:15:28', 92, 84, 91, 611.87);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-09-24 22:18:28', 7, 6, 95, 1182.46);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-09-28 21:09:52', 99, 84, 5, 627.46);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-02-08 15:28:05', 47, 33, 85, 390.97);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-04-12 01:33:42', 77, 40, 26, 3014.71);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-05-17 05:11:19', 53, 40, 22, 674.24);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-08 13:20:27', 86, 19, 2, 3337.35);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-08 11:46:14', 58, 11, 92, 2877.37);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-06-30 17:08:46', 35, 15, 42, 487.87);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-07-13 08:25:33', 61, 72, 71, 448.15);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-09-24 02:53:16', 75, 51, 98, 4863.22);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-04-08 12:21:58', 72, 32, 45, 2643.46);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-10-05 05:50:16', 15, 95, 39, 4490.87);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-11-20 09:12:50', 61, 12, 63, 1519.13);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-10 20:57:29', 92, 88, 34, 4470.09);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-12-24 23:08:37', 38, 81, 51, 1024.54);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-03-09 16:36:30', 90, 39, 99, 1798.77);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-08-07 09:13:47', 68, 7, 68, 559.87);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-15 08:45:58', 16, 49, 5, 2642.52);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-08-15 03:29:09', 42, 82, 45, 738.93);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-08-29 14:44:31', 81, 82, 42, 3799.7);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-11-26 05:49:29', 8, 40, 34, 3665.07);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-03-07 09:54:41', 9, 50, 87, 836.58);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-09-15 01:37:46', 88, 46, 55, 2517.72);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-31 19:35:17', 10, 13, 46, 265.32);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-13 15:25:46', 24, 77, 26, 1223.55);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-10-21 13:26:30', 70, 97, 99, 354.61);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-10-05 04:38:34', 68, 2, 30, 4352.42);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-07-08 11:39:34', 66, 37, 13, 1348.72);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-09-29 21:48:56', 79, 38, 95, 2761.33);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-07-19 07:04:49', 67, 93, 84, 2445.3);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-11-15 20:14:30', 94, 46, 3, 861.37);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-08-30 10:15:20', 68, 90, 41, 3478.08);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-02-16 03:22:21', 51, 71, 4, 2176.42);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-01-31 20:42:59', 62, 10, 51, 1823.47);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-07-22 02:49:22', 64, 96, 11, 2785.08);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-11-02 23:46:58', 7, 79, 29, 3995.07);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-07-28 20:50:58', 89, 47, 47, 2192.22);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-08-05 00:47:50', 99, 51, 39, 1196.03);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-02-07 21:10:00', 49, 76, 86, 2139.68);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-06-13 14:01:45', 100, 86, 100, 4856.29);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2026-01-01 20:00:13', 94, 86, 33, 1563.51);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-09-29 02:28:22', 18, 54, 87, 4249.09);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-12-18 16:15:59', 34, 49, 78, 4909.11);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-05-23 11:10:47', 73, 32, 39, 3883.12);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2025-11-24 22:52:58', 30, 76, 13, 4853.58);
INSERT INTO vendas (data_venda, id_cliente, id_funcionario, id_filial, valor_total) VALUES ('2024-07-16 17:03:32', 10, 73, 42, 2352.28);

INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (87, 62, 5, 55.93, 279.65);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (22, 56, 7, 648.69, 4540.83);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (25, 77, 9, 371.09, 3339.81);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (45, 87, 10, 396.49, 3964.9);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (25, 43, 10, 400.85, 4008.5);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (74, 78, 7, 224.97, 1574.79);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (8, 6, 8, 538.62, 4308.96);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (75, 54, 10, 26.86, 268.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (81, 94, 8, 530.58, 4244.64);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (81, 73, 3, 44.22, 132.66);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (80, 20, 6, 738.55, 4431.3);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (31, 62, 3, 187.8, 563.4);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (77, 73, 2, 513.99, 1027.98);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (39, 94, 3, 693.37, 2080.11);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (59, 98, 1, 516.19, 516.19);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (59, 31, 3, 697.02, 2091.06);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (67, 26, 1, 586.92, 586.92);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (54, 1, 10, 438.36, 4383.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (3, 45, 3, 748.46, 2245.38);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (30, 49, 2, 234.65, 469.3);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (33, 32, 5, 889.48, 4447.4);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (28, 36, 1, 441.94, 441.94);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (63, 3, 4, 350.96, 1403.84);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (39, 16, 3, 561.83, 1685.49);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (26, 57, 5, 111.65, 558.25);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (18, 37, 4, 415.22, 1660.88);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (47, 70, 3, 618.03, 1854.09);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (64, 2, 2, 538.55, 1077.1);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (2, 96, 7, 586.96, 4108.72);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (55, 50, 2, 483.21, 966.42);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (36, 77, 2, 384.38, 768.76);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (24, 65, 8, 185.39, 1483.12);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (24, 43, 3, 542.12, 1626.36);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (79, 23, 6, 833.08, 4998.48);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (9, 98, 3, 796.34, 2389.02);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (43, 68, 3, 680.72, 2042.16);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (1, 4, 10, 213.48, 2134.8);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (96, 3, 8, 151.66, 1213.28);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (51, 6, 4, 495.93, 1983.72);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (47, 19, 3, 661.58, 1984.74);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (31, 31, 2, 766.36, 1532.72);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (50, 14, 1, 799.98, 799.98);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (67, 38, 10, 643.07, 6430.7);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (70, 44, 5, 303.28, 1516.4);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (82, 44, 10, 348.2, 3482.0);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (51, 91, 6, 427.84, 2567.04);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (56, 70, 7, 773.39, 5413.73);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (42, 60, 4, 62.42, 249.68);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (95, 35, 5, 96.63, 483.15);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (100, 23, 10, 211.92, 2119.2);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (30, 21, 5, 696.16, 3480.8);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (20, 37, 5, 511.22, 2556.1);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (85, 72, 6, 665.87, 3995.22);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (21, 25, 5, 136.63, 683.15);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (6, 16, 7, 145.3, 1017.1);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (6, 19, 10, 451.78, 4517.8);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (41, 76, 5, 39.94, 199.7);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (38, 30, 9, 183.68, 1653.12);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (98, 65, 4, 57.85, 231.4);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (13, 9, 7, 863.64, 6045.48);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (53, 69, 1, 63.86, 63.86);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (77, 59, 3, 814.87, 2444.61);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (35, 12, 3, 616.33, 1848.99);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (78, 62, 6, 629.32, 3775.92);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (71, 30, 10, 461.49, 4614.9);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (51, 99, 8, 546.21, 4369.68);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (74, 28, 8, 334.52, 2676.16);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (91, 46, 1, 349.12, 349.12);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (72, 86, 5, 27.78, 138.9);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (68, 2, 10, 79.44, 794.4);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (18, 28, 7, 781.22, 5468.54);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (8, 66, 4, 896.76, 3587.04);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (74, 83, 3, 475.2, 1425.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (31, 14, 7, 201.13, 1407.91);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (16, 11, 7, 674.01, 4718.07);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (34, 66, 8, 308.52, 2468.16);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (59, 36, 4, 645.4, 2581.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (60, 44, 7, 739.87, 5179.09);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (4, 15, 10, 715.91, 7159.1);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (1, 57, 1, 845.42, 845.42);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (25, 38, 4, 181.17, 724.68);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (42, 45, 2, 585.1, 1170.2);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (81, 96, 10, 55.28, 552.8);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (42, 80, 10, 857.28, 8572.8);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (37, 66, 1, 59.53, 59.53);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (35, 17, 6, 99.23, 595.38);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (34, 79, 9, 664.77, 5982.93);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (27, 55, 10, 452.2, 4522.0);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (20, 33, 3, 427.79, 1283.37);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (88, 47, 6, 670.42, 4022.52);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (99, 81, 1, 362.66, 362.66);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (41, 32, 2, 313.38, 626.76);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (23, 66, 6, 687.54, 4125.24);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (36, 42, 10, 348.46, 3484.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (87, 6, 5, 309.91, 1549.55);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (62, 44, 3, 624.37, 1873.11);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (85, 90, 6, 500.1, 3000.6);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (96, 23, 5, 681.41, 3407.05);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (1, 80, 7, 195.62, 1369.34);
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal) VALUES (66, 2, 9, 600.85, 5407.65);

INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (27, 'DINHEIRO', 1569.47, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (2, 'BOLETO', 238.04, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (63, 'BOLETO', 1255.2, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (38, 'BOLETO', 3960.12, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (97, 'CARTAO DEBITO', 4198.9, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (3, 'CARTAO DEBITO', 3490.33, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (5, 'DINHEIRO', 2487.69, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (21, 'CARTAO CREDITO', 2309.09, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (47, 'DINHEIRO', 4146.07, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (41, 'DINHEIRO', 131.9, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (31, 'CARTAO CREDITO', 2612.6, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (94, 'DINHEIRO', 1950.72, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (65, 'BOLETO', 4683.96, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (9, 'CARTAO DEBITO', 4430.1, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (94, 'BOLETO', 4137.67, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (55, 'DINHEIRO', 2015.78, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (81, 'CARTAO CREDITO', 4107.77, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (5, 'PIX', 4688.11, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (95, 'BOLETO', 323.28, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (19, 'DINHEIRO', 904.74, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (89, 'BOLETO', 2315.56, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (58, 'CARTAO CREDITO', 1164.05, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (40, 'PIX', 796.69, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (70, 'DINHEIRO', 2168.35, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (30, 'CARTAO CREDITO', 2978.61, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (45, 'PIX', 2602.11, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (74, 'DINHEIRO', 2477.28, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (6, 'CARTAO CREDITO', 2258.71, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (10, 'CARTAO CREDITO', 2702.42, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (56, 'CARTAO CREDITO', 4338.27, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (23, 'BOLETO', 2321.56, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (80, 'CARTAO DEBITO', 3668.69, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (14, 'CARTAO CREDITO', 549.18, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (5, 'CARTAO DEBITO', 4433.81, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (19, 'CARTAO CREDITO', 2386.56, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (28, 'BOLETO', 4002.56, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (75, 'DINHEIRO', 4685.19, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (91, 'CARTAO DEBITO', 4076.08, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (45, 'BOLETO', 4835.18, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (4, 'BOLETO', 869.9, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (83, 'CARTAO CREDITO', 2087.86, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (96, 'CARTAO CREDITO', 456.83, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (59, 'DINHEIRO', 4638.79, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (57, 'CARTAO CREDITO', 3387.6, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (75, 'PIX', 1656.53, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (27, 'CARTAO DEBITO', 3750.53, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (60, 'CARTAO DEBITO', 782.76, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (99, 'BOLETO', 250.83, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (10, 'CARTAO DEBITO', 4850.7, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (63, 'PIX', 1438.78, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (55, 'DINHEIRO', 773.43, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (64, 'DINHEIRO', 769.98, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (83, 'CARTAO DEBITO', 3472.72, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (92, 'DINHEIRO', 856.89, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (33, 'PIX', 357.77, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (27, 'PIX', 3481.75, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (31, 'CARTAO DEBITO', 2460.22, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (92, 'CARTAO CREDITO', 864.34, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (81, 'PIX', 753.03, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (2, 'BOLETO', 428.59, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (81, 'PIX', 3555.97, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (52, 'PIX', 4403.86, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (48, 'BOLETO', 2517.59, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (16, 'CARTAO DEBITO', 975.08, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (72, 'BOLETO', 3178.8, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (22, 'BOLETO', 499.54, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (88, 'CARTAO CREDITO', 1559.51, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (49, 'CARTAO DEBITO', 816.8, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (1, 'DINHEIRO', 2163.39, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (83, 'BOLETO', 3035.37, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (73, 'PIX', 4546.6, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (48, 'PIX', 991.26, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (57, 'PIX', 4895.48, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (39, 'CARTAO CREDITO', 2493.54, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (99, 'BOLETO', 2412.03, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (11, 'CARTAO CREDITO', 766.37, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (9, 'PIX', 2043.54, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (100, 'DINHEIRO', 1945.9, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (58, 'PIX', 4298.13, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (45, 'CARTAO DEBITO', 51.04, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (23, 'DINHEIRO', 3845.18, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (38, 'PIX', 220.16, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (52, 'CARTAO CREDITO', 2973.81, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (74, 'PIX', 1703.2, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (56, 'DINHEIRO', 4738.98, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (10, 'CARTAO CREDITO', 2637.77, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (89, 'BOLETO', 367.63, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (98, 'CARTAO CREDITO', 4619.83, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (77, 'DINHEIRO', 473.81, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (67, 'CARTAO CREDITO', 2404.29, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (67, 'PIX', 2672.93, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (60, 'PIX', 2887.36, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (45, 'CARTAO DEBITO', 2638.08, 'PENDENTE');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (66, 'PIX', 365.02, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (87, 'CARTAO CREDITO', 476.55, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (99, 'DINHEIRO', 1340.16, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (5, 'PIX', 1176.68, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (97, 'CARTAO DEBITO', 2611.92, 'CANCELADO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (20, 'CARTAO CREDITO', 670.85, 'PAGO');
INSERT INTO pagamentos (id_venda, forma_pagamento, valor, status_pagamento) VALUES (2, 'BOLETO', 4343.54, 'PAGO');

INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 10, 'Distrito Diego Rezende, 6, Alto Das Antenas, 74824963 Dias / SC', 'EM PREPARACAO', '2025-06-11 13:54:58', '2025-11-04 09:49:54');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (87, 6, 'Vale Barbosa, 46, Ápia, 08360245 Pacheco do Norte / SP', 'EM PREPARACAO', '2025-09-09 00:24:11', '2025-12-27 11:01:37');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (74, 63, 'Praça Camargo, 40, Bernadete, 48388-375 Sá dos Dourados / PR', 'EM TRANSITO', '2025-09-07 21:47:14', '2026-01-05 07:12:51');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (36, 59, 'Conjunto de Pereira, 27, Vila São Geraldo, 13662-925 Viana do Oeste / GO', 'ENTREGUE', '2025-10-05 18:57:35', '2026-05-18 07:22:04');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (22, 34, 'Feira de Leão, 7, Nossa Senhora Da Aparecida, 92089-287 Marques do Sul / AC', 'EM TRANSITO', '2025-06-27 16:55:50', '2025-06-29 09:25:04');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (14, 86, 'Residencial Moura, 6, Vila São João Batista, 88385-074 Correia / RS', 'ENTREGUE', '2026-05-08 21:09:11', '2026-05-11 06:58:33');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (41, 45, 'Distrito Maria Liz Fogaça, 22, Belvedere, 23728-445 Abreu / SP', 'ENTREGUE', '2026-04-06 09:31:47', '2026-04-07 22:26:06');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 61, 'Recanto de da Costa, Atila De Paiva, 34527-465 Santos / ES', 'ENVIADO', '2025-06-02 05:00:09', '2026-04-06 11:57:42');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (74, 69, 'Vereda Renan Caldeira, 3, Jardinópolis, 75463-367 Camargo / DF', 'EM PREPARACAO', '2025-09-25 07:49:13', '2025-11-21 12:17:08');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (84, 69, 'Travessa Clara Aragão, 25, Andiroba, 34275451 Dias das Pedras / CE', 'ENVIADO', '2026-01-08 14:04:41', '2026-01-17 04:04:41');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (27, 69, 'Praia Maria Sophia Sousa, Vila Rica, 79084353 Fonseca / PA', 'EM PREPARACAO', '2025-06-07 20:04:53', '2025-11-25 17:03:38');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (83, 43, 'Núcleo de Dias, 32, Universitário, 30379-235 Siqueira dos Dourados / AL', 'ENVIADO', '2025-12-19 09:21:02', '2026-04-09 22:27:10');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (57, 79, 'Alameda Costa, 72, Jardinópolis, 21218-807 Costa / SE', 'ENVIADO', '2025-07-11 17:00:11', '2025-09-09 09:27:44');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (49, 1, 'Rodovia Nicole Gomes, 48, Marieta 3ª Seção, 66582-363 Melo / SC', 'EM PREPARACAO', '2026-04-27 05:05:17', '2026-05-14 17:30:00');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (95, 97, 'Distrito Alana Almeida, 12, Barão Homem De Melo 3ª Seção, 84348940 Ramos do Sul / TO', 'EM PREPARACAO', '2026-02-09 08:52:38', '2026-03-27 21:52:20');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (94, 10, 'Distrito Fernandes, 77, Graça, 28619-084 Montenegro / PI', 'ENVIADO', '2025-12-17 02:48:58', '2026-03-27 02:30:29');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (36, 66, 'Vereda de Borges, 68, Vila Coqueiral, 89616-416 Carvalho das Flores / PR', 'EM TRANSITO', '2025-05-30 00:06:15', '2025-06-14 03:07:32');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (47, 98, 'Rodovia Silva, 245, São Francisco, 20272-713 Correia de Correia / MT', 'EM PREPARACAO', '2026-04-03 02:08:35', '2026-05-26 11:37:34');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (46, 7, 'Alameda Cardoso, 320, Vila Santo Antônio Barroquinha, 95970-125 Rodrigues / SP', 'EM PREPARACAO', '2025-08-18 03:07:22', '2026-02-20 13:35:23');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (46, 98, 'Ladeira de Mendonça, 27, Alto Caiçaras, 64017-474 Rocha de Cavalcanti / SP', 'EM TRANSITO', '2025-11-02 06:58:47', '2026-05-24 23:36:57');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (38, 30, 'Praia Valentina Novaes, 14, Vila Califórnia, 11732-302 Rezende do Amparo / MA', 'ENVIADO', '2026-01-30 01:32:15', '2026-04-09 14:09:21');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (45, 84, 'Sítio Allana Pastor, 39, Vila Antena Montanhês, 83792467 Ramos da Mata / RN', 'EM TRANSITO', '2025-12-25 05:59:01', '2026-04-17 06:57:04');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (78, 19, 'Condomínio Vargas, Vila São Geraldo, 13533924 Rodrigues / MG', 'ENVIADO', '2025-07-26 00:26:35', '2026-03-02 10:25:07');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (82, 16, 'Vereda de da Paz, Chácara Leonina, 04689226 Aragão / CE', 'ENVIADO', '2026-01-14 19:13:36', '2026-03-06 00:28:17');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (95, 57, 'Núcleo de Cavalcante, 2, Vila Oeste, 13132316 Moreira / AM', 'EM TRANSITO', '2025-08-09 23:33:50', '2025-11-05 07:34:10');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (11, 37, 'Campo Hadassa Cavalcanti, Paraíso, 60856-279 Pacheco Grande / RN', 'EM PREPARACAO', '2025-10-31 15:58:43', '2026-05-07 17:00:28');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (71, 33, 'Chácara de Macedo, 89, Monte São José, 72697-587 Correia / DF', 'EM TRANSITO', '2025-07-31 18:14:28', '2025-12-02 03:34:49');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (59, 67, 'Praça Castro, 9, Conjunto Capitão Eduardo, 51331997 Sampaio / PI', 'EM PREPARACAO', '2025-12-04 19:14:07', '2026-05-19 19:42:17');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (6, 52, 'Praia de Peixoto, Vila Da Paz, 25990463 Freitas do Campo / PA', 'ENVIADO', '2025-10-23 11:12:55', '2026-05-17 00:28:55');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (32, 88, 'Residencial de da Cunha, 7, Marilandia, 99889-349 Caldeira Verde / SC', 'EM TRANSITO', '2025-08-08 14:45:08', '2026-01-01 23:41:03');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (31, 55, 'Lago de Duarte, 92, Ademar Maldonado, 87768-790 Teixeira / PA', 'ENVIADO', '2025-07-13 07:58:47', '2025-12-24 18:12:39');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (2, 68, 'Colônia de Souza, Cruzeiro, 20400-048 Oliveira da Prata / AP', 'ENVIADO', '2026-02-20 22:01:54', '2026-03-15 05:06:39');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (16, 30, 'Quadra de Novais, 12, Cidade Nova, 34294836 Gonçalves Verde / TO', 'EM PREPARACAO', '2026-01-22 20:30:06', '2026-04-01 05:20:22');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (35, 48, 'Viela de das Neves, 68, Conjunto Novo Dom Bosco, 63767368 da Costa de Siqueira / MA', 'ENVIADO', '2025-12-05 20:26:13', '2026-04-28 00:13:34');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (18, 85, 'Recanto Ana Beatriz Moreira, Vila São Geraldo, 59817-950 Cardoso das Pedras / SC', 'EM TRANSITO', '2026-04-08 08:33:59', '2026-05-09 05:04:07');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (72, 56, 'Avenida Camargo, 1, Etelvina Carneiro, 59398-780 Nogueira das Pedras / MS', 'ENVIADO', '2025-11-05 19:05:51', '2026-04-18 13:54:02');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 75, 'Fazenda Pastor, 91, Carmo, 85202-997 Nascimento / SC', 'EM TRANSITO', '2025-09-16 07:19:57', '2025-12-09 06:38:51');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (97, 57, 'Parque Silva, 86, Vila Independencia 1ª Seção, 23978-757 Almeida do Campo / MS', 'ENVIADO', '2025-06-19 03:20:37', '2025-08-22 11:30:05');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (20, 14, 'Sítio de Martins, Milionario, 18387410 Garcia de Camargo / RR', 'EM PREPARACAO', '2025-11-21 18:51:24', '2026-02-13 20:46:47');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (25, 67, 'Rodovia de Santos, 371, Das Industrias I, 96135539 Lima da Serra / PE', 'ENVIADO', '2026-01-29 06:54:59', '2026-02-20 08:32:54');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (3, 67, 'Núcleo de Caldeira, 58, Xodo-Marize, 49930-249 Barros / SC', 'EM PREPARACAO', '2025-11-24 17:02:47', '2026-03-09 16:23:43');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (53, 74, 'Lagoa Cecilia Moura, 966, Paquetá, 17279-808 Pereira / PR', 'EM PREPARACAO', '2025-11-08 18:11:41', '2026-05-11 20:20:45');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 68, 'Parque de da Luz, 377, Acaba Mundo, 28904-332 da Mata / RJ', 'EM PREPARACAO', '2026-03-24 11:08:24', '2026-05-14 18:07:21');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (92, 55, 'Via de Dias, 31, São Bento, 52261-171 Martins da Mata / PB', 'EM PREPARACAO', '2025-11-08 07:07:03', '2026-02-25 18:52:12');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (26, 27, 'Sítio de Nogueira, 69, Vila Nova Paraíso, 86082788 Abreu / RS', 'ENVIADO', '2025-09-28 21:38:31', '2026-02-11 14:14:21');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (37, 43, 'Jardim de Marques, 993, Atila De Paiva, 20650493 Mendonça / AC', 'ENTREGUE', '2025-07-04 12:26:10', '2026-05-12 07:53:20');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (19, 55, 'Campo Rebeca Garcia, Santana Do Cafezal, 03691-575 Oliveira / AL', 'EM PREPARACAO', '2026-04-19 19:10:28', '2026-05-09 05:05:54');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (3, 30, 'Feira Sampaio, 19, Vila Sumaré, 16267617 da Costa / AC', 'EM PREPARACAO', '2026-05-01 21:20:38', '2026-05-19 17:26:11');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 28, 'Favela Ester Vasconcelos, 22, Jardim Do Vale, 40126-834 Farias da Serra / RN', 'ENVIADO', '2025-10-10 08:28:48', '2026-01-18 14:16:11');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (80, 86, 'Rodovia Abreu, 11, Lagoinha Leblon, 91786742 Sales / ES', 'ENTREGUE', '2025-11-08 15:38:32', '2026-03-05 20:06:29');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (20, 11, 'Trevo de Costela, 1, Conjunto Jatoba, 25294-354 Barros / PE', 'EM TRANSITO', '2026-04-01 01:38:50', '2026-05-22 20:58:09');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (60, 93, 'Rua de da Cunha, 3, Jatobá, 33513624 Casa Grande da Serra / GO', 'ENTREGUE', '2025-11-09 21:26:11', '2026-05-18 01:19:17');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (78, 88, 'Esplanada Kamilly Freitas, Vila Paris, 19103-849 Costela de Rios / RS', 'ENTREGUE', '2025-09-12 08:26:05', '2026-01-07 00:28:45');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (13, 74, 'Vila da Cunha, 26, Bonfim, 99346306 Leão do Galho / SP', 'ENTREGUE', '2025-06-05 22:03:04', '2025-08-15 17:40:37');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (73, 26, 'Avenida de Lima, 31, Vila Nova Cachoeirinha 3ª Seção, 16155326 Freitas da Prata / SC', 'ENTREGUE', '2025-06-04 03:44:08', '2025-10-09 15:47:08');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (83, 43, 'Colônia de Aragão, 57, Novo Das Industrias, 02975402 Garcia de Lima / DF', 'EM PREPARACAO', '2026-02-16 00:23:45', '2026-04-30 04:42:40');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (8, 11, 'Viaduto Azevedo, 96, Horto, 10174075 Pinto Grande / PI', 'ENTREGUE', '2025-09-26 19:39:48', '2025-12-29 05:30:40');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (14, 48, 'Chácara de Souza, 94, Vila Mangueiras, 21455-118 Guerra / DF', 'ENVIADO', '2025-06-10 04:11:23', '2025-12-01 12:47:20');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (14, 84, 'Chácara de Borges, 32, Sagrada Família, 40806432 Moreira / AC', 'ENTREGUE', '2025-05-31 09:49:05', '2026-03-07 07:22:40');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (46, 93, 'Vale Maria Vitória Cirino, 93, Corumbiara, 43544-152 Viana das Pedras / MT', 'ENVIADO', '2025-07-14 04:09:11', '2025-11-26 03:44:09');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (64, 73, 'Pátio de Aragão, 98, Jaqueline, 23446822 Abreu de Viana / AL', 'ENVIADO', '2026-04-30 12:36:28', '2026-05-15 23:50:37');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (86, 49, 'Conjunto Correia, 30, Concórdia, 96913262 Barros de Araújo / PR', 'ENVIADO', '2026-01-08 23:51:57', '2026-03-29 10:23:40');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (59, 56, 'Condomínio Guerra, 81, Venda Nova, 95029373 da Cruz / AP', 'EM TRANSITO', '2025-09-12 11:07:20', '2025-12-26 04:39:17');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (87, 54, 'Loteamento de Nogueira, 5, Marieta 1ª Seção, 22208-358 Fogaça Paulista / ES', 'ENTREGUE', '2025-07-27 19:56:34', '2026-02-08 19:39:28');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (70, 7, 'Pátio de da Paz, 33, Jardim Alvorada, 13913702 Porto de Minas / AP', 'ENTREGUE', '2025-09-09 18:29:53', '2025-12-07 04:48:14');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (10, 14, 'Parque Silva, 83, São Paulo, 41880258 Siqueira do Sul / RS', 'ENTREGUE', '2025-07-20 13:02:12', '2025-10-25 14:43:15');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (53, 67, 'Recanto Clara Moreira, Nova Floresta, 93750076 da Mata de Minas / AL', 'EM TRANSITO', '2025-10-10 20:04:07', '2026-02-26 19:30:02');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (28, 52, 'Trecho de Vasconcelos, 89, Solar Do Barreiro, 57047731 da Cunha / SC', 'ENTREGUE', '2026-04-26 17:51:31', '2026-05-21 13:03:53');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (77, 41, 'Aeroporto Moreira, Túnel De Ibirité, 20630375 da Mota / RR', 'EM TRANSITO', '2025-08-28 18:54:03', '2025-10-27 11:02:22');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (74, 33, 'Colônia Evelyn Vasconcelos, 4, Vila Nova Gameleira 1ª Seção, 73142-153 Novaes de Mendonça / AP', 'EM TRANSITO', '2025-11-22 13:46:28', '2026-03-07 14:57:09');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (52, 23, 'Setor de Moraes, Barreiro, 87098-085 Moura do Sul / PE', 'ENVIADO', '2025-07-14 17:59:55', '2026-03-13 13:24:20');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (67, 24, 'Alameda da Costa, 72, Santa Rosa, 65140-877 Martins / MA', 'EM TRANSITO', '2026-03-04 10:41:05', '2026-05-25 15:33:02');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (76, 15, 'Viaduto de Macedo, 265, Distrito Industrial Do Jatoba, 50628-571 Costa / SP', 'EM PREPARACAO', '2025-06-10 03:48:13', '2025-11-28 02:08:11');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (15, 5, 'Aeroporto Melo, 689, Suzana, 37850335 Garcia / MG', 'ENVIADO', '2025-05-27 23:56:13', '2025-05-28 00:45:32');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (69, 76, 'Via da Paz, 88, Boa Esperança, 29417792 Barbosa / MG', 'ENVIADO', '2025-07-12 17:55:24', '2025-09-30 03:14:13');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (44, 72, 'Loteamento Oliveira, Pousada Santo Antonio, 24550619 Nascimento / PE', 'ENVIADO', '2026-01-09 04:15:06', '2026-05-05 06:12:19');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (77, 84, 'Lago de Viana, 5, Conjunto São Francisco De Assis, 00979116 Gonçalves / AP', 'ENVIADO', '2026-05-16 00:02:58', '2026-05-25 05:52:32');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (6, 59, 'Rua Francisco Vasconcelos, 47, Cruzeiro, 19457-484 Sousa / RJ', 'EM TRANSITO', '2025-11-13 14:07:04', '2026-03-28 23:27:52');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (26, 3, 'Rua Almeida, 6, Etelvina Carneiro, 90070032 Vasconcelos / PE', 'ENTREGUE', '2025-10-31 08:20:45', '2026-02-13 18:12:25');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (75, 77, 'Esplanada Rhavi Jesus, 35, Lorena, 71533640 Alves / MT', 'EM PREPARACAO', '2026-02-07 03:59:31', '2026-04-30 07:19:02');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (55, 34, 'Recanto de Marques, 93, Vila Piratininga, 36523-264 Cirino Grande / MA', 'ENVIADO', '2025-07-12 12:10:17', '2026-01-23 13:52:52');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (60, 51, 'Viela Alexandre da Cunha, 492, Maria Tereza, 71123893 Pacheco / AL', 'EM TRANSITO', '2026-01-19 01:52:07', '2026-05-20 13:58:04');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (49, 65, 'Largo Luna Azevedo, 44, Saudade, 22016541 da Conceição de Cavalcante / SC', 'EM PREPARACAO', '2025-10-17 05:43:27', '2026-04-25 23:49:53');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (63, 93, 'Ladeira de da Cunha, 9, Jardim América, 02957034 da Paz de Rios / BA', 'EM PREPARACAO', '2026-04-19 11:14:26', '2026-05-25 16:49:39');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (42, 6, 'Núcleo Rocha, 48, Vila Sesc, 79864626 da Cunha do Oeste / MA', 'ENTREGUE', '2025-10-04 16:04:31', '2026-01-16 07:54:48');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (75, 32, 'Trecho de Guerra, 81, Nova America, 56907717 Sales das Flores / AC', 'ENTREGUE', '2025-10-22 23:28:48', '2026-05-20 06:01:03');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (40, 29, 'Colônia Araújo, Conjunto São Francisco De Assis, 20633840 Sousa das Pedras / SE', 'EM PREPARACAO', '2025-11-27 22:24:50', '2026-04-17 05:57:44');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (91, 61, 'Viela Fogaça, 2, Bacurau, 12572184 Rocha / GO', 'EM TRANSITO', '2025-10-10 08:52:05', '2026-03-13 06:31:44');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (29, 61, 'Pátio de Jesus, 1, Milionario, 78101083 Aparecida / GO', 'ENTREGUE', '2025-06-26 16:27:32', '2025-09-26 22:00:56');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (50, 36, 'Favela Barros, 89, Pousada Santo Antonio, 78463755 Novaes de Goiás / TO', 'EM PREPARACAO', '2026-01-12 00:40:28', '2026-01-26 23:48:40');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (26, 8, 'Pátio Sousa, 74, Confisco, 67591925 Silveira / SP', 'EM PREPARACAO', '2025-07-26 15:03:15', '2025-10-20 09:53:49');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (71, 71, 'Estação Sá, 83, Vila Coqueiral, 20831-228 Sales de Minas / DF', 'ENTREGUE', '2026-03-04 06:26:25', '2026-03-30 14:02:20');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (74, 72, 'Estrada Emanuella Brito, 87, Nova Esperança, 90254567 Sá Paulista / SE', 'EM PREPARACAO', '2026-02-19 19:24:06', '2026-05-22 08:28:35');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (33, 70, 'Praia de Teixeira, 98, Calafate, 46675189 Novais de Oliveira / CE', 'EM PREPARACAO', '2025-07-31 04:16:47', '2026-04-03 23:40:12');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (60, 75, 'Viela Maysa Silveira, Vila Paris, 34161302 Campos da Prata / AL', 'ENVIADO', '2026-03-08 10:05:01', '2026-04-10 06:54:02');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (84, 95, 'Condomínio Costela, 19, Vila Jardim São José, 13151985 Sampaio de Lopes / RR', 'EM TRANSITO', '2026-01-28 23:59:22', '2026-02-08 04:56:51');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (47, 17, 'Morro Davi Lucca Martins, 499, Nossa Senhora Do Rosário, 15655-268 da Rocha Verde / PR', 'ENTREGUE', '2025-10-22 16:01:01', '2026-03-31 15:28:44');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (83, 87, 'Fazenda Campos, Engenho Nogueira, 37394-816 Pereira / SC', 'EM TRANSITO', '2026-04-27 04:58:04', '2026-04-29 07:10:21');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (72, 44, 'Estação de Andrade, 41, Alto Dos Pinheiros, 85056477 Rios do Oeste / MA', 'EM PREPARACAO', '2025-08-25 12:31:32', '2026-01-06 17:14:14');
INSERT INTO entregas (id_venda, id_funcionario_entregador, endereco_entrega, status_entrega, data_envio, data_entrega) VALUES (29, 97, 'Lagoa Arthur Gabriel Vieira, Minaslandia, 08882670 Borges de Santos / RS', 'EM TRANSITO', '2026-03-31 16:56:48', '2026-04-05 02:27:28');

