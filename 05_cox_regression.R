# -----------------------------------------------------------------------------
# Script: 05_cox_regression.R
# Objetivo: Modelar o Risco Instantâneo (Hazard Ratio) e validar premissas.
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, survival, survminer, broom)

# 2. Carregar Dados Limpos
churn <- read_rds("data/churn_clean.rds")

# 3. Preparação dos Dados
# Cox precisa de numéricos para o status (1=Event, 0=Censored)
churn_model <- churn %>%
  mutate(status_num = ifelse(churn == "Yes", 1, 0)) %>%
  select(-customer_id, -total_charges, -churn) # Remove colunas não usadas no fit

# 4. Ajuste do Modelo de Cox (Todas as variáveis)
# Surv(tempo, status) cria a variável resposta de sobrevivência
modelo_cox <- coxph(Surv(tenure, status_num) ~ ., data = churn_model)

# 5. Resultados (Hazard Ratios)
message("--- Principais Fatores de Risco (Hazard Ratio) ---")
# Tidy transforma o modelo em tabela legível
resultados_cox <- tidy(modelo_cox, exponentiate = TRUE, conf.int = TRUE) %>%
  filter(p.value < 0.05) %>% # Apenas estatisticamente significantes
  arrange(desc(estimate))

print(head(resultados_cox, 10))

# 6. Validação de Premissas (Teste de Resíduos de Schoenfeld)
# Acadêmico: Verifica se o risco é constante ao longo do tempo (Proportional Hazards)
# Se p < 0.05, a premissa foi violada (o risco muda com o tempo).
teste_ph <- cox.zph(modelo_cox)
message("--- Teste de Riscos Proporcionais (Schoenfeld) ---")
print(teste_ph)

# Nota: Se o teste Global for significativo, academicamente reportamos que 
# "a premissa de riscos proporcionais não foi perfeitamente atendida", 
# o que é comum em grandes datasets reais.

# 7. Visualização Profissional: Forest Plot
# Esse gráfico resume todo o modelo em uma imagem
p <- ggforest(modelo_cox, data = churn_model, 
              main = "Hazard Ratios: O que acelera o Churn?",
              cpositions = c(0.02, 0.22, 0.4), # Posição das colunas de texto
              fontsize = 0.8, 
              refLabel = "Ref")

# O ggforest é complexo de salvar com ggsave, vamos usar print
print(p)

# Para salvar (truque para ggforest que é base graphics):
png("output/05_cox_forest_plot.png", width = 1200, height = 800, res = 100)
print(p)
dev.off()
message("Gráfico salvo em 'output/05_cox_forest_plot.png'")

# --- CORREÇÃO PARA O GRÁFICO (FOREST PLOT MANUAL) ---

# 7. Visualização Profissional: Forest Plot (Via ggplot2)
# Reutilizamos o objeto 'resultados_cox' que já calculamos no passo 5
plot_data <- resultados_cox %>%
  filter(term != "(Intercept)") %>%
  # Limpeza visual dos nomes para o gráfico ficar bonito
  mutate(
    term = str_remove_all(term, "internet_service|contract|payment_method"),
    tipo = ifelse(estimate > 1, "Aumenta Risco", "Reduz Risco")
  ) %>%
  # Pegar apenas os Top 20 fatores para o gráfico não ficar poluido
  slice_max(order_by = abs(log(estimate)), n = 20)

p <- ggplot(plot_data, aes(x = reorder(term, estimate), y = estimate, color = tipo)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  coord_flip() +
  scale_color_manual(values = c("Aumenta Risco" = "#E63946", "Reduz Risco" = "#1D3557")) +
  scale_y_log10() + # Escala Log é obrigatória para Hazard Ratios
  labs(
    title = "Modelo de Cox: Velocidade do Churn (Hazard Ratios)",
    subtitle = "HR > 1: Sai mais rápido | HR < 1: Fica mais tempo",
    x = "Fator",
    y = "Hazard Ratio (Escala Log)",
    color = "Impacto"
  ) +
  theme_minimal()

# Salvar
ggsave("output/05_cox_forest_plot_fixed.png", plot = p, width = 10, height = 7)
message("Gráfico corrigido salvo em 'output/05_cox_forest_plot_fixed.png'")