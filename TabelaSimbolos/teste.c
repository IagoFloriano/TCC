#include "simbolo.h"
#include "tabelaSimbolo.h"
#include <stdio.h>

void printSimbolo(simb s, int tablevel){
  for(int i = 0; i < tablevel; i++){printf("\t");}
  char *tipos[] = {"PROC", "VAR", "PARAM"};
  //    ident  tipo  infos
  printf("%s\t%s\t",s.identificador,
      tipos[s.tipo_simbolo]);

  char *tiposVar[] = {"erro","int","bool"};
  switch(s.tipo_simbolo){
    case variavel:
      printf("%2d, %2d, %s\n",
          s.nivel_lexico, s.conteudo.var.deslocamento, tiposVar[s.conteudo.var.tipo]);
      break;
    case procedimento:
      break;
    case parametro:
      printf("%2d, %2d, %s, %s\n",
          s.nivel_lexico, s.conteudo.par.deslocamento, tiposVar[s.conteudo.par.tipo],
          s.conteudo.par.tipo_passagem ? "vlr" : "ref");
      break;
    default:
      printf("ERRO\n");
  }
}

void printTabela(tabela t){
  for(int i = t.topo; i >= 0; i--){
    printSimbolo(t.pilha[i], 1);
  }
}

int main(){
  t_conteudo c;
  c.var.deslocamento = 3;
  c.var.tipo = integer_pas;
  c.par.tipo_passagem = valor_par;

  printf("criaSimbolo(\"teste\", parametro, 0, c){\n");
  simb s = criaSimbolo("teste", parametro, 0, c);
  printSimbolo(s, 1);
  printf("}\n\n");

  tabela t;
  printf("inicializa(&t){\n");
  inicializa(&t);
  printTabela(t);
  printf("}\n\n");

  printf("push(&t, s){\n");
  push(&t, s);
  printTabela(t);
  printf("}\n\n");

  printf("push(&t, s){\n");
  push(&t, s);
  printTabela(t);
  printf("}\n\n");

  printf("push(&t, s){\n");
  push(&t, s);
  printTabela(t);
  printf("}\n\n");

  simb s2;
  printf("s2 = pop(&t){\n");
  s2 = pop(&t);
  printSimbolo(s2, 1);
  printf("\n");
  printTabela(t);
  printf("}\n\n");

  printf("push(&t, s2{foi modificado o deslocamento}){\n");
  s2.conteudo.var.deslocamento = 2;
  push(&t, s2);
  printTabela(t);
  printf("}\n\n");

  printf("busca(&t, \"teste\"){\n");
  simb *sp = busca(&t, "teste");
  printSimbolo(*sp, 1);
  printf("\n");
  printTabela(t);
  printf("}\n\n");

  printf("atribuiTipo(&t, boolean_pas, 2){\n");
  atribuiTipo(&t, boolean_pas, 2);
  printTabela(t);
  printf("}\n\n");

  printf("removeN(&t, 2){\n");
  removeN(&t, 2);
  printTabela(t);
  printf("}\n\n");

  return 0;
}
