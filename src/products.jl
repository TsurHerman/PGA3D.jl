import LinearAlgebra: dot , ⋅
#Generators of all products wedge and dot

Base.:*(a::Type{<:E{SIG,GRADE1,IDX1,T1}},b::Type{<:E{SIG,GRADE2,IDX2,T2}}) where {SIG,GRADE1,GRADE2,IDX1,IDX2,T1,T2} = begin
    ct,cs = common_type(SIG,to_index_tuple(SIG,GRADE1,IDX1), to_index_tuple(SIG,GRADE2,IDX2))
    out_type = make_type(SIG,ct)
    return out_type{promote_type(T1,T2)},cs    
end

@generated wedge(a::E,b::E) = begin
    out_type,cs = a*b
    cs = grade(out_type) >= grade(a) + grade(b) ? cs : 0

    return iszero(cs) ? 0 : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

@generated dot(a::E,b::E) = begin
    out_type,cs = a*b
    cs = grade(out_type) < grade(a) + grade(b) ? cs : 0
    
    return iszero(cs) ? 0 : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

# products

@generated wedge(a::GradedAlgebra{SIG} , b::GradedAlgebra{SIG}) where {SIG} = begin

    unroll_product("wedge","a",length(a),"b",length(b))
end

@generated dot(a::GradedAlgebra{SIG},b::GradedAlgebra{SIG}) where SIG = begin
    unroll_product("dot","a",length(a),"b",length(b))
end

Base.:*(a::GradedAlgebra{SIG},b::GradedAlgebra{SIG}) where SIG = begin
    a ⋅ b + a ∧ b
end







unroll_product(fn::String,a::String,alen::Int,b::String,blen::Int) = begin 
    foldl("$fn($a[$i],$b[$j])" for i in alen:-1:1, j in 1:blen) do l,r
        l * " + " * r
    end |> Base.Meta.parse
end