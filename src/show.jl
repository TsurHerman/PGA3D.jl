
to_symbol(::Meta{E{SIG,GRADE,IDX}}) where {SIG,GRADE,IDX} = begin
    indices = to_index_tuple(SIG,GRADE,IDX)
    indices = indices .- (1 - gylph_start_index[])
    return foldl(*,Char.( 8320 .+ indices);init = gylph[])
end

export to_symbol
to_symbol(SIG::NTuple{N,Int} where N) = begin
    map(x->iszero(x) ? "0" : x>0 ? "+" : "-",SIG )|> prod
end

const gylph = Ref("v")
const gylph_start_index = Ref(1)
element_gylph(s::String,start_index::Int) = begin
    gylph[] = s
    gylph_start_index[] = start_index
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
            show(IOContext(io, :compact => true),b)
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