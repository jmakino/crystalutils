#
# leapfrog.cr
#
require "./vector3.cr"
include Math

def rotate(v, theta)
  [v[0] = cos(theta)*v[0]-sin(theta)*v[1],
  v[1] = sin(theta)*v[0]+cos(theta)*v[1],
  v[2]].to_v
end

class Body
  property :id, :mass, :pos, :vel, :acc, :pot, :potbh, :bhmass
  @id = -1
  @mass = 0.0
  @pos=Vector.new(0)
  @vel=Vector.new(0)
  @acc=Vector.new(0)
  @pot=0.0
  @potbh=0.0
  @bhmass=0.0
  def initialize
  end

  def froms(s)
    a=s.split.map{|x| x.to_f}
    @id = a[0].to_i
    @mass = a[1].to_f
    @pos  = a[2..4].to_v
    @vel  = a[5..7].to_v
    @bhmass= a[8]
    self
  end
  def fromvalues(id,mass,pos,vel,bhmass)
    @id = id
    @mass = mass
    @pos  = pos
    @vel  = vel
    @bhmass= bhmass
    self
  end
  def fromb(b)
    @id = b.id
    @mass = b.mass
    @pos  = b.pos
    @vel  = b.vel
    @bhmass= b.bhmass
    self
  end
  def scalev(f)
    @vel = f*vel
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
    @pot -= otherbody.mass/r
    otherbody.acc += dr*(@mass/r3)
    otherbody.pot -= @mass/r
  end    

  def add_bh_force
    dr= -@pos
    r2 = dr*dr
    r = sqrt(r2)
    r3 = r2*r
    @acc += dr*(@bhmass/r3)
    @potbh = -@bhmass/r
  end    

  def rotate(theta)
    @pos = rotate(@pos,theta)
    @vel = rotate(@vel,theta)
    self
  end    

  def check_circular
    rv = (@pos*vel).abs
    av = (@acc*vel).abs
    averror = @vel*@vel - sqrt(@acc*@acc)
#    print rv, " ", av, " ", averror, "\n"
    error = 0
    error = 1 if (rv > 1e-15)
    error = 1 if (av > 1e-15)
    error = 1 if (averror > 1e-15)
    if error == 1
      print "r, v not orthogocal):", @pos, @vel, "\n"
    end
  end
    
  
end

class Nbody
  property :ba,  :time
  
  def initialize
    @ba=Array(Body).new
  end

  def calculate_force
    @ba.each{|x| 
      x.pot=0.0; x.acc = Vector.new(0)
      x.add_bh_force
    }
    (0..(@ba.size-2)).each{|i|
      ((i+1)..(@ba.size-1)).each{|j|
        @ba[i].accumulate_force(@ba[j])
      }
    }

  end

  def calculate_energy
    ke=pe=pebh=0.0
    @ba.each{|p| 
      ke += 0.5*p.mass*(p.vel*p.vel)
      pe += p.pot*p.mass
      pebh += p.potbh*p.mass
    }
    pe *= 0.5
    [ke+pe+pebh,ke,pe,pebh]
  end

  def leapfrog_1step(dt)
    calculate_force
    @ba.each{|b|
      b.pos += dt*b.vel + (dt*dt*0.5)*b.acc
      b.vel += (dt*0.5)*b.acc
    }
    calculate_force
    @ba.each{|b|
      b.vel += (dt*0.5)*b.acc
    }
  end

end

def makeonebodysystem(mass)
  b=Nbody.new
  b.ba.push(Body.new.fromvalues(0,mass, [1.0,0.0,0.0].to_v,
                                [0.0,1.0,0.0].to_v, 1.0))
  b
end
            
def makethreebodysystem(mass)
  b=makeonebodysystem(mass)
  b.ba.push(Body.new.fromb(b.ba[0]).rotate(PI*2/3.0))
  b.ba.push(Body.new.fromb(b.ba[0]).rotate(PI*4/3.0))
  
  3.times{|i| b.ba[i].id = i}
  b
end
            
steps = ARGV[0].to_i
mass = ARGV[1].to_f
print "steps = ", steps, " mass=", mass,"\n"
#b=Nbody.new
# while s=gets
#   particle=Body.new.froms(s)
#   b.ba.push(particle)
# end
b = makethreebodysystem(mass)
#b = makeonebodysystem(mass)
b.calculate_force
p b.ba[0]
vscale = sqrt(-b.ba[0].acc[0])
b.ba.each{|x| x.scalev(vscale)}

energies= b.calculate_energy
b.ba.each{|x| p x}
b.ba.each{|x| x.check_circular}
p energies
dt = 1.0/steps
steps.times{b.leapfrog_1step(dt)}
b.ba.each{|x| p x}
ex = b.ba[0].pos[0]-cos(vscale)
ey = b.ba[0].pos[1]-sin(vscale)
errtot = sqrt(ex*ex+ey*ey)
printf( "vscale= %.20e ",  vscale)
printf( "exact= %.20e %.20e err = %.20e\n",  cos(vscale),  sin(vscale),errtot)
#vscale2 = sqrt(1.0+mass/sqrt(3.0))
#printf( "vs2= %.20e exact2= %.20e %.20e\n", vscale2, cos(vscale2),  sin(vscale2))
#printf( "vs-vs2= %.20e\n", vscale-vscale2)
