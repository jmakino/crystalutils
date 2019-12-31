@[Link(ldflags: "-L/home/makino/src/crystalutils -lcint128")]
#@[Link(ldflags: "cint128.o")]
lib C
  struct Cint128
  lower : Int64
  upper : Int64
end
fun addCint128(x: Cint128, y: Cint128) : Cint128
fun subCint128(x: Cint128, y: Cint128) : Cint128
fun mulCint128(x: Cint128, y: Cint128) : Cint128
fun largerint128(x: Cint128, y: Cint128) : Int32
fun smallerint128(x: Cint128, y: Cint128) : Int32
fun zerocint128() : Cint128
fun largenumcint128() : Cint128
fun cos(value : Float64) : Float64
end



struct MyInt128
property i
def initialize(a : Int64|Int32)
  @i = C.zerocint128;
  @i.upper=0
  @i.lower=a
  @i.upper=-1 if (a<0)
end
def initialize(a : C::Cint128)
  @i = C.zerocint128;
  @i.upper=a.upper
  @i.lower=a.lower
end
def +(other : MyInt128)
  MyInt128.new(C.addCint128(@i, other.i))
end
def *(other : MyInt128)
  MyInt128.new(C.mulCint128(@i, other.i))
end
def *(other : MyInt128)
  MyInt128.new(C.mulCint128(@i, other.i))
end
def >(other : MyInt128)
  Int32.new(C.largerint128(@i, other.i))
end
def <(other : MyInt128)
  Int32.new(C.smallerint128(@i, other.i))
end
end
a=MyInt128.new(100)
b=MyInt128.new(1_i64<<60)
p a
p b
p b+b
p b*b
p C.largenumcint128
p a>b
p a<b
