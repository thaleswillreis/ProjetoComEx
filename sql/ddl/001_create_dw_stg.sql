-- SCHEMA DE STAGING
CREATE SCHEMA IF NOT EXISTS stg;

-- ============================================================================
-- TABELAS DE STAGING (dados brutos)
-- ============================================================================

-- Histórico de importações
CREATE TABLE IF NOT EXISTS stg.historico_importacao_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
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
  origem_arquivo TEXT,
  linha_numero INT,
  data_carga_dados TIMESTAMP,
  received_at TIMESTAMP DEFAULT now()
);
CREATE INDEX IF NOT EXISTS stg_historico_origem_idx 
  ON stg.historico_importacao_raw (origem_arquivo);

-- Geodados de países e bandeiras
CREATE TABLE IF NOT EXISTS stg.geodados_flags_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  iso_3166_alpha2 TEXT,
  iso_3166_alpha3 TEXT,
  pais_ptbr TEXT,
  capital TEXT,
  area_km2 TEXT,
  populacao TEXT,
  url_bandeira TEXT,
  linha_numero INT,
  data_carga_dados TIMESTAMP,
  origem_arquivo TEXT,
  received_at TIMESTAMP DEFAULT now()
);
CREATE INDEX IF NOT EXISTS stg_geodados_origem_idx 
  ON stg.geodados_flags_raw (origem_arquivo);

-- Carriers (operadores logísticos)
CREATE TABLE IF NOT EXISTS stg.carriers_comex_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  id_carrier TEXT,
  operador_logistico TEXT,
  origem_arquivo TEXT,
  linha_numero INT,
  data_carga_dados TIMESTAMP,
  received_at TIMESTAMP DEFAULT now()
);

-- Exceções logísticas
CREATE TABLE IF NOT EXISTS stg.excecoes_comex_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  cod_excecao TEXT,
  descricao_desvio TEXT,
  responsavel TEXT,
  origem_arquivo TEXT,
  linha_numero INT,
  data_carga_dados TIMESTAMP,
  received_at TIMESTAMP DEFAULT now()
);


