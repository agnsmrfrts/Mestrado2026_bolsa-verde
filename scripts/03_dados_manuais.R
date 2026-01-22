# ==============================================================================
# SCRIPT 03: DADOS DE CONTEXTO E COBERTURA (MANUAIS)
# ==============================================================================

pacman::p_load(tidyverse, here)

# 1. Dados de Desmatamento e Gini (Fase 1)
dados_contexto_fase1 <- data.frame(
  ano = c(2011, 2012, 2013, 2014, 2015, 2016),
  desmatamento = c(6418, 4571, 5891, 5012, 6207, 7893),
  gini = c(0.543, 0.540, 0.532, 0.526, 0.524, 0.537)
)

# 2. Dados de Desmatamento (Fase 2 - Retomada)
dados_contexto_fase2 <- data.frame(
  ano = c(2022, 2023, 2024),
  taxa = c(11594, 9064, 6288)
)

# 3. Dados Detalhados de Cobertura (Famílias)
dados_evolucao_familias <- data.frame(
  data = as.Date(c("2012-08-01", "2012-10-01", "2012-11-01", "2013-02-01", 
                   "2013-03-01", "2014-01-01", "2015-01-01", "2023-09-01", 
                   "2023-12-01", "2024-03-01", "2024-06-01", "2024-09-01", 
                   "2024-12-01", "2025-03-01", "2025-06-01", "2025-09-01", 
                   "2025-12-01")),
  familias = c(28919, 30590, 31412, 36384, 36844, 51498, 71759, 
               6242, 22805, 28505, 36187, 40482, 49798, 57521, 62305, 69378, 71811),
  fase = c(rep("Fase 1 (2011-2015)", 7), rep("Fase 2 (2023-2025)", 10))
)

# --- SALVAR ---
if(!dir.exists(here("data", "output"))) dir.create(here("data", "output"), recursive = TRUE)

saveRDS(dados_contexto_fase1, here("data", "output", "dados_contexto_fase1.rds"))
saveRDS(dados_contexto_fase2, here("data", "output", "dados_contexto_fase2.rds"))
saveRDS(dados_evolucao_familias, here("data", "output", "dados_evolucao_familias.rds"))

message("Sucesso! Dados manuais salvos em 'data/output'.")