#
# hybridr.cr
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

def k1(r)
  x = (r-1.0)*2+0.5
  f=1.0
  if x < 0 
    f=0.0
  elsif x < 1
    f =  x*x/(1.0 - 2.0*x + 2.0*x*x)
  end
  f
end

def k0(r)
  x = (r-1.0)*2+0.5
  f=1.0
  if x < 0 
    f=0.0
  elsif x < 1
    f =  x
  end
  f
end

def pot(x)
  -1.0/(sqrt(x*x))
end
def acc(x)
  r= sqrt(x*x)
  -x/(r*r*r)
end

def leapfrog_1step(x,v,dt,afunc)
  a = afunc.call(x)
  x = x+ dt*v+dt*dt*a*0.5
  newa=afunc.call(x)
  v = v+ dt*(a+newa)*0.5
  [x,v]
end

def yoshida4(x,v,dt,afunc)
  d1 = 1/(2-exp(log(2)/3))
  d2 = 1-2*d1
  x,v=leapfrog_1step(x,v,dt*d1,afunc)
  x,v=leapfrog_1step(x,v,dt*d2,afunc)
  x,v=leapfrog_1step(x,v,dt*d1,afunc)
  [x,v]
end

def hybrid1(x,v,dt, accfunc, kfunc,integrator)
  along = -> (x : Vector){accfunc.call(x)*kfunc.call(sqrt(x*x))}
  ashort = -> (x : Vector){accfunc.call(x)*(1.0-kfunc.call(sqrt(x*x)))}
  ah1 = along.call(x)
  v = v+dt*0.5*ah1
  nsteps = 128
  dt2 = dt/nsteps
  nsteps.times{x,v=integrator.call(x,v,dt2,ashort)}
  ah1 = along.call(x)
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
ttype=ARGV[3].to_i
dtreal=dt
dtreal=dt*(Math::PI*2) if (ttype==1)
n = ((tend+0.5*dt)/dt).to_i
x0= 1+e0
#k + u = - 0.5
#e = 
v0 = sqrt((1.0/x0-0.5)*2.0)
v=[0.0,v0,0.0].to_v
x=[x0,0.0,0.0].to_v
e00= e(x,v)
STDERR.print "ecc=#{e0}, etot0 =#{e00}, dt=#{dt}, tend=#{tend} type={#type}\n"
ninter = (1.0/dt+0.5).to_i//100
ninter = 1 if ninter == 0
printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", 0,
       x[0],x[1], v[0],v[1], 0,0);

macro to_f64f(name)
  -> {{name.id}}(Float64)
end
macro to_integf(name)
  -> {{name.id}}(Vector, Vector, Float64, Proc(Vector,Vector))
end

kfunc= to_f64f(:k2)
ifunc= to_integf(:leapfrog_1step)

if type > 1
  kfunc=[to_f64f(:k2),to_f64f(:k1), to_f64f(:k0)][(type-2)%3]
  ifunc = to_integf(:yoshida4) if type>4
end

n.times{|i|
  if type==0	
    x,v = leapfrog_1step(x,v,dtreal,->acc(Vector))
  elsif type==1
    x,v = yoshida4(x,v,dtreal,->acc(Vector))
  else
    x,v = hybrid1(x,v,dtreal,->acc(Vector), kfunc, ifunc)
  end
  if (i+1)%ninter == 0
    printf("%25.20e %25.20e %25.20e %25.20e %25.20e %25.20e %d\n", (i+1)*dtreal,
           x[0],x[1], v[0],v[1], e(x,v)-e00,i)
  end
}



