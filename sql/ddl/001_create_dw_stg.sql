-- SCHEMA DE STAGING
CREATE SCHEMA IF NOT EXISTS stg;

-- TABELAS DE STAGING (dados brutos)
CREATE TABLE IF NOT EXISTS stg.historico_importacao_raw (
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
CREATE INDEX IF NOT EXISTS stg_historico_origem_idx ON stg.historico_importacao_raw (origem_arquivo);

CREATE TABLE IF NOT EXISTS stg.geodados_flags_raw (
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

CREATE TABLE IF NOT EXISTS stg.cadastros_comex_raw (
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
CREATE TABLE IF NOT EXISTS stg.errors_import (
  error_id BIGSERIAL PRIMARY KEY,
  source_table TEXT,
  source_key TEXT,
  error_message TEXT,
  raw_row JSONB,
  occurred_at TIMESTAMP DEFAULT now()
);

