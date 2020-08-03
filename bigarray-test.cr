require "./bigarray.cr"

ibig = 1i64 << 33
(ibig..(ibig+3)).each{|i| pp! i}
big = (1i64 << 32)-100
pp! big
x=BigArray(Int8).new(big, 0i8)
i=2000000000i64
x[i]= 1i8
pp! x[i]
pp! x[i+1]
pp! x[i-1]
x.size.times{|i|
  x[i]= (i%128).to_i8
  pp! i if i % 100000000i64 == 0
}
l1 = 0x7fffffba_i64
l2       = 0x80000024_i64
pp! l1.to_s(16), l2.to_s(16), 
pp! x[l1..l2]
x[l1..l2]= x[l1..l2].sort
pp! x[l1..l2]

