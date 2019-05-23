lib C
  fun cos(value : Float64) : Float64
end
@[Link(ldflags: "-L/home/makino/src/crystalutils  -lmyclib")]
lib MyClib
  fun sqr(value : Float64) : Float64
end 

p C.cos(1.5)
p MyClib.sqr(2)
