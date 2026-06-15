-- SOul — Schema Completo
-- Importar: mysql -u root -p < SOul.sql

SET NAMES utf8mb4;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP DATABASE IF EXISTS `SOul`;
CREATE DATABASE `SOul` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `SOul`;

-- ─────────────────────────────────────────────
-- FABRICANTE
-- ─────────────────────────────────────────────
CREATE TABLE fabricante (
  id         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(100)    NOT NULL,
  site       VARCHAR(200)    NOT NULL,
  pais       VARCHAR(100)    NOT NULL,
  descricao  TEXT            NOT NULL,
  ano        YEAR            NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- USUARIO
-- ─────────────────────────────────────────────
CREATE TABLE usuario (
  id        INT UNSIGNED                  NOT NULL AUTO_INCREMENT,
  email     VARCHAR(100)                  NOT NULL,
  senha     VARCHAR(255)                  NOT NULL,
  nome      VARCHAR(100)                  NOT NULL,
  data_reg  DATETIME                      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tema      ENUM('claro','escuro')        NOT NULL DEFAULT 'escuro',
  PRIMARY KEY (id),
  UNIQUE KEY email_UNIQUE (email),
  INDEX idx_usuario_email (email)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- SISTEMA OPERACIONAL
-- ─────────────────────────────────────────────
CREATE TABLE so (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(30)     NOT NULL,
  slug          VARCHAR(30)     NOT NULL,
  pagina        VARCHAR(50)     NOT NULL,
  descricao     TEXT            NOT NULL,
  fabricante_id INT UNSIGNED    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY nome_UNIQUE  (nome),
  UNIQUE KEY slug_UNIQUE  (slug),
  INDEX idx_so_slug (slug),
  FOREIGN KEY (fabricante_id) REFERENCES fabricante(id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- USO (categorias de propósito)
-- ─────────────────────────────────────────────
CREATE TABLE uso (
  id    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome  VARCHAR(25)     NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- USO_SO (nota 1-6 de aptidão por categoria)
-- ─────────────────────────────────────────────
CREATE TABLE uso_so (
  uso_id  INT UNSIGNED  NOT NULL,
  so_id   INT UNSIGNED  NOT NULL,
  nota    TINYINT       NOT NULL CHECK (nota BETWEEN 1 AND 6),
  PRIMARY KEY (uso_id, so_id),
  FOREIGN KEY (uso_id) REFERENCES uso(id),
  FOREIGN KEY (so_id)  REFERENCES so(id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- FAVORITOS
-- ─────────────────────────────────────────────
CREATE TABLE favoritos (
  usuario_id  INT UNSIGNED  NOT NULL,
  so_id       INT UNSIGNED  NOT NULL,
  criado_em   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, so_id),
  INDEX idx_fav_usuario (usuario_id),
  FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
  FOREIGN KEY (so_id)      REFERENCES so(id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- HISTORICO DE RECOMENDAÇÕES
-- ─────────────────────────────────────────────
CREATE TABLE historico_recomendacoes (
  id              INT UNSIGNED                    NOT NULL AUTO_INCREMENT,
  usuario_id      INT UNSIGNED                    NOT NULL,
  respostas_json  JSON                            NOT NULL,
  so_recomendado  VARCHAR(30)                     NOT NULL,
  ranking_json    JSON,
  justificativa   TEXT,
  fonte           ENUM('ai','deterministic')      NOT NULL DEFAULT 'deterministic',
  confianca       TINYINT UNSIGNED,
  criado_em       DATETIME                        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_hist_usuario (usuario_id),
  FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- ═════════════════════════════════════════════
-- DADOS INICIAIS (SEED)
-- ═════════════════════════════════════════════

-- ── Fabricantes ──────────────────────────────
INSERT INTO fabricante (nome, site, pais, descricao, ano) VALUES
('Canonical',
 'https://canonical.com', 'Reino Unido',
 'Fundada em 2004 por Mark Shuttleworth, a Canonical é responsável pelo Ubuntu. '
 'Oferece soluções de nuvem, servidores e IoT com foco em software livre.',
 2004),
('Apple Inc.',
 'https://apple.com', 'Estados Unidos',
 'Fundada em 1976, a Apple é referência mundial em hardware e software integrados. '
 'O macOS é o sistema exclusivo dos computadores Mac.',
 1976),
('Comunidade Arch Linux',
 'https://archlinux.org', 'Global',
 'O Arch Linux surgiu em 2002, liderado por Judd Vinet. Mantido por voluntários, '
 'promove simplicidade, transparência e controle total ao usuário avançado.',
 2002),
('Microsoft Corporation',
 'https://microsoft.com', 'Estados Unidos',
 'Fundada em 1975, a Microsoft é criadora do Windows, Office e Azure. '
 'É referência global em software, nuvem e inteligência artificial.',
 1975),
('Projeto Debian',
 'https://debian.org', 'Global',
 'Iniciado por Ian Murdock em 1993, o Projeto Debian é mantido por voluntários '
 'ao redor do mundo com governança comunitária e decisões democráticas.',
 1993),
('Linux Mint Team',
 'https://linuxmint.com', 'Global',
 'Equipe liderada por Clement Lefebvre desde 2006. Visa oferecer um sistema '
 'estável e amigável baseado no Ubuntu, focando na simplicidade.',
 2006),
('Fedora Project / Red Hat',
 'https://fedoraproject.org', 'Estados Unidos',
 'O Fedora é patrocinado pela Red Hat e desenvolvido pela comunidade. '
 'Serve de laboratório de inovação para o Red Hat Enterprise Linux.',
 2003),
('System76',
 'https://system76.com', 'Estados Unidos',
 'Fabricante americana de hardware Linux que criou o Pop!_OS em 2017 para '
 'otimizar a experiência em seus notebooks e workstations.',
 2005),
('Zorin Group',
 'https://zorin.com', 'Irlanda',
 'Empresa fundada pelos irmãos Artyom e Kyrill Zorin em 2008. Desenvolve o '
 'Zorin OS com foco em facilitar a migração de Windows e Mac para o Linux.',
 2008),
('Manjaro GmbH & Co. KG',
 'https://manjaro.org', 'Alemanha',
 'Empresa alemã que desenvolve o Manjaro desde 2011, tornando o Arch Linux '
 'acessível com instalador gráfico e ferramentas de gestão simplificadas.',
 2011);

-- ── Sistemas Operacionais ─────────────────────
INSERT INTO so (nome, slug, pagina, descricao, fabricante_id) VALUES
('Ubuntu',
 'ubuntu', 'ubuntu.html',
 'Uma das distribuições Linux mais populares. Interface amigável, ampla comunidade, '
 'repositório imenso e ciclo LTS previsível. Ideal para iniciantes, desenvolvedores e ambientes corporativos.',
 1),
('macOS',
 'macos', 'macos.html',
 'Sistema da Apple: design refinado, excelente desempenho para criatividade e desenvolvimento. '
 'Exclusivo para hardware Mac, com profunda integração com iPhone e iPad.',
 2),
('Arch Linux',
 'arch', 'arch.html',
 'Para usuários avançados que desejam controle total. Instalação manual e minimalista, '
 'rolling release, AUR com repositório gigante. Você constrói exatamente o que quer.',
 3),
('Windows',
 'windows', 'windows.html',
 'O sistema mais usado do mundo. Compatibilidade incomparável com jogos, software corporativo '
 'e vasta gama de hardware. Suporte técnico amplo e ecossistema gaming imbatível.',
 4),
('Debian',
 'debian', 'debian.html',
 'Estabilidade lendária. Base para metade das distribuições Linux existentes, incluindo o Ubuntu. '
 'Ideal para servidores e desenvolvedores que priorizam confiabilidade acima de tudo.',
 5),
('Linux Mint',
 'mint', 'mint.html',
 'A transição mais suave do Windows para o Linux. Baseado no Ubuntu, estável, '
 'leve e completo desde o primeiro boot. Perfeito para uso doméstico e máquinas antigas.',
 6),
('Fedora',
 'fedora', 'fedora.html',
 'Distribuição de ponta patrocinada pela Red Hat. Pacotes sempre atualizados, foco em '
 'desenvolvedores e tecnologias emergentes. Equilíbrio entre novidade e estabilidade.',
 7),
('Pop!_OS',
 'popos', 'popos.html',
 'Criado pela System76 para máximo desempenho em jogos e criação. Driver Nvidia integrado, '
 'gerenciador de janelas em mosaico (tiling) e interface polida. Zero complicação.',
 8),
('Zorin OS',
 'zorin', 'zorinos.html',
 'O Linux mais amigável para migrantes do Windows ou Mac. Layout familiar, visual moderno '
 'e funcionamento imediato sem precisar do terminal. Excelente para hardware antigo.',
 9),
('Manjaro',
 'manjaro', 'manjaro.html',
 'O Arch Linux acessível. Rolling release, acesso ao AUR, instalador gráfico e '
 'ferramentas de gestão simplificadas. Para quem quer poder sem a complexidade do Arch puro.',
 10);

-- ── Categorias de uso ─────────────────────────
INSERT INTO uso (nome) VALUES
('Estudos'),
('Trabalho'),
('Jogos'),
('Arte/Design'),
('Dia a dia'),
('Desenvolvimento'),
('Servidor');

-- ── Notas de aptidão por uso e SO ─────────────
-- so_id: 1=Ubuntu 2=macOS 3=Arch 4=Windows 5=Debian 6=Mint
--         7=Fedora 8=Pop!_OS 9=Zorin 10=Manjaro
-- uso_id: 1=Estudos 2=Trabalho 3=Jogos 4=Arte 5=Dia-a-dia 6=Dev 7=Servidor
INSERT INTO uso_so (so_id, uso_id, nota) VALUES
-- Ubuntu
(1,1,4),(1,2,5),(1,3,2),(1,4,2),(1,5,4),(1,6,6),(1,7,5),
-- macOS
(2,1,3),(2,2,6),(2,3,1),(2,4,6),(2,5,3),(2,6,5),(2,7,2),
-- Arch Linux
(3,1,4),(3,2,4),(3,3,4),(3,4,2),(3,5,2),(3,6,6),(3,7,5),
-- Windows
(4,1,2),(4,2,5),(4,3,6),(4,4,4),(4,5,5),(4,6,3),(4,7,1),
-- Debian
(5,1,4),(5,2,5),(5,3,1),(5,4,1),(5,5,3),(5,6,5),(5,7,6),
-- Linux Mint
(6,1,4),(6,2,4),(6,3,2),(6,4,2),(6,5,6),(6,6,3),(6,7,2),
-- Fedora
(7,1,4),(7,2,5),(7,3,2),(7,4,2),(7,5,3),(7,6,6),(7,7,4),
-- Pop!_OS
(8,1,3),(8,2,4),(8,3,6),(8,4,5),(8,5,4),(8,6,5),(8,7,2),
-- Zorin OS
(9,1,4),(9,2,4),(9,3,2),(9,4,2),(9,5,6),(9,6,2),(9,7,1),
-- Manjaro
(10,1,4),(10,2,4),(10,3,5),(10,4,2),(10,5,3),(10,6,5),(10,7,3);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
