class MyVector(T) < Array(T)
  def +(a)
    sum = MyVector(T).new()
    self.each_index{|k| sum.push self[k]+a[k]}
    sum
  end
  def -(a)
    diff = MyVector(T).new()
    self.each_index{|k| diff.push self[k]-a[k]}
    diff
  end
  def -
    self.map{|x| -x}.to_v
  end
  def +
    self
  end
  def *(a)
    if a.class == MyVector(T)              # inner product
      product = 0
      self.each_index{|k| product += self[k]*a[k]}
    else
      product = MyVector.new(a.size,0.0)           # scalar product
      self.each_index{|k| product[k] = self[k]*a}
    end
    product
  end
  def /(a)
    if a.class == MyVector
      raise
    else
      quotient = MyVector.new(a.size,0.0)           # scalar quotient
      self.each_index{|k| quotient[k] = self[k]/a}
    end
    quotient
  end
  def cross(other)                   # outer product
    if other.size == 3
      result = MyVector.new(a.size,0.0)
      result[0] = self[1]*other[2] - self[2]*other[1]
      result[1] = self[2]*other[0] - self[0]*other[2]
      result[2] = self[0]*other[1] - self[1]*other[0]
      result
    elsif other.size == 2
      self[0]*other[1] - self[1]*other[0]
    elsif other.size == 1
      0
    else
      raise "dimension = #{other.size} not supported"
    end
  end
end

class Array
  def to_v
    MyVector[*self]
  end
end

struct  Float
  def original_mult(a)
    self.*(a)
  end

  def *(a)
    if a.class == MyVector
      a*self
    else
      original_mult(a)
    end
  end
end

class Fixnum
  def original_mult(a)
    self.*(a)
  end
  def *(a)
    if a.class == MyVector
      a*self
    else
      original_mult(a)
    end
  end
end


 print "Hi\n"
 a= MyVector.new(3,0.0)
 p a
 a[0]=1.0
 a[1]=2.0
 a[2]=3.0
 p a
 p a+a 
 p a+a-a 
 p (a+a)*a 

