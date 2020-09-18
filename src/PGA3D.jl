module PGA3D

# a BitCasting for tuples hopefuly compiler friendly
struct BitCast{S,T} <: AbstractVector{T}
    v::T
end
Base.@pure Base.size(::BitCast) = (1,)
Base.getindex(a::BitCast) = a.v
Base.getindex(a::BitCast,x) = a.v

@generated bitcast(::Type{S},v) where S = quote 
    reinterpret(S,BitCast{$S,$v}(v))[1]
end


include("util.jl")
include("types.jl")
include("arithmetic.jl")
include("show.jl")

# include("products.jl")



# export wedge
# const ∧ = wedge
# export ∧

greet() = print("Hello World!")

end # module
