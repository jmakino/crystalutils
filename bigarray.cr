#
# bigarray.cr minimal implementation of Array with element count
# larger than Int32:MAX
#
# only supports:
#    new(size, value)
#    [], []= for single element and range
#    range [] returns Array. So the range width  must be less than Int32::MAX
#     (start and end values can be Int64)
#
# Copyright 2020 Jun Makino
#
class BigArray(T)
  property :size, :arrays
  NBITSFORARRAY = 30
  SIZEFORARRAY = (1i64<<(BigArray::NBITSFORARRAY))
  MASKOFARRAY = (BigArray::SIZEFORARRAY-1i64)
  def initialize(n : Int64, val)
    @ntables = BigArray.tablecount(n)
    lastsize = n & BigArray::MASKOFARRAY  
    @ntables  += 1 if lastsize != 0i64
    @arrays = Array(Array(T)).new(@ntables){|i|
      npart = (BigArray::SIZEFORARRAY).to_i32
      npart = lastsize if i == @ntables-1
      Array(T).new(npart,val)
    }
    @size=n
  end
  
  def BigArray.tablecount(n : Int64) : Int64
    n >> BigArray::NBITSFORARRAY
  end
  def tableid(n : Int64) : Int32
    (n >> NBITSFORARRAY).to_i32
  end
  def lindex(n : Int64) : Int32
    (n & BigArray::MASKOFARRAY).to_i32
  end
  def [](n : Int64)
    @arrays[tableid(n)][lindex(n)]
  end
  def [](n : (Int32|UInt32))
    n=n.to_i64
    @arrays[tableid(n)][lindex(n)]
  end
  def []=(n : Int64, val)
    @arrays[tableid(n)][lindex(n)]=val
  end
  def []=(n : (Int32|UInt32), val)
    n= n.to_i64
    @arrays[tableid(n)][lindex(n)]=val
  end
  def [](r : Range)
    b = r.begin
    e = r.end
    bt = tableid(b)
    et = tableid(e)
    if (et - bt) > 1
      raise "BigArray: Range #{b}-#{e} too large"
    end
    if et == bt
      subarray= @arrays[bt][lindex(b)..lindex(e)]
    else
      #      subarray= @arrays[bt][lindex(b)..(BigArray::MASKOFARRAY.to_i32)]+
      #                @arrays[et][0..lindex(e)]
      subarray = Array(T).new((e-b+1).to_i32, @arrays[0][0])
      subarray.size.times{|i|
        subarray[i] = self[b+i]
      }
    end
    subarray
  end
  def []=(r : Range, val)
    b = r.begin
    e = r.end
    bt = tableid(b)
    et = tableid(e)
    if (et - bt) > 1
      raise "BigArray: Range #{b}-#{e} too large"
    end
    if et == bt
      @arrays[bt][lindex(b)..lindex(e)] = val
    else
      subsize = (BigArray::MASKOFARRAY.to_i32)-lindex(b)
      #      @arrays[bt][lindex(b)..(BigArray::MASKOFARRAY.to_i32)]=val[0..subsize]
      #      @arrays[et][0..lindex(e)]=val[(subsize+1)..(lindex(e)+subsize+1)]
      n = (e+1-b).to_i32
      n.times{|i|
        self[b+i]=val[i] 
      }
      print "[]= success\n"
    end
  end
end
