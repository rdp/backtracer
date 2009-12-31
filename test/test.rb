def go number
 if number == 4
   raise 'done'
 else
  go number + 1
 end
end

go 0