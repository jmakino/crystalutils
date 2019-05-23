#
# hybridr.rb
#
require "./vector3.cr"
include Math

def k2(r)
  # k2 (r)=0 if r < 0.75
  #    0-1 for r=0.75 -1.25
  # 1 for r > 1.25
  x = (r-1.0)*2+0.5
  f=1.0
  if x < 0 
    f=0.0
  elsif x < 1
    f =  x*x*x/(1.0 - 3.0*x + 3.0*x*x)
  end
  f
end

def k20(r)
  1.0
end

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
def leapfrog_1step_h2(x,v,dt)
  a = acc(x)*(1.0-k2(sqrt(x*x)))
  x = x+ dt*v+dt*dt*a*0.5
  newa=acc(x)*(1.0-k2(sqrt(x*x)))
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

def yoshida4_h2(x,v,dt)
     
  d1 = 1/(2-exp(log(2)/3))
  d2 = 1-2*d1
  x,v=leapfrog_1step_h2(x,v,dt*d1)
  x,v=leapfrog_1step_h2(x,v,dt*d2)
  x,v=leapfrog_1step_h2(x,v,dt*d1)
  [x,v]
end

def hybrid1(x,v,dt)
  ah1 = acc(x)*k2(sqrt(x*x))
  v = v+dt*0.5*ah1
  nsteps = 128
  dt2 = dt/nsteps
  nsteps.times{x,v=leapfrog_1step_h2(x,v,dt2)}
#  nsteps.times{x,v=yoshida4_h2(x,v,dt2)}
  ah1 = acc(x)*k2(sqrt(x*x))
  v = v+dt*0.5*ah1
  [x,v]
end

def e(x,v)
  pot(x)+v*v*0.5
end
e0=ARGV[0].to_f
dt=ARGV[1].to_f
tend=ARGV[2].to_f
type=ARGV[3].to_i
dtreal=dt*(Math::PI*2)
n = ((tend+0.5*dt)/dt).to_i
x0= 1+e0
#k + u = - 0.5
#e = 
v0 = sqrt((1.0/x0-0.5)*2.0)
v=[0.0,v0,0.0].to_v
x=[x0,0.0,0.0].to_v
e00= e(x,v)
STDERR.print "ecc=#{e0}, etot0 =#{e00}, dt=#{dt}, tend=#{tend} type={#type}\n"
ninter = (1.0/dt+0.5).to_i/100
ninter = 1 if ninter == 0
    printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", 0,
           x[0],x[1], v[0],v[1], 0,0)
n.times{|i|
  if type==0	
    x,v = leapfrog_1step(x,v,dtreal)
  elsif type==1
    x,v = yoshida4(x,v,dtreal)
  else
    x,v = hybrid1(x,v,dtreal)
  end
  if (i+1)%ninter == 0
    printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", (i+1)*dtreal,
           x[0],x[1], v[0],v[1], e(x,v)-e00,i)
  end
}


