
# cached zero values
Base.zero(e::Meta{Algebra}) = zero(internal_type(e),e)
Base.zero(dt::DataType,e::Algebra) = zero(dt,typeof(e))
@generated Base.zero(dt::Type{T},e::Type{<:Algebra}) where T = similar_type(meta(e),T)(ntuple(i->zero(T),internal_size(meta(e))))
# Base.iszero(e::Algebra) = all(iszero.(e.v))


#plus 
# approax_plus(a,b) = isapprox(a,-b) ? zero(a) : a + b
# approax_plus(a,b) =  a + b

Base.:+(a::E{SIG},b::E{SIG}) where SIG = ifelse( (grade(a) == grade(b)) && (index(a) == index(b)),unroll_plus(a,b), lift(a) + b)

Base.:+(a::Blade{SIG,GRADE},b::E{SIG,GRADE}) where {SIG,GRADE} = begin
    T = promote_type(internal_type(a),internal_type(b))
    TT = similar_type(a,T)
    TT(Base.setindex(a.v,a.v[index(b)] + b.v,index(b)))
end

@inline @inbounds Base.:+(a::MultiBlade{SIG},b::E{SIG}) where {SIG} = begin
    T = promote_type(internal_type(a),internal_type(b))
    TT = similar_type(a,T)
    idx = index(Blade{sig(a),grade(b)}) + index(b)- 1
    TT(Base.setindex(a.v,a.v[idx] + b.v,idx))
end


@inline Base.:+(a::Blade{SIG,GRADE1},b::E{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = lift(a) + lift(lift(b))
@inline Base.:+(a::Blade{SIG},b::Blade{SIG}) where SIG = if grade(eltype(a)) == grade(eltype(b))
    unroll_plus(a,b)
else
    lift(a) + lift(b)
end

@inline Base.:+(a::MultiBlade{SIG},b::Blade{SIG}) where {SIG} = a + lift(b)
@inline Base.:+(a::MultiBlade{SIG},b::MultiBlade{SIG}) where {SIG} = unroll_plus(a,b)

@inline Base.:+(a::Algebra, b::Algebra) = +(b,a) # if you dont know what to do switch sides


@generated lift(e::E) = begin 
    N = internal_size(Blade{sig(e),grade(e)})
    T = internal_type(e)
    B = Blade{sig(e),grade(e),N,T}
    T = internal_type(e)
    sexpr = map(1:internal_size(B)) do i
        i==index(e) ? "e.v," : "zero($T),"
    end
    ret = "$B(($(prod(sexpr))))"
    quote 
        Base.@_inline_meta
        Base.@_propagate_inbounds_meta
        $(Base.Meta.parse(ret))
    end
end
export lift

@generated lift(b::Blade) = begin
    SIG = sig(b)
    MB = MultiBlade{SIG}
    N = internal_size(MB)
    T = internal_type(b)
    si = index(b)
    sexpr = map(1:internal_size(MB)) do i
        i >= si && i < (si + internal_size(b)) ? "b.v[$(i-si + 1)]," : "zero($T),"
    end
    ret = "MultiBlade{$SIG,$N,$T}( ($(prod(sexpr))) )"
    quote 
        Base.@_inline_meta
        Base.@_propagate_inbounds_meta
        $(Base.Meta.parse(ret))
    end
end

Base.:+(a::Algebra,b::Number)  = iszero(b) ? a : +(a , E{sig(a),0,1}(b))
Base.:+(a::Number,b::Algebra)  = +(b,a)

#minus is plus
Base.:-(a::Algebra) = (-1) * a
Base.:-(a::Algebra,b::Number)  = a + (-b)
Base.:-(a::Number,b::Algebra)  = a + (-b)
Base.:-(a::Algebra,b::Algebra)  = a + (-b)
  

Base.:*(a::Number,b::Algebra)  = *(b,a)
@inline Base.:*(a::Algebra,b::Number)  = similar_type(typeof(a),promote_type(internal_type(a),typeof(b)))(broadcast(*,a.v,b))

# Base.:/(a::Number,b::Algebra)  = *(a,inv(b))
Base.:/(a::Algebra,b::Number)  = *(a,inv(b))


@generated unroll_plus(a::Algebra,b::Algebra) = begin
    T = promote_type(internal_type(a),internal_type(b))
    out_type = similar_type(a,T)
    terms = map(1:internal_size(a)) do i
        "a.v[$i] + b.v[$i],"
    end
    expr = "($(prod(terms)))"
    ret = "$out_type($expr)"
    quote 
        Base.@_propagate_inbounds_meta
        Base.@_inline_meta
        $(Base.Meta.parse(ret))
    end
end

# @inline unroll_plus(a::Algebra,b::Algebra) = similar_type(typeof(a),promote_type(internal_type(a),internal_type(b)))(broadcast(+,a.v,b.v))

