English version - [en-US](https://github.com/thaleswillreis/ProjetoComEx/blob/main/README.md)

# Data Warehouse - ComEx

## Descrição

Este é um projeto *"end to end"*  didático de um Data Warehouse construído em Apache Hop e os bancos de dados PostgreSQL e MongoDB. Nele realizamos a extração de dados de arquivos estruturados contendo registros de operações de comércio exterior (Frete, Exportação, Importação, etc). O projeto é baseado em dados, regras de negócios e problemas reais como a necessidade de considerar os intervalos de tempo entre cargas de dados, implementação de um mecanismo de Slowly Changing Dimension Tipo 2 personalizado, tratamento de erros, rastreamento de novos dados, gerenciamento de logs, governança de dados e outros aspectos técnicos que serão abordados posteriormente nessa documentação.

## Ambiente de desenvolvimento

Softwares e bibliotecas:

* Debian Linux 13
* Docker 29.0.2
* Apache Hop 2.15.0
* PostgreSQL 15
* MongoDB 7
* DBeaver 25.2.3
* MongoDB Compass 1.48.2
* Github

## Estrutura de Dados

O projeto está estruturado em torno de duas bases de dados:

 **Base de Dados MongoDB:** audit

  **Collections:** dw_load_log, raw_load_log.

> [!NOTE]
> A base de dados **audit** é utilizada para guardar dados de log para auditoria. Durante cada execução dos workflows e pipelines de dados do projeto, os logs de execução mais relevantes são capturados e armazenados no formato de documento nas Collections do MongoDB de acordo com seu estágio no processo de data warehousing (coleta de dados ou integração, limpeza e armazenamento).


**Base de Dados PostgreSQL:** comex_dw

**Schemas:**  stg, dw_dim, dw_fact.

**Tabelas:**

| stg | dw_dim | dw_fact |
|---------|----------|----------|
| carriers_comex_raw| dim_carrier  | fato_importacao |
| historico_importacao_raw| dim_date |    |
| excecoes_comex_raw| dim_excecao    |    |
| geodados_flags_raw| dim_incoterm   |    |
|                   | dim_pais       |    |


### Criação da Base de Dados Principal

#### Scripts SQL de criação dos schemas e tabelas

* 001_create_dw_stg.sql
* 002_create_dw_dim.sql
* 003_create_dw_fact.sql
* Script de preenchimento da tabela calendario - dim_date .sql

#### `001_create_dw_stg.sql`:

```sql
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
```
#### `002_create_dw_dim.sql`:

```sql
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
```

#### `003_create_dw_fact.sql`:

```sql
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


```

#### `Script de preenchimento da tabela calendário - dim_date .sql`:

```sql
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

```

## Preparação da Execução do Projeto

1. **Instalação de softwares** : Todos os software ou equivalentes necessários para iniciar devem está devidamente instalados.
2. **Estrutura de dados** : Toda a estrutura de dados deve está devidamente criada e operacional.
3. **Scripts e variáveis de ambiente** : Arquivos de configuração do Apache Hop, variáveis de ambiente e scripts do docker devem está criados, salvos e testados.

#### Exemplo de arquivo `.env`

```yml
# --- Configurações PostgreSQL
DB_NAME=base de dados
DB_USER=usuario
DB_PASS=senha
DB_PORT=#### (Nº da porta. Padrão é 5432)

# --- Configurações MongoDB
MONGO_PORT=#### (Nº da porta. Padrão é 27017)
MONGO_USER=usuario
MONGO_PASS=senha
```
> [!IMPORTANT]
> Para diminuir a probabilidade de erros e facilitar a manutenção, o arquivo .env deve ser salvo no mesmo diretório do script do docker-compose antes da criação dos containers e volumes Docker para as bases de dados.

> [!WARNING]
> Para evitar compartilhamento acidental de dados sensíveis, arquivos **.env** devem ser incluídos na lista de ítens não rastreados do **.gitignore** caso o projeto utilize versionamento Git.

### Criação do Container e dos volumes Docker das bases de dados.

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
## Estrutura do `Workflow Master` (orquestrador) no Apache Hop

![Workflow Master](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_COMEX_Master.png)

### Lista de pipelines que compõe os workflow:

Pipelines independentes com função de governança e que são disparados por gatilhos de execução dos Workflows (gerenciamento de log).

    PIPE_log_raw
    PIPE_log_dw

Camada de rastreamento e extração de novos dados: 

   >`WF_Stage_Create_Tables.hwf`

   	PIPE_raw_excecoes_comex.hpl
   	PIPE_raw_carriers_comex.hpl
   	PIPE_raw_geodados_flags.hpl
   	PIPE_raw_historico_importacao.hpl

Camada de limpeza de dados e 'montagem' das tabelas dimensão e fato: 

   >`WF_dim_loads.hwf`

   	PIPE_stg_to_dim_pais.hpl
   	PIPE_stg_to_dim_carrier.hpl
   	PIPE_stg_to_dim_excecao.hpl
   	PIPE_stg_to_dim_incoterm.hpl

   >`WF_fact_loads.hwf`

	PIPE_stg_to_fact_importacao.hpl

## Resultado da construção da `Tabela Fato`

![Tabela Fato](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_dw_fact_fato_importacao.png)

## Resultado do `Tratamento de Logs`

### Tratamento dos logs da camada de `descoberta e extração de dados`:

![Log Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_raw_load_log.png)

### Tratamento dos logs da camada de `construção das tabelas dimensão e fato`:

![Log Dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/DadosDWeLog/Dados_dw_load_log.png)

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests no repositório do projeto.

## Links relacionados:

* [Debian Linux](https://www.debian.org/index.pt.html)
* [Docker](https://www.docker.com/)
* [Apache Hop](https://hop.apache.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [MongoDB](https://www.mongodb.com)
* [DBeaver](https://dbeaver.io/)
* [MongoDB Compass](https://www.mongodb.com/products/tools/compass)
* [Github](https://github.com/)

<a href="https://github.com/thaleswillreis/ProjetoComEx/blob/main/doc/Galeria.md">
  <img src="https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Icones/GalleryIcon3d.png" align="right"  width="48">
</a>

## Galeria de Imagens

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](https://github.com/thaleswillreis/ProjetoComEx/blob/main/LICEN%C3%87A_PT-BR.md) para mais detalhes.

