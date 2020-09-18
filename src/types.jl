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

abstract type GradedAlgebra{SIG} <: Number end
@generated sig(e::Meta{GradedAlgebra}) = meta_params(e,1)
@generated Base.length(e::Meta{GradedAlgebra}) = length(sig(e)) + 1
@generated internal_size(e::Meta{GradedAlgebra}) = 2^length(sig(e))

abstract type Grade{SIG,GRADE} <: GradedAlgebra{SIG} end
@generated grade(e::Meta{Grade}) = meta_params(e,2)
@generated Base.length(e::Meta{Grade}) = binomial(length(sig(e)),grade(e))
@generated internal_size(e::Meta{Grade}) = length(e)
@generated index(e::Meta{Grade}) = foldl(+,binomial.(length(sig(e)),0:grade(e)-1)) + 1


abstract type GradeElement{SIG,GRADE,IDX} <: Grade{SIG,GRADE} end
@generated index(e::Meta{GradeElement}) = meta_params(e,3)
@generated Base.length(e::Meta{GradeElement}) = 1
@generated internal_size(e::Meta{GradeElement}) = 1

@generated internal_type(e::Meta{GradedAlgebra}) = metatype(e).parameters[end]
export internal_type



struct E{SIG,GRADE,IDX,T} <: GradeElement{SIG,GRADE,IDX} #IDX is the index inside the GRADE
    v::T
    E{SIG,GRADE,IDX,T}(arg::Union{T,Tuple{T}}) where {SIG,GRADE,IDX,T} = new{SIG,GRADE,IDX,T}(T(arg[1]))
end
export E
@generated E{SIG,GRADE,IDX}(arg) where {SIG,GRADE,IDX} = begin
    return quote
        E{SIG,GRADE,IDX,$arg}(arg)
    end
end 




struct Blade{SIG,GRADE,N,T} <: Grade{SIG,GRADE}
    v::NTuple{N,T}
end
export Blade
@generated Blade{SIG,GRADE}(args...) where {SIG,GRADE} = begin
    T = promote_type(args...)
    N = internal_size(Blade{SIG,GRADE})
    len = length(args)
    @assert N == len "wrong number of elements: expected $N got $len"
    return quote
        Blade{$SIG,$GRADE,$N,$T}($T.(args))
    end
end
Base.getindex(e::Blade,i::Int) = _getindex(e,Val{i}())
@generated _getindex(e::Blade,::Val{i}) where i = quote 
    E{$(sig(e)),$(grade(e)),i,$(internal_type(e))}(e.v[i])
end
    


struct MultiBlade{SIG,N,T} <: GradedAlgebra{SIG}
    v::NTuple{N,T}
end
export MultiBlade
@generated MultiBlade{SIG}(args...) where {SIG} = begin
    T = promote_type(args...)
    N = internal_size(MultiBlade{SIG})
    len = length(args)
    @assert N == len "wrong number of elements: expected $N got $len"
    return quote
        MultiBlade{$SIG,$N,$T}($T.(args))
    end
end 
Base.getindex(e::MultiBlade,i::Int) = _getindex(e,Val{i}())


@generated _getindex(mb::MultiBlade,::Val{i}) where i = begin
    SIG = sig(b)
    B = Blade{SIG,i}
    N = internal_size(B)
    T = internal_type(mb)
    si = index(B)
    sexpr = map(1:internal_size(B)) do i
        "mb.v[$(si + i + -1)],"
    end
    "Blade{$SIG,$N,$T}( ($(prod(sexpr))) )" |> Base.Meta.parse
end




@generated similar_type(e::Meta{E},::Type{T}) where T = begin
    E{sig(e),grade(e),index(e),T}
end
@generated similar_type(e::Meta{Blade},::Type{T}) where T = begin
    Blade{sig(e),grade(e),length(e),T}
end
@generated similar_type(e::Meta{MultiBlade},::Type{T}) where {T} = begin
    MultiBlade{sig(e),internal_size(e),T}
end
export similar_type
