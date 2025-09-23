-- SCHEMA DE FATO
CREATE SCHEMA IF NOT EXISTS dw_fact;

-- TABELA FATO
CREATE TABLE IF NOT EXISTS dw_fact.fato_importacao (
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

CREATE INDEX IF NOT EXISTS idx_fato_ingest_id ON dw_fact.fato_importacao(ingest_id);
CREATE INDEX IF NOT EXISTS idx_fato_datas ON dw_fact.fato_importacao(data_coleta, data_entrega);

