def go1 n
  raise 'done' if n == 30
 go2 n
end

def go2 n
 go1 n + 1
end

go2 0