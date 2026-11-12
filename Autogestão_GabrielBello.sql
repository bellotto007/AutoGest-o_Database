CREATE DATABASE autogestao
    ENCODING 'UTF8';

\c autogestao

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