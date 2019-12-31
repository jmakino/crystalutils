  @[Link(ldflags: "-L/home/makino/src/crystalutils -lmulcint128")]
  lib Libmulcint128
    fun mulCint128(x: Int128, y: Int128) : Int128
  end
  struct Int128
    def *(other : Int128)
      Libmulcint128.mulCint128(self, other)
    end
  end
  a=100.to_i128
  b=(1_i64<<60).to_i128
  p a
  p b
  p b+b
  p b*b
