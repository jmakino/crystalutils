#
# august.rb : numerical integration for three bodies
#
#
require 'vector.rb'
include Math
class Body
  attr_accessor :mass, :pos, :vel, :acc, :pot, :withring
  def initialize
    @pos=[]
    @vel=[]
    @withring=nil
  end

  def froms(s)
    a=s.split.collect{|x| x.to_f}
    p a
    n=(a.size-1)/2
    @mass = a[0]
    @pos  = a[1..n].to_v
    @vel  = a[(n+1)..(2*n)].to_v
    p self
  end

  def convertfromelements(a,e)
    @pos[0]=a*(1+e)
    @pos[1]=0
    @vel[0]=0
    @vel[1]= sqrt(2*(1/@pos[0]-0.5/a))
    @pos=@pos.to_v
    @vel=@vel.to_v
  end

  def fromvectortocontactelements(mass,pos,vel)
    raise "contactelements works only for 2D vector" if pos.size != 2 
    r=sqrt(pos*pos)
    be = -mass/r+0.5*(vel*vel)
    # be = -mass/2a, a = -mass/2be
    a = -mass/(be*2)
    vcirc = sqrt(mass/a)
    jmax = a*vcirc
    j = pos[0]*vel[1]-pos[1]*vel[0]
    vbyj = vel*j
    vbyh=[vbyj[1],-vbyj[0]].to_v
    e = vbyh-pos*(1/r)
    eabs=sqrt(e*e)
    argp = atan2(-e[1],-e[0])
    [e,eabs,a,argp]
  end

  def contactelements(ref)
    fromvectortocontactelements(@mass+ref.mass,
				@pos-ref.pos,@vel-ref.vel)
  end

    #
# relation between J and e
#
# assume a=1,j=1
# ra = (1+e)
# E= -1/r+v^2/2
# va = sqrt(1/ra - 1/2a) 
    

  def accumulate_force(otherbody)
    dr= @pos-otherbody.pos
    r2 = dr*dr
    r = sqrt(r2)
    r3 = r2*r
    mfact=@mass/r3
    @acc += dr*(-otherbody.mass/r3)
    otherbody.acc += dr*(@mass/r3)
    @pot -= otherbody.mass/r
    otherbody.pot -= @mass/r
  end    

  def forcefromring
    dummyp = Body.new
    dummyp.mass=@ringmass/@ringndivide
    dummyp.acc=@acc
    dummyp.pot=@pot
    dt = 2*Math::PI/@ringndivide
    for i in 0..(@ringndivide-1)
      theta = dt*i
      dummyp.pos[0]=@ringradius*cos(theta)
      dummyp.pos[1]=@ringradius*sin(theta)
      accumulate_force(dummyp)
    end
  end
  
  def ringinit(radius,mass,ndivide)
    @ringradius,@ringmass,@ringndivide = radius,mass,ndivide
    @withring=1
  end

  def makenull
    null = ([0.0]*(@pos.size)).to_v
  end
end

class Nbody
  attr_accessor :ba,  :time

  def initialize
    @ba=[]
  end

  def calculate_force
    @ba.each{|x| 
      x.pot=0; x.acc = x.makenull
      x.forcefromring if x.withring
    }
    for i in 0..(@ba.size-2)
      for j in (i+1)..(@ba.size-1)
	@ba[i].accumulate_force(@ba[j])
      end
    end
  end
  
  def leapfrog(first_call,dt)
    if first_call
      calculate_force
      first_call=nil
    end
    @ba.each{|p| p.vel += p.acc*0.5*dt}
    @ba.each{|p| p.pos += p.vel*dt}
    calculate_force
    @ba.each{|p| p.vel += p.acc*0.5*dt}
  end

  def yoshida6b(first_call,dt)
    d =   [0.784513610477560e0,
      0.235573213359357e0,
      -1.17767998417887e0,
      1.31518632068391e0]
    for i in 0..2 do leapfrog(first_call,dt*d[i]) end
    leapfrog(first_call,dt*d[3])
    for i in 0..2 do leapfrog(first_call,dt*d[2-i]) end
  end

  def calculate_energy
    ke=pe=0
    @ba.each{|p| 
      ke += 0.5*p.mass*(p.vel*p.vel)
      pe += p.pot*p.mass
    }
    pe *= 0.5
    [ke+pe,ke,pe]
  end

  def cmadjust
    cmp=@ba[0].makenull
    cmv=@ba[0].makenull
    cmm=0
    @ba.each{|p| 
      mass = p.mass
      cmp += p.pos*mass
      cmv += p.vel*mass
      cmm += mass
    }
    cmp *= 1/cmm
    cmv *= 1/cmm
    @ba.each{|p| 
      p.pos -= cmp
      p.vel -= cmv
    }
  end

  def plot
    @ba.each{|p| 
      relocate(*p.pos)
      dot
    }
  end

  def run(dt,tend,interval,plotendtime=0)
    steps = ((tend+dt*0.5)/dt).to_i
    calculate_force
    e0= calculate_energy
    print "Initial energy = #{e0[0]}\n"
    i=0
    @time=0
    first_call = 1
    steps.times{
      yoshida6b(first_call,dt)
      @time += dt
      i+= 1
      if i==interval or @time < plotendtime
	i=0
	yield
      end
    }
    e= calculate_energy
    print "Final energy = #{e[0]}, de = #{e0[0]-e[0]}\n"
  end
end


#the following is a test config for circular hierarchical binary
if nil
  b.ba= [Body.new,Body.new]
  b.ba[0].froms("0.5 1 0.0 0   1")
  b.ba[1].froms("0.5 0 0   0   0")
  p b
  b.cmadjust
  b.ba += [Body.new]
  #
  # M=2, R=5, a= 2/25, v^2/=a v=sqrt(2/5)
  # pe = 2/5 ke=1/5
  b.ba[2].froms("1 5 0   0   0")
  b.ba[2].vel[1]=sqrt(2.0/5.0)
  b.cmadjust
end

def marssetup(jupiterascale=1,marsecc=0.093,jupiterecc=0)
  b = Nbody.new
  b.time=0
  b.ba= [Body.new,Body.new,Body.new]
  b.ba[0].froms("1 0.0 0.0  0  0")
  b.ba[1].convertfromelements(5.203/1.524*jupiterascale,jupiterecc)
  b.ba[1].mass=0.001
  b.ba[2].convertfromelements(1,marsecc)
  b.ba[2].mass=0.00000
  p b
  b.cmadjust
  b
end


class Nbody
  def connectorplot(dt,tconnect)
    if @time <= dt or @time > tconnect
      relocate(*ba[2].pos)
      dot
    else
      draw(*ba[2].pos)
    end
  end
end

      

unless File.exist?("august-fig1b.ps")
  printer august-fig1b.ps/vcps
#  term
  endtime=10000
#  endtime=100
  tpend=6.38
  b=marssetup
  square
  expand 1.5
  viewport 0 0.45 0.55 1
  limit -1.2 1.2  -1.2 1.2
  box BCTSV  BCNTSV 
  ylabel y
  expand 0.1
  dt = 0.07
  b.run(dt,endtime,50,tpend){
    b.connectorplot(dt,tpend)
  }
  
  viewport 1.2 2.2 0 1
  b=marssetup
  b.ba[1].mass*10
  expand 1.5
  limit -1.2 1.2  -1.2 1.2
  box BCTSV  BCTSV 
  expand 0.1
  b.run(dt,endtime,50,tpend){
    b.connectorplot(dt,tpend)
  }
  
  viewport -1.2 -0.2 -1.2 -0.2
  b=marssetup(0.5)
  expand 1.5
  limit -1.2 1.2  -1.2 1.2
  box BCNTSV  BCNTSV 
  xlabel x
  ylabel y
  expand 0.1
  b.run(dt,endtime,50,tpend){
    b.connectorplot(dt,tpend)
  }
  expand 1
  
  viewport 1.2 2.2 0 1
  b=marssetup(0.5)
  b.ba[1].mass*10
  expand 1.5
  limit -1.2 1.2  -1.2 1.2
  box BCNTSV  BCTSV 
  xlabel x
  expand 0.1
  b.run(dt,endtime,50,tpend){
    b.connectorplot(dt,tpend)
  }
  expand 1
  pgend
  psfix
end

unless File.exist?("august-fig2.ps")
  printer august-fig2.ps/vcps
  b = marssetup
  square
  viewport 0.1 1.1 0.1 1.1
  limit 0 500 -0.005 0.015
  expand 1.2
  box BCNSTV  BCNSTV
  expand 2
  xlabel T
  reloc -100 0.007
  label \\gh
  a=b.ba[2].contactelements(b.ba[0])
  p b.time
  p a[3]
  reloc b.time a[3]
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw(b.time,a[3])
  }
  
  b = marssetup
  b.ba[1].mass*=0.5
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time a[3]
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw(b.time,a[3])
  }
  
  b = marssetup
  b.ba[1].mass*=0
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time a[3]
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw(b.time,a[3])
  }
  expand 1
  pgend
  psfix
end

unless File.exist?("august-fig3.ps")
  printer august-fig3.ps/vcps
  $plotlylimit = -6
  $ymin = exp($plotlylimit*log(10.0))
  $lymax =   $plotlylimit
  def logp(x,y)
    p x
    p y
    if y > 0
      ly = log10(y)
      if ly > $lymax
	draw x ly
	$lymax = ly
      end
    end
  end
      
  square
  viewport 0.1 1.1 0.1 1.1
  limit 0 500 $plotlylimit -0.5
  expand 1.2
  box BCNSTV  BCNSTVL
  expand 2
  xlabel T
  ylabel \\gh
  b = marssetup
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time $plotlylimit 
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    logp(b.time, a[3])

  }

  $lymax =   $plotlylimit
  b = marssetup
  b=marssetup(0.5)
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time $plotlylimit 
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    logp(b.time, a[3])
  }

  $lymax =   $plotlylimit
  b = marssetup
  b=marssetup(2)
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time $plotlylimit 
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    logp(b.time, a[3])
  }

  $lymax =   $plotlylimit
  b = marssetup
  b=marssetup(4)
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time $plotlylimit 
  b.run(0.05,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    logp(b.time, a[3])
  }
end



unless File.exist?("august-fig4.ps")
  printer august-fig4.ps/vcps
  square
  viewport 0.1 1.1 0.1 1.1
  limit 0 500 -0.005 0.01
  expand 1.2
  box BCNSTV  BCNSTV
  expand 2
  xlabel T
  ylabel \\gh

  b = marssetup(1,0.1)
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time 0
  b.run(0.07,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw b.time a[3]

  }

  b = marssetup(1,0.4)
  a=b.ba[2].contactelements(b.ba[0])
  reloc b.time 0
  b.run(0.03,500,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw b.time a[3]

  }
end

unless File.exist?("august-fig5.ps")
  printer august-fig5.ps/vcps
#  term
  square
  viewport 0.1 1.1 0.1 1.1
  tend = 500
  limit 0 tend -0.005 0.01
  expand 1.2
  box BCNSTV  BCNSTV
  expand 2
  xlabel T
  ylabel \\gh

  color 1
  b = marssetup
  reloc b.time 0
  b.run(0.07,tend,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw b.time a[3]

  }

  b = marssetup
  reloc b.time 0
  b.ba[1].mass=0
  b.ba[2].ringinit(5.203/1.524,0.001,32)

  color 2
  b.run(0.07,tend,5){
    a=b.ba[2].contactelements(b.ba[0])
    draw b.time a[3]

  }
  color 1

end
