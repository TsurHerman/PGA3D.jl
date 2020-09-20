using Base

# Meta mechanism to simplify access to type meta parameters 
# from type instances(values) UnionAll types (where types) and Type{} types (in generated functions)

const Meta = Union{T,Type{S},Type{Type{S}},Type{Type{Type{S}}},Type{Type{Type{Type{S}}}}} where {T,S<:T}

@generated metatype(a) = begin
    b = Base.unwrap_unionall(a)
    while(b.name === Type.body.name)
        b = Base.unwrap_unionall(b.parameters[1])
    end
    return b
end
export metatype

meta_params(a,i) = meta_params(a,Val{i}())
@generated meta_params(a,::Val{i}) where i = begin
    metatype(a).parameters[i]
end

abstract type Algebra{SIG} <: Number end
@generated sig(e::Meta{Algebra}) = meta_params(e,1)
@generated Base.length(e::Meta{Algebra}) = length(sig(e)) + 1
@generated internal_size(e::Meta{Algebra}) = 2^length(sig(e))

abstract type Grade{SIG,GRADE} <: Algebra{SIG} end
@generated grade(e::Meta{Grade}) = meta_params(e,2)
@generated Base.length(e::Meta{Grade}) = binomial(length(sig(e)),grade(e))
@generated internal_size(e::Meta{Grade}) = length(e)
@generated index(e::Meta{Grade}) = foldl(+,binomial.(length(sig(e)),0:grade(e)-1)) + 1


abstract type GradeElement{SIG,GRADE,IDX} <: Grade{SIG,GRADE} end
@generated index(e::Meta{GradeElement}) = meta_params(e,3)
@generated Base.length(e::Meta{GradeElement}) = 1
@generated internal_size(e::Meta{GradeElement}) = 1

@generated internal_type(e::Meta{Algebra}) = metatype(e).parameters[end]
export internal_type



struct E{SIG,GRADE,IDX,T} <: GradeElement{SIG,GRADE,IDX} #IDX is the index inside the GRADE
    v::T
    E{SIG,GRADE,IDX,T}(arg::Union{T,Tuple{T}}) where {SIG,GRADE,IDX,T} = new{SIG,GRADE,IDX,T}(T(arg[1]))
end
export E
E{SIG,GRADE,IDX}(arg::T) where {SIG,GRADE,IDX,T} =  E{SIG,GRADE,IDX,T}(arg)




struct Blade{SIG,GRADE,N,T} <: Grade{SIG,GRADE}
    v::NTuple{N,T}
end
export Blade
Blade{SIG,GRADE}(args...) where {SIG,GRADE} = begin
    _args = promote(args...)
    Blade{SIG,GRADE,internal_size(Blade{SIG,GRADE}),eltype(_args)}(_args)
end
    


struct MultiBlade{SIG,N,T} <: Algebra{SIG}
    v::NTuple{N,T}
end
export MultiBlade
MultiBlade{SIG}(args...) where {SIG} = begin
    _args = promote(args...)
    MultiBlade{SIG,internal_size(MultiBlade{SIG}),eltype(_args)}(_args)
end

similar_type(e::Meta{E},::Type{T}) where T = begin
    E{sig(e),grade(e),index(e),T}
end
similar_type(e::Meta{Blade},::Type{T}) where T = begin
    Blade{sig(e),grade(e),length(e),T}
end
similar_type(e::Meta{MultiBlade},::Type{T}) where {T} = begin
    MultiBlade{sig(e),internal_size(e),T}
end
export similar_type



Base.eltype(a::Algebra) = eltype(typeof(a))

Base.eltype(a::Type{<:Algebra}) = Blade{sig(a),GRADE,N,internal_type(a)} where {GRADE,N}
Base.eltype(a::Type{<:Grade}) = E{sig(a),grade(a),IDX,internal_type(a)} where {IDX}
Base.eltype(a::Type{GradeElement}) = metatype(a)

Base.eltype(a::Algebra,i) = eltype(typeof(a),i)

Base.eltype(a::Meta{MultiBlade},i) = eltype(a){i,length(eltype(a){i})}
Base.eltype(a::Meta{Blade},i) = eltype(a){i}
Base.eltype(a::Meta{E},i) = metatype(a)


as_tuple(e::GradeElement) = e
@generated as_tuple(e::Algebra) = begin
    TType = Tuple{map(i->eltype(e,i),firstindex(e):lastindex(e))...}
    expr = ntuple(i->"e,",length(e))
    expr = "$TType((" * prod(expr) * "))"
    expr |> Base.Meta.parse
end

Base.getindex(e::Blade,i::Int) = eltype(e,i)(e)
Base.getindex(e::MultiBlade,grade::Int) = eltype(e,grade)(e)
Base.getindex(e::E,i::Int) = e



Base.firstindex(e::Meta{Algebra}) = 0
Base.firstindex(e::Meta{Grade}) = 1
Base.firstindex(e::Meta{GradeElement}) = 1

Base.lastindex(e::Meta{Algebra}) = length(e) - 1
Base.lastindex(e::Meta{Grade}) = length(e) 
Base.lastindex(e::Meta{GradeElement}) = length(e) 

E{SIG,GRADE,IDX,T}(a::Grade) where {SIG,GRADE,IDX,T} = E{SIG,GRADE,IDX,T}(a.v[IDX])
Blade{SIG,GRADE,N,T}(a::MultiBlade) where {SIG,GRADE,N,T} = begin
    TT = Blade{SIG,GRADE,N,T}
    si = index(TT)   
    ei = si + N - 1
    TT(a.v[si:ei])
end


Base.IteratorSize(e::Type{<:Algebra}) = Base.HasLength()
Base.iterate(e::Algebra) = (e[firstindex(e)],firstindex(e) + 1)
Base.iterate(e::Algebra,state) = state > lastindex(e) ? nothing : (e[state] , state + 1)

Base.iterate(e::E) = (e,nothing)
Base.iterate(e::E,state) = nothing
