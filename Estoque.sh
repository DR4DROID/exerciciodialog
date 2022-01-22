#!/usr/bin/env bash
#
# Estoque.sh controla um inventário simples de loja
#
#
# Site:       https://github.com/DR4DROID
# Autor:      Gilberto N Vieira
# Manutenção: Gilberto N Vieira

#
# ------------------------------------------------------------------------ #
# este programa simula um controle de inventário simples de uma loja de
# acessorios para celular!
#
#
# ------------------------------------------------------------------------ #
# Histórico:
#  v1.0 19/01/2022 Versão inicial sem interface gráfica
#  v1.2 20/01/2022 adicionado interface gráfica
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 4.4.19
# ------------------------------------------------------------------------ #
# Agradecimentos:

# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #
ARQUIVO_BD="bd_estoque.txt"
SEP=:
TEMP=temp.$$

# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ------------------------------------------------- --#
[ ! -e "$ARQUIVO_BD" ] && echo "ERRO. Arquivo de Banco de Dados nao encontrado!" && exit 1
[ ! -r "$ARQUIVO_BD" ] && echo "ERRO. Arquivo de Banco de Dados sem autorização de leitura!" && exit 1
[ ! -w "$ARQUIVO_BD" ] && echo "ERRO. Arquivo de Banco de Dados sem autorização de escrita!" && exit 1
[ ! -x "$(which dialog)" ] && sudo apt install dialog 1> /dev/null 2>&1  #verifica se possui dialog instalado

# ----------------------------------------------------------------------------------------------- #

# ------------------------------- FUNÇÕES ----------------------------------------- #

ListaEstoque () {

  egrep -v "^#|^$" "$ARQUIVO_BD" | tr : ' ' > "$TEMP"
  dialog --title "INVENTÁRIO" --textbox "$TEMP" 20 40
  rm -f "$TEMP"

}

ValidaExistenciaProduto () {
  grep -i -q "$1$SEP" "$ARQUIVO_BD"
}

# ------------------------------------------------------------------------ #

# ------------------------------- EXECUÇÃO ----------------------------------------- #
while :
do
  acao=$(dialog --title "Gerenciamento de Estoque 1.2" \
                --stdout \
                --menu "Escolha uma das opções abaixo:" \
                0 0 0\
                listar "Listar Inventário" \
                remover "Remover Produto" \
                inserir "Adicionar Produto ao inventário")
[ $? -ne 0 ] && exit

 case $acao in
   listar) ListaEstoque    ;;

   inserir) #ira validar e inserir produto ao banco de dados
    ultimoId=$(egrep -v "^#|^$" $ARQUIVO_BD | sort -g | tail -n 1 | cut -d $SEP -f 1)
    proximoId=$(($ultimoId+1))

    produto=$(dialog --title "Cadastro de Produto" --stdout --inputbox "Digite o nome do Produto" 0 0)
    [ ! "$produto" ] && continue


     ValidaExistenciaProduto "$produto" && {
       dialog --title "ERRO!" --msgbox "Produto ja Cadastrado no inventário" 6 40
       exit 1
     }


    valor=$(dialog --title "Cadastro de Produto" --stdout --inputbox "Digite o valor do Produto" 0 0)
    [ $? -ne 0 ] && continue

    quantidade=$(dialog --title "Cadastro de Produto" --stdout --inputbox "Digite a quantidade do Produto" 0 0)


     echo "$proximoId$SEP$produto$SEP$valor$SEP$quantidade" >> "$ARQUIVO_BD"

     dialog --title "SUCESSO!" --msgbox "PRODUTO INSERIDO COM SUCESSO!" 6 40

     ListaEstoque
      ;;

   remover) #ira remover produto da lista
     usuarios=$(egrep "^#|^$" -v "$ARQUIVO_BD" | sort -h | cut -d $SEP -f 1,2 | sed 's/:/ "/;s/$/"/')
     id_usuarios=$(eval dialog --stdout --menu \"Escolha um Produto:\" 0 0 0  $usuarios)
     [ $? -ne 0 ] && continue

     grep -i -v "^$id_usuarios$SEP" "$ARQUIVO_BD" > "$TEMP"
     mv "$TEMP" "$ARQUIVO_BD"

     dialog --msgbox "Produto Removido Com Sucesso!" 6 40

     ListaEstoque
     ;;
 esac
done
# ------------------------------------------------------------------------ #
