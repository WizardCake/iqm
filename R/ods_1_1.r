## ODS 1.1 - Percentual de familias residentes cadastradas no CadUnico com renda familiar per capita de até meio salário mínimo
## sobre o total de famílias cadastradas

# libraries ----
library(tidyverse)


# Reading the input ----
df <- readr::read_csv('inputs/qtd_familias_cadunico_fev12_fev23.csv',
                      locale = readr::locale(encoding = "Latin1"))

# Cleaning data ----

df %>% 
  janitor::clean_names() %>% 
  dplyr::select(id_municipio_6 = codigo,
                nome_municipio = unidade_territorial,
                sigla_uf = uf,
                mes_ano = referencia,
                qtd_)

  
  
