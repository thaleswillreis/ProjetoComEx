-- SCHEMA DE DIMENSÕES
CREATE SCHEMA IF NOT EXISTS dw_dim;

-- DIMENSÕES
CREATE TABLE IF NOT EXISTS dw_dim.dim_pais (
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
CREATE INDEX IF NOT EXISTS idx_dim_pais_iso ON dw_dim.dim_pais(iso_3166);

CREATE TABLE IF NOT EXISTS dw_dim.dim_carrier (
  carrier_sk BIGSERIAL PRIMARY KEY,
  id_carrier TEXT UNIQUE,
  nome_operador TEXT,
  effective_from DATE DEFAULT CURRENT_DATE,
  effective_to DATE,
  current_flag BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_dim_carrier_id ON dw_dim.dim_carrier(id_carrier);

CREATE TABLE IF NOT EXISTS dw_dim.dim_excecao (
  excecao_sk BIGSERIAL PRIMARY KEY,
  codigo_excecao TEXT UNIQUE,
  descricao TEXT,
  responsavel TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_dim_excecao_codigo ON dw_dim.dim_excecao(codigo_excecao);

CREATE TABLE IF NOT EXISTS dw_dim.dim_incoterm (
  incoterm_sk BIGSERIAL PRIMARY KEY,
  incoterm_code TEXT UNIQUE,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_incoterm_code ON dw_dim.dim_incoterm(incoterm_code);

-- Dimensão de data (opcional: pode ser populada por job)
CREATE TABLE IF NOT EXISTS dw_dim.dim_date (
  date_sk BIGSERIAL PRIMARY KEY,
  dt DATE UNIQUE,
  year INT,
  month INT,
  day INT,
  week INT,
  weekday INT
);
CREATE INDEX IF NOT EXISTS idx_dim_date_dt ON dw_dim.dim_date(dt);

