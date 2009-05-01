# more "complicated" file to show off backtraces
def go2(a, b)
 3
 b = 3
 within_go2 = 4
 raise
end
def go(a); 
 within_go = 2
 go2(a, 55); 
 'abc'
end

def does_nothing a

end

does_nothing 3
does_nothing 4
does_nothing 5

go '3'
