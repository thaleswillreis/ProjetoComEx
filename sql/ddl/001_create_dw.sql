-- SCHEMAS
updated_at TIMESTAMP
);
CREATE INDEX idx_dim_excecao_codigo ON dw_dim.dim_excecao(codigo_excecao);


CREATE TABLE dw_dim.dim_incoterm (
incoterm_sk BIGSERIAL PRIMARY KEY,
incoterm_code TEXT UNIQUE,
descricao TEXT,
created_at TIMESTAMP DEFAULT now()
);
CREATE INDEX idx_incoterm_code ON dw_dim.dim_incoterm(incoterm_code);


-- Dimensão de data (opcional: pode ser populada por job)
CREATE TABLE dw_dim.dim_date (
date_sk BIGSERIAL PRIMARY KEY,
dt DATE UNIQUE,
year INT,
month INT,
day INT,
week INT,
weekday INT
);
CREATE INDEX idx_dim_date_dt ON dw_dim.dim_date(dt);


-- TABELA FATO
CREATE TABLE dw_fact.fato_importacao (
fato_sk BIGSERIAL PRIMARY KEY,
ingest_id BIGINT, -- referencia para staging se necessário
data_coleta DATE,
data_entrega DATE,
data_coleta_sk BIGINT,
data_entrega_sk BIGINT,
pais_origem_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
pais_destino_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
carrier_sk BIGINT REFERENCES dw_dim.dim_carrier(carrier_sk),
excecao_sk BIGINT REFERENCES dw_dim.dim_excecao(excecao_sk),
incoterm_sk BIGINT REFERENCES dw_dim.dim_incoterm(incoterm_sk),
doc_embarque TEXT,
peso_kg NUMERIC,
volume_cbm NUMERIC,
tipo_servico TEXT,
prazo_contratado INT,
numero_invoice TEXT,
operacao TEXT,
created_at TIMESTAMP DEFAULT now()
);


CREATE INDEX idx_fato_ingest_id ON dw_fact.fato_importacao(ingest_id);
CREATE INDEX idx_fato_datas ON dw_fact.fato_importacao(data_coleta, data_entrega);


-- TABELAS DE AUDIT / LOG
CREATE TABLE audit.load_log (
log_id BIGSERIAL PRIMARY KEY,
job_name TEXT,
step_name TEXT,
source_file TEXT,
rows_read BIGINT,
rows_written BIGINT,
rows_error BIGINT,
started_at TIMESTAMP,
finished_at TIMESTAMP,
status TEXT,
message TEXT
);


-- VIEWs úteis (exemplo)
CREATE OR REPLACE VIEW dw_fact.vw_fato_importacao AS
SELECT f.*, p_ori.nome_ptbr AS pais_origem, p_dest.nome_ptbr AS pais_destino, c.nome_operador, e.descricao AS descricao_excecao, i.incoterm_code
FROM dw_fact.fato_importacao f
LEFT JOIN dw_dim.dim_pais p_ori ON f.pais_origem_sk = p_ori.pais_sk
LEFT JOIN dw_dim.dim_pais p_dest ON f.pais_destino_sk = p_dest.pais_sk
LEFT JOIN dw_dim.dim_carrier c ON f.carrier_sk = c.carrier_sk
LEFT JOIN dw_dim.dim_excecao e ON f.excecao_sk = e.excecao_sk
LEFT JOIN dw_dim.dim_incoterm i ON f.incoterm_sk = i.incoterm_sk;


-- EXEMPLO: permissões (ajuste conforme seu usuário)
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA stg TO your_etl_user;
