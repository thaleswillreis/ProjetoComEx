-- SCHEMA DE AUDITORIA
CREATE SCHEMA IF NOT EXISTS audit;

-- TABELA DE AUDIT / LOG
CREATE TABLE IF NOT EXISTS audit.load_log (
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

