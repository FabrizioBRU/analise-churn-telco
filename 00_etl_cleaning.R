# -----------------------------------------------------------------------------
# Script: 00_etl_cleaning.R
# Objetivo: Carregar dados brutos, tratar nulos e tipagem, salvar dataset limpo.
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, janitor)

# 2. Carregar Dados Brutos
# O arquivo DEVE estar na pasta 'data' do projeto
caminho_arquivo <- "data/WA_Fn-UseC_-Telco-Customer-Churn.csv"

if (file.exists(caminho_arquivo)) {
  message("Arquivo encontrado. Iniciando leitura...")
  raw_data <- read_csv(caminho_arquivo, show_col_types = FALSE)
} else {
  stop("ERRO CRÍTICO: O arquivo não está na pasta 'data/'. Verifique o passo 1 da minha resposta.")
}

# 3. Limpeza e Transformação
churn <- raw_data %>%
  # Padronizar nomes das colunas (ex: 'SeniorCitizen' vira 'senior_citizen')
  janitor::clean_names() %>%
  
  # Tratamento da coluna TotalCharges (Texto -> Numérico)
  # Isso vai gerar NAs onde houver espaço em branco, o que é esperado
  mutate(total_charges = as.numeric(total_charges)) %>%
  
  # Regra de Negócio: Se tenure (tempo de casa) é 0, a cobrança total deve ser 0
  # Substituímos os NAs gerados acima por 0
  mutate(total_charges = replace_na(total_charges, 0)) %>%
  
  # Transformar a variável alvo e outras strings em Fatores
  mutate(
    churn = factor(churn, levels = c("No", "Yes")),
    across(where(is.character), as.factor),
    # Senior Citizen é categórico, não numérico
    senior_citizen = as.factor(ifelse(senior_citizen == 1, "Yes", "No"))
  )

# 4. Validação Rápida (Check de Sanidade)
message("--- Resumo dos Dados Limpos ---")
glimpse(churn)

# Verificar se ainda restam Nulos
nulos <- sum(is.na(churn))
if(nulos == 0) {
  message("SUCESSO: Nenhum valor nulo encontrado após o tratamento.")
} else {
  warning(paste("ALERTA: Ainda existem", nulos, "valores nulos."))
}

# 5. Salvar o arquivo limpo (RDS mantém a tipagem dos fatores)
# Vamos usar este arquivo .rds nos próximos scripts
write_rds(churn, "data/churn_clean.rds")
message("Arquivo 'data/churn_clean.rds' salvo com sucesso!")