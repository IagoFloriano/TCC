const lerp = (x, y, a) => x * (1 - a) + y * a;

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
' "n": { ' + ' "tipo_passagem": "valor", ' +
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

function processaArvore(input) {
  let obj = JSON.parse(input);
  let arv = new Arvore();
  arv.constroi(obj, "Program");
  arv.imprimePreOrdem();
  let procs = [];
  let procsObjs = Object.keys(obj["procedimentos"]);
  procsObjs.forEach((procedimento) => {
    let novaArv = new Arvore();
    novaArv.constroi(obj["procedimentos"][procedimento], procedimento);
    procs.push(novaArv);
    novaArv.imprimePreOrdem();
  });
  return [arv, procs];
}

function desenhaCirculo(x, y, ctx) {
  ctx.beginPath();
  ctx.arc(x, y, 20, 0, 2 * Math.PI);
  ctx.fillStyle = "white";
  ctx.fill();
  ctx.stroke();
}

function desenhaLosango(x, y, ctx) {
  ctx.beginPath();
  ctx.moveTo(x, y-10);
  ctx.lineTo(x+20, y);
  ctx.lineTo(x, y+10);
  ctx.lineTo(x-20, y);
  ctx.lineTo(x, y-10);
  ctx.stroke();
}

function desenhaFlecha(x, y, x2, y2, ctx) {
  ctx.beginPath();
  ctx.moveTo(x,y);
  ctx.lineTo(x2,y2);
  ctx.stroke();
}

$(document).ready(() => {
  const canvas = document.getElementById('canvas');
  let w = window.innerWidth; const ctx = canvas.getContext('2d');
  let h = window.innerHeight;
  canvas.width = w * 0.9;
  canvas.height = h * 0.9;

  let [arv, procs] = processaArvore(input);

  let [matriz, altura, largura] = [arv.matriz, arv.altura, arv.largura];

  console.log(matriz);
  console.log(altura);
  console.log(largura);
  ctx.strokeStyle = 'rgb(0,0,0)';
  for(let i = 0; i < matriz.length; i++) {
    for(let j = 0; j < matriz[i].length; j++) {
      let x = lerp(0, w, j/(matriz[i].length-1)) + 20;
      let y = lerp(0, h, i/(matriz.length)) + 20;
      let atual = matriz[i][j];
      if(atual) {
        atual.x = x;
        atual.y = y;
        if (atual.pai) {
          let [xpai, ypai] = [atual.pai.x, atual.pai.y];
          desenhaFlecha(xpai, ypai, x, y, ctx);
        }
      }
    }
  }
  for(let i = 0; i < matriz.length; i++) {
    for(let j = 0; j < matriz[i].length; j++) {
      let atual = matriz[i][j];
      if(atual) {
        let [x, y] = [atual.x, atual.y];
        console.log(atual.comando);
        if(atual.comando.search(/.*if.*/i) != -1) {
          desenhaLosango(x, y, ctx);
        }
        else {
          desenhaCirculo(x, y, ctx);
        }
      }
    }
  }
});
