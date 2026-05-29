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

