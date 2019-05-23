fun init = crystal_init : Void
  print "test in init 0\n"
  GC.init
  STDOUT.print "test in init 1\n"
end

lib C
  fun cos(value : Float64) : Float64
end
#@[Link(ldflags: "-L/home/makino/src/crystalutils  -lmyclib")]
lib MyClib
  fun sqr(value : Float64) : Float64
end 


fun log = crystal_log(text: UInt8*): Void
  puts String.new(text)
  puts MyClib.sqr(2)
end
