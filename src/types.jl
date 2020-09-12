struct EZero end

struct E{SIG,GRADE,IDX,T} #IDX is the index inside the GRADE
    v::T
    E{SIG,GRADE,IDX}(val::T) where {SIG,GRADE,IDX,T} = new{SIG,GRADE,IDX,T}(val)
    E{SIG,GRADE,IDX,T}(val::T) where {SIG,GRADE,IDX,T} = new{SIG,GRADE,IDX,T}(val)
end
export E
  
struct Blade{SIG,GRADE,T<:NTuple{N,E{SIG,GRADE}} where N}
    v::T
    Blade{SIG,GRADE}(args...) where {SIG,GRADE}= begin
        _v = ntuple(i->E{SIG,GRADE,i}(args[i]),length(args))
        new{SIG,GRADE,typeof(_v)}(_v)
    end
    Blade(args::NTuple{N,E{SIG,GRADE}}) where {N,SIG,GRADE} = begin 
        new{SIG,GRADE,typeof(args)}(args)
    end
    Blade(x::Blade) = x
end
export Blade
Base.length(::Type{Blade{SIG,GRADE,T}}) where {SIG,GRADE,T} = binomial(length(SIG), GRADE)

struct MultiBlade{SIG,NE}
    v::NTuple{NE,Blade{SIG}}
end
export MultiBlade

wedge(a::MultiBlade{SIG} , b::MultiBlade{SIG}) where {SIG} = begin
    foldl(+,wedge(a,b) for a in a.v, b in b.v)
end
export wedge

@generated wedge(a::Blade{SIG,GRADE1},b::Blade{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = begin
    sexpr = foldl("wedge(a.v[$i],b.v[$j])" for i in 1:length(a), j in 1:length(b)) do l,r
        l * " + " * r
    end |> Meta.parse
end


@generated wedge(a::E{SIG,GRADE1,IDX1},b::E{SIG,GRADE2,IDX2}) where {SIG,GRADE1,GRADE2,IDX1,IDX2} = begin
    ct,cs = common_type(SIG .* 0,to_tuple_index(SIG,GRADE1,IDX1), to_tuple_index(SIG,GRADE2,IDX2))
    out_type = make_type(SIG,ct)

    return iszero(cs) ? EZero() : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote 
        $out_type(-a.v * b.v)
    end
end

