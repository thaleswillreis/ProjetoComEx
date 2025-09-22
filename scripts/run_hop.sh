#!/bin/bash
# Carrega variáveis do .env para o ambiente
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Caminho do pipeline (passado como argumento)
PIPELINE=$1

if [ -z "$PIPELINE" ]; then
  echo "Uso: ./scripts/run_hop.sh <caminho_do_pipeline.hpl>"
  exit 1
fi

# Executa o pipeline com as variáveis carregadas
hop-run.sh \
  --file="$PIPELINE"

