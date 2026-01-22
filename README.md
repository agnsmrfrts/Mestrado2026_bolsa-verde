# Análise Longitudinal do Programa Bolsa Verde (2011-2025)

## 📌 Sobre o Projeto
Este repositório contém o código e os dados utilizados na dissertação de **Agnes Amaral (2026)**. O objetivo é analisar a trajetória do **Programa Bolsa Verde** — uma política pública brasileira de transferência de renda e conservação ambiental — através de técnicas de Mineração de Texto e Análise de Dados Longitudinais.

O estudo cobre três fases principais:
1. **Implementação (2011-2016)**
2. **Hiato/Desarticulação (2017-2022)**
3. **Retomada (2023-Presente)**

## 🛠 Metodologia
A análise foi realizada na linguagem **R** e utiliza as seguintes abordagens:

* **Matriz de Smith:** Classificação qualitativa do corpus documental (status legal, função e fase).
* **Latent Dirichlet Allocation (LDA):** Modelagem de tópicos para identificar as dimensões latentes (Operacional, Institucional, Conceitual e Técnica) nos documentos ao longo do tempo.
* **Validação Cruzada:** Comparação da aderência entre os tópicos matemáticos (LDA) e as categorias teóricas.
* **Análise Contextual:** Cruzamento dos dados da política com indicadores externos (Desmatamento na Amazônia e Índice de Gini).

## 📂 Estrutura do Repositório
O projeto está organizado da seguinte forma:

* `data/txt/`: Contém os documentos brutos (leis, decretos, portarias) em formato .txt.
* `data/output/`: Armazena os dados processados e modelos salvos (.rds).
* `figures/`: Contém todos os gráficos e tabelas gerados pelos scripts.
* `scripts/`: Códigos divididos por etapas.

## 🚀 Como Executar
Para reproduzir as análises, siga a ordem dos scripts abaixo:

1.  **`01_preparacao_corpus.R`**: Leitura, limpeza dos textos e classificação (Matriz de Smith).
2.  **`02_modelagem_lda.R`**: Processamento do modelo LDA e extração da evolução temporal (Gamma).
3.  **`03_dados_manuais.R`**: Organização dos dados externos (Desmatamento, Gini, Nº Famílias).
4.  **`04_visualizacao_resultados.R`**: Geração de todas as figuras, gráficos comparativos e validação teórica.

**Nota:** Recomenda-se abrir o projeto clicando no arquivo `.Rproj` (se houver) ou definindo o diretório de trabalho corretamente no RStudio.

## 📦 Pacotes Utilizados
* `tidyverse` (Manipulação de dados e gráficos)
* `tidytext` & `topicmodels` (Mineração de texto e LDA)
* `gt` & `flextable` (Tabelas formatadas para publicação)
* `patchwork` (Composição de gráficos)
* `here` (Gerenciamento de caminhos de arquivos)

---
*Autora: Agnes Amaral | Ano: 2026*
