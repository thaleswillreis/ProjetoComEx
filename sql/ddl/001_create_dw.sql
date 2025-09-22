-- SCHEMAS
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw_dim;
CREATE SCHEMA IF NOT EXISTS dw_fact;
CREATE SCHEMA IF NOT EXISTS audit;

-- TABELAS DE STAGING (dados brutos)
CREATE TABLE stg.historico_importacao_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  origem_arquivo TEXT,
  linha_numero INT,
  operacao TEXT,
  tipo TEXT,
  numero_invoice TEXT,
  incoterm TEXT,
  origem TEXT,
  id_pais_destino TEXT,
  local_destino TEXT,
  id_operador_logistico TEXT,
  doc_embarque TEXT,
  peso_kg TEXT,
  volume_cbm TEXT,
  tipo_servico TEXT,
  data_coleta_raw TEXT,
  data_entrega_raw TEXT,
  prazo_contratado_raw TEXT,
  cod_excecao TEXT,
  received_at TIMESTAMP DEFAULT now()
);

CREATE INDEX stg_historico_origem_idx ON stg.historico_importacao_raw (origem_arquivo);

CREATE TABLE stg.geodados_flags_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  origem_arquivo TEXT,
  linha_numero INT,
  iso_3166 TEXT,
  alpha2 TEXT,
  alpha3 TEXT,
  pais_ptbr TEXT,
  capital TEXT,
  area_km2 TEXT,
  populacao TEXT,
  url_bandeira TEXT,
  received_at TIMESTAMP DEFAULT now()
);

CREATE TABLE stg.cadastros_comex_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  origem_arquivo TEXT,
  pagina INT,
  linha_numero INT,
  campo1 TEXT,
  campo2 TEXT,
  campo3 TEXT,
  raw_text TEXT,
  received_at TIMESTAMP DEFAULT now()
);

-- TABELAS DE ERRO / REJEITOS
CREATE TABLE stg.errors_import (
  error_id BIGSERIAL PRIMARY KEY,
  source_table TEXT,
  source_key TEXT,
  error_message TEXT,
  raw_row JSONB,
  occurred_at TIMESTAMP DEFAULT now()
);

-- DIMENSÕES (modelo dimensional com surrogate keys)
CREATE TABLE dw_dim.dim_pais (
  pais_sk BIGSERIAL PRIMARY KEY,
  iso_3166 TEXT UNIQUE,
  alpha2 CHAR(2),
  alpha3 CHAR(3),
  nome_ptbr TEXT,
  capital TEXT,
  area_km2 NUMERIC,
  populacao BIGINT,
  url_bandeira TEXT,
  effective_from DATE DEFAULT CURRENT_DATE,
  effective_to DATE,
  current_flag BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP
);
CREATE INDEX idx_dim_pais_iso ON dw_dim.dim_pais(iso_3166);

CREATE TABLE dw_dim.dim_carrier (
  carrier_sk BIGSERIAL PRIMARY KEY,
  id_carrier TEXT UNIQUE,
  nome_operador TEXT,
  effective_from DATE DEFAULT CURRENT_DATE,
  effective_to DATE,
  current_flag BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP
);
CREATE INDEX idx_dim_carrier_id ON dw_dim.dim_carrier(id_carrier);

CREATE TABLE dw_dim.dim_excecao (
  excecao_sk BIGSERIAL PRIMARY KEY,
  codigo_excecao TEXT UNIQUE,
  descricao TEXT,
  responsavel TEXT,
  created_at TIMESTAMP DEFAULT now(),
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
