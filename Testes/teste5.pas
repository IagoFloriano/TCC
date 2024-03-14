program euclides(input, output);
var a, b, resultado: integer;

function gcd(a, b: integer):integer;
  var r:integer;
  
  procedure passo(var a, b, r:integer);
  begin
    r:=a mod b;
    a:=b;
    b:=r;
  end;
begin
  while(a mod b <> 0) do
    begin
      passo(a, b, r);
    end;
  gcd := b;
end;

begin
  read(a);
  read(b);
  resultado := gcd(a, b);
  write(resultado);
end.
