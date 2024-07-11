class Arvore {
  raiz;
  altura;
  largura;

  constructor() {
    this.altura = 0;
    this.largura = 0;
    this.larguras = [];
    this.matriz = [];
  }

  // entrada sendo uma string em formato json
  constroi(entrada) {
    let obj = JSON.parse(entrada);

    if (obj.hasOwnProperty("comandos")) {
      this.raiz = new No("Program", 0);
      this.altura = this.raiz.processaObj(obj["comandos"]);
    }
    this.larguras = this.raiz.calculaLarguras();
    console.log(this.larguras);
    this.largura = Math.max(...this.larguras);
    for (let i = 0; i <= this.altura; i++) {
      this.matriz.push(new Array(this.largura));
    }
    this.raiz.posMaisEsquerda(this.matriz);
    console.log(this.matriz);
  }

  imprimePreOrdem() {
    console.log(`${this.altura}x${this.largura}`);
    this.raiz.imprimePreOrdem();
  }
}

class No {
  comando = "";
  filhos = [];
  altura;
  largura = -1;

  constructor(comando, altura) {
    this.comando = comando;
    this.altura = altura;
  }

  processaObj(obj) {
    let subcomandos = Object.keys(obj);
    let alturaRetorno = this.altura;
    subcomandos.forEach((chave) => {
      let novoFilho = new No(chave, this.altura + 1);
      let novaAltura = novoFilho.processaObj(obj[chave]);
      alturaRetorno = novaAltura > alturaRetorno ? novaAltura : alturaRetorno;
      this.filhos.push(novoFilho);
    })
    return alturaRetorno;
  }

  calculaLarguras() {
    let larguras = [1];
    let soma = [];
    this.filhos.forEach((filho) => {
      let novaSoma = this.somaArrays(soma, filho.calculaLarguras());
      soma = novaSoma;
    });
    return larguras.concat(soma);
  }

  posMaisEsquerda(matriz) {
    let i = 0;
    while (!!(matriz[this.altura][i])) {
      i++;
    }
    matriz[this.altura][i] = this;
    this.largura = i;
    this.filhos.forEach((filho) => {
      filho.posMaisEsquerda(matriz);
    });
  }

  somaArrays(a, b) {
    let c = [];
    let menor;
    let maior;
    if (a.length < b.length) {menor = a; maior = b}
    else {menor = b; maior = a}
    for (let i = 0; i < menor.length; i++) {
      c.push(menor[i] + maior[i]);
    }
    for (let i = menor.length; i < maior.length; i++) {
      c.push(maior[i]);
    }
    return c;
  }

  imprimePreOrdem() {
    let tabs = "";
    console.log(`${this.comando.substring(0,this.comando.length-3)}(${this.altura}x${this.largura})`);
    this.filhos.forEach((filho) => filho.imprimePreOrdem());
  }
}
