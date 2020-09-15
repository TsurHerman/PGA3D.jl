type_maker(::E{SIG,GRADE,IDX,T}) where {SIG,GRADE,IDX,T} = E{SIG,GRADE,IDX}
type_maker(::Blade{SIG,GRADE,T}) where {SIG,GRADE,T} = Blade{SIG,GRADE}
type_maker(::MultiBlade{SIG,T}) where {SIG,T} = MultiBlade{SIG}

type_string(::Type{<:E{SIG,GRADE,IDX}}) where {SIG,GRADE,IDX} = "E{$SIG,$GRADE,$IDX}"
type_string(::Type{<:Blade{SIG,GRADE}}) where {SIG,GRADE} = "Blade{$SIG,$GRADE}"
type_string(::Type{<:MultiBlade{SIG}}) where {SIG} = "MultiBlade{$SIG}"

# cached zero values
Base.zero(e::Meta{GradedAlgebra}) = zero(Int8,e)
@generated Base.zero(dt::Type{T},e::Meta{GradedAlgebra}) where T = metatype(e)(ntuple(i->zero(T),length(metatype(e)))...)
Base.iszero(e::GradedAlgebra) = all(iszero.(e.v))


#plus 
approax_plus(a,b) = isapprox(a,-b) ? zero(a) : a + b
# approax_plus(a,b) =  a + b

#helping the compiler by spelling out all the combination rules in a non-recursive way
Base.:+(a::E{SIG,GRADE,IDX},b::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX}= E{SIG,GRADE}(approax_plus(a.v,b.v))
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
    typ = type_string(a)
    len = internal_size(a)
    tup = map(1:len) do i
        "a.v[$i] * b ,"
    end |> prod
    "$typ($tup)" |> Base.Meta.parse
end

Base.:/(a::Number,b::GradedAlgebra)  = *(a,inv(b))
Base.:/(a::GradedAlgebra,b::Number)  = *(a,inv(b))


@generated lift(e::E) = begin
    SIG = sig(e)
    GRADE = grade(e)
    N = internal_size(Blade{SIG,GRADE})
    vals = ntuple(i->isequal(i,index(e)) ? "e.v," : "0,",N)
    "Blade{$SIG,$GRADE}($(prod(vals)))" |> Base.Meta.parse
end

@generated lift(b::Blade) = begin
    SIG = sig(b)
    MB = MultiBlade{SIG}
    N = internal_size(MB)
    _start_index = foldl(+,binomial.(length(sig(b)),0:grade(b)-1)) + 1
    sexpr = map(1:internal_size(MB)) do i
        i >= _start_index && i < (_start_index + internal_size(b)) ? "b.v[$(i-_start_index + 1)]," : "0,"
    end
    "MultiBlade{$SIG}( $(prod(sexpr)) )" |> Base.Meta.parse
end

@generated unroll_plus(a::GradedAlgebra,b::GradedAlgebra) = begin
    typ = type_string(a)
    len = internal_size(a)
    tup = map(1:len) do i
        "approax_plus(a.v[$i],b.v[$i]) ,"
    end |> prod
    "$typ($tup)" |> Base.Meta.parse
end