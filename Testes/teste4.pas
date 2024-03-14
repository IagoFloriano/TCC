program troca(input, output);
var a, b: integer;

procedure troca(var a, b:integer);
var c: integer;
begin
  c := a;
  a := b;
  b := c;
end;

begin
  read(a);
  read(b);
  troca(a,b);
  write(a);
  write(b);
end.
