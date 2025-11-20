# --- CORREÇÃO DO SALVAMENTO DO GRÁFICO ---

# Armazene o gráfico no objeto 'p'
p <- ggsurvplot(
  fit_contract,
  data = churn_surv,
  size = 1,
  palette = cores_projeto,
  conf.int = TRUE,
  pval = TRUE,
  risk.table = TRUE,        # Tabela de risco ativada
  risk.table.col = "strata",
  legend.labs = c("Mensal", "1 Ano", "2 Anos"), # Traduzido para o PT
  risk.table.height = 0.25,
  ggtheme = theme_minimal(),
  title = "Curva de Sobrevivência: Quando o cliente sai?",
  xlab = "Tempo (Meses)",
  ylab = "Probabilidade de Retenção"
)

# Método de salvamento robusto (abre o dispositivo PNG, imprime, fecha)
png("output/01_survival_curve.png", width = 1000, height = 700, res = 100)
print(p)
dev.off() # Fecha o arquivo e salva

message("Gráfico corrigido e salvo em 'output/01_survival_curve.png'")