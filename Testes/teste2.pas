program teste2 (input, output);
var a, b, c: integer;

function soma(d, e:integer; var f:integer): integer;
  var a, b: integer;
  begin
    f := d + e;
    soma := f;
  end;
  
begin
  read(a);
  read(b);
  soma(a, b, c);
  write(c);
end.
