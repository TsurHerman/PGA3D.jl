using Setfield
@generated zero_blade(::E{SIG,GRADE,IDX,T}) where {SIG,GRADE,IDX,T} = begin 
    Blade{SIG,GRADE}(zeros(T,binomial(length(SIG),GRADE))...)
end

Base.:-(e::E) = typeof(e)(-e.v)

Base.:+(::PGA3D.EZero, x) = x
Base.:+(x,::PGA3D.EZero) = x
Base.:+(e1::E{SIG,GRADE,IDX},e2::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    E{SIG,GRADE,IDX}(e1.v+e2.v)
end
Base.:+(e1::E{SIG,GRADE,IDX1},e2::E{SIG,GRADE,IDX2}) where {SIG,GRADE,IDX1,IDX2} = begin
    b = zero_blade(e1)
    b + e1 + e2
end

@generated Base.:+(b::Blade{SIG,GRADE},e::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    sexp = map(1:binomial(length(SIG),GRADE)) do i 
        "b.v[$i],"
    end
    sexp[IDX] = "b.v[$IDX] + e ," 
    sexp = "Blade(($(prod(sexp))))"
    return Meta.parse(sexp)
end


IDX = 2
