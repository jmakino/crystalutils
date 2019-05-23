1.upto(100){|i|a=""
  a+="Fizz"if i%3==0
  a+="Buzz"if i%5==0
  a=i if a==""
  print a, "\n"
}
