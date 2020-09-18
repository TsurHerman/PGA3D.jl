
# cached zero values
Base.zero(e::Meta{GradedAlgebra}) = zero(internal_type(e),e)
@generated Base.zero(dt::Type{T},e::Meta{GradedAlgebra}) where T = similar_type(e,T)(ntuple(i->zero(T),internal_size(e)))
# Base.iszero(e::GradedAlgebra) = all(iszero.(e.v))


#plus 
# approax_plus(a,b) = isapprox(a,-b) ? zero(a) : a + b
# approax_plus(a,b) =  a + b

Base.:+(a::E{SIG},b::E{SIG}) where SIG = ifelse( (grade(a) == grade(b)) && (index(a) == index(b)),unroll_plus(a,b), lift(a) + b)

Base.:+(a::Blade{SIG,GRADE},b::E{SIG,GRADE}) where {SIG,GRADE} = begin
    T = promote_type(internal_type(a),internal_type(b))
    TT = similar_type(a,T)
    TT(Base.setindex(a.v,a.v[index(b)] + b.v,index(b)))
end

Base.:+(a::MultiBlade{SIG},b::E{SIG}) where {SIG} = begin
    T = promote_type(internal_type(a),internal_type(b))
    TT = similar_type(a,T)
    idx = index(Blade{sig(e),grade(e)}) - 1
    TT(Base.setindex(a.v,a.v[idx] + b.v,idx))
end


Base.:+(a::Blade{SIG,GRADE1},b::E{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = lift(a) + b
Base.:+(a::Blade{SIG},b::Blade{SIG}) where SIG   = ifelse( (grade(a) == grade(b)),unroll_plus(a,b), lift(a) + b)

Base.:+(a::MultiBlade{SIG},b::Blade{SIG}) where {SIG} = a + lift(b)
Base.:+(a::MultiBlade{SIG},b::MultiBlade{SIG}) where {SIG} = unroll_plus(a,b)

Base.:+(a::GradedAlgebra, b::GradedAlgebra) = +(b,a) # if you dont know what to do switch sides


lift(e::E) = begin 
    N = internal_size(Blade{sig(e),grade(e)})
    B = Blade{sig(e),grade(e),N,internal_type(e)}
    B(Base.setindex(zero(B).v,e.v,index(e)))
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
    "MultiBlade{$SIG,$N,$T}( ($(prod(sexpr))) )" |> Base.Meta.parse
end




# iszero check to avoid un-nesseceary widening
Base.:+(a::GradedAlgebra,b::Number)  = iszero(b) ? a : a + E{sig(a),0,1}(b)
Base.:+(a::Number,b::GradedAlgebra)  = +(b,a)

#minus is plus
Base.:-(a::GradedAlgebra) = (-1) * a
Base.:-(a::GradedAlgebra,b::Number)  = a + (-b)
Base.:-(a::Number,b::GradedAlgebra)  = a + (-b)
Base.:-(a::GradedAlgebra,b::GradedAlgebra)  = a + (-b)
  

Base.:*(a::Number,b::GradedAlgebra)  = *(b,a)
Base.:*(a::GradedAlgebra,b::Number)  = similar_type(typeof(a),typeof(b))(broadcast(*,a.v,b))

Base.:/(a::Number,b::GradedAlgebra)  = *(a,inv(b))
Base.:/(a::GradedAlgebra,b::Number)  = *(a,inv(b))


unroll_plus(a::GradedAlgebra,b::GradedAlgebra) = begin
    T = promote_type(internal_type(a),internal_type(b))
    similar_type(typeof(a),T)(broadcast(+,a.v,b.v))
end