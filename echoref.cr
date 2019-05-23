class Test
  property a
  def initialize(@a : Int32)
  end
  def pp
    p @a
  end
end

x= Test.new(1)
p x.a
x.a=2
x.pp



