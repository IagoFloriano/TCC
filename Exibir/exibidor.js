import Arvore from './arvore.js';

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

function printPre(node, level) {
  let tabs = "";
  for (let i = 0; i < level; i++) {
    tabs += "  ";
  }
  console.log(`${tabs}${node["command"]}: ${level}`);

  if(!node.hasOwnProperty("subcommands")) {
    return;
  }
  let subcmds = node["subcommands"];

  for (let i = 0; i < subcmds.length; i++) {
    printPre(subcmds[i], level + 1);
  }
}

function getAllCommands(commands) {
  if (!commands) return [];
  var cmds = [];
  for (key in commands) {
    cmds.push({command: key, subcommands: getAllCommands(commands[key])});
  }
  return cmds;
}

function main(/*inputfile*/) {
  console.clear();
  let obj = JSON.parse(input);
  let cmd;
  if (obj.hasOwnProperty("comandos")) {
    cmd = obj["comandos"];
  }
  let cmds = getAllCommands(cmd);
  printPre({command: "program", subcommands: cmds}, 0);
}

// Cuida dos valores da linha de comando
main();
//if (process.argv.length != 3) {
//  console.log(`Uso correto: node ${process.argv[1].split('/').reverse()[0]} <entrada.json>`);
//}
//else {
//  main(process.argv[2])
//}
