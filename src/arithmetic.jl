
# cached zero values
Base.zero(e::Meta{GradedAlgebra}) = zero(Int8,e)
@generated Base.zero(dt::Type{T},e::Meta{GradedAlgebra}) where T = similar_type(metatype(e),T)(ntuple(i->zero(T),length(metatype(e))))
Base.iszero(e::GradedAlgebra) = all(iszero.(e.v))


#plus 
approax_plus(a,b) = isapprox(a,-b) ? zero(a) : a + b
# approax_plus(a,b) =  a + b

#helping the compiler by spelling out all the combination rules in a non-recursive way
Base.:+(a::E{SIG,GRADE,IDX},b::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX}= unroll_plus(a,b)
Base.:+(a::E{SIG,GRADE,IDX1},b::E{SIG,GRADE,IDX2}) where {SIG,GRADE,IDX1,IDX2} = lift(a) + b
Base.:+(a::E{SIG,GRADE1},b::E{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = lift(lift(a)) + lift(lift(b))

Base.:+(a::Blade{SIG,GRADE1},b::E{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = lift(a) + lift(lift(b))
Base.:+(a::Blade{SIG,GRADE},b::E{SIG,GRADE}) where {SIG,GRADE} = a + lift(b)

Base.:+(a::Blade{SIG,GRADE},b::Blade{SIG,GRADE}) where {SIG,GRADE} = unroll_plus(a,b)
Base.:+(a::Blade{SIG,GRADE1},b::Blade{SIG,GRADE2}) where {SIG,GRADE1,GRADE2} = lift(a) + lift(b)

Base.:+(a::MultiBlade{SIG},e::E{SIG}) where {SIG} = a + lift(lift(b))
Base.:+(a::MultiBlade{SIG},b::Blade{SIG}) where {SIG} = a + lift(b)
Base.:+(a::MultiBlade{SIG},b::MultiBlade{SIG}) where {SIG} = unroll_plus(a,b)

Base.:+(a::GradedAlgebra, b::GradedAlgebra) = +(b,a)







# iszero check to avoid un-nesseceary widening
Base.:+(a::GradedAlgebra,b::Number)  = iszero(b) ? a : a + E{sig(a),0,1}(b)
Base.:+(a::Number,b::GradedAlgebra)  = +(b,a)

#minus is plus
Base.:-(a::GradedAlgebra) = (-1) * a
Base.:-(a::GradedAlgebra,b::Number)  = a + (-b)
Base.:-(a::Number,b::GradedAlgebra)  = a + (-b)
Base.:-(a::GradedAlgebra,b::GradedAlgebra)  = a + (-b)
  

Base.:*(a::Number,b::GradedAlgebra)  = *(b,a)
@generated Base.:*(a::GradedAlgebra,b::Number)  = begin
    len = internal_size(a)
    T = promote_type(FieldType(a),b)
    typ = similar_type(a,T)

    tup = [:( *(a.v[$i],b) ) for i=1:len] |> Tuple
    
    :($typ(   ($(tup...),)  ))
end

Base.:/(a::Number,b::GradedAlgebra)  = *(a,inv(b))
Base.:/(a::GradedAlgebra,b::Number)  = *(a,inv(b))


@generated lift(e::E) = begin
    SIG = sig(metatype(e))
    GRADE = grade(metatype(e))
    N = internal_size(Blade{SIG,GRADE})
    T = FieldType(metatype(e))
    vals = ntuple(i->isequal(i,index(metatype(e))) ? "e.v," : "zero(e.v),",N)
    
    "Blade{$SIG,$GRADE,$N,$T}( ($(prod(vals))) )" |> Base.Meta.parse
end
export lift

@generated lift(b::Blade) = begin
    SIG = sig(b)
    MB = MultiBlade{SIG}
    N = internal_size(MB)
    T = FieldType(b)
    _start_index = foldl(+,binomial.(length(sig(b)),0:grade(b)-1)) + 1
    sexpr = map(1:internal_size(MB)) do i
        i >= _start_index && i < (_start_index + internal_size(b)) ? "b.v[$(i-_start_index + 1)]," : "zero($T),"
    end
    "MultiBlade{$SIG,$N,$T}( ($(prod(sexpr))) )" |> Base.Meta.parse
end

@generated unroll_plus(a::GradedAlgebra,b::GradedAlgebra) = begin
    len = internal_size(a)
    T = promote_type(FieldType(a),FieldType(b))
    typ = similar_type(a,T)

    tup = [:( approax_plus(a.v[$i],b.v[$i]) ) for i=1:len] 
    :($typ(   ($(tup...),)  ))
end

