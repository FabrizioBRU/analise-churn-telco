# -----------------------------------------------------------------------------
# Script: 02_financial_elasticity.R
# Objetivo: Analisar sensibilidade a preço (Ticket Médio vs Churn)
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggpubr, scales)

# 2. Carregar Dados Limpos
churn <- read_rds("data/churn_clean.rds")

# 3. Estatística Descritiva: Quem paga mais sai mais?
# Vamos calcular a média e mediana de MonthlyCharges por Churn
stats_price <- churn %>%
  group_by(churn) %>%
  summarise(
    media_mensal = mean(monthly_charges, na.rm = TRUE),
    mediana_mensal = median(monthly_charges, na.rm = TRUE),
    desvio_padrao = sd(monthly_charges, na.rm = TRUE),
    total_clientes = n()
  )

print("--- Estatísticas de Pagamento Mensal (USD) ---")
print(stats_price)

# 4. Teste de Hipótese (Teste t de Welch)
# H0 (Nula): Não há diferença no valor pago entre quem sai e quem fica.
# H1 (Alternativa): Existe diferença significativa.
teste_t <- t.test(monthly_charges ~ churn, data = churn)

print("--- Resultado do Teste de Hipótese ---")
print(teste_t)

# 5. Visualização: Boxplot com Teste Estatístico
# Paleta oficial
cores_projeto <- c("#1D3557", "#E63946") # Azul (No), Vermelho (Yes)

p <- ggplot(churn, aes(x = churn, y = monthly_charges, fill = churn)) +
  # Boxplot para ver a distribuição e outliers
  geom_boxplot(alpha = 0.7, outlier.shape = NA) + 
  # Jitter para ver a densidade de pontos reais atrás do boxplot
  geom_jitter(width = 0.2, alpha = 0.1, color = "black") +
  
  scale_fill_manual(values = cores_projeto) +
  theme_minimal() +
  
  labs(
    title = "Sensibilidade a Preço: Mensalidade x Churn",
    subtitle = paste("P-valor do teste T:", format.pval(teste_t$p.value)),
    x = "O cliente saiu? (Churn)",
    y = "Cobrança Mensal ($)",
    fill = "Churn"
  ) +
  theme(legend.position = "none")

# 6. Salvar
if(!dir.exists("output")) dir.create("output")
ggsave("output/02_price_sensitivity.png", plot = p, width = 8, height = 6)
message("Gráfico salvo em 'output/02_price_sensitivity.png'")