using PGA3D
using BenchmarkTools


const SIG = (1,1,1,0)

v0 = E{SIG,0,1}(12)
const v1 = E{SIG,1,1}(1)
const v2 = E{SIG,1,2}(1)
v3 = E{SIG,1,3}(2.2)

v12 = E{SIG,2,1}(1.4)
v13 = E{SIG,2,2}(1.4)

wedge(v2,v1)





f(args...;grade = 1) = Blade{SIG,grade}(args...)