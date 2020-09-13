abstract type Algebra{SIG} end
struct EZero end

struct E{SIG,GRADE,IDX,T} <: Algebra{SIG} #IDX is the index inside the GRADE
    v::T
    E{SIG,GRADE,IDX}(val) where {SIG,GRADE,IDX} = new{SIG,GRADE,IDX,typeof(val)}(val)
    E{SIG,GRADE,IDX,T}(val) where {SIG,GRADE,IDX,T} = new{SIG,GRADE,IDX,T}(T(val))
end
export E
grade(e::E) = grade(typeof(e))
grade(e::Type{T}) where T<:E = e.parameters[2]
Base.getindex(e::E,::Int) = e
export grade


struct Blade{SIG,GRADE,T<:NTuple{N,E{SIG,GRADE}} where N} <: Algebra{SIG}
    v::T
    Blade{SIG,GRADE}(args...) where {SIG,GRADE}= begin
        _v = ntuple(i->E{SIG,GRADE,i}(args[i]),length(args))
        new{SIG,GRADE,typeof(_v)}(_v)
    end
    Blade(args::NTuple{N,E{SIG,GRADE}} where N) where {SIG,GRADE}  = new{SIG,GRADE,typeof(args)}(args) 
    Blade(x::Blade) = x
end
export Blade
Base.length(b::Blade) = length(typeof(b))
Base.length(::Type{Blade{SIG,GRADE,T}}) where {SIG,GRADE,T} = binomial(length(SIG), GRADE)
Base.getindex(b::Blade,i::Int) = b.v[i]




struct MultiBlade{SIG,T<:NTuple{N,Blade{SIG}} where N } <: Algebra{SIG}
    v::T
end
export MultiBlade
Base.getindex(mb::MultiBlade,i::Int) = mb.v[i]





