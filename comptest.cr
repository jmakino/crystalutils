@[Link(ldflags: "-fopenmp -L/home/makino/src/crystalutils  -lmyclib -lm")]
lib MyClib
  fun sqr(value : Float64) : Float64
  fun cmain() : Void
end 
p MyClib.sqr(3)
MyClib.cmain

