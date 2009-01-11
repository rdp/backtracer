def go2(a, b)
 3
 puts 'crashing'
 b = 3
 within_go2 = 4
 raise
end
def go(a); 
 within_go = 2
 $STOP = true
 go2(a, 55); 
 'abc'
end
def does_nothing a

end
topmost =1
does_nothing 3
does_nothing 4
does_nothing 5

go '3'
print 'done'

