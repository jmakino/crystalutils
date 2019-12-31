#
# check-energy.cr
#
require "./vector3.cr"
include Math

class Body
  property :mass, :pos, :vel, :acc, :pot, :potbh, :bhmass
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

  
end

class Nbody
  property :ba,  :time
  
  def initialize
    @ba=Array(Body).new
  end

  def calculate_force
    @ba.each{|x| 
      x.pot=0.0; x.acc = Vector.new(0)
      x.potbh = -x.bhmass/sqrt(x.pos*x.pos)
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

end


b=Nbody.new
while s=gets
  particle=Body.new.froms(s)
  b.ba.push(particle)
end
b.calculate_force
energies= b.calculate_energy
b.ba.each{|x| p x}
p energies

