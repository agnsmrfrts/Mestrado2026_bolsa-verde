# ==============================================================================
# SCRIPT 01: PREPARAÇÃO DO CORPUS E METADADOS
# ==============================================================================

if(!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, stringr, tidytext, tm, here)

# Criar pasta para salvar dados processados (se não existir)
if(!dir.exists(here("data", "output"))) dir.create(here("data", "output"), recursive = TRUE)

caminho_dados <- here("data", "txt")

if(dir.exists(caminho_dados)) {
  message("Iniciando leitura e classificação detalhada dos arquivos...")
  
  arquivos <- list.files(caminho_dados, pattern = "\\.txt$", full.names = FALSE)
  arquivos_full <- list.files(caminho_dados, full.names = TRUE)
  
  # --- ETAPA A: Metadados Detalhados (Sua Lógica) ---
  dados_metadata <- tibble(Arquivo_Original = arquivos) %>%
    mutate(
      # 1. Extração do Ano
      Ano = as.numeric(str_extract(Arquivo_Original, "^\\d{4}")),
      
      # 2. Definição do Status (Revogada vs Em Vigor)
      Status = case_when(
        str_detect(str_to_lower(Arquivo_Original), "revogada") ~ "Revogada",
        str_detect(str_to_lower(Arquivo_Original), "relatorio|monitoramento|resultado") ~ "---",
        TRUE ~ "Em Vigor"
      ),
      
      # 3. Limpeza do Nome
      Nome_Documento = Arquivo_Original %>%
        str_remove(".txt") %>%
        str_remove("^\\d{4}") %>%
        str_remove_all("(?i)revogada") %>%
        str_replace_all("_", " ") %>%
        str_squish(),
      
      # 4. Classificação na Matriz de Smith
      Funcao_Matriz = case_when(
        str_detect(Arquivo_Original, "Lei|Decreto") ~ "Política Idealizada (Normativo)",
        str_detect(Arquivo_Original, "Portaria.*Comit|Portaria.*494|Portaria.*138|Portaria.*371|Portaria.*362|Portaria.*824|Portaria.*1288") ~ "Org. Implementadora (Governança)",
        str_detect(Arquivo_Original, "Portaria") ~ "Gestão Administrativa",
        str_detect(Arquivo_Original, "Resolucao") ~ "Execução (Operacional)",
        str_detect(Arquivo_Original, "Relatorio|Monitoramento|Plano") ~ "Monitoramento (Técnico)",
        str_detect(Arquivo_Original, "Informativo|Publicacao") ~ "Comunicação/Legitimação",
        TRUE ~ "Outros"
      ),
      
      # 5. Fases da Política
      Fase = case_when(
        Ano < 2011 ~ "Antecedentes (Contexto)",
        Ano >= 2011 & Ano <= 2016 ~ "Fase 1: Implementação (2011-2016)",
        Ano >= 2017 & Ano <= 2022 ~ "Período de Desarticulação (2017-2022)",
        Ano >= 2023 ~ "Fase 2: Retomada (2023-Presente)",
        TRUE ~ "Outros"
      )
    )
  
  # --- ETAPA B: Limpeza do Texto (Para LDA) ---
  ler_limpar <- function(caminho) {
    texto <- readLines(caminho, warn = FALSE, encoding = "UTF-8")
    texto <- paste(texto, collapse = " ")
    texto <- iconv(texto, from = "UTF-8", to = "UTF-8", sub = "") 
    return(texto)
  }
  
  dados_brutos <- tibble(
    document = basename(arquivos_full),
    text = sapply(arquivos_full, ler_limpar)
  ) %>% filter(nchar(text) > 50) 
  
  palavras_proibidas <- c(stopwords("portuguese"), "fl", "fls", "pag", "art", "artigo", 
                          "bolsa", "verde", "programa", "bolsa_verde", "lei", "decreto")
  
  tokens_limpos <- dados_brutos %>%
    mutate(text = tolower(text)) %>%
    mutate(text = str_replace_all(text, "meio ambiente", "meio_ambiente")) %>%
    mutate(text = str_replace_all(text, "bolsa verde", "bolsa_verde")) %>% 
    mutate(text = str_replace_all(text, "famílias", "família")) %>%
    unnest_tokens(word, text) %>%
    filter(!str_detect(word, "[0-9]")) %>%
    filter(!word %in% palavras_proibidas) %>%
    filter(nchar(word) > 2)
  
  # --- SALVAR ---
  saveRDS(dados_metadata, here("data", "output", "dados_metadata.rds"))
  saveRDS(tokens_limpos, here("data", "output", "tokens_limpos.rds"))
  
  message("Sucesso! 'dados_metadata.rds' (com status e fases) e 'tokens_limpos.rds' salvos.")
  
} else {
  message("ERRO: Pasta 'data/txt' não encontrada.")
}