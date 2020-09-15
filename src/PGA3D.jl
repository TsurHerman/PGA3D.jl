module PGA3D
import StaticArrays

# a hack and slash reinterpret tuple , which unfortunately requires StaticArrays to be imported
@generated reinterpret_tuple(T,x::NTuple) = quote 
    Base.@_inline_meta
    x =length(x) == 1 ? (x,) : x
    first(reinterpret(T,StaticArrays.SArray{Tuple{1},$x,1,1}(x)))
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
