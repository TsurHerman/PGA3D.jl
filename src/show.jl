
@generated to_symbol(::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    indices = to_tuple_index(SIG,GRADE,IDX)
    return foldl(*,Char.( 8320 .+ indices);init ="v")
end

export to_symbol
@generated to_symbol(SIG::NTuple{N,Int} where N) = begin
    map(x->iszero(x) ? "0" : x>0 ? "+" : "-",(1,1,1,0)) |> prod
end

Base.show(io::IO, e::E)  = begin
    Base.show(IOContext(io, :compact => true),e.v)
    write(io,to_symbol(e))
end
Base.show(io::IO,mime::MIME"text/plain", e::E)  = begin
    Base.show(IOContext(io, :compact => true),mime,e.v)
    write(io,to_symbol(e))
end


Base.show(io::IO, b::Blade{SIG,GRADE}) where {SIG,GRADE} = begin
    write(io,"Blade{$(to_symbol(SIG)),$(GRADE)} ")
    show(b.v)
end
Base.show(io::IO,mime::MIME"text/plain", b::Blade{SIG,GRADE}) where {SIG,GRADE} = begin
    write(io,"Blade{$(to_symbol(SIG)),$(GRADE)} ")
    show(b.v)
end

