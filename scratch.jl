using PGA3D
PGA3D.element_gylph("v",0)

using LinearAlgebra
using BenchmarkTools


const SIG = (1,1,1,0)

v0 = E{SIG,0,1}(1)
const v1 = E{SIG,1,1}(1)
const v2 = E{SIG,1,2}(1)
v3 = E{SIG,1,3}(1)
v4 = E{SIG,1,4}(1)

v12 = E{SIG,2,1}(1)
v13 = E{SIG,2,2}(1)
v14 = E{SIG,2,3}(1)
v23 = E{SIG,2,4}(1)
v24 = E{SIG,2,5}(1)
v = E{SIG,2,6}(1)
v123 = E{SIG,3,1}(1)





# wedge(v2,v1)





f(args...;grade = 1) = Blade{SIG,grade}(args...)

b1 = f(1,2,3,4)
b2 = f(1,1,1,1)
f(b) = Blade((-b.v[1],-b.v[2],-b.v[3],-b.v[4]))



p(a,b,c,d) = a*v1+b*v2+c*v3+d*v4

b1 = p(1,2,3,4)
b2 = p(13.,.32,3.3,2.4)






using PGA3D: sig ,grade, index


a = typeof(b1)
TType_a = map(i->eltype(a,i),firstindex(a):lastindex(a))
b = typeof(b2)
TType_b = map(i->eltype(b,i),firstindex(b):lastindex(b))

table = [(TType_a[i] *TType_b[j],(i,j)) for i in eachindex(TType_a) , j in eachindex(TType_b)]
out_table = [Vector{Any}() for i = 1:length(Blade{sig(a),grade(a) + grade(b)})]
foreach(table) do tt
    t = tt[1] 
    iszero(t[2]) && return
    grade(t[1]) != grade(a) + grade(b) && return
    push!(out_table[index(t[1])],(tt[2]...,t[2]))
end


ret = foldl(map(out_table) do v
    foldl(map(v) do t
        if t[3] == 1 
            "a.v[$(t[1])] * b.v[$(t[2])]"
        else
            "b.v[$(t[2])] * a.v[$(t[1])]"
        end
    end) do l,r
        "$l + $r"
    end
end) do l,r
    "$l,$r"
end