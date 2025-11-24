# Image Gallery - ComEx Project

## `Workflow Master` (orchestrator) at Apache Hop
![Workflow Master](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_COMEX_Master.png)

<!-- Workflows that make up the Workflow Master -->
## Workflows que compõem o `Workflow Master`

### Workflow `WF_Stage_Create_Tables`
![Workflow Stage](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_Stage_Create_Tables.png)

### Workflow `WF_dim_loads`
![Workflow Dim](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/%20WF_dim_loads.png)

### Workflow `WF_fact_loads`
![Workflow Fact](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Workflows/WF_fact_loads.png)

<!-- Pipelines that make up WF_Stage_Create_Tables -->

## Pipelines that make up `WF_Stage_Create_Tables` *(Data discovery and extraction)*

### Pipeline `PIPE_raw_carriers_comex`
![Pipeline Raw Carrier](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_carriers_comex.png)

### Pipeline `PIPE_raw_excecoes_comex`
![Pipeline Raw Excecoes](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_excecoes_comex.png)

### Pipeline `PIPE_raw_geodados_flags`
![Pipeline Raw Geodados](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_geodados_flags.png)

### Pipeline `PIPE_raw_historico_importacao`
![Pipeline Raw Hist](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineRaw/PIPE_raw_historico_importacao.png)

<!-- Pipelines that make up WF_dim_loads -->

## Pipelines that make up `WF_dim_loads` *(Building dimension tables)*

### Pipeline `PIPE_stg_to_dim_carrier`
![Pipeline Dim Carrier](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_carrier.png)

### Pipeline `PIPE_stg_to_dim_excecao`
![Pipeline Dim Excecao](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_excecao.png)

### Pipeline `PIPE_stg_to_dim_incoterm`
![Pipeline Dim Incoterm](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_incoterm.png)

### Pipeline `PIPE_stg_to_dim_pais`
![Pipeline Dim Pais](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineDim/PIPE_stg_to_dim_pais.png)

<!-- Pipeline that makes up WF_fact_loads -->

## Pipeline that makes up `WF_fact_loads` *(Building fact table)*

### Pipeline `PIPE_stg_to_fact_importacao`
![Pipeline Fact](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/PipelineFact/PIPE_stg_to_fact_importacao.png)

<!-- Pipelines and log capture configurations -->

## Log Capture and Storage Configuration

### Handling logs from the discovery and data extraction layer

### Pipeline `PIPE_log_raw`

![Pipeline Logs Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/PIPE_log_raw2.png)

![Config Logs Raw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/Config%20de%20captura%20de%20log%20RAW.png)

### Handling logs from the dimension and fact table construction layer

### Pipeline `PIPE_log_dw`

![Pipeline Logs dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/PIPE_log_dw2.png)

![Config Logs dw](https://raw.githubusercontent.com/thaleswillreis/ProjetoComEx/main/doc/images/Log/Config%20de%20captura%20de%20log%20DW.png)



