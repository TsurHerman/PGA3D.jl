import LinearAlgebra: dot , ⋅
#Generators of all products wedge and dot

Base.:*(a::Type{<:E{SIG,GRADE1,IDX1,T1}},b::Type{<:E{SIG,GRADE2,IDX2,T2}}) where {SIG,GRADE1,GRADE2,IDX1,IDX2,T1,T2} = begin
    ct,cs = common_type(SIG,to_tuple_index(SIG,GRADE1,IDX1), to_tuple_index(SIG,GRADE2,IDX2))
    out_type = make_type(SIG,ct)
    return out_type{promote_type(T1,T2)},cs    
end

@generated wedge(a::E,b::E) = begin
    out_type,cs = a*b
    cs = grade(out_type) >= grade(a) + grade(b) ? cs : 0

    return iszero(cs) ? EZero() : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

@generated dot(a::E,b::E) = begin
    out_type,cs = a*b
    cs = grade(out_type) < grade(a) + grade(b) ? cs : 0
    
    return iszero(cs) ? EZero() : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

# products

@generated wedge(a::Algebra{SIG} , b::Algebra{SIG}) where {SIG} = begin
    unroll_product("wedge","a",length(a),"b",length(b))
end

@generated dot(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    unroll_product("dot","a",length(a),"b",length(b))
end

Base.:*(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    a ⋅ b + a ∧ b
end

