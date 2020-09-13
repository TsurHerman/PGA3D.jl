@generated zero_blade(e::E{SIG,GRADE,IDX,T}) where {SIG,GRADE,IDX,T} = begin 
    Blade{SIG,GRADE}(zeros(T,binomial(length(SIG),GRADE))...)
end


Base.:+(::EZero, x) = x
Base.:+(x,::EZero) = x

Base.:+(::PGA3D.EZero, ::PGA3D.EZero) = 0

Base.:+(e1::E{SIG,GRADE,IDX},e2::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin 
    E{SIG,GRADE,IDX}(e1.v+e2.v)
end
Base.:+(e1::E{SIG,GRADE,IDX1},e2::E{SIG,GRADE,IDX2}) where {SIG,GRADE,IDX1,IDX2} = begin
    b = zero_blade(e1)
    b + e1 + e2
end


@generated Base.:+(a::Blade{SIG,GRADE},b::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    unroll_add_idx("Blade","a",length(a),"b",IDX)
end
@generated Base.:+(a::Blade{SIG,GRADE},b::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    unroll_add_idx("Blade","a",length(a),"b",IDX)
end


Base.:-(e::E) = typeof(e)(-e.v)
Base.:-(e::Blade) = Blade(map(-,e.v))
Base.:-(e::MultiBlade) = MultiBlade(map(-,e.v))
Base.:-(a::Algebra,b::Algebra) = a + (-b)

