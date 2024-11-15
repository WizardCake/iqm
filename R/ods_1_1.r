## ODS 1.1 - Percentual de familias residentes cadastradas no CadUnico com renda familiar per capita de até meio salário mínimo
## sobre o total de famílias cadastradas

# libraries ----
library(httr)
library(tidyverse)
library(basedosdados)

# id_municipio with 7 digits dictionary
basedosdados::set_billing_id('projeto-iqm')

dic_municipio <- 'SELECT id_municipio_6, id_municipio, nome
FROM `basedosdados.br_bd_diretorios_brasil.municipio`' %>% 
  basedosdados::read_sql()
2

# function to pull data from dados.gov.br -----
pull_data_mds <- function(year_months) {
  # Define base URL for the API
  base_url <- "https://aplicacoes.mds.gov.br/sagi/servicos/misocial/"
  
  # Create the filter query to include multiple years or year-months
  fq_filter <- paste0("anomes_s:", year_months, "*")
  fq_combined <- paste(fq_filter, collapse = " OR ")
  
  # Determine columns to include based on the requested dates
  fl_columns <- "codigo_ibge,anomes_s,qtd_fam_pob:cadun_qtd_familias_cadastradas_pobreza_pbf_i,qtd_fam_baixa_renda:cadun_qtd_familias_cadastradas_baixa_renda_i,qtd_fam_acima_meio_sm:cadun_qtd_familias_cadastradas_rfpc_acima_meio_sm_i"
  
  
  # Define parameters for the request
  params <- list(
    fl = fl_columns,
    fq = fq_combined,
    q = "*:*",
    sort = "anomes_s desc, codigo_ibge asc",
    rows = "1000000", # Request all rows without limitation
    wt = 'csv'
  )
  
  # Make the GET request to retrieve the data
  response <- GET(base_url, query = params)
  
  # Check if the response was successful
  if (status_code(response) != 200) {
    stop("Failed to retrieve data. Please check the URL or your connection.")
  }
  
  # Read the CSV content from the response
  content <- content(response, "text")
  data <- read_csv(content)
  
  return(data)
}

# Data Available since 2012 (monthly)
df11 <- pull_data_mds(2012:2024)
df11 <- df11 %>%
  dplyr::filter(anomes_s != '202411') %>% 
  # Proportion of CadUnico families that receive a per capita family income of up to half the minimum wage 
  # out of the total CadUnico Families
  dplyr::mutate(ods_1_1 = (qtd_fam_pob + qtd_fam_baixa_renda)/(qtd_fam_pob + qtd_fam_baixa_renda + qtd_fam_acima_meio_sm),
                data = lubridate::ym(anomes_s),
                codigo_ibge = as.character(codigo_ibge)) %>% 
  dplyr::select(id_municipio_6 = codigo_ibge,
                data, ods_1_1) %>% 
  dplyr::left_join(dic_municipio,
                   join_by(id_municipio_6)) %>% 
  dplyr::relocate(id_municipio, nome, .after = id_municipio_6)

writexl::write_xlsx(df11, 'outputs/ods_1_1.xlsx')
readr::write_rds(df11, 'outputs/ods_1_1.rds')
