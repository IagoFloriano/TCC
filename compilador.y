
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "TabelaSimbolos/simbolo.h"
#include "TabelaSimbolos/tabelaSimbolo.h"
#include "Pilha/pilha.h"


char mepaTemp[256];
char rotrTemp[256];
char commandTemp[256];

int num_vars;
int qtTipoAtual;
int tipoAtual;
int nivelLexico;
int chamandoProc;
int numParamProc;
int counterComandos=0;

simb simboloTemp;
simb simboloTempP;
simb *simboloPtr;
simb *simbVarProcPtr;
simb *simbFuncDeclara;
simb *simbFuncDeclaraP;
simb simbCallProc;
simb simbAtribuicao;

t_conteudo conteudoTemp;
t_conteudo conteudoTempP;

tabela t;
tabela permanente;

pilha rotulos;
pilha num_vars_p;

int proxRotulo;
int tipoAtual;
int numParamCallProc;
int ignoraVariavelFunc;

struct parametro *paramsProcAtual;
struct parametro *paramsProcAtualP;
int parVarRef;

pilha numProcs;

int strToType(const char *str){
  if (!strcmp(str, "integer")) return integer_pas;
  if (!strcmp(str, "boolean")) return boolean_pas;
  if (!strcmp(str, "char")) return char_pas;
  if (!strcmp(str, "real")) return real_pas;
  return indefinido_pas;
}

// retornam índice do último simbolo que foi impresso
int printLabels(tabela t, int il);
int printProcs(tabela t, int ip);
int printVars(tabela t, int iv);
int printParams(tabela t, int ip);
int printCommands(tabela t, int ic);

void sprintf_tipo(char *string, int tipo) {
  switch (tipo) {
    case integer_pas:
      sprintf(string, "integer"); break;
    case boolean_pas:
      sprintf(string, "boolean"); break;
    case char_pas:
      sprintf(string, "char"); break;
    case real_pas:
      sprintf(string, "real"); break;
    default:
      sprintf(string, "%d", tipo); break;
  }
}

//             tabela   indice label
int printLabels(tabela t, int il) {
  int nivelLex = t.pilha[il].nivel_lexico;
  char *linha = (char *)malloc(sizeof(char)*TAM_LINHA);
  sprintf(linha, "\"labels\": [");
  strcat(linha, "\""); strcat(linha, t.pilha[il].identificador); strcat(linha, "\"");
  while (il+1 <= t.topo && t.pilha[il+1].tipo_simbolo == label) {
    il++;
    strcat(linha, ",\""); strcat(linha, t.pilha[il].identificador); strcat(linha, "\"");
  }
  sprintf(linha, "]%c", il+1 > t.topo ? '\0' : ',');
  escreveLinha(linha);
  return il;
}

//             tabela   indice procedimento
int printProcs(tabela t, int ip) {
  int nivelLex = t.pilha[ip].nivel_lexico;
  char *linha = (char *)malloc(sizeof(char)*TAM_LINHA);
  sprintf(linha, "\"procedimentos\": {");
  escreveLinha(linha);
  while(ip <= t.topo && t.pilha[ip].tipo_simbolo == procedimento) {
    sprintf(linha, "\"%s\": {", t.pilha[ip].identificador);
    escreveLinha(linha);
    if (t.pilha[ip].conteudo.proc.tipo_retorno) {
      char *tipo = (char *)malloc(sizeof(char)*20);
      sprintf_tipo(tipo, t.pilha[ip].conteudo.proc.tipo_retorno);
      sprintf(linha, "\"tipo_retorno\": \"%s\"", tipo);
      // se terá mais um atributo nesse procedimento
      if ( (t.pilha[ip+1].nivel_lexico > nivelLex && t.pilha[ip+1].tipo_simbolo == procedimento) ||
           (t.pilha[ip+1].nivel_lexico == nivelLex && t.pilha[ip+1].tipo_simbolo != procedimento) )
           strcat(linha, ",");
      escreveLinha(linha);
      free(tipo);
    }
    //parametros
    if (t.pilha[ip+1].nivel_lexico == nivelLex && t.pilha[ip+1].tipo_simbolo == parametro) {
      ip = printParams(t, ip+1);
    }
    //label
    if (t.pilha[ip+1].nivel_lexico == nivelLex && t.pilha[ip+1].tipo_simbolo == label) {
      ip = printLabels(t, ip+1);
    }
    //var
    if (t.pilha[ip+1].nivel_lexico == nivelLex && t.pilha[ip+1].tipo_simbolo == variavel) {
      ip = printVars(t, ip+1);
    }
    //procs
    if (t.pilha[ip+1].nivel_lexico > nivelLex && t.pilha[ip+1].tipo_simbolo == procedimento) {
      ip = printProcs(t, ip+1);
    }
    if (t.pilha[ip+1].nivel_lexico == nivelLex && t.pilha[ip+1].tipo_simbolo == comando) {
      ip = printCommands(t, ip+1);
    }
    ip++;
    escreveLinha("fim de um procedimento");
    ip > t.topo || t.pilha[ip].tipo_simbolo != procedimento ? escreveLinha("}") : escreveLinha("},");
  }
  escreveLinha("fim desse conjunto de procedimentos");
  ip > t.topo ? escreveLinha("}") : escreveLinha("},");
  return ip-1;
}

//             tabela   indice variavel
int printVars(tabela t, int iv) {
  int nivelLex = t.pilha[iv].nivel_lexico;
  char *linha = (char *)malloc(sizeof(char)*TAM_LINHA);
  sprintf(linha, "\"variaveis\": {");
  escreveLinha(linha);
  while (iv <= t.topo && t.pilha[iv].tipo_simbolo == variavel && t.pilha[iv].nivel_lexico == nivelLex) {
    sprintf(linha, "\"%s\": {", t.pilha[iv].identificador);
    escreveLinha(linha);
    //tipo da variavel
    char *tipo = (char *)malloc(sizeof(char)*20);
    sprintf_tipo(tipo, t.pilha[iv].conteudo.proc.tipo_retorno);
    sprintf(linha, "\"tipo\": \"%s\"", tipo);
    escreveLinha(linha);
    iv++;
    escreveLinha("fim de uma variavel");
    iv > t.topo || t.pilha[iv].tipo_simbolo != variavel ? escreveLinha("}") : escreveLinha("},");
  }
  escreveLinha("fim de um conjunto de variaveis");
  if (iv > t.topo ||
     (t.pilha[iv].nivel_lexico == nivelLex && t.pilha[iv].tipo_simbolo == procedimento) ||
     (t.pilha[iv].nivel_lexico < nivelLex))
          { escreveLinha("}"); }
  else if (t.pilha[iv].nivel_lexico == nivelLex ||
          (t.pilha[iv].nivel_lexico > nivelLex && t.pilha[iv].tipo_simbolo == procedimento))
          { escreveLinha("},"); }
  return iv-1;
}

//             tabela   indice parametro
int printParams(tabela t, int ip) {
  int nivelLex = t.pilha[ip].nivel_lexico;
  char *linha = (char *)malloc(sizeof(char)*TAM_LINHA);
  sprintf(linha, "\"parametros\": {");
  escreveLinha(linha);
  while (ip <= t.topo && t.pilha[ip].tipo_simbolo == parametro && t.pilha[ip].nivel_lexico == nivelLex) {
    sprintf(linha, "\"%s\": {", t.pilha[ip].identificador);
    escreveLinha(linha);
    sprintf(linha, "\"tipo_passagem\": \"%s\",", t.pilha[ip].conteudo.par.tipo_passagem == valor_par ? "valor" : "referencia");
    escreveLinha(linha);
    //tipo do parametro
    char *tipo = (char *)malloc(sizeof(char)*20);
    sprintf_tipo(tipo, t.pilha[ip].conteudo.proc.tipo_retorno);
    sprintf(linha, "\"tipo\": \"%s\"", tipo);
    escreveLinha(linha);
    ip++;
    escreveLinha("fim de um parametro");
    ip > t.topo || t.pilha[ip].tipo_simbolo != parametro ? escreveLinha("}") : escreveLinha("},");
  }
  escreveLinha("fim de um conjunto de parametros");
  if (ip > t.topo ||
     (t.pilha[ip].nivel_lexico == nivelLex && t.pilha[ip].tipo_simbolo == procedimento) ||
     (t.pilha[ip].nivel_lexico < nivelLex))
          { escreveLinha("}"); }
  else if (t.pilha[ip].nivel_lexico == nivelLex ||
          (t.pilha[ip].nivel_lexico > nivelLex && t.pilha[ip].tipo_simbolo == procedimento))
          { escreveLinha("},"); }
  return ip-1;
}

int printCommands(tabela t, int ic) {
  int nivelLex = t.pilha[ic].nivel_lexico;
  char *linha = (char *)malloc(sizeof(char)*TAM_LINHA);
  escreveLinha("\"comandos\": {");
  while (ic <= t.topo && t.pilha[ic].nivel_lexico == nivelLex &&
         t.pilha[ic].tipo_simbolo == comando) {
    sprintf(linha, "\"%s\": {", t.pilha[ic].identificador);
    escreveLinha(linha);
    ic++;
    if (t.pilha[ic].tipo_simbolo == fimcomando) {
      ic++;
      escreveLinha("acabou um comando");
      if (ic > t.topo || t.pilha[ic].tipo_simbolo == fimcomando) {
        ic++;
        escreveLinha("}");
      }
      else {
        escreveLinha("},");
      }
    }
  }
  escreveLinha("acabou um conjunto de comandos");
  escreveLinha("}");
  return ic-1;
}

void printTabela(tabela t) {
  escreveLinha("{");
  for(int i = 0; i <= t.topo; i++){
    //label
    if (t.pilha[i].tipo_simbolo == label) {
      i = printLabels(t, i);
    }
    //var
    else if (t.pilha[i].tipo_simbolo == variavel) {
      i = printVars(t, i);
    }
    //procs
    else if (t.pilha[i].tipo_simbolo == procedimento) {
      i = printProcs(t, i);
    }
    //comandos
    else if (t.pilha[i].tipo_simbolo == comando) {
      i = printCommands(t, i);
    }
  }
  escreveLinha("}");
}
%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR NUMERO IDENT ATRIBUICAO
%token LABEL TYPE ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO
%token OR DIV AND NOT OF VEZES MAIS MENOS
%token MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL DIFERENTE IGUAL
%token ABRE_COLCHETES FECHA_COLCHETES ABRE_CHAVES FECHA_CHAVES
%token WRITE READ MOD

%union{
   char *str;  // define o tipo str
   int int_val; // define o tipo int_val
//    simb *simbPtr;
}

%type <str> vezes_div_and;
%type <str> mais_menos_or;
%type <str> mais_menos_vazio;
%type <str> relacao;
%type <int_val> expressao;
%type <int_val> expressao_simples;
%type <int_val> fator;
%type <int_val> termo;

%nonassoc "lower_than_else"
%nonassoc ELSE

%%

// REGRA 01
programa    :{
             inicializa(&t);
             inicializa(&permanente);
             pilha_init(&rotulos);
             pilha_init(&num_vars_p);
             pilha_pop(&numProcs);
             proxRotulo = 0;
             nivelLexico = 0;
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             pilha_pop(&num_vars_p);
             }
;

// REGRA 02
bloco       :
              parte_declara_labels
              parte_declara_vars {
                sprintf(mepaTemp, "DSVS R%02d", proxRotulo);
                pilha_push(&rotulos, proxRotulo);
                proxRotulo++;

                nivelLexico++;
              }
              parte_declara_subrotinas {
                nivelLexico--;

                sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos));
                pilha_pop(&rotulos);
              }

              comando_composto{
                sprintf(mepaTemp, "DMEM %d", pilha_topo(&num_vars_p));
                removeN(&t, pilha_topo(&num_vars_p));
                pilha_pop(&num_vars_p);
              }
;

// REGRA 03
parte_declara_labels: LABEL
                    declara_labels PONTO_E_VIRGULA
                    |
;

declara_labels: declara_labels VIRGULA label
              | label
;

label: NUMERO {
     simboloTemp = criaSimbolo(token, label, nivelLexico, conteudoTemp);
     push(&t, simboloTemp);
     push(&permanente, simboloTemp);
     }
;

// REGRA 08
parte_declara_vars: {
                  num_vars = 0;
                  } VAR declara_vars {
                    sprintf(mepaTemp, "AMEM %d", num_vars);
                    pilha_push(&num_vars_p, num_vars);
                  }
                  | {pilha_push(&num_vars_p, 0);}
;

// REGRA 09
declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : {}
              lista_id_var DOIS_PONTOS
              {}
              tipo
              {qtTipoAtual = 0;
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT {
            tipoAtual = strToType(token);
            atribuiTipo(&t, tipoAtual, qtTipoAtual);
            atribuiTipo(&permanente, tipoAtual, qtTipoAtual);
            }
;


// REGRA 10
lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

lista_id_var: lista_id_var VIRGULA var
            | var
;

var: IDENT  {
   conteudoTemp.var.deslocamento = num_vars;
   simboloTemp = criaSimbolo(token, variavel, nivelLexico, conteudoTemp);
   push(&t, simboloTemp);
   push(&permanente, simboloTemp);
   qtTipoAtual++;
   num_vars++;
   }
;

// REGRA 11
parte_declara_subrotinas: parte_declara_subrotinas declara_proc PONTO_E_VIRGULA
                        | parte_declara_subrotinas declara_func PONTO_E_VIRGULA
                        |
;

// REGRA 12
declara_proc:
            PROCEDURE
            IDENT {
              conteudoTemp.proc.tipo_retorno = indefinido_pas;
              conteudoTemp.proc.rotulo = proxRotulo;
              conteudoTemp.proc.num_parametros = 0;
              simboloTemp = criaSimbolo(token, procedimento, nivelLexico, conteudoTemp);
              push(&t, simboloTemp);
              paramsProcAtual = busca(&t, token)->conteudo.proc.lista;
              simbFuncDeclara = busca(&t, token);

              push(&permanente, simboloTemp);
              paramsProcAtualP = busca(&permanente, token)->conteudo.proc.lista;
              simbFuncDeclaraP = busca(&permanente, token);
              numParamProc = 0;
            }
            talvez_params_formais
            {
              sprintf(mepaTemp, "ENPR %d", nivelLexico);
              sprintf(rotrTemp, "R%02d", proxRotulo);
              atribuiDeslocamento(&t, numParamProc);
              atribuiDeslocamento(&permanente, numParamProc);

              proxRotulo++;
            }
            PONTO_E_VIRGULA
            bloco
            {
              removeAte(&t, nivelLexico);
              sprintf(mepaTemp, "RTPR %d, %d", nivelLexico, topo(&t).conteudo.proc.num_parametros);
            }
;

// REGRA 13
declara_func:
            FUNCTION
            IDENT {
              conteudoTemp.proc.tipo_retorno = indefinido_pas;
              conteudoTemp.proc.rotulo = proxRotulo;
              conteudoTemp.proc.num_parametros = 0;
              simboloTemp = criaSimbolo(token, procedimento, nivelLexico, conteudoTemp);
              push(&t, simboloTemp);
              paramsProcAtual = busca(&t, token)->conteudo.proc.lista;
              simbFuncDeclara = busca(&t, token);

              push(&permanente, simboloTemp);
              paramsProcAtualP = busca(&permanente, token)->conteudo.proc.lista;
              simbFuncDeclaraP = busca(&permanente, token);
              numParamProc = 0;
            }
            talvez_params_formais
            {
              sprintf(mepaTemp, "ENPR %d", nivelLexico);
              sprintf(rotrTemp, "R%02d", proxRotulo);
              atribuiDeslocamento(&t, numParamProc);
              atribuiDeslocamento(&permanente, numParamProc);

              proxRotulo++;
            }
            DOIS_PONTOS
            tipo
            {
              simbFuncDeclara = busca(&t, simbFuncDeclara->identificador);
              simbFuncDeclara->conteudo.proc.tipo_retorno = tipoAtual;

              simbFuncDeclaraP = busca(&permanente, simbFuncDeclaraP->identificador);
              simbFuncDeclaraP->conteudo.proc.tipo_retorno = tipoAtual;
            }
            PONTO_E_VIRGULA
            bloco
            {
              removeAte(&t, nivelLexico);
              sprintf(mepaTemp, "RTPR %d, %d", nivelLexico, topo(&t).conteudo.proc.num_parametros);

            }
;

// REGRA 14
talvez_params_formais: params_formais |
;

params_formais: ABRE_PARENTESES parametros FECHA_PARENTESES
;

parametros: secoes_parametros {
            simbFuncDeclara = busca(&t, simbFuncDeclara->identificador);
            memcpy(simbFuncDeclara->conteudo.proc.lista,
              paramsProcAtual,
              numParamProc*sizeof(struct parametro));
            simbFuncDeclaraP = busca(&permanente, simbFuncDeclaraP->identificador);
            memcpy(simbFuncDeclaraP->conteudo.proc.lista,
              paramsProcAtualP,
              numParamProc*sizeof(struct parametro));
          }
;

secoes_parametros:
                 secoes_parametros PONTO_E_VIRGULA{qtTipoAtual =0;}
                 lista_de_parametros DOIS_PONTOS tipo{
                   for(int i = numParamProc - qtTipoAtual;
                       i < numParamProc;
                       i++){
                       paramsProcAtual[i].tipo = tipoAtual;
                       paramsProcAtualP[i].tipo = tipoAtual;
                   }
                 }
                 |{qtTipoAtual =0;}
                 lista_de_parametros DOIS_PONTOS tipo{
                   for(int i = numParamProc - qtTipoAtual;
                       i < numParamProc;
                       i++){
                       paramsProcAtual[i].tipo = tipoAtual;
                       paramsProcAtualP[i].tipo = tipoAtual;
                   }
                 }
;

lista_de_parametros:
                   lista_de_parametros VIRGULA param {
                   }
                   | talvez_var param {
                   }
;

param: IDENT {
       conteudoTemp.par.tipo_passagem = parVarRef;
       simboloTemp = criaSimbolo(token, parametro, nivelLexico, conteudoTemp);
       push(&t, simboloTemp);
       push(&permanente, simboloTemp);
       qtTipoAtual++;
       paramsProcAtual[numParamProc].tipo_passagem = parVarRef;
       paramsProcAtualP[numParamProc].tipo_passagem = parVarRef;
       numParamProc++;
     }
;

talvez_var: VAR {parVarRef = referencia_par;}
          | {parVarRef = valor_par;}
;

// REGRA 16
comando_composto: T_BEGIN comandos T_END

comandos: comandos PONTO_E_VIRGULA comando
        | comando
;

// REGRA 17
comando: NUMERO {
        sprintf(mepaTemp, "ENRT %d, %d", nivelLexico, pilha_topo(&num_vars_p));
       }DOIS_PONTOS comando_sem_rotulo
       | comando_sem_rotulo
;

// REGRA 18
comando_sem_rotulo: atribuicao_proc_ou_func
                  | comando_repetitivo
                  | comando_condicional
                  | comando_composto
                  | leitura
                  | escrita
                  | desvio
                  |
;

leitura: READ ABRE_PARENTESES itens_leitura FECHA_PARENTESES
;

itens_leitura: itens_leitura VIRGULA item_leitura | item_leitura
;

item_leitura: IDENT
            {
              simboloPtr = busca(&t, token);
              if (!simboloPtr){
                fprintf(stderr, "COMPILATION ERROR\n Cannot read to varible %s is not in scope\n",
                token);
                exit(1);
              }
              simboloTemp = *simboloPtr;
              sprintf(mepaTemp, "ARMZ %d, %d", simboloTemp.nivel_lexico,
                simboloTemp.conteudo.var.deslocamento);
            }
;

escrita: WRITE ABRE_PARENTESES itens_escrita FECHA_PARENTESES
;

itens_escrita: itens_escrita VIRGULA expressao {}
             | expressao {}
;

atribuicao_proc_ou_func: IDENT
                       {
                        simbVarProcPtr = busca(&t, token);
                        if (!simbVarProcPtr) {
                          fprintf(stderr, "COMPILATION ERROR!\n Variable, procedure or function %s was not declared.\n"
                          , token); 
                          exit(1);
                        }
                       }
                       a_continua
                       {
                       }
;

a_continua:
          {
            simbAtribuicao = *simbVarProcPtr;
          }
          ATRIBUICAO atribuicao
          | proc_sem_param
          | proc_com_param
;


// REGRA 19
atribuicao:
          expressao
          {
            if ($1 != simbAtribuicao.conteudo.var.tipo) {
              fprintf(stderr, "COMPILATION ERROR!\n Atributing wrong type to variable\n");
              exit(1);
            }
            // armazena em variavel e função
            if (simbAtribuicao.tipo_simbolo == variavel ||
              simbAtribuicao.tipo_simbolo == procedimento){
              sprintf(mepaTemp, "ARMZ %d, %d",
              simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
            }
            else if (simbAtribuicao.tipo_simbolo == parametro){
              //salvar por valor
              if (simbAtribuicao.conteudo.par.tipo_passagem == valor_par){
                sprintf(mepaTemp, "ARMZ %d, %d",
                simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
              }
              //salvar por referencia
              else {
                sprintf(mepaTemp, "ARMI %d, %d",
                simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
              }
            }
          }
;

proc_sem_param:{
                simboloTemp = *simbVarProcPtr;
                if(simboloTemp.tipo_simbolo != procedimento) {
                  fprintf(stderr, "COMPILATION ERROR!\n Symbol %s is not procedure\n"
                  ,token);
                  exit(1);
                }
                if (simboloTemp.conteudo.proc.num_parametros != 0) {
                    fprintf(stderr, "COMPILATION ERROR!\n Procedure called incorrectly\n");
                    exit(1);
                }
                if (simboloTemp.conteudo.proc.tipo_retorno != indefinido_pas){
                }
                sprintf(mepaTemp, "CHPR R%02d, %d", simboloTemp.conteudo.proc.rotulo, nivelLexico);
              }
;

// REGRA 20
proc_com_param:
              {
                simbCallProc = *simbVarProcPtr;
                if (simbCallProc.tipo_simbolo != procedimento ||
                    simbCallProc.conteudo.proc.num_parametros == 0) {
                    fprintf(stderr, "COMPILATION ERROR!\n Procedure called incorrectly\n");
                    exit(1);
                }
                if (simbCallProc.conteudo.proc.tipo_retorno){
                }
                chamandoProc = 1;
              }
              ABRE_PARENTESES
              {numParamCallProc = 0;}
              lista_de_expressoes
              {
                if (numParamCallProc != simbCallProc.conteudo.proc.num_parametros){
                  fprintf(stderr, "COMPILATION ERROR!\n Procedure with wrong number of params\n");
                  fprintf(stderr, "%d\n", numParamCallProc);
                  exit(1);
                }
                sprintf(mepaTemp, "CHPR R%02d, %d", simbCallProc.conteudo.proc.rotulo,
                nivelLexico);
                chamandoProc = 0;
              }
              FECHA_PARENTESES
;

// REGRA 21
desvio: GOTO NUMERO {
      simboloPtr = busca(&t, token);
      if (!simboloPtr) {
        fprintf(stderr, "COMPILATION ERROR\n Label %s was not declared\n", token);
        exit(1);
      }
      simboloTemp = *simboloPtr;
      sprintf(mepaTemp, "DSVR %s, %02d, %d", simboloTemp.identificador,
        simboloTemp.nivel_lexico, nivelLexico);
      }
;

// REGRA 22
comando_condicional:
                  IF expressao {
                    // desvia falso pra else
                    if ($2 != boolean_pas){
                      fprintf(stderr, "COMPILATION ERROR\n Cannot do if with integer expression\n");
                      exit(1);
                    }
                    sprintf(mepaTemp, "DSVF R%02d", proxRotulo+1);
                    // empilha rotulo
                    pilha_push(&rotulos, proxRotulo);
                    proxRotulo+=2;

                    sprintf(commandTemp, "If%03d", counterComandos++);
                    simboloTempP = criaSimbolo(commandTemp, comando, nivelLexico, conteudoTempP);
                    push(&permanente, simboloTempP);
                  }
                  THEN comando_sem_rotulo {
                    // desvia sempre fim else
                    sprintf(mepaTemp, "DSVS R%02d", pilha_topo(&rotulos));

                    // rotulo else
                    sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos)+1);

                  }
                  talvez_else {
                    // rotulo fim else
                    sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos));

                    pilha_pop(&rotulos);

                    sprintf(commandTemp, "null", counterComandos);
                    simboloTempP = criaSimbolo(commandTemp, fimcomando, nivelLexico, conteudoTempP);
                    push(&permanente, simboloTempP);
                  }
;

talvez_else: ELSE {
                    sprintf(commandTemp, "Else%03d", counterComandos++);
                    simboloTempP = criaSimbolo(commandTemp, comando, nivelLexico, conteudoTempP);
                    push(&permanente, simboloTempP);
           }
           comando_sem_rotulo {
                    sprintf(commandTemp, "null", counterComandos);
                    simboloTempP = criaSimbolo(commandTemp, fimcomando, nivelLexico, conteudoTempP);
                    push(&permanente, simboloTempP);
           }
           | %prec "lower_than_else"
;

// REGRA 23
comando_repetitivo: WHILE {
                      pilha_push(&rotulos, proxRotulo);
                      sprintf(rotrTemp, "R%02d", proxRotulo);

                      sprintf(commandTemp, "While%03d", counterComandos++);
                      simboloTempP = criaSimbolo(commandTemp, comando, nivelLexico, conteudoTempP);
                      push(&permanente, simboloTempP);

                      proxRotulo += 2;
                    }
                    expressao
                    DO {
                      sprintf(mepaTemp, "DSVF R%02d", pilha_topo(&rotulos)+1);
                    } comando_sem_rotulo {
                      
                      sprintf(mepaTemp, "DSVS R%02d", pilha_topo(&rotulos));
                      
                      sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos)+1);

                      pilha_pop(&rotulos);

                      sprintf(commandTemp, "null", counterComandos);
                      simboloTempP = criaSimbolo(commandTemp, fimcomando, nivelLexico, conteudoTempP);
                      push(&permanente, simboloTempP);
                    }
;

// REGRA 24
lista_de_expressoes: lista_de_expressoes VIRGULA {numParamCallProc++;}expressao 
                   |  {numParamCallProc++;}expressao 
                   |
;

// REGRA 25
expressao: expressao_simples { $$ = $1; }
         | expressao_simples relacao expressao_simples
            {
            if ($1 != $3 ) {
              fprintf(stderr, "COMPILATION ERROR!\n Cannot compare expressions with diferent types\n");
              exit(1);
            }
            $$ = boolean_pas;
            }
;

// REGRA 26
relacao: IGUAL       { $$ = "CMIG"; }
       | DIFERENTE   { $$ = "CMDG"; }
       | MENOR       { $$ = "CMME"; }
       | MENOR_IGUAL { $$ = "CMEG"; }
       | MAIOR       { $$ = "CMMA"; }
       | MAIOR_IGUAL { $$ = "CMAG"; }
;

// REGRA 27
expressao_simples: expressao_simples mais_menos_or termo {
                  if (!strcmp($2, "DISJ")){
                    if($1 != boolean_pas || $3 != boolean_pas){
                      fprintf(stderr, "COMPILATION ERROR!\n Operation OR must be between two booleans\n");
                      exit(1);
                    }
                    $$ = boolean_pas;
                  }
                  else {
                    if($1 != integer_pas || $3 != integer_pas){
                      fprintf(stderr, "COMPILATION ERROR!\n Operation + and - must be between two integers\n");
                      exit(1);
                    }
                    $$ = integer_pas;
                  }
                }
                |
                mais_menos_vazio termo {
                  if (strcmp($1, "VAZIO")){
                    if ($2 == boolean_pas) {
                      fprintf(stderr, "COMPILATION ERROR!\n Signed variable must be integer\n");
                      exit(1);
                    }
                  }
                  $$ = $2;

                }
;

mais_menos_or:
             MAIS  {$$ = "SOMA"; }|
             MENOS {$$ = "SUBT"; }|
             OR    {$$ = "DISJ"; }
;

mais_menos_vazio:
             MAIS  { $$ = "MAIS"; }|
             MENOS { $$ = "MENOS";}|
                   { $$ = "VAZIO";}
;

// REGRA 28
termo: termo vezes_div_and fator
    {
      if (!strcmp($2, "CONJ")) {
        if ($1 != boolean_pas || $3 != boolean_pas){
          fprintf(stderr, "COMPILATION ERROR!\n Operation AND must be made between booleans\n");
          exit(1);
        }
      }
      else {
        if ($1 != integer_pas || $3 != integer_pas){
          fprintf(stderr, "COMPILATION ERROR!\n Operation must be made between integers\n");
          exit(1);
        }
      }
      $$ = $3;

    }
    | fator { $$ = $1; }
;

vezes_div_and:
              VEZES { $$ = "MULT"; }
            | DIV { $$ = "DIVI"; }
            | MOD { $$ = "DIVI"; }
            | AND { $$ = "CONJ"; }
;

// REGRA 29
fator: variavel_ou_func {
      int passarPara = valor_par;
      if (chamandoProc){
        passarPara = simbCallProc.conteudo.proc.lista[numParamCallProc-1].tipo_passagem;
      }
      if (ignoraVariavelFunc) {
        ignoraVariavelFunc = 0;
      }
      else{
        if (simboloTemp.tipo_simbolo == variavel){
          // passar pra um q pede por valor ou carregar normal
          if (passarPara){
            sprintf(mepaTemp, "CRVL %d, %d",
              simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
          }
          // passar pra um q pede por referencia
          else {
            sprintf(mepaTemp, "CREN %d, %d",
              simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
          }
        }
        else if (simboloTemp.tipo_simbolo == procedimento){
          sprintf(mepaTemp, "AMEM 1");
          sprintf(mepaTemp, "CHPR R%02d, %d", simboloTemp.conteudo.proc.rotulo, nivelLexico);
        }
        else if (simboloTemp.tipo_simbolo == parametro){
          //se foi passado por valor
          if (simboloTemp.conteudo.par.tipo_passagem == valor_par){
            if(passarPara){
              sprintf(mepaTemp, "CRVL %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            }
            else{
              sprintf(mepaTemp, "CREN %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            }
          }
          //se foi passado por referencia
          else {
            if(passarPara){
              sprintf(mepaTemp, "CRVI %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            }
            else{
              sprintf(mepaTemp, "CRVL %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            }
          }
        }
      }
      $$ = simboloTemp.conteudo.var.tipo;
    }
    | NUMERO {
      sprintf(mepaTemp, "CRCT %s", token);
      $$ = integer_pas;
    }
    | ABRE_PARENTESES expressao FECHA_PARENTESES { $$ = $2; }
;

// REGRA 30
variavel_ou_func: IDENT {
          simboloPtr = busca(&t, token);
          if (!simboloPtr) {
            fprintf(stderr, "COMPILATION ERROR\n Variable %s not declared\n", token);
            exit(1);
          }
          simboloTemp = *simboloPtr;
          ignoraVariavelFunc = 0;
        }
        talvez_params_func
;

talvez_params_func: ABRE_PARENTESES
                  {
                   numParamCallProc = 0;
                   chamandoProc = 1;
                   simbCallProc = simboloTemp;
                  }
                  lista_params_reais
                  FECHA_PARENTESES
                  {
                  chamandoProc = 0;
                  sprintf(mepaTemp, "CHPR R%02d, %d", simbCallProc.conteudo.proc.rotulo, nivelLexico);
                  ignoraVariavelFunc = 1;
                  }
                  |
;

lista_params_reais: lista_params_reais VIRGULA {numParamCallProc++;} expressao_simples
                  | {numParamCallProc++;} expressao_simples
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   char *pathOutput = (char *)malloc(sizeof(char) * 256);
   strcpy(pathOutput, argv[1]);
   strcat(pathOutput, ".json");
   printf("Arquivo de entrada: %s\n", argv[1]);
   printf("Arquivo de saida: %s\n", pathOutput);
   configuraArquivo(pathOutput);
   yyparse();
   printTabela(permanente);

   return 0;
}
