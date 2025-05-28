-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema SOul2
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema SOul2
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `SOul2` DEFAULT CHARACTER SET utf8 ;
USE `SOul2` ;

-- -----------------------------------------------------
-- Table `SOul2`.`compatib`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`compatib` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `dado_maq` ENUM('2009-2014', '2015-2019', '2020-2025') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`usuario` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(45) NOT NULL,
  `senha` VARCHAR(64) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `data_reg` DATETIME NOT NULL,
  `tema`ENUM('claro', 'escuro') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`respostas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`respostas` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `compatib_id` INT UNSIGNED NOT NULL,
  `usuario_id` INT UNSIGNED NOT NULL,
  `r_custom` ENUM('baixa', 'média', 'alta') NOT NULL,
  `r_multitask` ENUM('sim', 'não') NOT NULL,
  `r_curva_aprend` ENUM('baixa', 'média', 'alta') NOT NULL,
  `r_preco` ENUM('sim', 'não') NOT NULL,
  `r_tamanho` DECIMAL(4,2) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_respostas_compatib1_idx` (`compatib_id` ASC),
  INDEX `fk_respostas_usuario1_idx` (`usuario_id` ASC),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  CONSTRAINT `fk_respostas_compatib1`
    FOREIGN KEY (`compatib_id`)
    REFERENCES `SOul2`.`compatib` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_respostas_usuario1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `SOul2`.`usuario` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`fabricante`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`fabricante` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `site` VARCHAR(200) NOT NULL,
  `pais` VARCHAR(100) NOT NULL,
  `descricao` VARCHAR(300) NOT NULL,
  `ano` YEAR NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`so`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`so` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(10) NOT NULL,
  `custom` ENUM('baixa', 'média', 'alta') NOT NULL,
  `multitask` ENUM('sim', 'não') NOT NULL,
  `descricao` VARCHAR(350) NOT NULL,
  `curva_aprend` ENUM('baixa', 'média', 'alta') NOT NULL,
  `preco` ENUM('sim', 'não') NOT NULL,
  `tamanho` DECIMAL(4,2) UNSIGNED NOT NULL,
  `fabricante_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nome_UNIQUE` (`nome` ASC),
  INDEX `fk_so_fabricante1_idx` (`fabricante_id` ASC),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  CONSTRAINT `fk_so_fabricante1`
    FOREIGN KEY (`fabricante_id`)
    REFERENCES `SOul2`.`fabricante` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`uso`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`uso` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`respostas_uso`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`respostas_uso` (
  `respostas_id` INT UNSIGNED NOT NULL,
  `uso_id` INT UNSIGNED NOT NULL,
  INDEX `fk_respostas_uso_respostas_idx` (`respostas_id` ASC),
  INDEX `fk_respostas_uso_uso1_idx` (`uso_id` ASC),
  CONSTRAINT `fk_respostas_uso_respostas`
    FOREIGN KEY (`respostas_id`)
    REFERENCES `SOul2`.`respostas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_respostas_uso_uso1`
    FOREIGN KEY (`uso_id`)
    REFERENCES `SOul2`.`uso` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`compatib_so`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`compatib_so` (
  `compatib_id` INT UNSIGNED NOT NULL,
  `so_id` INT UNSIGNED NOT NULL,
  `nivel` ENUM('baixa', 'media', 'alta') NOT NULL,
  INDEX `fk_compatib_so_compatib1_idx` (`compatib_id` ASC),
  INDEX `fk_compatib_so_so1_idx` (`so_id` ASC),
  CONSTRAINT `fk_compatib_so_compatib1`
    FOREIGN KEY (`compatib_id`)
    REFERENCES `SOul2`.`compatib` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_compatib_so_so1`
    FOREIGN KEY (`so_id`)
    REFERENCES `SOul2`.`so` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`ranking`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`ranking` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ordem` TINYINT(100) UNSIGNED NOT NULL,
  `so_id` INT UNSIGNED NOT NULL,
  `respostas_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `ordem_UNIQUE` (`ordem` ASC),
  INDEX `fk_ranking_so1_idx` (`so_id` ASC),
  INDEX `fk_ranking_respostas1_idx` (`respostas_id` ASC),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  CONSTRAINT `fk_ranking_so1`
    FOREIGN KEY (`so_id`)
    REFERENCES `SOul2`.`so` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ranking_respostas1`
    FOREIGN KEY (`respostas_id`)
    REFERENCES `SOul2`.`respostas` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`so_usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`so_usuario` (
  `so_id` INT UNSIGNED NOT NULL,
  `usuario_id` INT UNSIGNED NOT NULL,
  INDEX `fk_so_usuario_so1_idx` (`so_id` ASC),
  INDEX `fk_so_usuario_usuario1_idx` (`usuario_id` ASC),
  CONSTRAINT `fk_so_usuario_so1`
    FOREIGN KEY (`so_id`)
    REFERENCES `SOul2`.`so` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_so_usuario_usuario1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `SOul2`.`usuario` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`favoritos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`favoritos` (
  `usuario_id` INT UNSIGNED NOT NULL,
  `so_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`usuario_id`, `so_id`),
  INDEX `fk_favoritos_usuario1_idx` (`usuario_id` ASC),
  INDEX `fk_favoritos_so1_idx` (`so_id` ASC),
  CONSTRAINT `fk_favoritos_usuario1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `SOul2`.`usuario` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favoritos_so1`
    FOREIGN KEY (`so_id`)
    REFERENCES `SOul2`.`so` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SOul2`.`uso_so`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SOul2`.`uso_so` (
  `uso_id` INT UNSIGNED NOT NULL,
  `so_id` INT UNSIGNED NOT NULL,
  INDEX `fk_uso_so_uso1_idx` (`uso_id` ASC),
  INDEX `fk_uso_so_so1_idx` (`so_id` ASC),
  CONSTRAINT `fk_uso_so_uso1`
    FOREIGN KEY (`uso_id`)
    REFERENCES `SOul2`.`uso` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_uso_so_so1`
    FOREIGN KEY (`so_id`)
    REFERENCES `SOul2`.`so` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


USE SOul2;
#Otimizações

#A coluna para comportar a nota de cada uso para cada SO:
ALTER TABLE uso_so
ADD COLUMN nota TINYINT CHECK (nota BETWEEN 1 AND 6);


#A remoção da restrição de unicidade em ordem na tabela ranking:
DROP TABLE ranking;
CREATE TABLE IF NOT EXISTS ranking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordem INT NOT NULL,
    respostas_id INT UNSIGNED NOT NULL,
    so_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (respostas_id) REFERENCES respostas(id),
    FOREIGN KEY (so_id) REFERENCES so(id)
);


#A criação dos índices:
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_ranking_respostas ON ranking(respostas_id);
CREATE INDEX idx_so_nome ON so (nome);




#População:

INSERT INTO fabricante (nome, site, pais, descricao, ano) VALUES
('Canonical', 'https://canonical.com', 'Reino Unido',
 'A Canonical, fundada em 2004 por Mark Shuttleworth no 
 Reino Unido, é conhecida pelo Ubuntu. A empresa oferece 
 soluções para nuvem, servidores e dispositivos IoT, com 
 foco em software livre, suporte técnico e automação de 
 sistemas.', 2004),
('Apple', 'https://apple.com', 'Estados Unidos',
 'A Apple Inc., fundada em 1976, é uma gigante de tecnologia 
 sediada na Califórnia. Conhecida pelo iPhone e Mac, 
 desenvolve hardware e software integrados. Seu foco inclui 
 inovação, design e ecossistemas como iOS e macOS.', 2001),
('Comunidade Arch Linux', 'https://archlinux.org', 'Global',
 'A comunidade Arch Linux surgiu em 2002, liderada inicialmente 
 por Judd Vinet. O projeto é mantido por voluntários e promove 
 simplicidade, transparência e controle total do sistema, 
 voltando-se a usuários mais experientes.', 2002),
('Microsoft', 'https://microsoft.com', 'Estados Unidos',
 'Fundada em 1975, a Microsoft é uma das maiores empresas 
 de tecnologia do mundo. Criadora do Windows, Office e Azure, 
 é referência global em software, computação em nuvem, 
 inteligência artificial e soluções corporativas.', 1985),
('Projeto Debian', 'https://debian.org', 'Global',
 'O Projeto Debian, iniciado por Ian Murdock em 1993, 
 é formado por voluntários ao redor do mundo. Seu 
 objetivo é criar um sistema operacional livre, estável 
 e de alta qualidade, com governança comunitária e 
 decisões democráticas.', 1993),
('Linux Mint Team', 'https://linuxmint.com', 'Global',
 'O Linux Mint é mantido por uma equipe global liderada 
 por Clement Lefebvre desde 2006. O projeto visa oferecer 
 um sistema estável, amigável e eficiente, baseado no 
 Ubuntu ou Debian, focando na experiência de uso e 
 simplicidade.', 2006);
 

INSERT INTO so (nome, custom, multitask, descricao, curva_aprend, preco, tamanho, fabricante_id) VALUES
('Ubuntu', 'baixa', 'sim', 
'Ubuntu é uma das distribuições Linux mais populares, 
ideal para quem está começando ou busca uma alternativa 
estável ao Windows. Possui interface amigável, ampla 
comunidade, atualizações regulares e suporte a uma grande 
variedade de softwares. É uma escolha segura para uso 
doméstico, profissional ou acadêmico.', 
'baixa', 'não', 10, 1),
('MacOS', 'média', 'sim', 
'MacOS é voltado a quem prioriza design, integração e 
desempenho, especialmente em áreas criativas como edição 
de vídeo, música e design gráfico. Funciona apenas em 
computadores Apple e se destaca pela estabilidade, 
segurança e integração com iPhone e iPad. É ideal para 
usuários do ecossistema Apple que valorizam produtividade 
e simplicidade.', 
'média', 'sim', 44, 2),
('Arch', 'alta', 'sim', 
'Arch Linux é recomendado para usuários avançados que 
desejam total controle e personalização. A instalação 
é manual e mínima, exigindo conhecimento técnico, mas 
oferece aprendizado profundo sobre o funcionamento do 
sistema. Ideal para quem quer um ambiente leve, sob 
medida e sempre atualizado com os pacotes mais recentes.', 
'alta', 'não', 5, 3),
('Windows', 'baixa', 'não', 
'Windows é o sistema mais utilizado no mundo, indicado 
para quem precisa de ampla compatibilidade com jogos, 
programas populares e hardware diverso. Tem interface 
intuitiva, suporte comercial e grande comunidade. Ideal 
para usuários que buscam facilidade, produtividade, 
suporte a games e uso em ambientes corporativos.', 
'baixa', 'sim', 20, 4),
('Debian', 'alta', 'não', 
'Debian é uma das distribuições Linux mais estáveis 
e confiáveis, ideal para servidores e ambientes que 
priorizam consistência e segurança. Usa pacotes 
amplamente testados e conta com enorme repositório 
de softwares. Embora tenha atualizações mais lentas, 
é ideal para usuários experientes e empresas que 
exigem robustez.', 
'média', 'não', 10, 5),
('Mint', 'média', 'não', 
'Linux Mint é voltado a usuários que 
estão migrando do Windows e buscam uma experiência 
simples e familiar. Baseado no Ubuntu, é estável, 
leve, e já vem pronto para uso com codecs e softwares 
essenciais. Ideal para computadores mais antigos, 
uso doméstico e quem quer evitar configurações 
complexas no Linux.', 
'baixa', 'não', 20, 6)
;


INSERT INTO uso (nome) VALUES
('Estudos'),
('Trabalho'),
('Jogos'),
('Arte'),
('Dia a dia'),
('Desenvolvimento');


INSERT INTO uso_so (so_id, uso_id, nota) VALUES
#Ubuntu
(1, 1, 3),  -- Estudos
(1, 2, 5),  -- Trabalho
(1, 3, 2),  -- Jogos
(1, 4, 1),  -- Arte
(1, 5, 4),  -- Dia a dia
(1, 6, 6),  -- Desenvolvimento
#MacOS
(2, 1, 2),  -- Estudos
(2, 2, 4),  -- Trabalho
(2, 3, 1),  -- Jogos
(2, 4, 6),  -- Arte
(2, 5, 3),  -- Dia a dia
(2, 6, 5),  -- Desenvolvimento
#Arch
(3, 1, 3),  -- Estudos
(3, 2, 4),  -- Trabalho
(3, 3, 5),  -- Jogos
(3, 4, 1),  -- Arte
(3, 5, 2),  -- Dia a dia
(3, 6, 6),  -- Desenvolvimento
#Windows
(4, 1, 1),  -- Estudos
(4, 2, 5),  -- Trabalho
(4, 3, 6),  -- Jogos
(4, 4, 3),  -- Arte
(4, 5, 4),  -- Dia a dia
(4, 6, 2),  -- Desenvolvimento
#Debian
(5, 1, 3),  -- Estudos
(5, 2, 5),  -- Trabalho
(5, 3, 2),  -- Jogos
(5, 4, 1),  -- Arte
(5, 5, 4),  -- Dia a dia
(5, 6, 6),  -- Desenvolvimento
#Mint
(6, 1, 2),  -- Estudos
(6, 2, 5),  -- Trabalho
(6, 3, 3),  -- Jogos
(6, 4, 1),  -- Arte
(6, 5, 6),  -- Dia a dia
(6, 6, 4);  -- Desenvolvimento


INSERT INTO compatib (dado_maq) VALUES
('2009-2014'),
('2015-2019'),
('2020-2025');

INSERT INTO compatib_so (compatib_id, nivel, so_id) VALUES
#Ubuntu
(1, 'média', 1),
(2, 'alta', 1),
(3, 'alta', 1),
#MacOS
(1, 'baixa', 2),
(2, 'média', 2),
(3, 'alta', 2),
#Arch
(1, 'alta', 3),
(2, 'alta', 3),
(3, 'alta', 3),
#Windows
(1, 'baixa', 4),
(2, 'média', 4),
(3, 'alta', 4),
#Debian
(1, 'alta', 5),
(2, 'alta', 5),
(3, 'alta', 5),
#Mint
(1, 'alta', 6),
(2, 'alta', 6),
(3, 'alta', 6)
;


INSERT INTO usuario (email, senha, nome, data_reg, tema) VALUES
('alice@exemplo.com', 'senha1', 'Alice Silva', NOW(), 'claro'),
('bruno@exemplo.com', 'senha2', 'Bruno Costa', NOW(), 'escuro'),
('carla@exemplo.com', 'senha3', 'Carla Mendes', NOW(), 'claro'),
('diego@exemplo.com', 'senha4', 'Diego Souza', NOW(), 'escuro'),
('elisa@exemplo.com', 'senha5', 'Elisa Rocha', NOW(), 'claro'),
('jefferson@exemplo.com', 'senha6', 'Jefferson Vieira', NOW(), 'escuro');


INSERT INTO respostas (usuario_id, compatib_id, r_custom, r_multitask,
 r_curva_aprend, r_preco, r_tamanho) VALUES
(1, 1, 'baixa', 'sim', 'baixa', 'sim', 15),
(2, 2, 'média', 'não', 'média', 'não', 30),
(3, 3, 'alta', 'sim', 'alta', 'sim', 60),
(4, 3, 'baixa', 'não', 'baixa', 'não', 15),
(5, 1, 'média', 'sim', 'alta', 'sim', 30),
(6, 2, 'alta', 'não', 'média', 'não', 60)
;

INSERT INTO respostas_uso (respostas_id, uso_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6)
;

INSERT INTO favoritos (usuario_id, so_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6)
;

INSERT INTO so_usuario (so_id, usuario_id) VALUES
(1, 6),
(2, 5),
(3, 4),
(4, 3),
(5, 2),
(6, 1)
;

INSERT INTO ranking (respostas_id, so_id, ordem) VALUES
#Ranking usuário 1:
(1, 1, 1), -- Ubuntu
(1, 2, 4), -- MacOS
(1, 3, 2), -- Arch
(1, 4, 5), -- Windows
(1, 5, 3), -- Debian
(1, 6, 6), -- Mint
#Ranking usuário 2:
(2, 1, 3), -- Ubuntu
(2, 2, 6), -- MacOS
(2, 3, 5), -- Arch
(2, 4, 4), -- Windows
(2, 5, 2), -- Debian
(2, 6, 1), -- Mint
#Ranking usuário 3:
(3, 1, 4), -- Ubuntu
(3, 2, 3), -- MacOS
(3, 3, 1), -- Arch
(3, 4, 2), -- Windows
(3, 5, 6), -- Debian
(3, 6, 5), -- Mint
#Ranking usuário 4:
(4, 1, 1), -- Ubuntu
(4, 2, 4), -- MacOS
(4, 3, 6), -- Arch
(4, 4, 3), -- Windows
(4, 5, 2), -- Debian
(4, 6, 5), -- Mint
#Ranking usuário 5:
(5, 1, 2), -- Ubuntu
(5, 2, 4), -- MacOs
(5, 3, 3), -- Arch
(5, 4, 6), -- Windows
(5, 5, 5), -- Debian
(5, 6, 1), -- Mint
#Ranking usuário 6:
(6, 1, 4), -- Ubuntu
(6, 2, 5), -- MacOS
(6, 3, 2), -- Arch
(6, 4, 3), -- Windows
(6, 5, 1), -- Debian
(6, 6, 6) -- Mint
;
