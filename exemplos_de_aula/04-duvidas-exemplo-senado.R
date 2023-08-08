# Autoria: Beatriz Milz
# milz.bea@gmail.com


# util para roberta e ana carolina
# neste script, vamos usar acessar os dados sobre matérias legislativas do senado

# EXEMPLO SEM QUERY (SEM FILTRO) --------
# Primeiro, vamos salvar em um objeto a url base da API do senado
url_base <- "https://legis.senado.leg.br/dadosabertos/materia/pesquisa/lista"

# Para acessar os dados, vamos usar a função fromJSON() do pacote jsonlite
# A função fromJSON() recebe como argumento a url da API e retorna um objeto
# o argumento simplifyDataFrame = TRUE indica que queremos um data frame
df_senado <- jsonlite::fromJSON(url_base, simplifyDataFrame = TRUE)

# o objeto df_senado é uma lista!
# precisamos acessar os elementos da lista para extrair os dados que queremos
class(df_senado)
# [1] "list"

materias <- df_senado |>
  # a função pluck() do pacote purrr é útil para acessar elementos de listas, usando o nome dos elementos
  purrr::pluck("PesquisaBasicaMateria", "Materias", "Materia") |>
  # a função clean_names() do pacote janitor é útil para padronizar os nomes das colunas
  janitor::clean_names()

dplyr::glimpse(materias)
# Rows: 3,199
# Columns: 11
# $ codigo                  <chr> "158165", "155764", "158910", "157947"…
# $ identificacao_processo  <chr> "8474680", "8361629", "8502775", "8468…
# $ descricao_identificacao <chr> "DEN 5/2023", "INS 8/2023", "MSF 52/20…
# $ sigla                   <chr> "DEN", "INS", "MSF", "OFS", "OFS", "PD…
# $ numero                  <chr> "00005", "00008", "00052", "00009", "0…
# $ ano                     <chr> "2023", "2023", "2023", "2023", "2023"…
# $ ementa                  <chr> "Requer a abertura de procedimento dis…
# $ autor                   <chr> "Cidadão Deputado Daniel Silveira", "S…
# $ data                    <chr> "2023-06-15", "2023-02-03", "2023-07-2…
# $ url_detalhe_materia     <chr> "http://legis.senado.leg.br/dadosabert…
# $ sigla_comissao          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…


# EXEMPLO COM QUERY (COM FILTRO) --------
# Intervalo de datas + palavra chave

# Vamos escrever a query que queremos usar para filtrar os dados
# A query é uma string que contém os argumentos que queremos passar para a API
# e depende da API que estamos usando
# para isso, é importante ler a documentação da API
# Nesse caso, está aqui:
# https://legis.senado.leg.br/dadosabertos/docs/resource_PesquisaMateriaService.html


# Na query abaixo, passamos 3 argumentos para a API:
# dataInicioApresentacao: data de início da apresentação da matéria
# dataFimApresentacao: data de fim da apresentação da matéria
# palavraChave: palavra chave que queremos buscar nas matérias
# lembrando que isso depende da API que estamos usando!
# para adicionar mais argumentos, usamos o símbolo "&"
query <- "?dataInicioApresentacao=20210501&dataFimApresentacao=20210531&palavraChave=mulher"

# Vamos juntar a url base com a query, "colando" os textos
url_com_query <- paste0(url_base, query)

# daqui pra frente é igual ao exemplo anterior :)
df_senado_query <- jsonlite::fromJSON(url_com_query, simplifyDataFrame = TRUE)

materias_query <- df_senado_query |>
  purrr::pluck("PesquisaBasicaMateria", "Materias", "Materia") |>
  janitor::clean_names()

# Rows: 15
# Columns: 10
# $ codigo                  <chr> "148491", "148418", "148343", "148315"…
# $ identificacao_processo  <chr> "8080263", "8078581", "8076063", "8074…
# $ descricao_identificacao <chr> "PL 1861/2021", "PL 1813/2021", "PL 59…
# $ sigla                   <chr> "PL", "PL", "PL", "PDL", "PL", "SUG", …
# $ numero                  <chr> "01861", "01813", "00598", "00183", "0…
# $ ano                     <chr> "2021", "2021", "2019", "2021", "2021"…
# $ ementa                  <chr> "Altera a redação do art. 24-A da Lei …
# $ autor                   <chr> "Senador Luiz do Carmo (MDB/GO)", "Sen…
# $ data                    <chr> "2021-05-18", "2021-05-14", "2021-05-1…
# $ url_detalhe_materia     <chr> "http://legis.senado.leg.br/dadosabert…



# Ideia: a partir do url_detalhe_materia, buscar o conteudo completo ---


# Criei uma função para baixar os dados de UMA matéria
# Tem vários conceitos que não tratamos, então não vou focar aqui.
# a ideia é que essa lista retornada não vem como uma tabela, então precisamos
# estruturar os dados para transformar em tabela
# e isso dá trabalho pois precisei fazer na mão, mas é possível automatizar
# também considerei que algumas matérias não tem alguns elementos, então
# tem alguns if/else no código por isso.

baixar_detalhes_materia <- function(url_detalhes_materia) {
  # url_detalhes_materia é um argumento da função,
  # então é algo que precisamos oferecer para que a função execute


  # Vamos usar a função fromJSON() do pacote jsonlite, da mesma forma que
  # os exemplos anteriores
  lista <- jsonlite::fromJSON(url_detalhes_materia, simplifyDataFrame = TRUE) |>
    purrr::pluck("DetalheMateria", "Materia")

  # Tratanto elementos da lista para transformar em tabela

  ##  id_materia ---
  df_id_materia <- lista$IdentificacaoMateria |>
    tibble::as_tibble()

  ## dados_basicos ---

  df_dados_basicos <- lista$DadosBasicosMateria |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    tidyr::nest(.key = "dados_basicos")

  ## classificacoes ---

  if (!is.null(lista$Classificacoes$Classificacao)) {
    df_classificacoes <- lista$Classificacoes$Classificacao |>
      tibble::as_tibble() |>
      janitor::clean_names() |>
      tidyr::nest(.key = "classificacoes")
  } else {
    df_classificacoes <- tibble::tibble(classificacoes = NA)
  }

  ## assunto ---
  if (!is.null(lista$Assunto)) {
    df_assunto_espeficico <- lista$Assunto$AssuntoEspecifico |>
      tibble::as_tibble() |>
      dplyr::rename_with(~ paste0("assunto_especifico_", .x))

    df_assunto_geral <- lista$Assunto$AssuntoGeral |>
      tibble::as_tibble() |>
      dplyr::rename_with(~ paste0("assunto_geral_", .x))
  } else {
    df_assunto_espeficico <- tibble::tibble(
      assunto_especifico_Codigo = NA_character_,
      assunto_especifico_Descricao = NA_character_
    )
  }
  ## origem ---
  df_origem_materia <- lista$OrigemMateria |> tibble::as_tibble()


  ## decisao e destino ---
  if (!is.null(lista$DecisaoEDestino)) {
    df_decisao <- lista$DecisaoEDestino$Decisao |>
      tibble::as_tibble() |>
      dplyr::rename_with(~ paste0("decisao_", .x))

    df_destino <- lista$DecisaoEDestino$Destino |>
      tibble::as_tibble() |>
      dplyr::rename_with(~ paste0("destino_", .x))
  } else {
    df_decisao <- tibble::tibble(
      decisao_Data = NA_character_,
      decisao_Sigla = NA_character_,
      decisao_Descricao = NA_character_
    )
  }

  ## servicos ---
  df_servicos <- lista$OutrasInformacoes$Servico |>
    tibble::as_tibble() |>
    dplyr::select(-DescricaoServico) |>
    tidyr::pivot_wider(names_from = "NomeServico", values_from = "UrlServico") |>
    dplyr::rename_with(~ paste0("servico", .x))

  # Depois juntamos todas as tabelas em uma só

  df_final <- df_id_materia |>
    dplyr::bind_cols(df_dados_basicos) |>
    dplyr::bind_cols(df_classificacoes) |>
    dplyr::bind_cols(df_assunto_geral) |>
    dplyr::bind_cols(df_assunto_espeficico) |>
    dplyr::bind_cols(df_origem_materia) |>
    dplyr::bind_cols(df_decisao) |>
    dplyr::bind_cols(df_destino) |>
    dplyr::bind_cols(df_servicos) |>
    janitor::clean_names()

  # Retornamos a tabela final

  return(df_final)
}


# Vamos testar a função com uma url de exemplo
baixar_detalhes_materia("http://legis.senado.leg.br/dadosabertos/materia/148491?v=7")

# Vamos usar a função map_df() do pacote purrr para aplicar a função baixar_detalhes_materia()
# para cada url de detalhes de matéria, queremos aplicar a função baixar_detalhes_materia()
urls_para_buscar <- materias_query$url_detalhe_materia

# Pode demorar um pouco!
tabela_materias <- purrr::map_df(urls_para_buscar, baixar_detalhes_materia)

tabela_materias |> dplyr::glimpse()
# Rows: 15
# Columns: 32
# $ codigo_materia                   <chr> "148491", "148418", "148343",…
# $ sigla_casa_identificacao_materia <chr> "SF", "SF", "SF", "SF", "SF",…
# $ sigla_subtipo_materia            <chr> "PL", "PL", "PL", "PDL", "PL"…
# $ descricao_subtipo_materia        <chr> "Projeto de Lei", "Projeto de…
# $ numero_materia                   <chr> "01861", "01813", "00598", "0…
# $ ano_materia                      <chr> "2021", "2021", "2019", "2021…
# $ descricao_objetivo_processo      <chr> "Iniciadora", "Iniciadora", "…
# $ descricao_identificacao_materia  <chr> "PL 1861/2021", "PL 1813/2021…
# $ indicador_tramitando             <chr> "Não", "Sim", "Não", "Sim", "…
# $ identificacao_processo           <chr> "8080265", "8078586", "807598…
# $ dados_basicos                    <list> [<tbl_df[3 x 9]>], [<tbl_df[…
# $ classificacoes                   <list> [<tbl_df[2 x 3]>], [<tbl_df[…
# $ assunto_geral_codigo             <chr> "84", "84", "84", "84", "84",…
# $ assunto_geral_descricao          <chr> "Social", "Social", "Social",…
# $ assunto_especifico_codigo        <chr> "145", "145", "145", NA, "149…
# $ assunto_especifico_descricao     <chr> "Família, proteção a crianças…
# $ nome_poder_origem                <chr> "Legislativo", "Legislativo",…
# $ sigla_casa_origem                <chr> "SF", "SF", "CD", "SF", "SF",…
# $ decisao_data                     <chr> "2022-12-21", NA, "2021-05-18…
# $ decisao_sigla                    <chr> "ARQUIVADO_FIM_LEGISLATURA", …
# $ decisao_descricao                <chr> "Arquivada ao final da Legisl…
# $ destino_sigla                    <chr> "ARQUIVO", "ARQUIVO", "SANCAO…
# $ destino_descricao                <chr> "Ao arquivo", "Ao arquivo", "…
# $ servico_atualizacao_materia      <chr> "http://legis.senado.leg.br/d…
# $ servico_autoria_materia          <chr> "http://legis.senado.leg.br/d…
# $ servico_emenda_materia           <chr> "http://legis.senado.leg.br/d…
# $ servico_movimentacao_materia     <chr> "http://legis.senado.leg.br/d…
# $ servico_relatoria_materia        <chr> "http://legis.senado.leg.br/d…
# $ servico_situacao_atual_materia   <chr> "http://legis.senado.leg.br/d…
# $ servico_texto_materia            <chr> "http://legis.senado.leg.br/d…
# $ servico_votacao_materia          <chr> "http://legis.senado.leg.br/d…
# $ servico_votacoes_comissao        <chr> "http://legis.senado.leg.br/d…
