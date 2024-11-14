## ODS 1.1 - Percentual de familias residentes cadastradas no CadUnico com renda familiar per capita de até meio salário mínimo
## sobre o total de famílias cadastradas

# libraries ----
library(tidyverse)


# Reading the input ----
familia_12_23 <- readr::read_csv('inputs/qtd_familias_cadunico_fev12_fev23.csv',
                      locale = readr::locale(encoding = "Latin1"))

familia_23_24 <- readr::read_csv('inputs/qtd_familias_cadunico_mar23_set24.csv',
                                 locale = readr::locale(encoding = 'Latin1'))

# Cleaning data ----

familia_12_23 <- familia_12_23 %>% 
  janitor::clean_names() %>% 
  dplyr::select(id_municipio_6 = codigo,
                nome_municipio = unidade_territorial,
                sigla_uf = uf,
                mes_ano = referencia,
                qtd_ate_meio_sl = quantidade_de_familias_com_renda_per_capita_mensal_ate_meio_salario_minimo_inscritas_no_cadastro_unico,
                qtd_acima_meio_sl = quantidade_de_familias_com_renda_per_capita_mensal_acima_de_meio_salario_minimo_inscritas_no_cadastro_unico)

df_familia <- familia_23_24 %>% 
  janitor::clean_names() %>% 
  dplyr::select(id_municipio_6 = codigo,
                nome_municipio = unidade_territorial,
                sigla_uf = uf,
                mes_ano = referencia,
                qtd_ate_meio_sl = quantidade_de_familias_com_renda_per_capita_mensal_ate_meio_salario_minimo_pobreza_baixa_renda_inscritas_no_cadastro_unico,
                qtd_acima_meio_sl = quantidade_de_familias_com_renda_per_capita_mensal_acima_de_meio_salario_minimo_inscritas_no_cadastro_unico) %>% 
  dplyr::bind_rows(familia_12_23) %>% 
  dplyr::mutate(
    mes_ano = lubridate::my(mes_ano),
    id_municipio_6 = as.character(id_municipio_6),
    year = lubridate::year(mes_ano)
  )

# Making the ODS 1.1 indicator
ods_1_1 <- df_familia %>% 
  dplyr::filter(mes_ano == max(mes_ano),
                .by = year) %>% 
  dplyr::mutate(value = qtd_ate_meio_sl/(qtd_ate_meio_sl+qtd_acima_meio_sl)) %>% 
  dplyr::select(id_municipio_6, nome_municipio, year, value) %>% 
  dplyr::arrange(id_municipio_6, year)


writexl::write_xlsx(ods_1_1, 'outputs/ods_1_1.xlsx')