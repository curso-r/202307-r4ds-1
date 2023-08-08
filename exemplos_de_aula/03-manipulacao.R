# Pacotes -----------------------------------------------------------------
library(tidyverse)

# Dúvida da Sarah sobre conflitos de funções
library(conflicted)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

# podemos adicionar isso no R profile,
# um arquivo carregado quando o R é iniciado
# usethis::edit_r_profile()

# Base de dados -----------------------------------------------------------

imdb <- read_rds("dados/imdb.rds")

# Jeito de ver a base -----------------------------------------------------



# R base
names(imdb)
View(imdb) # Cuidado com bases muito grandes!
head(imdb, n = 10)
tail(imdb, n = 10)

# tidyverse
glimpse(imdb)
slice_sample(imdb, n = 1000)

# SKIM - relatório da base
skimr::skim(imdb)

# Somar os NAs de alguma coluna
sum(is.na(imdb$orcamento))


# visualização dos NAs
naniar::gg_miss_var(imdb)


# DICA: padronizar nomes das colunas

iris

names(iris)

iris_limpo <- janitor::clean_names(iris)

names(iris_limpo)

# Disponibilizar algum video da Fe Peres sobre boxplot:
# https://fernandafperes.com.br/blog/interpretacao-boxplot/

# leitura de bases grandes
# vroom::vroom()
# https://vroom.r-lib.org/

# dplyr: 6 verbos principais
# select()    # seleciona colunas do data.frame
# arrange()   # reordena as linhas do data.frame
# filter()    # filtra linhas do data.frame
# mutate()    # cria novas colunas no data.frame (ou atualiza as colunas existentes)
# summarise() + group_by() # sumariza o data.frame
# left_join   # junta dois data.frames

# select ------------------------------------------------------------------

# Selecionando uma coluna da base


select(imdb, id_filme) # retorna uma base de dados!

# imdb$id_filme # retorna vetor

select(imdb, titulo)

# A operação NÃO MODIFICA O OBJETO imdb

imdb

# para modificar, precisa usar <- e salvar em um objeto!
imdb_titulos <- select(imdb, titulo)





# Selecionando várias colunas

select(imdb, titulo, ano, orcamento) # respeita a ordem

select(imdb, orcamento, ano, titulo) # respeita a ordem

1:10 # sequencia

select(imdb, titulo:generos)

# Funções auxiliares - detectar padroes de texto no nome das colunas!

select(imdb, starts_with("num")) # nome da coluna começa com o texto ....

select(imdb, ends_with("cao")) # nome da coluna termina com o texto ...

select(imdb, contains("cri")) # nome da coluna contém o texto ...



# Principais funções auxiliares

# starts_with(): para colunas que começam com um texto padrão
# ends_with(): para colunas que terminam com um texto padrão
# contains():  para colunas que contêm um texto padrão

# Selecionando colunas por exclusão

select(imdb, -titulo)

select(imdb, -starts_with("num"), -titulo, -ends_with("ao"))

# Treinando esse conceito

# combinar regras
select(imdb, titulo, starts_with("num"), orcamento:receita_eua)

# sequencia de colunas com : 
select(imdb, id_filme:num_avaliacoes)

# salvar o resultado do select em um objeto
imdb_selecionado <- select(imdb, titulo, ano, generos)



# -----
# criando uma tabela para servir de exemplo
exemplo_luiz <- tibble::tibble(
  cod_01_akskoad = c(1, 2, 3),
  cod_02_sfghuhfd = c(4, 5, 6), 
  cod_03_aushdiahus = c(7,8,9),
)

# valores que estão nas colunas que queremos selecionar
valores <- 2:3

# completa com o 0 para numeros menores que 10
valores_preenchidos <- str_pad(valores, width = 2, pad = "0")

# cola o prefixo e os números 
padroes_selecao <- paste0("cod_", valores_preenchidos)

# usa o padroes_selecao para selecionar
select(exemplo_luiz, contains(padroes_selecao))


# resumir em uma linha
# paste0("cod_", str_pad(2:3, 2, pad = "0"))




# arrange -----------------------------------------------------------------


# nome_verbo(nome_base, regras)

# Ordenando linhas de forma crescente de acordo com 
# os valores de uma coluna

# por padrao é ordenacao crescente
View(arrange(imdb, orcamento) )

# Agora de forma decrescente
View(arrange(imdb, desc(orcamento)))

# só vai mudar a ordem no objeto se salvar, com a <-
imdb_ordenado <- arrange(imdb, desc(orcamento))

# ordem das colunas que usamos no arrange importa!
View(arrange(imdb, desc(ano), desc(nota_imdb)))
# ano e desempate pela nota



# nota, desempate pelo ano
View(arrange(imdb, desc(nota_imdb), desc(ano)))

# por padrao, ordenacao por texto será em ordem alfabetica
View(arrange(imdb, direcao))

# para categorias que são ordenadas, é necessário tratar como fator primeiro
# Buscar base para treinar o arrange com fatores!
# TO DO!




# Ordenando de acordo com os valores 
# de duas colunas

View(arrange(imdb, desc(ano), orcamento))

# O que acontece com o NA? Sempre fica no final!

df <- tibble(x = c(NA, 2, 1), y = c(1, 2, 3))

arrange(df, x)
arrange(df, desc(x))


# exemplo 
# arrange(decisoes_judiciais, status_deferimento) # deferido, indeferido

# ---------

# FORMAS PARA CRIAR UMA TABELA
# COM AS COLUNAS TITULO E NOTA,
# COM AS NOTAS DECRESCENTES

# FORMA 1
imdb_notas <- select(imdb, titulo, nota_imdb)

arrange(imdb_notas, desc(nota_imdb))

# FORMA 2
# CODIGO ANINHADO - NÃO É LEGAL
# dificil de ler
arrange(select(imdb, titulo, nota_imdb), desc(nota_imdb))


# forma 3
# forma mais usada
# pipe - cano
# conecta as operações
# é um operador
# tidyverse %>%
# R base |> 

imdb |> 
  select(titulo, nota_imdb)

# select(imdb, titulo, nota_imdb)

# salvar em um objeto
imdb_pipe <- imdb |> # usando a base do IMDB
  # quero selecionar as colunas titulo e nota
  select(titulo, nota_imdb) |> 
  # ordenar de forma decrescente pela nota 
  arrange(desc(nota_imdb))

# |> |> |> |> |> |> |> 
  
# %>% %>% %>% %>% %>% %>% %>% %>% 

# |> |> |> |> |> 

# Pipe (%>%) --------------------------------------------------------------

# Transforma funçõe aninhadas em funções
# sequenciais

# g(f(x)) = x %>% f() %>% g()

x %>% f() %>% g()   # CERTO
x %>% f(x) %>% g(x) # ERRADO

# Receita de bolo sem pipe. 
# Tente entender o que é preciso fazer.

esfrie(
  asse(
    coloque(
      bata(
        acrescente(
          recipiente(
            rep(
              "farinha", 
              2
            ), 
            "água", "fermento", "leite", "óleo"
          ), 
          "farinha", até = "macio"
        ), 
        duração = "3min"
      ), 
      lugar = "forma", tipo = "grande", untada = TRUE
    ), 
    duração = "50min"
  ), 
  "geladeira", "20min"
)

# Veja como o código acima pode ser reescrito 
# utilizando-se o pipe. 
# Agora realmente se parece com uma receita de bolo.

recipiente(rep("farinha", 2), "água", "fermento", "leite", "óleo") %>%
  acrescente("farinha", até = "macio") %>%
  bata(duração = "3min") %>%
  coloque(lugar = "forma", tipo = "grande", untada = TRUE) %>%
  asse(duração = "50min") %>%
  esfrie("geladeira", "20min")

# ATALHO DO %>%: CTRL (command) + SHIFT + M


# pipe nativo - Atalho: CTRL SHIFT M 
imdb |> 
  select(titulo, ano, nota_imdb, num_avaliacoes) |> 
  arrange(desc(nota_imdb))

# pipe do tidyverse - Atalho: CTRL SHIFT M 
imdb %>% 
  select(titulo, ano, nota_imdb, num_avaliacoes) %>% 
  arrange(desc(nota_imdb))


# atalhos do RStudio:
# ctrl + F - pesquisa dentro do script que estamos usando!

# CTRL + SHIFT + F - pesquisa dentro do projeto



# R é case sensitive: 'NOME' é diferente de 'nome'



# PREPARATORIO PRO FILTER: DISTINCT
# olhar as categorias de uma variável:


# Retorna uma tabela

distinct(imdb, direcao) # deixa apenas valores unicos!
distinct(imdb, ano, idioma) %>%
  arrange(ano) %>% 
  View()


imdb %>% 
  distinct(direcao) 

# Retorna um vetor
unique(imdb$direcao)


# Contagem ---- 

imdb %>% 
  count(direcao)

count(imdb, direcao, ano) %>% View()

diretores_ordenados <- imdb %>% 
  count(direcao, sort = TRUE)

imdb %>% 
  filter(direcao == "Quentin Tarantino") %>% 
  count(producao)


# filter ------------------------------------------------------------------

# nome_da_funcao(base_de_dados, regra)

# CTRL + F - pesquisa no arquivo

# CTRL + SHIFT + F - pesquisa no projeto

# filter() - filtrar linhas da base --------

# Aqui falaremos de Conceitos importantes para filtros, 
# seguindo de exemplos!

## Comparações lógicas -------------------------------

# comparacao logica
# == significa: uma coisa é igual a outra?
x <- 1
# x = 1 - igual sozinho é uma atribuicao

# Teste com resultado verdadeiro
x == 1

# Teste com resultado falso
x == 2

# Exemplo com filtros!
# Filtrando uma coluna da base: O que for TRUE (verdadeiro)
# será mantido!

# filter(imdb, comparacoes_para_filtrar)


filter(imdb, direcao == "Quentin Tarantino")

# reescrever com pipe

imdb %>% 
  filter(direcao == "Quentin Tarantino") %>% 
  arrange(ano) %>% # decrescente: desc(ano)
  select(titulo, ano, nota_imdb) %>% 
  View()


imdb %>% 
  filter(direcao == "Quentin Tarantino") %>%
  View()

imdb %>% 
  filter(direcao == "Quentin Tarantino", 
         producao == "Miramax") %>%
  View()



## Comparações lógicas -------------------------------

# maior 
x > 3
x > 0
# menor
x < 3
x < 0


x > 1
x >= 1 # # Maior ou igual
x < 1
x <= 1 # menor ou igual

# Exemplo com filtros!

imdb %>%
  filter(nota_imdb >= 9) %>%
  View()



## Recentes e com nota alta
imdb %>%
  filter(nota_imdb >= 9, num_avaliacoes > 10000) %>%
  View()

imdb %>% filter(ano > 2010, nota_imdb > 8.5, num_avaliacoes > 1000) %>% View()
imdb %>% filter(ano > 2010 & nota_imdb > 8.5)

## Gastaram menos de 100 mil, faturaram mais de 1 milhão
imdb %>% filter(orcamento < 100000, receita > 1000000) %>% View()

## Lucraram
imdb %>% filter(receita - orcamento > 0) %>% View()

imdb %>% 
  # é NA na receita OU é NA no orçamento
  # OU - satisfazer pelo menos uma das comparacoes/condicoes
  filter(is.na(receita) | is.na(orcamento)) %>%
  # nrow()
  View()




## Comparações lógicas -------------------------------

x != 2
x != 1

# Exemplo com filtros!
imdb %>% 
  filter(direcao != "Quentin Tarantino") %>% 
  View()

# duvidas no final da aula!

imdb %>% 
  filter(str_starts(titulo, "The")) %>% View()

imdb %>% 
  filter(idioma == "English") %>% View()

imdb %>% 
  filter(str_detect(idioma, "Spanish")) %>% View()

imdb %>% 
  filter(str_detect(direcao, "Quentin Tarantino")) %>% 
  View()


# PARAR AQUI ----------------------------------


# igual à ==
# diferente de !=
# maior que, menor que, maior ou igual à, menor ou igual à
# str_detect(), str_starts()


## Comparações lógicas -------------------------------

# operador %in%
# o x é igual à 1
# o x faz parte do conjunto 1, 2 e 3? SIM
x %in% c(1, 2, 3)
# o x faz parte do conjunto 2, 3 e 4? NÃO
x %in% c(2, 3, 4)

# Exemplo com filtros!


# O operador %in%

imdb %>% 
  filter(direcao %in% c('Matt Reeves', "Christopher Nolan")) %>% View()

# dá pra reescrever com o OU
imdb %>% 
  filter(
    direcao == "Matt Reeves" | direcao == "Christopher Nolan"
  )


# ISSO NAO FUNCIONA
# imdb %>% 
#  filter(direcao == c("..", '...'))


diretores_favoritos_do_will <- imdb %>%
  filter(
    direcao %in% c(
      "Quentin Tarantino",
      "Christopher Nolan",
      "Matt Reeves",
      "Steven Spielberg",
      "Francis Ford Coppola"
    )
  ) %>% 
  view()


# <- 


## Operadores lógicos -------------------------------
## operadores lógicos - &, | , !

## & - E - Para ser verdadeiro, os dois lados
# precisam resultar em TRUE
x <- 5

x >= 3 # verdadeiro

x <= 7 # verdadeiro

x >= 3 & x <= 7 # 

x >= 3 & x <= 4

# no filter, a virgula funciona como o &!
imdb %>%  
  filter(ano > 2010, nota_imdb > 8.5) %>%
  View()


# menos frequente de ser usado, mas funciona!
imdb %>% 
  filter(ano > 2010 & nota_imdb > 8.5)


## Operadores lógicos -------------------------------

## | - OU - Para ser verdadeiro, apenas um dos
# lados precisa ser verdadeiro

# operador |


y <- 2
y >= 3 # FALSO
y <= 7 # VERDADEIRO

# & - Resultado falso, VERDADEIRO + FALSO = FALSO
# | - Resultado verdadeiro, VERDADEIRO + FALSO = VERDADEIRO

y >= 3 | y <= 7

y >= 3 | y <= 0

# Exemplo com filter

## Lucraram mais de 500 milhões OU têm nota muito alta
imdb %>% 
  filter(receita - orcamento > 500000000 | nota_imdb > 9) %>% 
  View()

# O que esse quer dizer?
imdb %>%
  filter(ano > 2010 | nota_imdb > 8.5) %>%
  View()



## Operadores lógicos -------------------------------

## ! - Negação - É o "contrário"
# NOT

# operador de negação !
# é o contrario

!TRUE

!FALSE

# Exemplo com filter

imdb %>% 
  filter(!direcao %in% c("Quentin Tarantino",
                         "Christopher Nolan",
                         "Matt Reeves",
                         "Steven Spielberg",
                         "Francis Ford Coppola"
  )) %>%
  View()


#. função que testa se algo é um valor faltante - NA
is.na("bia")
is.na(NA)

imdb %>% 
  filter(!is.na(orcamento)) %>% 
  View()



imdb %>% 
  filter(!is.na(orcamento), !is.na(receita)) %>% 
  View()


# 

imdb %>% 
  mutate(descricao_minusculo = str_to_lower(descricao)) %>% 
  filter(str_detect(descricao_minusculo, "woman|hero|friend")) %>% 
  View()


imdb %>% 
  mutate(descricao_minusculo = str_to_lower(descricao)) %>% 
  filter(str_detect(descricao_minusculo, "woman"),
         str_detect(descricao_minusculo, "friend")) %>% 
  View()


##  NA ---- 

# exemplo com NA
is.na(imdb$orcamento)

imdb %>% 
  filter(!is.na(orcamento))

# tira toooodas as linhas que tenham algum NA
imdb %>% 
  drop_na()

# tira as linhas que tem NA nas colunas indicadas
imdb %>% 
  drop_na(orcamento, receita)


# o filtro por padrão tira os NAs!
df <- tibble(x = c(1, 2, 3, NA))
df


filter(df, x > 1)

filter(df, x < 2)

# NA == 1
# NA > 1
# 
# NA == NA


# manter os NAs!
filter(df, x > 1 | is.na(x))
# Por padrão, a função filter retira os NAs.



# ISSO DÁ ERRO
filter(imdb, orcamento == NA)

# contar os NA quando a variavel é categórica/texto
count(imdb, producao, sort = TRUE) %>% View()

# para numéricos, assim é mais fácil
filter(imdb, is.na(orcamento)) %>% 
  nrow()
# tambem funciona para texto
filter(imdb, is.na(producao)) %>% 
  nrow()



# filtrar textos sem correspondência exata

textos <- c("a", "aa", "abc", "bc", "A", NA)
textos

library(stringr) # faz parte do tidyverse

str_detect(textos, pattern =  "a")

str_view_all(textos, "a")

# validacao do padrao usado
str_view_all(imdb$descricao[1:10], "woman|movie", html = TRUE)


## Pegando os seis primeiros valores da coluna "generos"
imdb$generos[1:6]

str_detect(
  string = imdb$generos[1:6],
  pattern = "Drama"
)


## Pegando apenas os filmes que 
## tenham o gênero ação
imdb %>% filter(str_detect(generos, "Action")) %>% View()


# filtra generos que contenha filmes que tenha "Crime" no texto
imdb %>% 
  filter(str_detect(generos, "Crime")) %>% 
  View()

# filtra generos que seja IGUAL e APENAS "Crime"
imdb %>% filter(generos == "Crime")

# INTERVALO!



# mutate ------------------------------------------------------------------



# mutate(base, nome_da_coluna_para_criar = operacao_que_tem_resultado,
       # nome_da_coluna_para_criar_2 = operacao_que_tem_resultado)

# Modificando uma coluna
imdb %>% 
  mutate(duracao = duracao/60) %>% 
  View()

# Criando uma nova coluna

imdb %>% 
  mutate(duracao_horas = duracao/60) %>% 
  View()

# util pra criar colunas em uma posicao especifica
imdb %>% 
  mutate(duracao_horas = duracao/60, .after = duracao) %>% View()


imdb %>% 
  mutate(lucro = receita - orcamento, .after = receita) %>% 
  View()


lucro_filmes <- imdb %>% 
  drop_na(orcamento, receita) %>% 
  select(titulo, ano, receita, orcamento) %>% 
  mutate(lucro = receita - orcamento, 
         lucrou = lucro > 0,
         .after = orcamento) %>% 
  arrange(lucro) 


# Parenteses
library(esquisse)
esquisser(viewer = "browser")




library(ggplot2)

ggplot(lucro_filmes) +
 aes(x = ano) +
 geom_histogram(bins = 30L, fill = "#112446") +
 theme_minimal() +
 facet_wrap(vars(lucrou))



grafico_exemplo <- imdb %>%
  filter(ano >= 1950) %>%
  filter(nota_imdb >= 5 & nota_imdb <= 10) %>%
  ggplot() +
  aes(x = ano) +
  geom_histogram(bins = 30L, fill = "#46337E") +
  labs(x = "Ano de lançamento",
       y = "Quantidade de filmes",
       title = "Filmes com nota entre 5 e 10, lançados a partir de 1950") +
  theme_minimal()


  ggsave(filename = "exemplo.jpg", 
         plot = grafico_exemplo,
         dpi = 300)



# A função ifelse é uma ótima ferramenta
# para fazermos classificação binária (2 CATEGORIAS)
  
# if else
  # SE A CONDICAO FOR VERDADEIRA, FACA TAL COISA,
  # SE NAO, FACA OUTRA COISA
  

imdb %>% mutate(
  lucro = receita - orcamento,
  houve_lucro = ifelse(lucro > 0, "Sim", "Não")
) %>% 
  View()


nota_categorizada <- imdb %>% 
  select(titulo, nota_imdb) %>% 
  mutate(
    categoria_nota = case_when(
      # quando essa condicao for verdadeira ~ salve esse valor,
      nota_imdb >= 8 ~ "Alta",
      nota_imdb >= 5 & nota_imdb < 8 ~ "Média",
      nota_imdb < 5 ~ "Baixa",
      .default = "Outros"
     #  TRUE ~ "CATEGORIZAR" # Em alguns lugares aparece assim
    )
  )

nota_categorizada %>% 
  count(categoria_nota)

# classificacao com mais de 2 categorias:
# usar a função case_when()

imdb %>%
  mutate(
    categoria_nota = case_when(
      nota_imdb >= 8 ~ "Alta",
      nota_imdb < 8 & nota_imdb >= 5 ~ "Média",
      nota_imdb < 5 ~ "Baixa",
      TRUE ~ "Não classificado"
    )
  ) %>% View()


# summarise ---------------------------------------------------------------

# Sumarizando uma coluna

imdb %>% 
  summarise(media_orcamento = mean(orcamento, na.rm = TRUE))

# repare que a saída ainda é uma tibble


# Sumarizando várias colunas
imdb %>% summarise(
  media_orcamento = mean(orcamento, na.rm = TRUE),
  media_receita = mean(receita, na.rm = TRUE),
  media_lucro = mean(receita - orcamento, na.rm = TRUE)
)

# Diversas sumarizações da mesma coluna
imdb %>% summarise(
  media_orcamento = mean(orcamento, na.rm = TRUE),
  mediana_orcamento = median(orcamento, na.rm = TRUE),
  variancia_orcamento = var(orcamento, na.rm = TRUE),
  variancia_orcamento = var(orcamento, na.rm = TRUE),
  desvio_padrao_orcamento = sd(orcamento, na.rm = TRUE)
)

# Tabela descritiva
imdb %>% summarise(
  media_orcamento = mean(orcamento, na.rm = TRUE),
  media_receita = mean(receita, na.rm = TRUE),
  qtd = n(),
  qtd_direcao = n_distinct(direcao)
)


# n_distinct() é similar à:
imdb %>% 
  distinct(direcao) %>% 
  nrow()


# funcoes que transformam -> N valores
log(1:10)
sqrt()
str_detect()

# funcoes que sumarizam -> 1 valor - FUNÇÕES BOAS PARA SUMMARISE
mean(c(1, NA, 2))
mean(c(1, NA, 2), na.rm = TRUE)
n_distinct()


# group_by + summarise ----------------------------------------------------

# Agrupando a base por uma variável.

imdb %>% group_by(producao)

# Agrupando e sumarizando
imdb %>% 
  group_by(producao) %>% 
  summarise(
    media_orcamento = mean(orcamento, na.rm = TRUE),
    media_receita = mean(receita, na.rm = TRUE),
    qtd = n(),
    qtd_direcao = n_distinct(direcao)
  ) %>%
  arrange(desc(qtd)) 



  
  
# left join ---------------------------------------------------------------

# A função left join serve para juntarmos duas
# tabelas a partir de uma chave. 
# Vamos ver um exemplo bem simples.

band_members
band_instruments

band_members %>% 
  left_join(band_instruments)

band_instruments %>%
  left_join(band_members)

# o argumento 'by'
band_members %>%
  left_join(band_instruments, by = "name")

# OBS: existe uma família de joins

band_instruments %>%
  left_join(band_members)

band_instruments %>%
  inner_join(band_members)

band_instruments %>%
  full_join(band_members)

band_instruments %>%
  anti_join(band_members)

band_instruments %>%
  right_join(band_members)


# Um exemplo usando a outra base do imdb

imdb <- read_rds("dados/imdb.rds")
imdb_avaliacoes <- read_rds("dados/imdb_avaliacoes.rds")

imdb %>% 
  left_join(imdb_avaliacoes, by = "id_filme") %>%
  View()


# Colocar um exemplo com recodificacao


