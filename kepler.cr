#
# kepler.rb
#
require "./vector3.cr"
include Math

def pot(x)
  -1.0/(sqrt(x*x))
end
def acc(x)
  r= sqrt(x*x)
  -x/(r*r*r)
end
def leapfrog_1step(x,v,dt)
  a = acc(x)
  x = x+ dt*v+dt*dt*a*0.5
  newa=acc(x)
  v = v+ dt*(a+newa)*0.5
  [x,v]
end
def yoshida4(x,v,dt)
  
  d1 = 1/(2-exp(log(2)/3))
  d2 = 1-2*d1
  x,v=leapfrog_1step(x,v,dt*d1)
  x,v=leapfrog_1step(x,v,dt*d2)
  x,v=leapfrog_1step(x,v,dt*d1)
  [x,v]
end

def e(x,v)
  pot(x)+v*v*0.5
end
v0=ARGV[0].to_f
dt=ARGV[1].to_f
tend=ARGV[2].to_f
type=ARGV[3].to_i
dtreal=dt*(Math::PI*2)
STDERR.print "v0=#{v0}, dt=#{dt}, tend=#{tend} type={#type}\n"
n = ((tend+0.5*dt)/dt).to_i
v=[0.0,v0,0.0].to_v
x=[1.0,0.0,0.0].to_v
e0=e(x,v)
ninter = n/100
ninter = 1 if ninter == 0
    printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", 0,
           x[0],x[1], v[0],v[1], 0,0)
n.times{|i|
  if type==0	
    x,v = leapfrog_1step(x,v,dtreal)
  else
    x,v = yoshida4(x,v,dtreal)
  end
  if (i+1)%ninter == 0
    printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", (i+1)*dtreal,
           x[0],x[1], v[0],v[1], e(x,v)-e0,i)
  end
}



