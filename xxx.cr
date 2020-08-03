x=1.0
v=0.0
h=0.1

def newxv(x, v, h)
  xnew = x + v*h-h*h*x/2.0
  vnew = v - (x+xnew)*h/2.0
  [xnew,vnew]
end
def hcandidate(x,v,h)
  (x*x+v*v)*0.5 - h*h*x*x/8.0
end
100.times{
  print x, " ",  v," ",  hcandidate(x,v,h), "\n"
  x,v=newxv(x,v,h)
}
