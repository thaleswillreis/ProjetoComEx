# Galeria de Imagens - Projeto ComEx

## `Workflow Master` (orquestrador) no Apache Hop
![Workflow Master](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_COMEX_Master.png)

<!-- Workflows que compõem o Workflow Master -->
## Workflows que compõem o `Workflow Master`

### Workflow `WF_Stage_Create_Tables`
![Workflow Stage](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_Stage_Create_Tables.png)

### Workflow `WF_dim_loads`
![Workflow Dim](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/%20WF_dim_loads.png)

### Workflow `WF_fact_loads`
![Workflow Fact](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_fact_loads.png)

<!-- Pipelines que compõem o WF_Stage_Create_Tables -->

## Pipelines que compõem o `WF_Stage_Create_Tables` *(Descoberta e extração de dados)*

### Pipeline `PIPE_raw_carriers_comex`
![Pipeline Raw Carrier](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_carriers_comex.png)

### Pipeline `PIPE_raw_excecoes_comex`
![Pipeline Raw Excecoes](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_excecoes_comex.png)

### Pipeline `PIPE_raw_geodados_flags`
![Pipeline Raw Geodados](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_geodados_flags.png)

### Pipeline `PIPE_raw_historico_importacao`
![Pipeline Raw Hist](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_historico_importacao.png)

<!-- Pipelines que compõem o WF_dim_loads -->

## Pipelines que compõem o `WF_dim_loads` *(Construção das tabelas dimensão)*

### Pipeline `PIPE_stg_to_dim_carrier`
![Pipeline Dim Carrier](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_carrier.png)

### Pipeline `PIPE_stg_to_dim_excecao`
![Pipeline Dim Excecao](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_excecao.png)

### Pipeline `PIPE_stg_to_dim_incoterm`
![Pipeline Dim Incoterm](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_incoterm.png)

### Pipeline `PIPE_stg_to_dim_pais`
![Pipeline Dim Pais](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_pais.png)

<!-- Pipeline que compõe o WF_fact_loads -->

## Pipeline que compõe o  `WF_fact_loads` *(Construção da tabela fato)*

### Pipeline `PIPE_stg_to_fact_importacao`
![Pipeline Fact](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineFact/PIPE_stg_to_fact_importacao.png)

<!-- Configurações de pipelines e captura de logs -->

## Configuração da captura e armazenamento de logs

### Tratamento dos logs da camada de descoberta e extração de dados

### Pipeline `PIPE_log_raw`

![Pipeline Logs Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/PIPE_log_raw2.png)

![Config Logs Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/Config%20de%20captura%20de%20log%20RAW.png)

### Tratamento dos logs da camada de construção das tabelas dimensão e fato

### Pipeline `PIPE_log_dw`

![Pipeline Logs dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/PIPE_log_dw2.png)

![Config Logs dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/Config%20de%20captura%20de%20log%20DW.png)

