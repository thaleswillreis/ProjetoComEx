 Versão em português - [pt-BR](https://github.com/thaleswillreis/ProjetoComEx/blob/main/LEIAME.md)



# Data Warehouse - ComEx

## Description

This is an end-to-end educational project for a Data Warehouse built on Apache Hop and the PostgreSQL and MongoDB databases. It involves extracting data from structured files containing records of foreign trade operations (Freight, Export, Import, etc.). The project is based on real-world data, business rules, and problems such as the need to consider time intervals between data loads, implementation of a custom Slowly Changing Dimension Type 2 mechanism, error handling, tracking of new data, log management, data governance, and other technical aspects that will be addressed later in this documentation.


## Development Environment

Software and Libraries:

* Debian Linux 13
* Docker 29.0.2
* Apache Hop 2.15.0
* PostgreSQL 15
* MongoDB 7
* DBeaver 25.2.3
* MongoDB Compass 1.48.2
* Github

## Data Structure

The project is structured around two databases:

**MongoDB Database:** audit

**Collections:** dw_load_log, raw_load_log.

> [!NOTE]
> The **audit** database is used to store log data for auditing. During each execution of the project's workflows and data pipelines, the most relevant execution logs are captured and stored in document format in the MongoDB Collections according to their stage in the data warehousing process (data collection or integration, cleaning, and storage).

**PostgreSQL Database:** comex_dw

**Schemas:** stg, dw_dim, dw_fact.

**Tables:**

| stg | dw_dim | dw_fact |
|---------|----------|----------|
| carriers_comex_raw| dim_carrier  | fato_importacao |
| historico_importacao_raw| dim_date |    |
| excecoes_comex_raw| dim_excecao    |    |
| geodados_flags_raw| dim_incoterm   |    |
|                   | dim_pais       |    |

### Creating the Main Database

#### SQL Scripts for Creating Schemas and Tables

* 001_create_dw_stg.sql
* 002_create_dw_dim.sql
* 003_create_dw_fact.sql
* Script for populating the calendar table - dim_date.sql

#### `001_create_dw_stg.sql`:

```sql
-- SCHEMA DE STAGING
CREATE SCHEMA IF NOT EXISTS stg;

-- ============================================================================
-- STAGING TABLES (raw data)
-- ============================================================================

-- Import History
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

-- Geodata of countries and flags
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

-- Carriers (logistics operators)
CREATE TABLE IF NOT EXISTS stg.carriers_comex_raw (
  ingest_id BIGSERIAL PRIMARY KEY,
  id_carrier TEXT,
  operador_logistico TEXT,
  origem_arquivo TEXT,
  linha_numero INT,
  data_carga_dados TIMESTAMP,
  received_at TIMESTAMP DEFAULT now()
);

-- Logistical exceptions
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
```
#### `002_create_dw_dim.sql`:

```sql
-- DIMENSION SCHEME
CREATE SCHEMA IF NOT EXISTS dw_dim;

-- ============================================================================
-- Country Dimension (dw_dim.dim_pais)
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
-- Carrier Dimension (dw_dim.dim_carrier)
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
-- Logistics Exception Dimension (dw_dim.dim_excecao)
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
-- Incoterm Dimension (dw_dim.dim_incoterm)
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
-- Date Dimension (dw_dim.dim_date)
-- Note: date_sk is the surrogate key in YYYYMMDD (INTEGER) format,
-- non-sequential, reflecting current practice.
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
```

#### `003_create_dw_fact.sql`:

```sql
-- ============================================================================
-- FACTUAL SCHEME
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS dw_fact;

-- ============================================================================
-- IMPORT FACT TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS dw_fact.fato_importacao (
  fato_sk BIGSERIAL PRIMARY KEY,
  ingest_id BIGINT, 

  -- Dates
  data_coleta DATE,
  data_entrega DATE,
  data_coleta_sk BIGINT REFERENCES dw_dim.dim_date(date_sk),
  data_entrega_sk BIGINT REFERENCES dw_dim.dim_date(date_sk),

  -- Dimensions
  pais_origem_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
  pais_destino_sk BIGINT REFERENCES dw_dim.dim_pais(pais_sk),
  carrier_sk BIGINT REFERENCES dw_dim.dim_carrier(carrier_sk),
  excecao_sk BIGINT REFERENCES dw_dim.dim_excecao(excecao_sk),
  incoterm_sk BIGINT REFERENCES dw_dim.dim_incoterm(incoterm_sk),

  -- Measurements and attributes
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
  
  -- SCD2 Columns
  effective_from DATE,
  effective_to DATE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_fato_ingest_id ON dw_fact.fato_importacao(ingest_id);
CREATE INDEX IF NOT EXISTS idx_fato_datas ON dw_fact.fato_importacao(data_coleta, data_entrega);
```

#### `Script de preenchimento da tabela calendário - dim_date .sql`:
(Script for filling in the calendar table)

```sql
-- ============================================================================
-- Populate script for the dw_dim.dim_date table
-- Generates dates from 2022-01-01 to 2040-12-31
-- ============================================================================

INSERT INTO dw_dim.dim_date (
  date_sk, dt, "year", "month", "day", week, weekday,
  quarter, month_name, weekday_name, is_weekend, is_workday
)
SELECT
  -- substitute key in YYYYMMDD format
  EXTRACT(YEAR FROM d)::INT * 10000 +
  EXTRACT(MONTH FROM d)::INT * 100 +
  EXTRACT(DAY FROM d)::INT AS date_sk,
  
  d::DATE AS dt,
  EXTRACT(YEAR FROM d)::INT AS "year",
  EXTRACT(MONTH FROM d)::INT AS "month",
  EXTRACT(DAY FROM d)::INT AS "day",
  EXTRACT(WEEK FROM d)::INT AS week,
  
  -- PostgreSQL: EXTRACT(DOW) returns 0=Sunday, 6=Saturday
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

```

## Project Execution Preparation

1. **Software Installation**: All necessary software or equivalents must be properly installed.

2. **Data Structure**: All data structures must be properly created and operational.

3. **Scripts and Environment Variables**: Apache Hop configuration files, environment variables, and Docker scripts must be created, saved, and tested.

#### Example of a `.env` file

```yml

# --- PostgreSQL Configurations
DB_NAME=database
DB_USER=username
DB_PASS=password
DB_PORT=#### (Port number. Default is 5432)

# --- MongoDB Configurations
MONGO_PORT=#### (Port number. Default is 27017)
MONGO_USER=username
MONGO_PASS=password
```
> [!IMPORTANT]
> To reduce the likelihood of errors and facilitate maintenance, the .env file should be saved in the same directory as the docker-compose script before creating the Docker containers and volumes for the databases.

> [!WARNING]
> To avoid accidental sharing of sensitive data, **.env** files should be included in the **.gitignore** list of untracked items if the project uses Git versioning.

### Creating the Docker Container and Database Volumes.

#### Script `docker-compose.yml`

```yml
services:
  postgres:
    image: postgres:15
    container_name: postgres_comex_dw
    restart: unless-stopped
    ports:
      - "${DB_PORT}:5432"
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - comex_net

  mongodb:
    image: mongo:7.0
    container_name: mongodb_comex_log
    restart: unless-stopped
    ports:
      - "${MONGO_PORT}:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASS}
    volumes:
      - mongo_data:/data/db
    networks:
      - comex_net

volumes:
  postgres_data:
  mongo_data:

networks:
  comex_net:
    driver: bridge
```

## Structure of the `Workflow Master` (orchestrator) in Apache Hop

![Workflow Master](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_COMEX_Master.png)

## List of pipelines that make up the workflows:

Independent pipelines with a governance function that are triggered by workflow execution triggers (log management).

    PIPE_log_raw
    PIPE_log_dw

Layer for tracking and extracting new data: 

   >`WF_Stage_Create_Tables.hwf`

   	PIPE_raw_excecoes_comex.hpl
   	PIPE_raw_carriers_comex.hpl
   	PIPE_raw_geodados_flags.hpl
   	PIPE_raw_historico_importacao.hpl

Data cleaning layer and 'assembly' of dimension and fact tables:

   >`WF_dim_loads.hwf`

   	PIPE_stg_to_dim_pais.hpl
   	PIPE_stg_to_dim_carrier.hpl
   	PIPE_stg_to_dim_excecao.hpl
   	PIPE_stg_to_dim_incoterm.hpl

   >`WF_fact_loads.hwf`

	PIPE_stg_to_fact_importacao.hpl

#### To view the complete project structure [>> click here](https://github.com/thaleswillreis/ProjetoComEx/blob/main/doc/Workflow%20Structure%20-%20ComEx%20Project.txt)

## Result of constructing the `Fact Table`

![Fact Table](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_dw_fact_fato_importacao.png)

## Log Processing Results

### Processing of logs from the `data discovery and extraction` layer:

![Log Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_raw_load_log.png)

### Handling logs from the `dimension and fact table construction` layer:

![Log Dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_dw_load_log.png)

## Challenges Encountered

Possibly due to a combination of factors — such as business rule requirements, data structure, the architectural approach selected for the project, and the databases involved — using the Dimension Lookup/Update transform, which is commonly adopted in Apache Hop for implementing Slowly Changing Dimensions Type 2 in Data Warehousing environments, proved to be problematic.
During testing, I faced issues such as inconsistent pipeline execution results, false positives indicating data changes in dimension tables, and execution errors occurring under different circumstances.
At this stage of development, I decided to implement a custom SCD2 mechanism using other native Apache Hop transforms. This custom solution can be examined in the image gallery or in the complete project structure, both of which are referenced in the documentation through attached links.

## Related links:

* [Debian Linux](https://www.debian.org/index.pt.html)
* [Docker](https://www.docker.com/)
* [Apache Hop](https://hop.apache.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [MongoDB](https://www.mongodb.com)
* [DBeaver](https://dbeaver.io/)
* [MongoDB Compass](https://www.mongodb.com/products/tools/compass)
* [Github](https://github.com/)


## Image Gallery
<a href="https://github.com/thaleswillreis/ProjetoComEx/blob/main/doc/Gallery.md">
  <img src="https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Icones/GalleryIcon3d.png"  width="48">
</a>


## License

This project is licensed under the MIT License - see the file [LICENSE](https://github.com/thaleswillreis/ProjetoComEx/blob/main/LICEN%C3%87A_PT-BR.md) for more details.
