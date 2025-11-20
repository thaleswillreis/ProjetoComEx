-- ============================================================================
-- Script de população da tabela dw_dim.dim_date
-- Gera datas de 2022-01-01 até 2040-12-31
-- ============================================================================

INSERT INTO dw_dim.dim_date (
  date_sk, dt, "year", "month", "day", week, weekday,
  quarter, month_name, weekday_name, is_weekend, is_workday
)
SELECT
  -- chave substituta no formato YYYYMMDD
  EXTRACT(YEAR FROM d)::INT * 10000 +
  EXTRACT(MONTH FROM d)::INT * 100 +
  EXTRACT(DAY FROM d)::INT AS date_sk,
  
  d::DATE AS dt,
  EXTRACT(YEAR FROM d)::INT AS "year",
  EXTRACT(MONTH FROM d)::INT AS "month",
  EXTRACT(DAY FROM d)::INT AS "day",
  EXTRACT(WEEK FROM d)::INT AS week,
  
  -- PostgreSQL: EXTRACT(DOW) retorna 0=Domingo, 6=Sábado
  (EXTRACT(DOW FROM d)::INT + 1) AS weekday,
  
  EXTRACT(QUARTER FROM d)::INT AS quarter,
  TO_CHAR(d, 'TMMonth') AS month_name,
  TO_CHAR(d, 'TMDay') AS weekday_name,
  
  CASE WHEN EXTRACT(DOW FROM d) IN (0,6) THEN TRUE ELSE FALSE END AS is_weekend,
  CASE WHEN EXTRACT(DOW FROM d) BETWEEN 1 AND 5 THEN TRUE ELSE FALSE END AS is_workday
FROM generate_series(
  DATE '2022-01-01',
  DATE '2040-12-31',
  INTERVAL '1 day'
) AS g(d)
ON CONFLICT (date_sk) DO NOTHING;

