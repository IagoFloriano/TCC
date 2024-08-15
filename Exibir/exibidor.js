const lerp = (x, y, a) => x * (1 - a) + y * a;
let pilha = [];
let lista = document.getElementById('procedimentos');
let procToChange = {};

function processaArvore(obj, nome) {
  let arv = new Arvore();
  arv.constroi(obj, nome);
  arv.imprimePreOrdem();
  let procs = [];
  if (obj.hasOwnProperty("procedimentos")) {
    let procsObjs = Object.keys(obj["procedimentos"]);
    procsObjs.forEach((procedimento) => {
      procs.push({nome: procedimento, obj: obj["procedimentos"][procedimento]});
    });
  }
  return [arv, procs];
}

function desenhaCirculo(x, y, tam, ctx) {
  ctx.beginPath();
  ctx.arc(x, y, tam/3, 0, 2 * Math.PI);
  ctx.fillStyle = "white";
  ctx.fill();
  ctx.stroke();
}

function desenhaLosango(x, y, tam, ctx) {
  ctx.beginPath();
  ctx.moveTo(x, y-(tam/4));
  ctx.lineTo(x+(tam/2), y);
  ctx.lineTo(x, y+(tam/4));
  ctx.lineTo(x-(tam/2), y);
  ctx.lineTo(x, y-(tam/4));
  ctx.stroke();
}

function desenhaFlecha(x, y, x2, y2, ctx) {
  ctx.beginPath();
  ctx.moveTo(x,y);
  ctx.lineTo(x2,y2);
  ctx.stroke();
}

function gerenciaArquivo(evt) {
  const file = evt.target.files[0];
  const reader = new FileReader();

  reader.addEventListener("load", () => {
    pilha = [];
    while (lista.firstChild) lista.removeChild(lista.firstChild);
    let obj = JSON.parse(reader.result);
    pilha.push({obj: obj, nome: "Program"});
    exibeArvore();
  }, false);

  reader.readAsText(file);
}

function desempilha() {
  if (pilha.length == 0) return;
  const input = pilha.pop();
  exibeArvore();
}

function exibeProc() {
  while (lista.firstChild) lista.removeChild(lista.firstChild);
  pilha.push({obj: pilha[pilha.length-1].procs[this.id].obj, nome: pilha[pilha.length-1].procs[this.id].nome});
  exibeArvore();
}

function exibeArvore() {
  const input = pilha[pilha.length-1].obj;
  const nome = pilha[pilha.length-1].nome;
  const canvas = document.getElementById('canvas');
  const ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  let w = canvas.width;
  let h = canvas.height;

  let [arv, procs] = processaArvore(input, nome);
  pilha[pilha.length-1].procs = procs;

  for (let i = 0; i < procs.length; i++) {
    let novo = document.createElement('li');
    novo.innerHTML = `<button id="${i}">${procs[i].nome}</button>`;
    lista.appendChild(novo);
    let btnnovo = document.getElementById(`${i}`);
    btnnovo.onclick = exibeProc;
  }

  const titulo = document.getElementById('titulo');
  titulo.innerHTML = nome;

  let [matriz, altura, largura] = [arv.matriz, arv.altura, arv.largura];

  let tamno = Math.min(canvas.width/largura, canvas.height/altura) / 2;
  ctx.strokeStyle = 'rgb(0,0,0)';
  for(let i = 0; i < matriz.length; i++) {
    for(let j = 0; j < matriz[i].length; j++) {
      let x = lerp(tamno, w-tamno, j/(matriz[i].length-1));
      let y = lerp(tamno, h-tamno, i/(matriz.length-1));
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
        if(atual.comando.search(/^if.*/i) != -1) {
          desenhaLosango(x, y, tamno, ctx);
        }
        else {
          desenhaCirculo(x, y, tamno, ctx);
        }
      }
    }
  }
}

$(document).ready(() => {
  const upArquivo = document.getElementById('input');
  upArquivo.addEventListener("change", gerenciaArquivo, false);

  const canvas = document.getElementById('canvas');
  canvas.width = window.innerWidth * 0.99;
  canvas.height = window.innerHeight * 0.95;
});
