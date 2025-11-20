-- SCHEMA DE DIMENSÕES
CREATE SCHEMA IF NOT EXISTS dw_dim;

-- ============================================================================
-- Dimensão País (dw_dim.dim_pais)
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_dim.dim_pais (
  pais_sk               BIGSERIAL PRIMARY KEY,
  iso_3166_alpha2       CHAR(2),
  iso_3166_alpha3       CHAR(3),
  nome_ptbr             TEXT,
  capital               TEXT,
  area_km2              NUMERIC,
  populacao             BIGINT,
  url_bandeira          TEXT,
  effective_from        DATE DEFAULT CURRENT_DATE,
  effective_to          DATE,
  created_at            TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dim_pais_alpha2 ON dw_dim.dim_pais (iso_3166_alpha2);
CREATE INDEX IF NOT EXISTS idx_dim_pais_alpha3 ON dw_dim.dim_pais (iso_3166_alpha3);

-- ============================================================================
-- Dimensão Carrier (dw_dim.dim_carrier)
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_dim.dim_carrier (
  carrier_sk              BIGSERIAL PRIMARY KEY,
  id_carrier              TEXT,
  nome_operador_logistico TEXT,
  effective_from          DATE DEFAULT CURRENT_DATE,
  effective_to            DATE,
  created_at              TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dim_carrier_id ON dw_dim.dim_carrier (id_carrier);

-- ============================================================================
-- Dimensão Exceção logística (dw_dim.dim_excecao)
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_dim.dim_excecao (
  excecao_sk         BIGSERIAL PRIMARY KEY,
  cod_excecao        TEXT,
  descricao_desvio   TEXT,
  responsavel        TEXT,
  created_at         TIMESTAMP DEFAULT now(),
  effective_from     DATE DEFAULT CURRENT_DATE,
  effective_to       DATE
);

CREATE INDEX IF NOT EXISTS idx_dim_excecao_codigo ON dw_dim.dim_excecao (cod_excecao);

-- ============================================================================
-- Dimensão Incoterm (dw_dim.dim_incoterm)
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_dim.dim_incoterm (
  incoterm_sk    BIGSERIAL PRIMARY KEY,
  incoterm_code  TEXT,
  descricao      TEXT,
  created_at     TIMESTAMP DEFAULT now(),
  effective_from DATE DEFAULT CURRENT_DATE,
  effective_to   DATE
);

CREATE INDEX IF NOT EXISTS idx_incoterm_code ON dw_dim.dim_incoterm (incoterm_code);

-- ============================================================================
-- Dimensão de Data (dw_dim.dim_date)
-- Observação: date_sk é a chave substituta no formato YYYYMMDD (INTEGER),
-- não sequencial, refletindo a prática atual.
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_dim.dim_date (
  date_sk       INTEGER PRIMARY KEY,  -- ex.: 20220101
  dt            DATE,
  "year"        INT,
  "month"       INT,
  "day"         INT,
  week          INT,
  weekday       INT,
  quarter       INT,
  month_name    TEXT,
  weekday_name  TEXT,
  is_weekend    BOOLEAN,
  is_workday    BOOLEAN
);

CREATE INDEX IF NOT EXISTS idx_dim_date_dt ON dw_dim.dim_date (dt);



