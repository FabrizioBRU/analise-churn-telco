# -----------------------------------------------------------------------------
# Script: 01_survival_analysis.R
# Objetivo: Determinar o risco de Churn ao longo do tempo (Curvas Kaplan-Meier)
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, survival, survminer)

# 2. Carregar Dados Limpos (Aqui está a vantagem do RDS!)
churn <- read_rds("data/churn_clean.rds")

# 3. Preparação do Objeto de Sobrevivência
# O R precisa de dois vetores: Tempo (tenure) e Status (Churn aconteceu?)
# A função Surv() cria esse par. Churn "Yes" vira 1 (evento), "No" vira 0 (censura).
churn_surv <- churn %>%
  mutate(status_num = ifelse(churn == "Yes", 1, 0))

surv_object <- Surv(time = churn_surv$tenure, event = churn_surv$status_num)

# 4. Modelagem: Curva Geral
fit_geral <- survfit(surv_object ~ 1, data = churn_surv)

# 5. Modelagem Estratificada: Por Tipo de Contrato
# Hipótese: Contratos longos protegem o churn?
fit_contract <- survfit(surv_object ~ contract, data = churn_surv)

# 6. Visualização: O Gráfico da "Queda"
# Paleta oficial do projeto
cores_projeto <- c("#E63946", "#1D3557", "#457B9D") 

ggsurvplot(
  fit_contract,
  data = churn_surv,
  size = 1,                 # Espessura da linha
  palette = cores_projeto,  # Cores personalizadas
  conf.int = TRUE,          # Intervalo de confiança (sombra)
  pval = TRUE,              # Teste Log-Rank (diferença estatística)
  risk.table = TRUE,        # Tabela de risco abaixo do gráfico
  risk.table.col = "strata",
  legend.labs = c("Month-to-month", "One year", "Two year"),
  risk.table.height = 0.25,
  ggtheme = theme_minimal(),
  title = "Curva de Sobrevivência Kaplan-Meier por Contrato",
  xlab = "Tempo de Permanência (Meses)",
  ylab = "Probabilidade de Retenção"
)

# 7. Insights Matemáticos (Mediana de Sobrevivência)
message("--- Mediana de Vida Útil por Contrato ---")
print(surv_median(fit_contract))

# 8. Salvar Gráfico (Opcional - cria pasta output se não existir)
if(!dir.exists("output")) dir.create("output")
ggsave("output/01_survival_curve.png", width = 10, height = 6)
message("Gráfico salvo em 'output/01_survival_curve.png'")