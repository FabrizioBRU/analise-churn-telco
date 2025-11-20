# -----------------------------------------------------------------------------
# Script: 04_logistic_regression.R
# Objetivo: Calcular Odds Ratios para identificar fatores de risco e proteção.
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, broom, scales)

# 2. Carregar Dados Limpos
churn <- read_rds("data/churn_clean.rds")

# 3. Preparação para Modelagem
# Removemos ID (inútil) e TotalCharges (altamente correlacionado com Tenure * Monthly)
# para evitar Multicolinearidade que distorce os coeficientes.
model_data <- churn %>% 
  select(-customer_id, -total_charges)

# 4. Ajuste do Modelo Logístico (Binomial)
# Churn ~ . significa "Churn em função de TODAS as outras variáveis"
modelo_logistico <- glm(churn ~ ., data = model_data, family = "binomial")

# 5. Extração dos Resultados (Tidy)
# exponentiate = TRUE transforma Log-Odds em Odds Ratio (mais fácil de ler)
resultados <- tidy(modelo_logistico, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>% # Remove o intercepto (não interpretável)
  filter(p.value < 0.05) %>%        # Filtra apenas o que é estatisticamente relevante
  arrange(desc(estimate))           # Ordena pelo impacto

# 6. Exibir Tabela no Console
message("--- Top Fatores de Risco (Odds Ratio > 1) ---")
print(resultados %>% filter(estimate > 1) %>% select(term, estimate, p.value))

message("--- Top Fatores de Proteção (Odds Ratio < 1) ---")
print(resultados %>% filter(estimate < 1) %>% select(term, estimate, p.value))

# 7. Visualização: Forest Plot
# Vamos limpar os nomes das variáveis para o gráfico ficar bonito
plot_data <- resultados %>%
  mutate(
    tipo_efeito = ifelse(estimate > 1, "Aumenta Risco", "Reduz Risco"),
    term = str_remove_all(term, "internet_service|contract|payment_method") # Limpeza de strings
  )

p <- ggplot(plot_data, aes(x = reorder(term, estimate), y = estimate, color = tipo_efeito)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") + # Linha de neutralidade
  coord_flip() +
  scale_color_manual(values = c("Aumenta Risco" = "#E63946", "Reduz Risco" = "#1D3557")) +
  scale_y_log10() + # Escala logarítmica para visualização correta de Odds Ratio
  theme_minimal() +
  labs(
    title = "Forest Plot: O que impulsiona o Churn?",
    subtitle = "Razão de Chances (Odds Ratio) com Intervalo de Confiança 95%",
    x = "Variável",
    y = "Odds Ratio (Escala Log)",
    color = "Impacto"
  )

# 8. Salvar
if(!dir.exists("output")) dir.create("output")
ggsave("output/04_odds_ratio_forest_plot.png", plot = p, width = 10, height = 7)
message("Gráfico salvo em 'output/04_odds_ratio_forest_plot.png'")