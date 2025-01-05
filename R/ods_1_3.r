#1.3 - Percentual de pessoas abaixo da linha da pobreza no Cadastro Único pós Bolsa Família
# - Percentual da população abaixo da linha de pobreza após o Bolsa Família

library(tidyverse)
library(basedosdados)

# id_municipio with 7 digits dictionary
basedosdados::set_billing_id('projeto-iqm')

dic_municipio <- 'SELECT id_municipio_6, id_municipio, nome
FROM `basedosdados.br_bd_diretorios_brasil.municipio`' %>% 
  basedosdados::read_sql()
2

qtd_cadunico_total <- readr::read_delim('inputs/qtd_pessoas_cadunico_beneficiarias_ou_nao_do pbf_por faixa de renda per capita_apos_pbf.csv',
                                        delim=',', locale = locale(encoding='Latin1'))

qtd_cadunico_total

qtd_cadunico_pbf <- readr::read_delim('inputs/qtd_pessoas_cadunico_beneficiarias_do pbf_por faixa de renda per capita_apos_pbf.csv',
                                      delim = ',', locale = locale(encoding='Latin1'))

qtd_cadunico_pbf

colnames(qtd_cadunico_total) <- c('id_municipio_6', 'nome_municipio', 'sigla_uf', 'mes_ano',
                                  'qtd_abaixo_lp', 'qtd_abaixo_meio_sm',
                                  'qtd_acima_meio_sm', 'qtd_acima_lp')

colnames(qtd_cadunico_pbf) <- c('id_municipio_6', 'nome_municipio', 'sigla_uf', 'mes_ano',
                                'qtd_pbf_abaixo_lp', 'qtd_pbf_abaixo_meio_sm', 'qtd_pbf_acima_meio_sm',
                                'qtd_pbf_acima_lp')

df13 <- qtd_cadunico_total %>% 
  # Getting beneficiaries from PBF (bolsa familia's program)
  dplyr::left_join(qtd_cadunico_pbf, by = join_by(id_municipio_6, nome_municipio, sigla_uf, mes_ano)) %>%
  dplyr::mutate(id_municipio_6 = as.character(id_municipio_6)) %>% 
  dplyr::left_join(dic_municipio, by = join_by(id_municipio_6)) %>%
  # Exploring possible options for ODS 1.3 considering the indicator's name
  dplyr::mutate(
    ods_1_3_v1 = qtd_abaixo_lp/(qtd_abaixo_lp + qtd_acima_lp),
    ods_1_3_v2 = qtd_pbf_abaixo_lp/(qtd_abaixo_lp + qtd_acima_lp),
    ods_1_3_v3 = qtd_pbf_abaixo_lp/(qtd_pbf_abaixo_lp+qtd_pbf_acima_lp)
    ) %>%
  dplyr::select(id_municipio_6, id_municipio, nome, data = mes_ano, ods_1_3_v1, ods_1_3_v2, ods_1_3_v3) %>% 
  # NA presence in v2 and v3 accounts for the lack of beneficiaries in the respective municipality or lack of data for that date
  tidyr::replace_na(list(ods_1_3_v2 = 0, 
                         ods_1_3_v3 = 0))

writexl::write_xlsx(df13, 'outputs/ods_1_3.xlsx')
readr::write_rds(df13, 'outputs/ods_1_3.rds')
