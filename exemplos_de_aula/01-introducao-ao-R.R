# Rodando códigos (o R como calculadora) ----------------------------------

# ATALHO para rodar o código: CTRL + ENTER

# Comentário
# Isso não vai ser executado

# Executar
# mouse no código: ctrl + enter
# mouse no código: botão run
# selecionar o códig e rodar com botão run (isso é util para resolver erros!)

# adição
1 + 1

# subtração
4 - 2

# multiplicação
2 * 3

# divisão
5 / 3

# potência
4 ^ 2

# Objetos -----------------------------------------------------------------

# As bases de dados serão o nosso objeto de trabalho
mtcars

# O objeto mtcars já vem com a instalação do R
# Ele está sempre disponível

# Outros exemplos
pi
letters
LETTERS

# Na prática, vamos precisar trazer nossas bases
# para dentro do R. Como faremos isso?

objeto_criado <- 30

# Funções -----------------------------------------------------------------

Sys.Date()

somar_dois_numeros <- function(numero_a, numero_b){
  numero_a + numero_b
}

somar_dois_numeros(10, 20)

# Funções são nomes que guardam um código de R. Esse código é
# avaliado quando rodamos uma função.

nrow(mtcars) # número de linhas - row = linha
ncol(mtcars) # número de colunas - col = coluna

# ------------------ Aula 1 foi até aqui!\
