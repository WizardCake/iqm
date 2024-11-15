## ODS 1.2 - Participação das pessoas que recebem o bolsa família sobre o total de pessoas cadastradas no Cadastro Único.
## A data de referência para extração do dado é sempre dezembro do ano anterior na Base do CadÚnico.

# Libraries -----
library(tidyverse)
library(httr)

# id_municipio with 7 digits dictionary
basedosdados::set_billing_id('projeto-iqm')

dic_municipio <- 'SELECT id_municipio_6, id_municipio, nome
FROM `basedosdados.br_bd_diretorios_brasil.municipio`' %>% 
  basedosdados::read_sql()
2

# Get data from dados.gov.br
pull_data_mds <- function(base_link, year_month, fl_columns) {
  # Define base link for API
  base_url <- base_link
  
  # fq filtering for multiple years/year-month
  fq_filter <- paste0('anomes_s: ', year_month, '*')
  fq_combined <- paste0(fq_filter, collapse = ' OR ')
  
  # list parameters
  params <- list(
    fl = fl_columns,
    fq = fq_combined,
    q = '*:*',
    sort = 'anomes_s desc, codigo_ibge asc',
    rows = '1000000',
    wt = 'csv'
  )
  
  # GET 
  response <- httr::GET(base_url, query = params)
  
  # Check if the response was successful
  if (status_code(response) != 200) {
    stop("Failed to retrieve data. Please check the URL or your connection.")
  }
  
  # Read the CSV file
  content <- httr::content(response, 'text')
  data <- readr::read_csv(content)
  
  return(data)
}

df_cadunico <- pull_data_mds(base_link = 'https://aplicacoes.mds.gov.br/sagi/servicos/misocial',
                             year_month = 2012:2024,
                             fl_columns = 'codigo_ibge, anomes_s, cadun_qtd_familias_cadastradas_i')

df_bf <- pull_data_mds(base_link = 'https://aplicacoes.mds.gov.br/sagi/servicos/misocial',
                        year_month = 2012:2024,
                        fl_columns = 'codigo_ibge, anomes_s, qtd_familias_beneficiarias_bolsa_familia_s')


df12 <- df_cadunico %>% 
  dplyr::left_join(df_bf, join_by(codigo_ibge, anomes_s)) %>% 
  dplyr::filter(anomes_s != '202411') %>% 
  dplyr::mutate(ods_1_2 = qtd_familias_beneficiarias_bolsa_familia_s/cadun_qtd_familias_cadastradas_i,
                data = lubridate::ym(anomes_s),
                codigo_ibge = as.character(codigo_ibge)) %>% 
  dplyr::left_join(dic_municipio,
                   join_by(codigo_ibge == id_municipio_6)) %>% 
  dplyr::select(id_municipio_6 = codigo_ibge,
                id_municipio, nome, data, ods_1_2)

writexl::write_xlsx(df12, 'outputs/ods_1_2.xlsx')
readr::write_rds(df12, 'outputs/ods_1_2.rds')
