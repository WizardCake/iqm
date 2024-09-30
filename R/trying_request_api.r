library(tidyverse)
library(httr2)
# making first request

req <- 'https://dados.gov.br/dados/api/publico/conjuntos-dados?isPrivado=false&pagina=1'
api_key <- 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJhNElWS0U4RkZEY3R3WlIzSEtUc0MtVGZacko0cG1Mb2pYd25SRjQ1SUViSGFyQm9QNDdpdWc5WUx0d0xUb0lUZElZR2Itc0dwOGJzM2tXUSIsImlhdCI6MTcyNzY0NjU3M30.QjWdEDOkEq8-tyYj9RmxjF-ZzmHn7hMU_ZRnZkVoaqU'


teste1 <- httr2::request(req) %>% 
  httr2::req_auth_basic(api_key) %>% 
  req_perform() %>% 
  resp_body_json('application/json') %>% 
  resp_check_content_type('TRUE')

teste1
