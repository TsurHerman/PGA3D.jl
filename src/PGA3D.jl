module PGA3D

# a BitCasting for tuples hopefuly compiler friendly
struct BitCast{S,T} <: AbstractVector{T}
    v::T
    BitCast{S}(v::T) where {S,T} = begin
        a = new{S,T}(v)
        reinterpret(S,a)[1]
    end
end
Base.@pure Base.size(::BitCast) = (1,)
@inline Base.getindex(@nospecialize a::BitCast) = a.v
@inline Base.getindex((@nospecialize a::BitCast),x) = a.v


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
