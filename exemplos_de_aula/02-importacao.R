library(tidyverse)

# Caminhos até o arquivo --------------------------------------------------

# diretório de trabalho - onde o R vai buscar ou salvar arquivos.
getwd()
# com projetos, o diretorio de trabalho é a pasta do projeto!


# Caminhos absolutos - Não é uma boa prática
"/home/william/Documents/Curso-R/main-r4ds-1/dados/imdb.csv"

# imdb <- leitura("~/Desktop/material_do_curso-r-para-ciencia-de-dados/dados/imdb.csv")

# Caminhos relativos - partem do diretório de trabalho
"dados/imdb.csv"
"dados/imdb.csv"

# (cara(o) professora(o), favor lembrar de falar da dica 
# de navegação entre as aspas)

# Tibbles -----------------------------------------------------------------

airquality

iris

class(airquality)

as_tibble(airquality)

class(as_tibble(airquality))


t_airquality <- as_tibble(airquality)

class(t_airquality)


# Lendo arquivos de texto -------------------------------------------------

# Quais formatos vocês costumam usar?
# excel - xls, xlsx
# csv
# txt 
# XML

# readr - pacote para importacao

# CSV, separado por vírgula-  comma separated values
imdb_csv <- read_csv("dados/imdb.csv")

# CSV, separado por ponto-e-vírgula
imdb_csv2 <- read_csv2("dados/imdb2.csv")

# TXT, separado por tabulação (tecla TAB)
imdb_txt <- read_delim("dados/imdb.txt", delim = "\t") # \t representa o tab

# A função read_delim funciona para qualquer tipo de separador
imdb_delim <- read_delim("dados/imdb.csv", delim = ",")
imdb_delim2 <- read_delim("dados/imdb2.csv", delim = ";")

# direto da internet
imdb_csv_url <- read_csv("https://raw.githubusercontent.com/curso-r/main-r4ds-1/master/dados/imdb.csv")


# Interface point and click do RStudio também é útil!

# library(readr)
imdb2 <- read_delim("dados/imdb2.csv", delim = ";", 
                    escape_double = FALSE, trim_ws = TRUE)
# View(imdb2)


# library(readr)
imdb2 <- read_delim("dados/imdb2.csv", delim = ";", 
                    escape_double = FALSE, trim_ws = TRUE)
# View(imdb2)



# 
# Caminho para download: 
# http://dadosabertos.camara.leg.br/arquivos/proposicoes/{formato}/proposicoes-{ano}.{formato}, em que:
#   
# {ano} é o ano de apresentação das proposições
# {formato} pode ser “csv”, “xlsx”, "ods", “json” ou “xml”.



"http://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2023.csv"


proposicoes_2023 <- read_delim("http://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2023.csv", 
                               delim = ";", escape_double = FALSE,  trim_ws = TRUE)

glimpse(proposicoes_2023) 


filter(proposicoes_2023, siglaTipo == "PDL") |> 
  select(urlInteiroTeor)

# link para o PDF
proposicoes_2023$urlInteiroTeor[1]

# Lendo arquivos do Excel -------------------------------------------------

library(readxl)

imdb_excel <- read_excel("dados/imdb.xlsx")

excel_sheets("dados/imdb.xlsx")

imdb_excel <- read_excel("dados/imdb.xlsx", sheet = "Sheet1")








# Salvando dados ----------------------------------------------------------

imdb <- read_csv("dados/imdb.csv")


# As funções iniciam com 'write'

# imdb <- imdb_excel

# CSV
write_csv(imdb, file = "imdb.csv")

write_csv2(imdb, file = "imdb2.csv")


# criar pasta
dir.create("dados-output")

# para salvar em outra pasta, ela precisa existir!
write_csv2(imdb, file = "dados-output/imdb2.csv")


# exemplo em outra pasta

# Excel
library(writexl)
write_xlsx(imdb, path = "imdb.xlsx")



# pratica

proposicoes_2023 <- read_delim("http://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-2023.csv", 
                               delim = ";", escape_double = FALSE,  trim_ws = TRUE)



write_xlsx(proposicoes_2023, path = "proposicoes_2023.xlsx")


# O formato rds -----------------------------------------------------------

# .rds são arquivos binários do R
# Você pode salvar qualquer objeto do R em formato .rds

imdb_rds <- read_rds("dados/imdb.rds")
write_rds(imdb_rds, file = "dados/imdb_rds.rds")



# exemplo

library(readr) # ou tidyverse
imdb_rds <- read_rds("dados/imdb.rds")


# CSV, tentar descobrir o separador
# 
imdb <- read_csv2("dados/imdb2.csv")






















