# ==============================================================================
# SCRIPT 04: GERAÇÃO DE FIGURAS E VISUALIZAÇÃO
# ==============================================================================

pacman::p_load(tidyverse, gt, scales, patchwork, here)

# 1. Carregar Dados Processados
dados_metadata   <- readRDS(here("data", "output", "dados_metadata.rds"))
dados_gamma      <- readRDS(here("data", "output", "dados_gamma_lda.rds"))
ctx_fase1        <- readRDS(here("data", "output", "dados_contexto_fase1.rds"))
ctx_fase2        <- readRDS(here("data", "output", "dados_contexto_fase2.rds"))
dados_familias   <- readRDS(here("data", "output", "dados_evolucao_familias.rds"))

# 2. Definir Tema Gráfico
tema_pb <- theme_minimal() +
  theme(
    text = element_text(family = "serif", color = "black", size = 12),
    plot.title = element_text(face = "bold", size = 14, color = "black"),
    axis.text = element_text(color = "black"),
    axis.title = element_text(face = "bold", color = "black"),
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "grey90")
  )

# ------------------------------------------------------------------------------
# FIGURA 1: TABELA CORPUS (Design Acadêmico com GT)
# ------------------------------------------------------------------------------
tabela_visual <- dados_metadata %>%
  select(Fase, Ano, Funcao_Matriz, Nome_Documento, Status) %>%
  arrange(Ano) %>% 
  group_by(Fase) %>%
  gt() %>%
  
  # Cabeçalho
  tab_header(
    title = md("**Corpus Documental do Programa Bolsa Verde**"),
    subtitle = "Trajetória normativa e institucional analisada através da Matriz de Smith"
  ) %>%
  
  # Renomear Colunas
  cols_label(
    Ano = "Ano",
    Funcao_Matriz = "Função",
    Nome_Documento = "Documento Analisado",
    Status = "Situação Legal"
  ) %>%
  
  # Alinhamento
  cols_align(align = "center", columns = c("Ano", "Status")) %>%
  cols_align(align = "left", columns = c("Funcao_Matriz", "Nome_Documento")) %>%
  
  # Estilização do Status
  tab_style(
    style = list(cell_text(color = "red", weight = "bold")),
    locations = cells_body(columns = Status, rows = Status == "Revogada")
  ) %>%
  tab_style(
    style = list(cell_text(color = "darkgreen", weight = "bold")),
    locations = cells_body(columns = Status, rows = Status == "Em Vigor")
  ) %>%
  
  # Design Geral
  tab_options(
    heading.background.color = "#8FBC8F",
    row_group.background.color = "#E0E0E0",
    table.font.size = 12,
    data_row.padding = px(6)
  ) %>%
  
  # Fonte
  tab_source_note(
    source_note = "Fonte: Elaboração própria a partir de dados do MMA e Diário Oficial da União."
  )

# Salvar
gtsave(tabela_visual, here("figures", "Quadro_Corpus_Revisado.png"))
# Se quiser em Word também, descomente a linha abaixo:
# gtsave(tabela_visual, here("figures", "Quadro_Corpus_Revisado.docx"))

# ------------------------------------------------------------------------------
# FIGURA 2: EVOLUÇÃO TEMPORAL (LDA)
# ------------------------------------------------------------------------------
fig2 <- ggplot(dados_gamma, aes(x = ano, y = media_gamma)) +
  
  # CORREÇÃO AQUI: Adicionei 'ggplot2::' antes de annotate
  ggplot2::annotate("rect", xmin = 2016, xmax = 2022, ymin = -Inf, ymax = Inf, 
                    alpha = 0.15, fill = "black") +
  
  geom_line(color = "black", size = 0.8) +
  geom_point(color = "black", size = 2.5) +
  facet_wrap(~topico_nome, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = c(2011, 2016, 2022, 2025)) +
  labs(title = "Evolução Temporal das Dimensões Latentes", y = "Intensidade (Gamma)", x = "Ano") +
  theme_bw() +
  theme(text = element_text(family = "serif", color = "black"), 
        strip.background = element_rect(fill = "grey90"))

ggsave(here("figures", "Figura2_Evolucao_LDA.png"), plot = fig2, width = 10, height = 8)
# ------------------------------------------------------------------------------
# FIGURA 3: CONTEXTO (Desmatamento e Social)
# ------------------------------------------------------------------------------
# 3A. Desmatamento Fase 1
g_desmat <- ggplot(ctx_fase1, aes(x = ano, y = desmatamento)) +
  geom_col(fill = "grey40", width = 0.7) + 
  geom_line(aes(group = 1), color = "black", size = 1, linetype = "dashed") +
  geom_point(size = 3, color = "black") +
  geom_label(aes(label = desmatamento), vjust = -0.3, fontface = "bold", fill = "white", label.size = 0, size = 3.5) +
  scale_y_continuous(limits = c(0, 9000)) + 
  labs(title = "Pressão Ambiental Externa (Fase 1)", subtitle = "Desmatamento na Amazônia Legal (km²)", x = "Ano", y = "km²", caption = "Fonte: PRODES/INPE.") +
  tema_pb

ggsave(here("figures", "Contexto_Desmatamento_Fase1.png"), plot = g_desmat, width = 7, height = 5)

# ------------------------------------------------------------------------------
# FIGURA 3B: RETOMADA FASE 2 (CORRIGIDO)
# ------------------------------------------------------------------------------
g_retomada <- ggplot(ctx_fase2, aes(x = as.factor(ano), y = taxa)) +
  geom_col(fill = "grey40", width = 0.6) +
  geom_line(aes(group = 1), color = "black", linewidth = 1.2) +
  geom_point(size = 4, color = "black") +
  geom_label(aes(label = number(taxa, big.mark = ".", suffix = " km²")), 
             vjust = -0.4, fontface = "bold", size = 4, fill = "white", label.size = 0) +
  
  # CORREÇÃO AQUI: ggplot2::annotate
  ggplot2::annotate("text", x = 3, y = 8000, label = "-30,6%\n(Queda Histórica)", 
                    color = "black", fontface = "bold", size = 3.5) +
  
  labs(title = "Contexto da Retomada (2023-2024)", 
       subtitle = "Queda do Desmatamento durante reestruturação", 
       x = "Ano", y = "km²", caption = "Fonte: PRODES/INPE (2024).") +
  tema_pb + 
  theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank())

ggsave(here("figures", "Contexto_Retomada_Fase2.png"), plot = g_retomada, width = 8, height = 5)

# ------------------------------------------------------------------------------
# FIGURA 4: TRAJETÓRIA DETALHADA (CORRIGIDO)
# ------------------------------------------------------------------------------
# Já apliquei a correção aqui também para evitar o próximo erro
g_evolucao <- ggplot(dados_familias, aes(x = data, y = familias, color = fase, group = fase)) +
  
  # CORREÇÃO 1: ggplot2::annotate (Retângulo de Sombra)
  ggplot2::annotate("rect", xmin = as.Date("2016-01-01"), xmax = as.Date("2022-12-31"), 
                    ymin = 0, ymax = 85000, alpha = 0.2, fill = "grey80") +
  
  geom_line(linewidth = 1.2) + geom_point(size = 3) +
  scale_color_manual(values = c("Fase 1 (2011-2015)" = "#555555", "Fase 2 (2023-2025)" = "#004C8C")) +
  
  # CORREÇÃO 2: ggplot2::annotate (Texto explicativo)
  ggplot2::annotate("text", x = as.Date("2019-06-01"), y = 40000, 
                    label = "Hiato da Política\n(2016-2022)", 
                    color = "black", fontface = "bold", size = 4) +
  
  geom_label(data = dados_familias %>% group_by(fase) %>% filter(data == min(data) | data == max(data)), 
             aes(label = format(familias, big.mark = ".", scientific = FALSE)), 
             vjust = -0.4, fontface = "bold", size = 3.5, color = "black", fill = "white", label.size = 0, show.legend = FALSE) +
  scale_y_continuous(limits = c(0, 85000), labels = function(x) format(x, big.mark = ".", scientific = FALSE)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(title = "Trajetória de Cobertura do Programa Bolsa Verde", subtitle = "Evolução detalhada e período de descontinuidade", x = "Ano", y = "Número de Famílias", color = "Ciclo da Política", caption = "Fonte: Relatórios de Gestão.") +
  tema_pb

ggsave(here("figures", "Figura4_Trajetoria_Detalhada.png"), plot = g_evolucao, width = 10, height = 6)

message("Tudo pronto! Todas as figuras foram geradas na pasta 'figures'.")


# ==============================================================================
# TABELA METODOLÓGICA: DICIONÁRIO DE VARIÁVEIS (SMITH + LDA)
# ==============================================================================

# Carrega pacotes extras para tabela em Word
pacman::p_load(flextable, officer, dplyr)

# 1. Definição dos Dados
tabela_smith <- tibble::tribble(
  ~`Dimensão Teórica`, ~`Definição Operacional`, ~`Principais Termos e Radicais`,
  
  # 1. Política Idealizada 
  "1. Política Idealizada", 
  "Refere-se à estrutura formal, normativa e aos objetivos abstratos do programa. Engloba o 'dever-ser', a base jurídica e os valores fundamentais prometidos pela política.",
  "lei, decreto, norma*, regulament*, legisla*, preserva*, conserva*, sustenta*, biodiversidade, florest*, criterio*, condicional*, elegib*, diretriz*, estrateg*, cidadania, desenvolvimento, protecao, inclusao, direitos humanos, assistencia tecnica, foment*, capacita*, transferencia, social, meioambiente, ambiental, brasil, uso_sustentavel",
  
  # 2. Org. Implementadora 
  "2. Org. Implementadora", 
  "Refere-se à burocracia estatal responsável pela execução. Inclui os órgãos, os processos gerenciais, os instrumentos de controle técnico e a execução orçamentária.",
  "ministerio, mma, icmbio, incra, comite gestor, orgao*, coorden*, planej*, gesta*, gestor*, implement*, execu*, servidor*, agente*, equipe, capacidade operacional, monitor*, fiscaliz*, vistori*, avali*, diagnostico, satelite, georreferenc*, sistema, base_de_dados, orcamento, recurso*, pagamento, financeir*, indicador*, mapa*, anobase, uts, metas, relatorio",
  
  # 3. Grupo-Alvo 
  "3. Grupo-Alvo", 
  "Refere-se aos sujeitos da política, definidos por sua identidade cultural, condição socioeconômica ou localização. Inclui também a reação ou comportamento esperado (adesão).",
  "beneficiari*, familia*, populacao, povo*, comunidade*, tradicion*, indigena*, quilombola*, ribeirinh*, extrativist*, agricultor*, assentado*, cooperativa, lideranca, associac*, pobreza, extrema, vulnerab*, renda, cadunico, adesao, compromisso, ativo ambiental, assentamento*, produtor*, producao, atividades",
  
  # 4. Fatores Ambientais 
  "4. Fatores Ambientais", 
  "Refere-se ao contexto externo e às tensões que pressionam a política, mas não estão sob controle direto da burocracia. Inclui crises, geografia e conflitos.",
  "crise, cenario, contingencia*, ajuste fiscal, economia, mudanca (do) clima*, clima*, rio+20, paradigma, amazonia, bioma, norte, territori*, isolamento, logistica, pressao, conflito, desmat*, invasa*, grilagem, plantacao, agricola, queimad*, lixo"
)

# 2. Formatação Visual (Flextable)
minha_tabela <- flextable(tabela_smith) %>%
  width(j = 1, width = 3.5, unit = "cm") %>% 
  width(j = 2, width = 5.5, unit = "cm") %>% 
  width(j = 3, width = 7.0, unit = "cm") %>% 
  
  font(fontname = "Times New Roman", part = "all") %>%
  fontsize(size = 11, part = "all") %>%
  
  bg(part = "header", bg = "#E5E5E5") %>% 
  color(part = "header", color = "black") %>%
  bold(part = "header") %>%
  align(align = "center", part = "header") %>%
  
  align(align = "left", part = "body") %>%
  valign(valign = "top", part = "body") %>% 
  
  # Destaques das Categorias
  color(i = 1, j = 1, color = "#333333") %>% bold(i = 1, j = 1) %>% 
  color(i = 2, j = 1, color = "#333333") %>% bold(i = 2, j = 1) %>% 
  color(i = 3, j = 1, color = "#333333") %>% bold(i = 3, j = 1) %>% 
  color(i = 4, j = 1, color = "#333333") %>% bold(i = 4, j = 1) %>%
  
  # Bordas
  border_remove() %>% 
  hline_top(border = fp_border(color = "black", width = 1.5)) %>%
  hline_bottom(border = fp_border(color = "black", width = 1.5)) %>%
  hline(part = "header", border = fp_border(color = "black", width = 1.0)) %>%
  hline(i = 1:3, border = fp_border(color = "#bfbfbf", width = 0.5))

# 3. Salvar como Word na pasta 'figures'
caminho_tabela <- here("figures", "dicionario_smith_lda.docx")
save_as_docx(minha_tabela, path = caminho_tabela)

message("Tabela Dicionário salva com sucesso em: ", caminho_tabela)

# ==============================================================================
# QUADRO COMPARATIVO: MUDANÇA DE PARADIGMA (FASE 1 vs FASE 2)
# ==============================================================================

# 1. Definição dos Dados (Manual)
dados_comparativos <- tibble(
  Criterio = c(
    "Enquadramento da Agenda",
    "Critério de Elegibilidade",
    "Valor do Benefício",
    "Arranjo Institucional",
    "Governança e Parcerias",
    "Operacionalização (Cadastro)",
    "Monitoramento e Avaliação"
  ),
  Fase_1 = c(
    "Brasil Sem Miséria: Foco na erradicação da pobreza extrema. A conservação era vista como meio para inclusão produtiva.",
    "Extrema Pobreza: Vínculo estrito com a linha da miséria (R$ 70,00 per capita).",
    "R$ 300,00 trimestrais.",
    "Comitê Interministerial: Foco na articulação social (MMA, MDS, MDA, Casa Civil).",
    "Centrada no Estado: Execução direta via órgãos federais (ICMBio, INCRA, SPU).",
    "Analógica: Formulários em papel, Busca Ativa presencial e envio via Correios.",
    "Reativo: Metodologia desenvolvida durante a implementação. Foco em monitoramento remoto."
  ),
  Fase_2 = c(
    "Agenda Climática: Foco na redução da vulnerabilidade climática para atrair financiamento global.",
    "Baixa Renda: Desvinculação da extrema pobreza. Ampliação para até 1/2 salário-mínimo.",
    "R$ 600,00 trimestrais.",
    "Inclusão Estratégica do MPO: Entrada do Ministério do Planejamento para garantir avaliação.",
    "Governança em Rede (Híbrida): Inclusão formal de ONGs, institutos de pesquisa e setor privado.",
    "Digital: Modernização com migração para processos digitais via Gov.br.",
    "Proativo e Robusto: Plano de Monitoramento e Avaliação previsto na formulação."
  )
)

# 2. Formatação Visual (Estilo Acadêmico GT)
tabela_ajustada <- dados_comparativos %>%
  gt() %>%
  
  # Cabeçalho
  tab_header(
    title = md("**Mudança de Paradigma: Programa Bolsa Verde**"),
    subtitle = "Comparativo estrutural entre a Fase de Implementação e a Retomada"
  ) %>%
  
  # Rótulos
  cols_label(
    Criterio = md("**Dimensão**"),
    Fase_1 = md("**Fase 1 (2011–2017)**"),
    Fase_2 = md("**Fase 2 (2023–Presente)**")
  ) %>%
  
  # Larguras
  cols_width(
    Criterio ~ px(110),
    Fase_1 ~ px(270),
    Fase_2 ~ px(270)
  ) %>%
  
  # Alinhamento do Texto
  cols_align(align = "left", columns = everything()) %>%
  
  # Estilo Acadêmico (Fontes e Bordas)
  tab_options(
    table.font.names = "Times New Roman",
    table.font.size = 12,
    table.border.top.color = "black",
    table.border.bottom.color = "black",
    heading.border.bottom.color = "black",
    column_labels.border.bottom.color = "black",
    data_row.padding = px(10)
  ) %>%
  
  # Negrito na primeira coluna
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(columns = Criterio)
  ) %>%
  
  # Alinhamento vertical do cabeçalho
  tab_style(
    style = cell_text(v_align = "middle"),
    locations = cells_column_labels(columns = everything())
  )

# 3. Salvar na pasta 'figures' (Formatos DOCX e PNG)
caminho_docx <- here("figures", "Quadro_Comparativo_Fases.docx")
caminho_png  <- here("figures", "Quadro_Comparativo_Fases.png")

gtsave(tabela_ajustada, filename = caminho_docx)
gtsave(tabela_ajustada, filename = caminho_png)

message("Quadro Comparativo salvo em DOCX e PNG na pasta 'figures'.")

# ==============================================================================
# VALIDAÇÃO CRUZADA: LDA vs. TEORIA DE SMITH (ADERÊNCIA TEÓRICA)
# ==============================================================================

pacman::p_load(stringi) # Necessário para remover acentos na comparação

# 1. Carregar o Modelo Completo (Salvo no Passo 02)
caminho_modelo <- here("data", "output", "modelo_lda_completo.rds")

if(file.exists(caminho_modelo)) {
  
  lda_model <- readRDS(caminho_modelo)
  
  # 2. Definir o Dicionário Teórico Otimizado
  dicionario_smith <- list(
    "1. Polít. Idealizada" = c("lei", "decreto", "norma.*", "regulament.*", "legisla.*", 
                               "preserva.*", "conserva.*", "sustenta.*", "biodiversidade", "florest.*", 
                               "criterio.*", "condicional.*", "elegib.*", "diretriz.*", "estrateg.*", 
                               "cidadania", "desenvolvimento", "protecao", "inclusao", "direitos_humanos", 
                               "assistencia_tecnica", "foment.*", "capacita.*", "transferencia"),
    
    "2. Grupo-Alvo" = c("beneficiari.*", "familia.*", "populacao", "povo.*", "comunidade.*", 
                        "tradicion.*", "indigena.*", "quilombola.*", "ribeirinh.*", "extrativist.*", 
                        "agricultor.*", "assentado.*", "cooperativa", "lideranca", "associac.*", 
                        "pobreza", "extrema", "vulnerab.*", "renda", "cadunico", 
                        "adesao", "compromisso", "ativo_ambiental"),
    
    "3. Org. Implementadora" = c("ministerio", "mma", "icmbio", "incra", "comite_gestor", "orgao.*", 
                                 "coorden.*", "planej.*", "gesta.*", "gestor.*", "implement.*", "execu.*", 
                                 "servidor.*", "agente.*", "equipe", "capacidade_operacional", 
                                 "monitor.*", "fiscaliz.*", "vistori.*", "avali.*", "diagnostico", 
                                 "satelite", "georreferenc.*", "sistema", "base_de_dados", 
                                 "orcamento", "recurso.*", "pagamento", "financeir.*"),
    
    "4. Fatores Ambientais" = c("crise", "cenario", "contingencia.*", "ajuste_fiscal", "economia", 
                                "mudanca_clima.*", "clima.*", "rio\\+20", "paradigma", 
                                "amazonia", "bioma", "norte", "territori.*", "isolamento", "logistica", 
                                "pressao", "conflito", "desmat.*", "invasa.*", "grilagem", 
                                "plantacao", "agricola", "rural")
  )
  
  # 3. Extrair Termos do LDA e Classificar
  top_termos_lda <- tidy(lda_model, matrix = "beta") %>%
    group_by(topic) %>%
    slice_max(beta, n = 50) %>% 
    ungroup() %>%
    mutate(term_clean = stri_trans_general(term, "Latin-ASCII")) # Remove acentos
  
  classificacao_lda <- top_termos_lda %>%
    mutate(categoria_teorica = case_when(
      str_detect(term_clean, paste(dicionario_smith$`1. Polít. Idealizada`, collapse="|")) ~ "1. Polít. Idealizada",
      str_detect(term_clean, paste(dicionario_smith$`2. Grupo-Alvo`, collapse="|")) ~ "2. Grupo-Alvo",
      str_detect(term_clean, paste(dicionario_smith$`3. Org. Implementadora`, collapse="|")) ~ "3. Org. Implementadora",
      str_detect(term_clean, paste(dicionario_smith$`4. Fatores Ambientais`, collapse="|")) ~ "4. Fatores Ambientais",
      TRUE ~ "Não Classificado"
    ))
  
  # 4. Gerar Gráfico de Validação
  grafico_coerencia <- classificacao_lda %>%
    filter(categoria_teorica != "Não Classificado") %>%
    ggplot(aes(x = factor(topic), fill = categoria_teorica)) +
    geom_bar(position = "fill") + 
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(values = c(
      "1. Polít. Idealizada" = "#7570B3",   # Roxo
      "2. Grupo-Alvo" = "#D95F02",          # Laranja
      "3. Org. Implementadora" = "#377EB8", # Azul
      "4. Fatores Ambientais" = "#E7298A"   # Rosa
    )) +
    labs(title = "Validação Cruzada: LDA vs. Matriz de Smith",
         subtitle = "Aderência dos Tópicos Indutivos às Categorias Teóricas",
         x = "Tópico (LDA)", y = "Composição Teórica (%)", fill = "Categoria (Smith)") +
    tema_clean +
    theme(legend.position = "bottom")
  
  # Salvar
  ggsave(here("figures", "Validacao_Teorica_LDA.png"), plot = grafico_coerencia, width = 8, height = 6)
  
  # 5. Diagnóstico de Palavras Perdidas (Aparece no Console)
  message("\n--- DIAGNÓSTICO: Palavras fortes do LDA fora do Dicionário ---")
  classificacao_lda %>%
    filter(categoria_teorica == "Não Classificado") %>%
    select(Topico = topic, Palavra = term, Importancia = beta) %>%
    group_by(Topico) %>% slice_head(n = 5) %>% print()
  
} else {
  message("AVISO: 'modelo_lda_completo.rds' não encontrado. Rode o Script 02 novamente.")
}

