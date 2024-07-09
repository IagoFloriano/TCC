export default class Arvore {
  raiz;
  altura;
  largura;

  constructor() {
    this.altura = 0;
    this.largura = 0;
  }

  // entrada sendo uma string em formato json
  constroi(entrada) {
    let obj = JSON.parse(entrada);

    if (obj.hasOwnProperty("comandos")) {
      this.raiz = new No("Program");
      this.raiz.processaObj(obj["comandos"]);
    }
  }

  atualizaAlturaLargura() {
  }

  imprimePreOrdem() {
    raiz.imprimePreOrdem();
  }
}

class No {
  comando = "";
  filhos = [];

  constructor(comando) {
    this.comando = comando;
  }

  processaObj(obj) {
    for (chave in obj) {
      let novoFilho = new No(chave);
      novoFilho.processaObj(obj[chave]);
      filhos.push(new No(chave));
    }
  }

  imprimePreOrdem() {
    console.log(`${this.comando}:`); // ${!!tempObj ? tempObj : null}`);
    for (filho in this.filhos) {
      filho.imprimePreOrdem();
    }
  }
}
