program collatz(input, output);
var n: integer;

function collatzStep(n: integer): integer;
begin
  if (n mod 2 = 0) then
    collatzStep := n div 2
  else
    collatzStep := (n*3) + 1;
end;

begin
  read(n);
  while(n <> 1) do
  begin
    n := collatzStep(n);
  end;
  write(n);
end.
