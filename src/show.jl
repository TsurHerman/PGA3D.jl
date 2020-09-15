
@generated to_symbol(::E{SIG,GRADE,IDX}) where {SIG,GRADE,IDX} = begin
    indices = to_index_tuple(SIG,GRADE,IDX)
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
    compact = get(io, :compact, false)
    sig = compact ? "" : "$(to_symbol(SIG)),"
    write(io,"Blade{$sig$(GRADE)} ")

    blade = as_tuple(b)
    blade = isone(length(blade)) ? blade[1] : blade
    show(io,blade)
end
Base.show(io::IO,mime::MIME"text/plain", b::Blade{SIG,GRADE}) where {SIG,GRADE} = begin
    compact = get(io, :compact, false)
    sig = compact ? "" : "$(to_symbol(SIG)),"
    write(io,"Blade{$sig$(GRADE)} ")

    blade = as_tuple(b)
    blade = isone(length(blade)) ? blade[1] : blade
    show(io,mime,blade)
end





Base.show(io::IO, mb::MultiBlade{SIG}) where {SIG} = begin
    write(io,"MultiBlade{$(to_symbol(SIG))} \n")
    for i=1:length(SIG) + 1
        b = mb[i-1]
        if iszero(grade(b)) || !iszero(b)
            write(io,"\n")
            show(IOContext(io, :compact => true),mime,b)
        end
    end
end

Base.show(io::IO,mime::MIME"text/plain", mb::MultiBlade{SIG}) where {SIG} = begin
    write(io,"MultiBlade{$(to_symbol(SIG))} \n")
    for i=1:length(SIG) + 1
        b = mb[i-1]
        if iszero(grade(b)) || !iszero(b)
            write(io,"\n")
            show(IOContext(io, :compact => true),mime,b)
        end
    end
end