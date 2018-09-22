Various programs in Crystal

kepler.cr: sample program to solve one-body kepler problem by numerical
           integration

vector3.cr: simple three-dimentional vector class

kepler problem is defined by the total energy (Hamiltonian)

H = v^2/2 -1/r

where r= sqrt(x^2+y^2).
Initial condition is given by x,y,v_x, v_y = 1,0,0, v0

would numerically integrate the kepler problem (for circular orbit)
for 1000 orbits (orbital period is meaningful only for circular orbit
case)

	crystal build --release kepler.cr
	time kepler 1 0.001 1000 1

would integrate kepler problem for 1000 orbits using Yoshida's
4th-order symplectic integrator and dt = 2pi*0.001

On my note pc (Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz), the last program output and time output for the above run are:

6.28318530717958674359e+03 9.99999999959086394163e-01 9.06689784111692830904e-06 -9.06689787258732615705e-06 9.99999999958810725786e-01 1.05804254246777418302e-13 999999
0.396u 0.096s 0:00.35 137.1%	0+0k 0+0io 0pf+0w

and,
   	time ruby kepler.rb 1 0.001 1000 2
gives:

6.28318530717958674359e+03 9.99999999959086394163e-01 9.06689784111692830904e-06 -9.06689787258732615705e-06 9.99999999958810725786e-01 1.05804254246777418302e-13 999999
28.811u 0.004s 0:28.81 100.0%	0+0k 0+0io 0pf+0w

You can see that Crystal runs 70 times faster than Ruby, for this particilar code

ruby -v
ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-linux]

crystal -v
Crystal 0.25.1 [b782738ff] (2018-06-27)

LLVM: 4.0.0
Default target: x86_64-unknown-linux-gnu
