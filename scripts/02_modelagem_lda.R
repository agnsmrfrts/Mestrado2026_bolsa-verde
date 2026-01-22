# ==============================================================================
# SCRIPT 02: MODELAGEM DE TÓPICOS (LDA)
# ==============================================================================

pacman::p_load(tidyverse, tidytext, topicmodels, tm, here)

arquivo_tokens <- here("data", "output", "tokens_limpos.rds")

if(file.exists(arquivo_tokens)) {
  
  message("Carregando tokens e iniciando modelagem LDA...")
  tokens_limpos <- readRDS(arquivo_tokens)
  
  # Criar Document-Term Matrix
  dtm <- tokens_limpos %>% count(document, word) %>% cast_dtm(document, word, n)
  
  # Rodar o Modelo (Isso pode demorar um pouco dependendo do tamanho do corpus)
  lda_model <- LDA(dtm, k = 4, method = "Gibbs", control = list(seed = 1234))
  
  # Extrair Gamma (Probabilidade do tópico por ano)
  dados_gamma_anuais <- tidy(lda_model, matrix = "gamma") %>%
    mutate(ano = as.numeric(str_extract(document, "\\d{4}")),
           topico_nome = nomes_topicos[as.character(topic)]) %>%
    filter(!is.na(ano)) %>%
    group_by(ano, topico_nome) %>%
    summarise(media_gamma = mean(gamma), .groups = "drop")
  
  # --- SALVAR ---
  # Salva os dados para o gráfico temporal
  saveRDS(dados_gamma_anuais, here("data", "output", "dados_gamma_lda.rds"))
  
  # NOVO: Salva o modelo matemático completo (necessário para a validação teórica)
  saveRDS(lda_model, here("data", "output", "modelo_lda_completo.rds"))
  
  message("Sucesso! 'dados_gamma_lda.rds' e 'modelo_lda_completo.rds' salvos.")
  
} else {
  message("ERRO: Execute o Script 01 primeiro para gerar os tokens.")
}