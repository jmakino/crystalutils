def same_type(a,b)
  a.class == b.class
end

def myappend(a : Array(_), b : _)
  a+[b]
end
p same_type(1,2)
p same_type(1,2.0)
p myappend([1],2)
p myappend([1],"test")
#p myappend([1],"test").class

