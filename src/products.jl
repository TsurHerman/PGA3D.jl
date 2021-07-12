import LinearAlgebra: dot , ⋅
#Generators of all products wedge and dot
Base.:+(a::Algebra, ::Nothing) = a
Base.:+(::Nothing, a::Algebra) = a
Base.:+(::Nothing, ::Nothing) = nothing



Base.:*(a::Type{<:E{SIG,GRADE1,IDX1,T1}},b::Type{<:E{SIG,GRADE2,IDX2,T2}}) where {SIG,GRADE1,GRADE2,IDX1,IDX2,T1,T2} = begin
    ct,cs = common_type(SIG,to_index_tuple(SIG,GRADE1,IDX1), to_index_tuple(SIG,GRADE2,IDX2))
    out_type = make_type(SIG,ct)
    return out_type{promote_type(T1,T2)},cs    
end

# products
@generated Base.length(tt::Type{T}) where T<:Tuple = length(metatype(tt).parameters)

@inline Base.:*(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    a ⋅ b + a ∧ b
end


wedge_table(a::Type{<:Algebra{SIG}}, b::Type{<:Algebra{SIG}}) where SIG = begin
    a = meta(a);b=meta(b)
    ca = collect_elements(a)
    cb = collect_elements(b)
    
    table = map(Iterators.product(ca,cb)) do cacb
        va = cacb[1][2]
        vb = cacb[2][2]
        ea = cacb[1][1]
        eb = cacb[2][1]

        res = ea*eb
        res = grade(ea) + grade(eb) == grade(res[1]) ? res : (res[1],0)
        (res,(va,vb))
    end
    grade_table = [ [[] for i=1:length(Blade{SIG,grade})] for grade = 0:length(SIG)]
    foreach(table) do tt
        typ = tt[1][1]
        sgn = tt[1][2]
        res = (tt[2]...,sgn)
        iszero(sgn) && return
        push!(grade_table[grade(typ)+1][index(typ)],res)
    end
    grade_table
end

dot_table(a::Type{<:Algebra{SIG}}, b::Type{<:Algebra{SIG}}) where SIG = begin
    a = meta(a);b=meta(b)
    ca = collect_elements(a)
    cb = collect_elements(b)
    
    table = map(Iterators.product(ca,cb)) do cacb
        va = cacb[1][2]
        vb = cacb[2][2]
        ea = cacb[1][1]
        eb = cacb[2][1]

        res = ea*eb
        res = grade(ea) + grade(eb) == grade(res[1]) ? (res[1],0) : res
        (res,(va,vb))
    end
    grade_table = [ [[] for i=1:length(Blade{SIG,grade})] for grade = 0:length(SIG)]
    foreach(table) do tt
        typ = tt[1][1]
        sgn = tt[1][2]
        res = (tt[2]...,sgn)
        iszero(sgn) && return
        push!(grade_table[grade(typ)+1][index(typ)],res)
    end
    grade_table
end


@generated wedge(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    T = promote_type(internal_type(a),internal_type(b))
    grade_table = wedge_table(a,b)

    sizes = [!all(isempty.(grade_table[i])) for i=1:length(SIG)+1]
    sum(sizes) == 0 && return 0
    ret = if sum(sizes) > 1
        "MultiBlade{$SIG,$(internal_size(MultiBlade{SIG})),$T}(($(unroll(grade_table))),)"
    else
        blade = grade_table[findfirst(sizes)]
        
        all(isempty.(blade)) && return 0
        sizes = (!isempty).(blade)
        ret = if sum(sizes) == 1 
            "E{$SIG,$(grade(a) + grade(b)),$(findfirst(sizes)),$T}(($(unroll(blade[findfirst(sizes)]))))"
        else
            N = length(Blade{SIG,grade(a) + grade(b)})
            "Blade{$SIG,$(grade(a) + grade(b)),$N,$T}(($(unroll(blade))))"
        end
    end
    quote 
        Base.@_inline_meta
        $(Base.Meta.parse(ret))
    end
end

@generated dot(a::Algebra{SIG},b::Algebra{SIG}) where SIG = begin
    T = promote_type(internal_type(a),internal_type(b))
    grade_table = dot_table(a,b)

    sizes = [!all(isempty.(grade_table[i])) for i=1:length(SIG)+1]
    sum(sizes) == 0 && return 0
    ret = if sum(sizes) > 1
        "MultiBlade{$SIG,$(internal_size(MultiBlade{SIG})),$T}(($(unroll(grade_table))),)"
    else
        grade = findfirst(sizes) - 1
        blade = grade_table[grade + 1]
        
        all(isempty.(blade)) && return 0
        sizes = (!isempty).(blade)
        ret = if sum(sizes) == 1 
            "E{$SIG,$(grade),$(findfirst(sizes)),$T}(($(unroll(blade[findfirst(sizes)]))))"
        else
            N = length(Blade{SIG,grade})
            "Blade{$SIG,$(grade),$N,$T}(($(unroll(blade))))"
        end
    end
    quote 
        Base.@_inline_meta
        $(Base.Meta.parse(ret))
    end
end


Base.:~(e::E) = (grade(e) % 2 == 0) ? -e : e
Base.:~(e::Blade) = (grade(e) % 2 == 0) ? -e : e
Base.:~(e::MultiBlade) = begin
    typeof(e)(map(collect(e)) do e
        (~e).v
    end |> Iterators.flatten |> collect )
end


unroll(c::Array{Array{Any,1},1}) = begin
    terms = map(c) do t
        isempty(t) ? "0" : unroll(t)
    end
    foldl(terms) do l,r
        "$l , $r"
    end
end

unroll(c::Array{Any,1}) = begin
    terms = map(c) do t
        "$(t[3])*a.v[$(t[1])] * b.v[$(t[2])]"
    end
    ret = foldl(terms) do l,r
        "$l + $r"
    end
end

unroll(c::Array{Array{Array{Any,1},1},1}) = unroll(collect(Iterators.flatten(c)))

