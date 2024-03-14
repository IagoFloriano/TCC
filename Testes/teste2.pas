program teste2 (input, output);
var a, b, c: integer;

procedure soma(d, e:integer; var f:integer);
  var a, b: integer;
  begin
    f := d + e;
  end;
  
begin
  read(a);
  read(b);
  soma(a, b, c);
  write(c);
end.
