using Base

# Meta mechanism to simplify access to type meta parameters 
# from type instances(values) UnionAll types (where types) and Type{} types (in generated functions)

const Meta = Union{T,Type{S}} where {T,S<:T}

metatype(a) = begin
    b = Base.unwrap_unionall(a)
    while(b.name === Type.body.name)
        b = Base.unwrap_unionall(b.parameters[1])
    end
    return b
end
export metatype

meta_params(a,i) = metatype(a).parameters[i]


abstract type GradedAlgebra{SIG} <: Number end
@generated sig(e::Meta{GradedAlgebra}) = meta_params(e,1)
@generated Base.length(e::Meta{GradedAlgebra}) = length(sig(metatype(e))) + 1
@generated internal_size(e::Meta{GradedAlgebra}) = 2^length(sig(metatype(e)))

abstract type Grade{SIG,GRADE} <: GradedAlgebra{SIG} end
@generated grade(e::Meta{Grade}) = meta_params(e,2)
@generated Base.length(e::Meta{Grade}) = binomial(length(sig(metatype(e))),grade(metatype(e)))
@generated internal_size(e::Meta{Grade}) = length(metatype(e))

abstract type GradeElement{SIG,GRADE,IDX} <: Grade{SIG,GRADE} end
@generated index(e::Meta{GradeElement}) = meta_params(e,3)
@generated Base.length(e::Meta{GradeElement}) = 1
@generated internal_size(e::Meta{GradeElement}) = 1

@generated FieldType(e::Meta{GradedAlgebra}) = metatype(e).parameters[end]
export FieldType



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
@generated as_tuple(e::Blade{SIG,GRADE,N,T}) where {SIG,GRADE,N,T} = begin 
    TType = Tuple{ntuple(i->E{sig(e),grade(e),i,T},internal_size(e))...}
    return quote 
        reinterpret_tuple($TType,e.v)
    end
end
Base.getindex(e::Blade,i::Int) = E{sig(e),grade(e),i,typeof(e.v[i])}(e.v[i])
    


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
@generated as_tuple(e::MultiBlade{SIG,N,T}) where {SIG,N,T} = begin
    TType = Tuple{ntuple(i->Blade{SIG,i-1,internal_size(Blade{SIG,i-1}),T},length(SIG) + 1)...}
    return quote 
        reinterpret_tuple($TType,e.v)
    end
end
Base.getindex(e::MultiBlade,i::Int) = as_tuple(e)[i+1]





@generated similar_type(e::Meta{E},::Type{T}) where T = begin
    E{sig(metatype(e)),grade(metatype(e)),index(metatype(e)),T}
end
@generated similar_type(e::Meta{Blade},::Type{T}) where T = begin
    Blade{sig(metatype(e)),grade(metatype(e)),length(metatype(e)),T}
end
@generated similar_type(e::Meta{MultiBlade},::Type{T}) where {T} = begin
    MultiBlade{sig(metatype(e)),internal_size(metatype(e)),T}
end
export similar_type
