# 📊 Análise de Churn em Telecomunicações

Este projeto aplica técnicas avançadas de **Data Science** e **Estatística** para analisar o comportamento de rotatividade (Churn) em uma base de dados de telecomunicações. O objetivo é identificar os perfis de risco e propor estratégias de retenção baseadas em dados.

> **Contexto:** Trabalho final da disciplina de *Data Analysis and Visualization*.

## 🎯 Objetivos da Análise
1.  **Diagnóstico Temporal:** Entender *quando* o cliente sai (Análise de Sobrevivência).
2.  **Fatores de Risco:** Identificar quais produtos e contratos aceleram o cancelamento.
3.  **Elasticidade:** Validar se o churn é motivado por preço ou percepção de valor.

## 🗂️ Estrutura do Projeto

O projeto foi organizado de forma modular para garantir reprodutibilidade:

* **`data/`**: Contém o dataset bruto (`.csv`) e o processado (`.rds`).
* **`output/`**: Gráficos gerados pelas análises (curvas de sobrevivência, forest plots, etc.).
* **`scripts/`**:
    * `00_etl_cleaning.R`: Limpeza de dados, tratamento de nulos e engenharia de features.
    * `01_survival_analysis.R`: Curvas Kaplan-Meier (Sobrevivência do cliente).
    * `02_financial_elasticity.R`: Testes de hipótese sobre sensibilidade a preço.
    * `03_categorical_correlation.R`: Ranking de impacto das variáveis (V de Cramer).
    * `04_logistic_regression.R`: Modelagem preditiva de risco (Odds Ratio).
    * `05_cox_regression.R`: Análise de risco instantâneo (Hazard Ratios) e validação de premissas.

## 🔍 Principais Resultados

### 1. O "Momento Crítico"
A análise de sobrevivência revelou que clientes com **contratos mensais** têm uma vida mediana de apenas **35 meses**, com risco acentuado no primeiro ano. Contratos de 1 e 2 anos funcionam como blindagem efetiva.

### 2. O Paradoxo do Preço
Contrariando o senso comum, o *churn* é maior entre clientes de alto valor.
* **Ticket Médio (Churn):** $74.44
* **Ticket Médio (Retido):** $61.26
* *Conclusão:* Estamos perdendo clientes Premium, indicando falha na entrega de valor em produtos caros (como Fibra Ótica).

### 3. Vilões e Heróis (Modelagem Cox)
* 🔴 **Aceleradores de Churn:** Fibra Ótica (Risco 2x maior) e Streaming.
* 🔵 **Retentores (Lock-in):** Suporte Técnico e Segurança Online reduzem drasticamente o risco de saída.

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** R (4.x)
* **IDE:** RStudio
* **Bibliotecas:** `tidyverse`, `survival`, `survminer`, `broom`, `vcd`.

## 🚀 Como Reproduzir

1.  Clone este repositório:
    ```bash
    git clone [https://github.com/SEU-USUARIO/analise-de-churn-telco.git](https://github.com/SEU-USUARIO/analise-de-churn-telco.git)
    ```
2.  Abra o projeto `analise-de-churn-telco.Rproj` no RStudio.
3.  Execute os scripts na ordem numérica (00 -> 05).

---
**Autores:** Fabrizio Bruzetti, Bruna Tadeu, Bruno Kenjo, Maria Clara Farias e Tercia Sarmento e Sá
