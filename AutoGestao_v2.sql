DROP TABLE IF EXISTS
    item_peca,
    item_servico,
    os_mecanico,
    orcamento,
    ordem_servico,
    peca,
    servico,
    mecanico,
    veiculo,
    cliente
CASCADE;

CREATE TABLE cliente (
    id_cliente  INTEGER GENERATED ALWAYS AS IDENTITY,
    nome        VARCHAR(100)  NOT NULL,
    cpf         CHAR(11)      NOT NULL,
    telefone    VARCHAR(20)   NOT NULL,
    endereco    VARCHAR(200),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf UNIQUE (cpf),
    CONSTRAINT ck_cliente_cpf CHECK (cpf ~ '^[0-9]{11}$')
);

CREATE TABLE veiculo (
    id_veiculo  INTEGER GENERATED ALWAYS AS IDENTITY,
    placa       VARCHAR(8)    NOT NULL,
    marca       VARCHAR(50)   NOT NULL,
    modelo      VARCHAR(50)   NOT NULL,
    ano         SMALLINT      NOT NULL,
    id_cliente  INTEGER       NOT NULL,
    CONSTRAINT pk_veiculo PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa),
    CONSTRAINT ck_veiculo_ano CHECK (ano BETWEEN 1950 AND 2100),
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE ordem_servico (
    id_os              INTEGER GENERATED ALWAYS AS IDENTITY,
    id_veiculo         INTEGER       NOT NULL,
    data_abertura      DATE          NOT NULL DEFAULT CURRENT_DATE,
    problema_relatado  VARCHAR(500)  NOT NULL,
    status             VARCHAR(20)   NOT NULL DEFAULT 'ABERTA',
    CONSTRAINT pk_ordem_servico PRIMARY KEY (id_os),
    CONSTRAINT ck_os_status CHECK (status IN ('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
    CONSTRAINT fk_os_veiculo FOREIGN KEY (id_veiculo)
        REFERENCES veiculo (id_veiculo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE orcamento (
    id_orcamento    INTEGER GENERATED ALWAYS AS IDENTITY,
    id_os           INTEGER        NOT NULL,
    data_orcamento  DATE           NOT NULL DEFAULT CURRENT_DATE,
    valor_total     NUMERIC(10,2)  NOT NULL DEFAULT 0.00,
    situacao        VARCHAR(20)    NOT NULL DEFAULT 'PENDENTE',
    CONSTRAINT pk_orcamento PRIMARY KEY (id_orcamento),
    CONSTRAINT ck_orcamento_valor CHECK (valor_total >= 0),
    CONSTRAINT ck_orcamento_situacao CHECK (situacao IN ('PENDENTE', 'APROVADO', 'RECUSADO')),
    CONSTRAINT fk_orcamento_os FOREIGN KEY (id_os)
        REFERENCES ordem_servico (id_os)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE mecanico (
    id_mecanico   INTEGER GENERATED ALWAYS AS IDENTITY,
    nome          VARCHAR(100)  NOT NULL,
    especialidade VARCHAR(50),
    CONSTRAINT pk_mecanico PRIMARY KEY (id_mecanico)
);

CREATE TABLE servico (
    id_servico  INTEGER GENERATED ALWAYS AS IDENTITY,
    descricao   VARCHAR(100)   NOT NULL,
    valor_base  NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_servico PRIMARY KEY (id_servico),
    CONSTRAINT uq_servico_descricao UNIQUE (descricao),
    CONSTRAINT ck_servico_valor CHECK (valor_base >= 0)
);

CREATE TABLE peca (
    id_peca      INTEGER GENERATED ALWAYS AS IDENTITY,
    nome         VARCHAR(100)   NOT NULL,
    preco        NUMERIC(10,2)  NOT NULL,
    qtd_estoque  INTEGER        NOT NULL DEFAULT 0,
    CONSTRAINT pk_peca PRIMARY KEY (id_peca),
    CONSTRAINT uq_peca_nome UNIQUE (nome),
    CONSTRAINT ck_peca_preco CHECK (preco >= 0),
    CONSTRAINT ck_peca_estoque CHECK (qtd_estoque >= 0)
);

CREATE TABLE os_mecanico (
    id_os        INTEGER NOT NULL,
    id_mecanico  INTEGER NOT NULL,
    CONSTRAINT pk_os_mecanico PRIMARY KEY (id_os, id_mecanico),
    CONSTRAINT fk_osmec_os FOREIGN KEY (id_os)
        REFERENCES ordem_servico (id_os)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_osmec_mecanico FOREIGN KEY (id_mecanico)
        REFERENCES mecanico (id_mecanico)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE item_servico (
    id_orcamento    INTEGER        NOT NULL,
    id_servico      INTEGER        NOT NULL,
    quantidade      INTEGER        NOT NULL DEFAULT 1,
    valor_unitario  NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_item_servico PRIMARY KEY (id_orcamento, id_servico),
    CONSTRAINT ck_itemserv_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_itemserv_valor CHECK (valor_unitario >= 0),
    CONSTRAINT fk_itemserv_orcamento FOREIGN KEY (id_orcamento)
        REFERENCES orcamento (id_orcamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_itemserv_servico FOREIGN KEY (id_servico)
        REFERENCES servico (id_servico)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE item_peca (
    id_orcamento    INTEGER        NOT NULL,
    id_peca         INTEGER        NOT NULL,
    quantidade      INTEGER        NOT NULL DEFAULT 1,
    valor_unitario  NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_item_peca PRIMARY KEY (id_orcamento, id_peca),
    CONSTRAINT ck_itempeca_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_itempeca_valor CHECK (valor_unitario >= 0),
    CONSTRAINT fk_itempeca_orcamento FOREIGN KEY (id_orcamento)
        REFERENCES orcamento (id_orcamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_itempeca_peca FOREIGN KEY (id_peca)
        REFERENCES peca (id_peca)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO cliente (nome, cpf, telefone, endereco) VALUES
('Carlos Eduardo Silva', '11122233344', '(19) 99111-0001', 'Rua das Flores, 120 - Americana/SP'),
('Mariana Oliveira Costa', '22233344455', '(19) 99222-0002', 'Av. Brasil, 845 - Americana/SP'),
('Roberto Almeida Santos', '33344455566', '(19) 99333-0003', 'Rua Quinze de Novembro, 56 - Nova Odessa/SP'),
('Fernanda Lima Rocha', '44455566677', '(19) 99444-0004', 'Rua das Palmeiras, 310 - Santa Bárbara d''Oeste/SP'),
('João Pedro Martins', '55566677788', '(19) 99555-0005', 'Rua Sete de Setembro, 78 - Americana/SP');

INSERT INTO mecanico (nome, especialidade) VALUES
('Antônio Ferreira', 'Motor'),
('Rafael Gomes', 'Suspensão e freios'),
('Marcos Vinícius', 'Elétrica e injeção eletrônica'),
('Lucas Barbosa', 'Mecânica geral');

INSERT INTO servico (descricao, valor_base) VALUES
('Troca de óleo e filtro',         120.00),  
('Alinhamento e balanceamento',    150.00), 
('Revisão de freios',              200.00),  
('Troca de pastilhas de freio',    180.00),  
('Diagnóstico eletrônico',         100.00),  
('Troca de correia dentada',       350.00),  
('Troca de bateria',                60.00),  
('Revisão de suspensão',           280.00), 
('Troca de velas de ignição',       80.00);  

INSERT INTO peca (nome, preco, qtd_estoque) VALUES
('Óleo 5W30 (1 litro)',             38.90, 40),  
('Filtro de óleo',                  29.90, 25),  
('Pastilha de freio dianteira',    119.90, 12),  
('Kit correia dentada',            289.90,  6),  
('Bateria 60Ah',                   459.00,  4),  
('Filtro de ar',                    42.50, 15),  
('Amortecedor dianteiro',          245.00,  8),  
('Vela de ignição',                 24.90, 30);  

INSERT INTO veiculo (placa, marca, modelo, ano, id_cliente) VALUES
('ABC1D23', 'Fiat',       'Uno',     2012, 1),  
('DEF4G56', 'Volkswagen', 'Gol',     2015, 1), 
('GHI7J89', 'Chevrolet',  'Onix',    2019, 2),  
('JKL0M12', 'Honda',      'Civic',   2017, 3),  
('MNO3P45', 'Ford',       'Ka',      2014, 4),  
('PQR6S78', 'Toyota',     'Corolla', 2020, 5), 
('STU9V01', 'Hyundai',    'HB20',    2018, 2);  

INSERT INTO ordem_servico (id_veiculo, data_abertura, problema_relatado, status) VALUES
(1, '2026-10-02', 'Barulho no motor ao ligar e luz de injeção acesa', 'CONCLUIDA'),     
(2, '2026-10-10', 'Revisão geral antes de viagem',                    'CONCLUIDA'),     
(3, '2026-10-20', 'Freio rangendo ao frear',                          'EM_ANDAMENTO'),  
(4, '2026-10-28', 'Carro não pega pela manhã',                        'ABERTA'),        
(5, '2026-11-02', 'Volante tremendo em alta velocidade',              'EM_ANDAMENTO'),  
(6, '2026-11-05', 'Troca de correia dentada preventiva',              'ABERTA'),        
(7, '2026-09-15', 'Barulho na suspensão em lombadas',                 'CANCELADA'),     
(3, '2026-08-12', 'Troca de óleo e filtro',                           'CONCLUIDA');     

INSERT INTO ordem_servico (id_veiculo, problema_relatado) VALUES
(6, 'Ruído estranho no painel');                                                         

INSERT INTO orcamento (id_os, data_orcamento, valor_total, situacao) VALUES
(1, '2026-10-03', 279.60, 'APROVADO'),  
(2, '2026-10-11', 698.00, 'APROVADO'),   
(3, '2026-10-21', 299.90, 'APROVADO'),   
(4, '2026-10-28', 619.00, 'RECUSADO'),  
(5, '2026-11-03', 920.00, 'APROVADO'),  
(6, '2026-11-05', 639.90, 'PENDENTE'),  
(7, '2026-09-16', 770.00, 'RECUSADO'),   
(8, '2026-08-12', 305.50, 'APROVADO'),   
(4, '2026-10-29', 519.00, 'PENDENTE');   


INSERT INTO os_mecanico (id_os, id_mecanico) VALUES
(1, 1), (1, 3),   
(2, 4), (2, 2),   
(3, 2),          
(4, 3),          
(5, 2), (5, 4),   
(6, 1),           
(7, 2),           
(8, 4);          

INSERT INTO item_servico (id_orcamento, id_servico, quantidade, valor_unitario) VALUES
(1, 5, 1, 100.00), (1, 9, 1,  80.00),
(2, 1, 1, 120.00), (2, 2, 1, 150.00), (2, 3, 1, 200.00),
(3, 4, 1, 180.00),
(4, 5, 1, 100.00), (4, 7, 1,  60.00),
(5, 2, 1, 150.00), (5, 8, 1, 280.00),
(6, 6, 1, 350.00),
(7, 8, 1, 280.00),
(8, 1, 1, 120.00),
(9, 7, 1,  60.00);


INSERT INTO item_peca (id_orcamento, id_peca, quantidade, valor_unitario) VALUES
(1, 8, 4,  24.90),
(2, 1, 4,  38.90), (2, 2, 1, 29.90), (2, 6, 1, 42.50),
(3, 3, 1, 119.90),
(4, 5, 1, 459.00),
(5, 7, 2, 245.00),
(6, 4, 1, 289.90),
(7, 7, 2, 245.00),
(8, 1, 4,  38.90), (8, 2, 1, 29.90),
(9, 5, 1, 459.00);

SELECT 'cliente' AS tabela, COUNT(*) AS total FROM cliente
UNION ALL SELECT 'veiculo',       COUNT(*) FROM veiculo
UNION ALL SELECT 'mecanico',      COUNT(*) FROM mecanico
UNION ALL SELECT 'servico',       COUNT(*) FROM servico
UNION ALL SELECT 'peca',          COUNT(*) FROM peca
UNION ALL SELECT 'ordem_servico', COUNT(*) FROM ordem_servico
UNION ALL SELECT 'orcamento',     COUNT(*) FROM orcamento
UNION ALL SELECT 'os_mecanico',   COUNT(*) FROM os_mecanico
UNION ALL SELECT 'item_servico',  COUNT(*) FROM item_servico
UNION ALL SELECT 'item_peca',     COUNT(*) FROM item_peca;


SELECT v.placa, v.modelo, os.id_os, os.data_abertura, os.problema_relatado, os.status
FROM veiculo v
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
WHERE v.placa = 'GHI7J89'
ORDER BY os.data_abertura;


SELECT o.id_orcamento,
       o.valor_total AS total_gravado,
       COALESCE(s.total_servicos, 0) + COALESCE(p.total_pecas, 0) AS total_calculado
FROM orcamento o
LEFT JOIN (SELECT id_orcamento, SUM(quantidade * valor_unitario) AS total_servicos
           FROM item_servico GROUP BY id_orcamento) s ON s.id_orcamento = o.id_orcamento
LEFT JOIN (SELECT id_orcamento, SUM(quantidade * valor_unitario) AS total_pecas
           FROM item_peca GROUP BY id_orcamento) p ON p.id_orcamento = o.id_orcamento
ORDER BY o.id_orcamento;
