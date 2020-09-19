import LinearAlgebra: dot , ⋅
#Generators of all products wedge and dot
Base.:+(a::Algebra, ::Nothing) = a
Base.:+(::Nothing, a::Algebra) = a
Base.:+(::Nothing, ::Nothing) = nothing



wedge(a::Type{<:E{SIG,GRADE1,IDX1,T1}},b::Type{<:E{SIG,GRADE2,IDX2,T2}}) where {SIG,GRADE1,GRADE2,IDX1,IDX2,T1,T2} = begin
    ct,cs = common_type(SIG,to_index_tuple(SIG,GRADE1,IDX1), to_index_tuple(SIG,GRADE2,IDX2))
    out_type = make_type(SIG,ct)
    return out_type{promote_type(T1,T2)},cs    
end

@noinline @generated wedge(a::E,b::E) = begin
    out_type,cs = wedge(a,b)
    @async @show a
    cs = grade(out_type) >= grade(a) + grade(b) ? cs : 0

    return iszero(cs) ? nothing : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

# @generated wedge(a::Blade{SIG},b::Blade{SIG}) where SIG = begin
#     grade(a) + grade(b) > lengths(SIG) && return nothing
#     outype = Blade{SIG,grade(a) + grade(b),N,promote_types(internal_type(a),internal_type(b))} where N
#     outype = outype{length(outype)}
    
#     out_type,cs = a*b
#     @async @show a
#     cs = grade(out_type) >= grade(a) + grade(b) ? cs : 0

#     return iszero(cs) ? nothing : isone(cs) ?  quote 
#         $out_type(a.v * b.v)
#     end : quote          
#         $out_type(-a.v * b.v)
#     end
# end
#     @async @show a
#     cs = grade(out_type) >= grade(a) + grade(b) ? cs : 0

#     return iszero(cs) ? nothing : isone(cs) ?  quote 
#         $out_type(a.v * b.v)
#     end : quote          
#         $out_type(-a.v * b.v)
#     end
# end


@generated dot(a::E,b::E) = begin
    out_type,cs = a*b
    cs = grade(out_type) < grade(a) + grade(b) ? cs : 0
    
    return iszero(cs) ? nothing : isone(cs) ?  quote 
        $out_type(a.v * b.v)
    end : quote          
        $out_type(-a.v * b.v)
    end
end

# products
@generated Base.length(tt::Type{T}) where T<:Tuple = length(metatype(tt).parameters)

# wedge(a,b) = _wedge(as_tuple(a),as_tuple(b))

@generated wedge(a , b)= begin quote 
        Base.@_inline_meta
        $(unroll_product("wedge","a",length(a),"b",length(b)))
    end
end

@generated dot(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    unroll_product("dot","a",length(a),"b",length(b))
end

Base.:*(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    a ⋅ b + a ∧ b
end







unroll_product(fn::String,a::String,alen::Int,b::String,blen::Int) = begin
    foldl("$fn($a[$i],$b[$j])" for i in alen:-1:1, j in 1:blen) do l,r
        l * " + " * r
    end |> Base.Meta.parse
end