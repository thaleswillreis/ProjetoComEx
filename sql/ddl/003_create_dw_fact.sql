-- ============================================================================
-- SCHEMA DE FATO
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS dw_fact;

-- ============================================================================
-- TABELA FATO DE IMPORTAÇÃO
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_fact.fato_importacao (
  fato_sk BIGSERIAL PRIMARY KEY,
  ingest_id BIGINT, 

  -- Datas
  data_coleta DATE,
  data_entrega DATE,
  data_coleta_sk BIGINT REFERENCES dw_dim.dim_date(date_sk),
  data_entrega_sk BIGINT REFERENCES dw_dim.dim_date(date_sk),

  -- Dimensões
  pais_origem_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
  pais_destino_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
  carrier_sk BIGINT REFERENCES dw_dim.dim_carrier(carrier_sk),
  excecao_sk BIGINT REFERENCES dw_dim.dim_excecao(excecao_sk),
  incoterm_sk BIGINT REFERENCES dw_dim.dim_incoterm(incoterm_sk),

  -- Medidas e atributos
  doc_embarque TEXT,
  peso_kg NUMERIC,
  volume_cbm NUMERIC,
  tipo TEXT,             
  tipo_servico TEXT,      
  prazo_contratado INT,
  numero_invoice TEXT,
  operacao TEXT,
  local_destino TEXT,     

  created_at TIMESTAMP DEFAULT now(),
  
  -- Colunas SCD2
  effective_from DATE,
  effective_to DATE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_fato_ingest_id ON dw_fact.fato_importacao(ingest_id);
CREATE INDEX IF NOT EXISTS idx_fato_datas ON dw_fact.fato_importacao(data_coleta, data_entrega);

