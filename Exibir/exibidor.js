// import Arvore from './arvore.js';

var input = ' { ' +
' "variaveis": { ' +
' "n": { ' +
' "tipo": "integer" ' +
' } ' +
' }, ' +
' "procedimentos": { ' +
' "collatzStep": { ' +
' "tipo_retorno": "integer", ' +
' "parametros": { ' +
' "n": { ' +
' "tipo_passagem": "valor", ' +
' "tipo": "integer" ' +
' } ' +
' }, ' +
' "comandos": { ' +
' "If000": { ' +
' "Atribuicao001": { ' +
' }, ' +
' "Else002": { ' +
' "Atribuicao003": { ' +
' } ' +
' } ' +
' } ' +
' } ' +
' } ' +
' }, ' +
' "comandos": { ' +
' "Leitura004": { ' +
' }, ' +
' "While005": { ' +
' "Atribuicao006": { ' +
' } ' +
' }, ' +
' "Escrita007": { ' +
' } ' +
' } ' +
' } ';

function main(input) {
  let obj = JSON.parse(input);
  let arv = new Arvore();
  arv.constroi(obj, "Program");
  arv.imprimePreOrdem();
  let procs = [];
  let procsObjs = Object.keys(obj["procedimentos"]);
  procsObjs.forEach((procedimento) => {
    console.log(procedimento);
    let novaArv = new Arvore();
    novaArv.constroi(obj["procedimentos"][procedimento], procedimento);
    procs.push(novaArv);
    novaArv.imprimePreOrdem();
  });
  console.log(procs);
}

// Cuida dos valores da linha de comando
main(input);
//if (process.argv.length != 3) {
//  console.log(`Uso correto: node ${process.argv[1].split('/').reverse()[0]} <entrada.json>`);
//}
//else {
//  main(process.argv[2])
//}
