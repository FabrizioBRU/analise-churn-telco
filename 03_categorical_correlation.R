# -----------------------------------------------------------------------------
# Script: 03_categorical_correlation.R
# Objetivo: Medir associação entre variáveis categóricas e Churn (V de Cramer)
# Autor: Data Buddy Gem
# -----------------------------------------------------------------------------

# 1. Carregar bibliotecas
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rstatix, vcd, viridis)

# 2. Carregar Dados Limpos
churn <- read_rds("data/churn_clean.rds")

# 3. Selecionar apenas colunas categóricas (Fatores)
# Removemos CustomerID (identificador único não tem poder preditivo)
cat_vars <- churn %>%
  select(where(is.factor), -customer_id) %>%
  names()

# Removemos a própria variável alvo da lista de preditores para o loop
predictors <- setdiff(cat_vars, "churn")

# 4. Cálculo do V de Cramer (Loop Acadêmico)
# Vamos iterar sobre cada variável categórica e calcular a força da relação com Churn
results <- map_dfr(predictors, function(var) {
  
  # Tabela de contingência
  tabela <- table(churn[[var]], churn$churn)
  
  # Teste Qui-Quadrado
  chisq <- chisq.test(tabela)
  
  # V de Cramer (tamanho do efeito)
  cramer <- assocstats(tabela)$cramer
  
  tibble(
    Variavel = var,
    Chi_Square = chisq$statistic,
    P_Value = chisq$p.value,
    Cramers_V = cramer
  )
}) %>%
  arrange(desc(Cramers_V)) # Ordenar do mais forte para o mais fraco

# 5. Exibir Tabela de Resultados (Essencial para o Paper Acadêmico)
message("--- Força de Associação (V de Cramer) ---")
print(results)

# 6. Visualização: Heatmap de Associação
# Vamos plotar o V de Cramer para facilitar a leitura executiva
p <- results %>%
  ggplot(aes(x = reorder(Variavel, Cramers_V), y = Cramers_V)) +
  geom_col(fill = "#457B9D") +
  geom_text(aes(label = round(Cramers_V, 3)), hjust = -0.2, size = 3.5) +
  coord_flip() + # Barra horizontal para ler os nomes
  theme_minimal() +
  labs(
    title = "O que mais impacta o Churn?",
    subtitle = "Ranking de Associação Categórica (V de Cramer)",
    y = "Força da Associação (0 a 1)",
    x = "Variável"
  ) +
  scale_y_continuous(limits = c(0, 0.6)) # Ajuste de escala visual

# 7. Salvar
if(!dir.exists("output")) dir.create("output")
ggsave("output/03_cramers_v_ranking.png", plot = p, width = 8, height = 6)
message("Gráfico salvo em 'output/03_cramers_v_ranking.png'")

# 8. BÔNUS: Visualização Cruzada (Internet Service vs Churn)
# Como suspeitamos que o serviço de internet é chave, vamos detalhar ele
p2 <- churn %>%
  count(internet_service, churn) %>%
  group_by(internet_service) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = internet_service, y = prop, fill = churn)) +
  geom_col() +
  geom_text(aes(label = scales::percent(prop, accuracy = 1)), 
            position = position_stack(vjust = 0.5), color = "white") +
  scale_fill_manual(values = c("#1D3557", "#E63946")) +
  theme_minimal() +
  labs(
    title = "Taxa de Churn por Tipo de Internet",
    y = "Proporção",
    x = "Serviço de Internet"
  )

ggsave("output/03_internet_churn_detail.png", plot = p2, width = 8, height = 6)
message("Gráfico detalhado salvo em 'output/03_internet_churn_detail.png'")