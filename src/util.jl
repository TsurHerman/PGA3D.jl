using Combinatorics

to_tuple_index(SIG,GRADE,IDX) = begin
    collect(combinations(ntuple(i->i,length(SIG)),GRADE))[IDX] |> Tuple
end

pop_out(T::Tuple,i) = begin
    (i<=0 || i> length(T)) && return T
    (i==1) && ( (length(T) == 1) ? (return ()) : return T[2:end]) |> Tuple
    (i == length(T)) && return T[1:end-1] |> Tuple;
    (T[1:i-1]...,T[i+1:end]...) |> Tuple
end

insert_before(T::Tuple,i,n1) = begin 
    (i==1) && return (n1,T...) |> Tuple
    (T[1:i-1]...,n1,T[i:end]...) |> Tuple
end

common_type(sig::NTuple{N,Int} where N,n1::Int,N2::NTuple{N,Int} where N) = begin 
    iszero(length(N2)) && return ((n1,),1)
    cs = 1
    for i=1:length(N2)
        if n1 == N2[i]
            cs *= sig[n1]
            return (pop_out(N2,i),cs)
        elseif n1 < N2[i]
            return insert_before(N2,i,n1),cs
        end
        cs *= -1
    end
    return (N2...,n1),cs
end

common_type(sig::NTuple{N,Int} where N,N1::Tuple,N2::NTuple{N,Int} where N) = begin
    (length(N1) == 0) && (return (N2,1))
    ct,cs = common_type(sig,N1[end],N2)
    for i=length(N1)-1:-1:1
        ct,cs1 = common_type(sig,N1[i],ct)
        cs *= cs1
    end
    ct,cs
end

make_type(SIG,ct::Tuple) = begin
    grade = length(ct)
    idx = findfirst(isequal([ct...]),collect(combinations(ntuple(i->i,length(SIG)),grade)))
    return E{SIG,grade,idx}
end
