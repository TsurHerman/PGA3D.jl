using PGA3D
using LinearAlgebra
using BenchmarkTools


const SIG = (1,1,1,0)

v0 = E{SIG,0,1}(1)
const v1 = E{SIG,1,1}(1)
const v2 = E{SIG,1,2}(1)
v3 = E{SIG,1,3}(1)
v4 = E{SIG,1,4}(1)

v12 = E{SIG,2,1}(1)
v13 = E{SIG,2,2}(1.4)
v14 = E{SIG,2,3}(1.4)
v23 = E{SIG,2,4}(1.4)


wedge(v2,v1)





f(args...;grade = 1) = Blade{SIG,grade}(args...)

b1 = f(1,2,3,4)
b2 = f(1,1,1,1)
f(b) = Blade((-b.v[1],-b.v[2],-b.v[3],-b.v[4]))

